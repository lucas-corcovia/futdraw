import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/soccer_field.dart';
import 'package:futdraw/core/di/service_locator.dart';
import 'package:futdraw/data/models/requests/salvar_sorteio_request.dart';
import 'package:futdraw/helpers/team_generator.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/utils/file.utils.dart';
import 'package:screenshot/screenshot.dart';

class TeamsDisplayScreen extends StatefulWidget {
  final List<Team> teams;
  final String? grupoId;
  final String? instrucoes;
  final bool usouIA;

  const TeamsDisplayScreen({
    super.key,
    required this.teams,
    this.grupoId,
    this.instrucoes,
    this.usouIA = false,
  });

  @override
  State<TeamsDisplayScreen> createState() => _TeamsDisplayScreenState();
}

class _TeamsDisplayScreenState extends State<TeamsDisplayScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Team> _teams;
  bool _showField = true;
  bool _isSaving = false;
  bool _isSaved = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  // Cross-team swap mode
  bool _crossSwapMode = false;
  Player? _selectedCrossPlayer;
  int? _selectedCrossPlayerTeamIndex;

  @override
  void initState() {
    super.initState();
    _teams = List.from(widget.teams);
    _tabController = TabController(length: _teams.length, vsync: this);
  }

  Future<void> _saveTeams() async {
    final grupoId = widget.grupoId;
    if (grupoId == null || _isSaving || _isSaved) return;

    setState(() => _isSaving = true);

    final request = SalvarSorteioRequest(
      instrucoes: widget.instrucoes,
      usouIA: widget.usouIA,
      times: _teams.map((team) => TimeSalvarItem(
        nome: team.name,
        jogadores: team.players.map((p) => JogadorSalvarItem(
          jogadorId: p.id,
          nome: p.nome,
          nota: p.nota,
          posicao: p.position.index,
          ehCapitao: p.ehCapitao,
        )).toList(),
      )).toList(),
    );

    final result = await ServiceLocator().sorteioIADataSource.salvarSorteio(
      grupoId,
      request,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      success: (_) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Sorteio salvo com sucesso!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _swapPlayers(Player playerA, Player playerB) {
    setState(() {
      Team? teamA;
      Team? teamB;
      int teamAIndex = -1;
      int teamBIndex = -1;
      int playerAIndex = -1;
      int playerBIndex = -1;

      for (int i = 0; i < _teams.length; i++) {
        final playerAPos = _teams[i].players.indexWhere(
          (p) => p.id == playerA.id,
        );
        if (playerAPos != -1) {
          teamA = _teams[i];
          teamAIndex = i;
          playerAIndex = playerAPos;
        }

        final playerBPos = _teams[i].players.indexWhere(
          (p) => p.id == playerB.id,
        );
        if (playerBPos != -1) {
          teamB = _teams[i];
          teamBIndex = i;
          playerBIndex = playerBPos;
        }
      }

      if (teamA != null &&
          teamB != null &&
          playerAIndex != -1 &&
          playerBIndex != -1) {
        if (teamAIndex == teamBIndex) {
          final List<Player> newPlayers = List.from(teamA.players);
          final temp = newPlayers[playerAIndex];
          newPlayers[playerAIndex] = newPlayers[playerBIndex];
          newPlayers[playerBIndex] = temp;
          _teams[teamAIndex] = Team(name: teamA.name, players: newPlayers);
        } else {
          final List<Player> newTeamAPlayers = List.from(teamA.players);
          final List<Player> newTeamBPlayers = List.from(teamB.players);

          newTeamAPlayers[playerAIndex] = playerB;
          newTeamBPlayers[playerBIndex] = playerA;

          _teams[teamAIndex] = Team(name: teamA.name, players: newTeamAPlayers);
          _teams[teamBIndex] = Team(name: teamB.name, players: newTeamBPlayers);
        }
      }
    });
  }

  void _onCrossSwapTap(Player tapped, int tappedTeamIndex) {
    if (_selectedCrossPlayer == null) {
      setState(() {
        _selectedCrossPlayer = tapped;
        _selectedCrossPlayerTeamIndex = tappedTeamIndex;
      });
      return;
    }

    if (_selectedCrossPlayer!.id == tapped.id) {
      setState(() {
        _selectedCrossPlayer = null;
        _selectedCrossPlayerTeamIndex = null;
      });
      return;
    }

    if (_selectedCrossPlayerTeamIndex == tappedTeamIndex) {
      // Mesmo time — troca a seleção para o novo jogador
      setState(() {
        _selectedCrossPlayer = tapped;
      });
      return;
    }

    // Times diferentes — executa o swap
    _swapPlayers(_selectedCrossPlayer!, tapped);
    setState(() {
      _selectedCrossPlayer = null;
      _selectedCrossPlayerTeamIndex = null;
    });
  }

  bool _canDragPlayer(Player player) {
    return !player.isGoalkeeper;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Times Gerados'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelColor: Theme.of(context).colorScheme.outline,
          isScrollable: true,
          tabs: _teams.map((team) => Tab(text: team.name)).toList(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.swap_horiz,
              color: _crossSwapMode
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: _crossSwapMode
                ? 'Sair do modo de troca entre times'
                : 'Trocar jogadores entre times',
            onPressed: () {
              setState(() {
                _crossSwapMode = !_crossSwapMode;
                _selectedCrossPlayer = null;
                _selectedCrossPlayerTeamIndex = null;
              });
            },
          ),
          IconButton(
            icon: Icon(_showField ? Icons.list : Icons.sports_soccer),
            tooltip: _showField ? 'Mostrar Lista' : 'Mostrar Campo',
            onPressed: () {
              setState(() {
                _showField = !_showField;
                // Sair do modo cross-swap ao mudar para campo
                if (_showField) {
                  _crossSwapMode = false;
                  _selectedCrossPlayer = null;
                  _selectedCrossPlayerTeamIndex = null;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Reorganizar por Tática',
            onPressed: () {
              _reorganizeTeamByTactic(_tabController.index);
            },
          ),
          if (widget.grupoId != null && !_isSaved)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.bookmark_add_rounded),
                    tooltip: 'Salvar Sorteio',
                    onPressed: _saveTeams,
                  ),
          if (_isSaved)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.bookmark_rounded, size: 24),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar Times',
            onPressed: _exportTeamsImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: TabBarView(
                controller: _tabController,
                children: _teams.asMap().entries.map((entry) {
                  return _showField
                      ? _buildFieldView(entry.value)
                      : _buildTeamView(entry.value, entry.key);
                }).toList(),
              ),
            ),
          ),
          if (_crossSwapMode && !_showField) _buildCrossSwapBanner(),
        ],
      ),
    );
  }

  Widget _buildCrossSwapBanner() {
    final hasSelection = _selectedCrossPlayer != null;
    final teamName = hasSelection
        ? _teams[_selectedCrossPlayerTeamIndex!].name
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            hasSelection ? Icons.person_pin : Icons.touch_app,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasSelection
                  ? '${_selectedCrossPlayer!.nome} ($teamName) — toque em outro jogador para trocar'
                  : 'Toque em um jogador para selecionar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight:
                    hasSelection ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (hasSelection)
            IconButton(
              icon: const Icon(Icons.close),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              onPressed: () => setState(() {
                _selectedCrossPlayer = null;
                _selectedCrossPlayerTeamIndex = null;
              }),
            ),
        ],
      ),
    );
  }

  Future<void> _exportTeamsImage() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final Uint8List? capturedImage = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0,
      );

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (capturedImage == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao capturar imagem')),
          );
        }
        return;
      }

      await _shareImageMobile(capturedImage);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar imagem: $e')));
      }
    }
  }

  Future<void> _shareImageMobile(Uint8List bytes) async {
    try {
      final teamName = _teams[_tabController.index].name;
      final fileName = FileUtils.generateUniqueFileName(teamName, 'png');

      await FileUtils.shareFileMobile(
        bytes,
        fileName,
        'image/png',
        text: teamName,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao compartilhar: $e')));
      }
    }
  }

  Widget _buildFieldView(Team team) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  team.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Média: ${team.averageSkill.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SoccerField(
                players: team.players,
                onPlayersSwapped: _swapPlayers,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Arraste jogadores da mesma posição para trocar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamView(Team team, int teamIndex) {
    final goalkeepers =
        team.players
            .where((p) => p.position == PlayerPosition.goalkeeper)
            .toList();
    final defenders =
        team.players
            .where((p) => p.position == PlayerPosition.defender)
            .toList();
    final midfielders =
        team.players
            .where((p) => p.position == PlayerPosition.midfielder)
            .toList();
    final forwards =
        team.players
            .where((p) => p.position == PlayerPosition.striker)
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Text(
                          team.name,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Média de Habilidade: ${team.averageSkill.toStringAsFixed(1)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          'Jogadores: ${team.players.length}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Escalação', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            _crossSwapMode
                ? 'Toque em um jogador para selecioná-lo e trocar entre times'
                : 'Arraste os jogadores para alterar posições entre times',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),

          if (goalkeepers.isNotEmpty) ...[
            _buildPositionSection(
              'Goleiros',
              goalkeepers,
              Icons.sports_handball,
              teamIndex,
            ),
            const SizedBox(height: 16),
          ],

          if (defenders.isNotEmpty) ...[
            _buildPositionSection(
                'Defensores', defenders, Icons.shield, teamIndex),
            const SizedBox(height: 16),
          ],

          if (midfielders.isNotEmpty) ...[
            _buildPositionSection(
              'Meio-Campistas',
              midfielders,
              Icons.change_circle,
              teamIndex,
            ),
            const SizedBox(height: 16),
          ],

          if (forwards.isNotEmpty) ...[
            _buildPositionSection(
                'Atacantes', forwards, Icons.sports_soccer, teamIndex),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildPositionSection(
    String title,
    List<Player> players,
    IconData icon,
    int teamIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...players.map((player) => _buildPlayerCard(player, teamIndex)),
      ],
    );
  }

  Widget _buildPlayerCard(Player player, int teamIndex) {
    // Modo cross-swap: interação via tap simples em todos os jogadores
    if (_crossSwapMode) {
      final isSelected = _selectedCrossPlayer?.id == player.id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GestureDetector(
          onTap: () => _onCrossSwapTap(player, teamIndex),
          child: _buildPlayerCardContent(
            player,
            crossSelected: isSelected,
          ),
        ),
      );
    }

    // Modo normal: drag-and-drop dentro do mesmo time
    final canDrag = _canDragPlayer(player);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: canDrag
          ? LongPressDraggable<Player>(
              data: player,
              feedback: Material(
                elevation: 4,
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: player.urlFoto != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(player.urlFoto!),
                          )
                        : CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSecondary,
                            child: Text(player.nome[0].toUpperCase()),
                          ),
                    title: Text(player.nome),
                    subtitle: Text(
                      '${player.position} • ${player.nota.toStringAsFixed(1)}',
                    ),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildPlayerCardContent(player),
              ),
              child: DragTarget<Player>(
                onWillAcceptWithDetails: (details) =>
                    details.data.id != player.id,
                onAcceptWithDetails: (details) {
                  _swapPlayers(player, details.data);
                },
                builder: (context, candidateData, rejectedData) {
                  return _buildPlayerCardContent(
                    player,
                    highlighted: candidateData.isNotEmpty,
                  );
                },
              ),
            )
          : DragTarget<Player>(
              onWillAcceptWithDetails: (details) =>
                  details.data.id != player.id,
              onAcceptWithDetails: (details) {
                _swapPlayers(player, details.data);
              },
              builder: (context, candidateData, rejectedData) {
                return _buildPlayerCardContent(
                  player,
                  highlighted: candidateData.isNotEmpty,
                );
              },
            ),
    );
  }

  Widget _buildPlayerCardContent(
    Player player, {
    bool highlighted = false,
    bool crossSelected = false,
  }) {
    final Color backgroundColor;
    final Color borderColor;
    final double borderWidth;

    if (crossSelected) {
      backgroundColor =
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4);
      borderColor = Theme.of(context).colorScheme.primary;
      borderWidth = 2.5;
    } else if (highlighted) {
      backgroundColor =
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
      borderColor = Theme.of(context).colorScheme.primary;
      borderWidth = 2;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surface;
      borderColor =
          Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
      borderWidth = 1;
    }

    return Card(
      elevation: (highlighted || crossSelected) ? 3 : 1,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: ListTile(
        leading: player.urlFoto != null
            ? Hero(
                tag: 'player_avatar_${player.id}',
                child: CircleAvatar(
                  backgroundImage: NetworkImage(player.urlFoto!),
                ),
              )
            : CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                child: Text(player.nome[0].toUpperCase()),
              ),
        title: Text(
          player.nome,
          style: TextStyle(
            fontWeight: player.ehCapitao ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${_getPositionName(player.position)} • Nota: ${player.nota.toStringAsFixed(1)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (crossSelected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'TROCAR',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (player.ehCapitao)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tooltip(
                  message: 'Capitão',
                  child: Icon(
                    Icons.stars,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPositionName(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return 'Goleiro';
      case PlayerPosition.defender:
        return 'Defensor';
      case PlayerPosition.midfielder:
        return 'Meio-Campo';
      case PlayerPosition.striker:
        return 'Atacante';
    }
  }

  void _reorganizeTeamByTactic(int teamIndex) {
    final team = _teams[teamIndex];
    final goalkeepers =
        team.players
            .where((p) => p.position == PlayerPosition.goalkeeper)
            .toList();
    final defenders =
        team.players
            .where((p) => p.position == PlayerPosition.defender)
            .toList();
    final midfielders =
        team.players
            .where((p) => p.position == PlayerPosition.midfielder)
            .toList();
    final forwards =
        team.players
            .where((p) => p.position == PlayerPosition.striker)
            .toList();

    int defendersCount = 2;
    int midfieldersCount = 3;
    int forwardsCount = 1;
    int totalField =
        team.players
            .where((p) => p.position != PlayerPosition.goalkeeper)
            .length;

    if (totalField == 6) {
      defendersCount = 2;
      midfieldersCount = 3;
      forwardsCount = 1;
    } else if (totalField == 5) {
      defendersCount = 2;
      midfieldersCount = 2;
      forwardsCount = 1;
    } else if (totalField == 4) {
      defendersCount = 1;
      midfieldersCount = 2;
      forwardsCount = 1;
    }

    List<Player> allDefenders = List.from(defenders)
      ..sort((a, b) => b.nota.compareTo(a.nota));
    List<Player> allMidfielders = List.from(midfielders)
      ..sort((a, b) => b.nota.compareTo(a.nota));
    List<Player> allForwards = List.from(forwards)
      ..sort((a, b) => b.nota.compareTo(a.nota));

    while (allMidfielders.length < midfieldersCount &&
        allDefenders.length > defendersCount) {
      final moved = allDefenders.removeLast();
      moved.position = PlayerPosition.midfielder;
      allMidfielders.add(moved);
    }

    while (allDefenders.length < defendersCount && allMidfielders.isNotEmpty) {
      final moved = allMidfielders.removeAt(0);
      moved.position = PlayerPosition.defender;
      allDefenders.add(moved);
    }

    while (allMidfielders.length < midfieldersCount && allForwards.isNotEmpty) {
      final moved = allForwards.removeAt(0);
      moved.position = PlayerPosition.midfielder;
      allMidfielders.add(moved);
    }

    while (allForwards.length < forwardsCount &&
        allMidfielders.length > midfieldersCount) {
      final moved = allMidfielders.removeLast();
      moved.position = PlayerPosition.striker;
      allForwards.add(moved);
    }

    while (allForwards.length < forwardsCount && allMidfielders.isNotEmpty) {
      final moved = allMidfielders.removeLast();
      moved.position = PlayerPosition.striker;
      allForwards.add(moved);
    }

    allDefenders = allDefenders.take(defendersCount).toList();
    allMidfielders = allMidfielders.take(midfieldersCount).toList();
    allForwards = allForwards.take(forwardsCount).toList();

    final newPlayers = [
      ...goalkeepers,
      ...allDefenders,
      ...allMidfielders,
      ...allForwards,
    ];

    setState(() {
      _teams[teamIndex] = Team(name: team.name, players: newPlayers);
    });
  }
}
