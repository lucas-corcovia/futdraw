import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/soccer_field.dart';
import 'package:futdraw/helpers/team_generator.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/utils/file.utils.dart';
import 'package:screenshot/screenshot.dart';

class TeamsDisplayScreen extends StatefulWidget {
  final List<Team> teams;

  const TeamsDisplayScreen({super.key, required this.teams});

  @override
  State<TeamsDisplayScreen> createState() => _TeamsDisplayScreenState();
}

class _TeamsDisplayScreenState extends State<TeamsDisplayScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Team> _teams;
  bool _showField = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _teams = List.from(widget.teams);
    _tabController = TabController(length: _teams.length, vsync: this);
  }

  void _swapPlayers(Player playerA, Player playerB) {
    setState(() {
      // Find the teams containing the players
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
        // Create copies of the player lists
        final List<Player> newTeamAPlayers = List.from(teamA.players);
        final List<Player> newTeamBPlayers = List.from(teamB.players);

        // Swap the players
        newTeamAPlayers[playerAIndex] = playerB;
        newTeamBPlayers[playerBIndex] = playerA;

        // Update the teams
        _teams[teamAIndex] = Team(name: teamA.name, players: newTeamAPlayers);
        _teams[teamBIndex] = Team(name: teamB.name, players: newTeamBPlayers);
      }
    });
  }

  void _substitutePlayer(Player player) {
    // In a real app, you'd show a form to select a substitute player
    // For this MVP, we'll just show a dialog saying it's substituted
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Jogador Substituto'),
            content: const Text(
              'Em uma versão completa, aqui você poderia selecionar um jogador substituto.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // Check if the player can be dragged (not a goalkeeper)
  bool _canDragPlayer(Player player) {
    return !player.isGoalkeeper;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Times Gerados'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          isScrollable: true,
          tabs: _teams.map((team) => Tab(text: team.name)).toList(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showField ? Icons.list : Icons.sports_soccer),
            tooltip: _showField ? 'Mostrar Lista' : 'Mostrar Campo',
            onPressed: () {
              setState(() {
                _showField = !_showField;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar Times',
            onPressed: _exportTeamsImage,
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: TabBarView(
          controller: _tabController,
          children:
              _teams.map((team) {
                return _showField
                    ? _buildFieldView(team)
                    : _buildTeamView(team);
              }).toList(),
        ),
      ),
    );
  }

  Future<void> _exportTeamsImage() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Set pixel ratio for higher quality
      final Uint8List? capturedImage = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0, // Higher resolution
      );

      // Dismiss loading dialog
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
        Navigator.of(context).pop(); // Dismiss loading dialog if still showing
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar imagem: $e')));
      }
    }
  }

  Future<void> _shareImageMobile(Uint8List bytes) async {
    try {
      final fileName = FileUtils.generateUniqueFileName('times', 'png');

      await FileUtils.shareFileMobile(
        bytes,
        fileName,
        'image/png',
        text: 'Times gerados pelo app Sorteio de Times',
        subject: 'Times Equilibrados',
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
      color: Colors.white,
      child: Column(
        children: [
          // Team header
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

          // Soccer field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SoccerField(
                players: team.players,
                onPlayersSwapped: _swapPlayers,
              ),
            ),
          ),

          // Instructions footer
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

  Widget _buildTeamView(Team team) {
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
          // Team Header
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
                            ).colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          'Jogadores: ${team.players.length}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withOpacity(0.8),
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

          // Team Lineup
          Text('Escalação', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Arraste os jogadores para alterar posições entre times',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),

          // Goalkeepers Section
          if (goalkeepers.isNotEmpty) ...[
            _buildPositionSection(
              'Goleiros',
              goalkeepers,
              Icons.sports_handball,
            ),
            const SizedBox(height: 16),
          ],

          // Defenders Section
          if (defenders.isNotEmpty) ...[
            _buildPositionSection('Defensores', defenders, Icons.shield),
            const SizedBox(height: 16),
          ],

          // Midfielders Section
          if (midfielders.isNotEmpty) ...[
            _buildPositionSection(
              'Meio-Campistas',
              midfielders,
              Icons.change_circle,
            ),
            const SizedBox(height: 16),
          ],

          // Forwards Section
          if (forwards.isNotEmpty) ...[
            _buildPositionSection('Atacantes', forwards, Icons.sports_soccer),
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
        ...players.map((player) => _buildPlayerCard(player)),
      ],
    );
  }

  Widget _buildPlayerCard(Player player) {
    final canDrag = _canDragPlayer(player);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child:
          canDrag
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
                      leading:
                          player.urlFoto != null
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
                  onWillAccept: (incomingPlayer) {
                    return incomingPlayer != null &&
                        incomingPlayer.id != player.id &&
                        _canDragPlayer(incomingPlayer);
                  },
                  onAccept: (incomingPlayer) {
                    _swapPlayers(player, incomingPlayer);
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
                onWillAccept: (incomingPlayer) {
                  return incomingPlayer != null &&
                      incomingPlayer.id != player.id &&
                      _canDragPlayer(incomingPlayer);
                },
                onAccept: (incomingPlayer) {
                  _swapPlayers(player, incomingPlayer);
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

  Widget _buildPlayerCardContent(Player player, {bool highlighted = false}) {
    final backgroundColor =
        highlighted
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface;

    final borderColor =
        highlighted
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withOpacity(0.3);

    return Card(
      elevation: highlighted ? 3 : 1,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: highlighted ? 2 : 1),
      ),
      child: ListTile(
        leading:
            player.urlFoto != null
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
            if (player.ehCapitao)
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
            IconButton(
              icon: const Icon(Icons.repeat),
              tooltip: 'Substituir Jogador',
              onPressed: () => _substitutePlayer(player),
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
}
