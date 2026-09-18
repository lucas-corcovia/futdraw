// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/components/widgets/filters.player.list.dart';
import 'package:futdraw/components/widgets/group_actions_header.dart';
import 'package:futdraw/components/widgets/player.list.dart';
import 'package:futdraw/components/widgets/player_row.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/theme/app_theme.dart';
import 'package:futdraw/theme/app_tokens.dart';
import 'package:futdraw/views/matches_view.dart';
import 'package:futdraw/views/members_view.dart';
import 'package:futdraw/views/ranking_view.dart';
import 'package:futdraw/views/team_generator_view.dart';
import 'package:provider/provider.dart';

/// O elenco do grupo, em duas abas.
///
/// A AppBar carregava cinco acoes sem rotulo e o nome do grupo truncava no meio
/// ("Teste gr..."). Agora o nome ocupa a area expandida da barra grande, e as
/// tres acoes que levam a outra tela -- sortear, partidas, ranking -- viraram
/// botoes com nome no topo da lista, onde rolam junto com o conteudo em vez de
/// disputar a barra.
class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key, required this.group});
  final Group group;

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  /// Um controlador de busca para as duas abas. Cada aba renderiza o seu painel
  /// de filtros, mas os dois escrevem no mesmo texto.
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshPlayers();
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PlayerController>(
        builder: (context, controller, _) {
          final titulares = controller.filteredPlayers
              .where((p) => !p.reserva)
              .toList();
          final reservas = controller.filteredPlayers
              .where((p) => p.reserva)
              .toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  pinned: true,
                  forceElevated: innerBoxIsScrolled,
                  toolbarHeight: _toolbarHeight(context),
                  title: Text(
                    widget.group.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: _showFilters ? 'Fechar busca' : 'Buscar e filtrar',
                      isSelected: _showFilters,
                      onPressed: () {
                        setState(() => _showFilters = !_showFilters);
                      },
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Mais opções do grupo',
                      onSelected: (value) {
                        if (value == 'membros') {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => MembrosView(group: widget.group),
                            ),
                          );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'membros',
                          child: ListTile(
                            leading: Icon(Icons.manage_accounts_outlined),
                            title: Text('Membros'),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Titulares (${titulares.length})'),
                      Tab(text: 'Reservas (${reservas.length})'),
                    ],
                  ),
                ),
              ),
            ],
            body: _isLoading
                ? Builder(
                    builder: (context) => CustomScrollView(
                      slivers: [
                        SliverOverlapInjector(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                context,
                              ),
                        ),
                        const SliverToBoxAdapter(child: PlayerListSkeleton()),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      TitularesList(
                        group: widget.group,
                        players: titulares,
                        header: _header(0, titulares.length, reservas.length),
                        onRefresh: (_) => _refreshPlayers(),
                        onAdd: _addPlayer,
                        onEdit: _editPlayer,
                        onDelete: _deletePlayer,
                        onSwap: (player) => _startSwap(player, reservas),
                      ),
                      ReservasList(
                        group: widget.group,
                        players: reservas,
                        header: _header(1, titulares.length, reservas.length),
                        onRefresh: (_) => _refreshPlayers(),
                        onAdd: _addPlayer,
                        onEdit: _editPlayer,
                        onDelete: _deletePlayer,
                      ),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
        tooltip: 'Adicionar jogador',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Altura da barra: o bastante para um nome de grupo em duas linhas.
  ///
  /// A barra grande (`SliverAppBar.large`) abria um vao morto entre o botao de
  /// voltar e o nome. O nome volta para a barra, ao lado do voltar, e a barra
  /// cresce so o necessario -- incluindo quando o sistema aumenta o texto.
  double _toolbarHeight(BuildContext context) {
    // titleLarge: 18 px com height 1.25.
    final lineHeight = MediaQuery.textScalerOf(context).scale(18) * 1.25;
    return (lineHeight * 2 + AppSpacing.lg).clamp(kToolbarHeight, 160);
  }

  Widget _header(int tabIndex, int titulares, int reservas) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: AppMotion.at(context, AppMotion.base),
          curve: AppMotion.moving,
          alignment: Alignment.topCenter,
          child: _showFilters
              ? FiltersPlayerList(
                  tabIndex: tabIndex,
                  searchController: _searchController,
                )
              : const SizedBox(width: double.infinity),
        ),
        GroupActionsHeader(
          titulares: titulares,
          reservas: reservas,
          onSortear: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  TeamGenerationScreen(preselectedGroup: widget.group),
            ),
          ),
          onPartidas: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => MatchesView(group: widget.group),
            ),
          ),
          onRanking: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => RankingView(group: widget.group),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshPlayers() async {
    await context.read<PlayerController>().getAllByGroupId(
      context,
      widget.group.id,
    );
  }

  Future<void> _addPlayer() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AddPlayer(group: widget.group),
      ),
    );
    await _refreshPlayers();
  }

  /// Navega e so depois recarrega.
  ///
  /// A ordem estava invertida: recarregava antes de abrir a edicao, o que
  /// gastava uma chamada de API e ainda deixava a lista velha ao voltar.
  Future<void> _editPlayer(Player player) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AddPlayer(player: player, group: widget.group),
      ),
    );
    await _refreshPlayers();
  }

  Future<void> _deletePlayer(Player player) async {
    await context.read<PlayerController>().delete(context, player);
    await _refreshPlayers();
  }

  Future<void> _startSwap(Player titular, List<Player> reservas) async {
    // Goleiro so troca com goleiro: um lateral no gol e um time sem goleiro.
    final elegiveis = titular.isGoalkeeper
        ? reservas.where((r) => r.position == titular.position).toList()
        : reservas;

    await _showSwapScreen(context, titular, elegiveis);
    await _refreshPlayers();
  }

  Future<void> _showSwapScreen(
    BuildContext context,
    Player titular,
    List<Player> reservas,
  ) async {
    final escolhido = await Navigator.push<Player>(
      context,
      MaterialPageRoute<Player>(
        fullscreenDialog: true,
        builder: (context) => _SwapScreen(titular: titular, reservas: reservas),
      ),
    );

    if (escolhido == null || !mounted) return;

    final playerController = context.read<PlayerController>();
    await playerController.update(context, titular.copyWith(reserva: true));
    await playerController.update(context, escolhido.copyWith(reserva: false));
    await playerController.getAllByGroupId(context, widget.group.id);
    if (mounted) setState(() {});
  }
}

/// Escolha da reserva que entra no lugar do titular.
class _SwapScreen extends StatelessWidget {
  const _SwapScreen({required this.titular, required this.reservas});

  final Player titular;
  final List<Player> reservas;

  @override
  Widget build(BuildContext context) {
    final sorted = List<Player>.from(reservas)..sort(comparePlayersForRoster);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quem entra?'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.md,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Sai ${titular.nome}',
                style: context.texts.bodySmall?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: sorted.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  titular.isGoalkeeper
                      ? 'Nenhum goleiro no banco. Um goleiro só pode ser '
                            'substituído por outro goleiro.'
                      : 'Nenhum reserva disponível para substituição.',
                  textAlign: TextAlign.center,
                  style: context.texts.bodyMedium?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              itemCount: sorted.length,
              separatorBuilder: (context, _) => Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: context.scheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final reserva = sorted[index];
                return PlayerRow(
                  player: reserva,
                  onEdit: () {},
                  onDelete: () {},
                  onTap: () => _confirm(context, reserva),
                );
              },
            ),
    );
  }

  Future<void> _confirm(BuildContext context, Player reserva) async {
    final confirmado = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${reserva.nome} entra no lugar de ${titular.nome}?',
              style: Theme.of(sheetContext).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    child: const Text('Substituir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmado == true && context.mounted) {
      Navigator.of(context).pop(reserva);
    }
  }
}
