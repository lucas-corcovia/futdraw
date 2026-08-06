import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/components/widgets/filters.player.list.dart';
import 'package:futdraw/components/widgets/player.card.dart';
import 'package:futdraw/components/widgets/player.list.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/views/team_generator_view.dart';
import 'package:provider/provider.dart';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key, required this.group});
  final Group group;

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late final TabController _tabController;

  bool _isLoading = true;
  bool _showFilters = false;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PlayerController>().getAllByGroupId(
        context,
        widget.group.id,
      );
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.nome),
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_sharp),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.sports_soccer),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          TeamGenerationScreen(preselectedGroup: widget.group),
                ),
              );
            },
            tooltip: 'Gerar Times',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          isScrollable: false,
          tabs: const [Tab(text: 'Titulares'), Tab(text: 'Reservas')],
        ),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return FadeTransition(opacity: _animation, child: child);
        },
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<PlayerController>(
                  builder: (context, controller, _) {
                    final titulares =
                        controller.filteredPlayers
                            .where((p) => !p.reserva)
                            .toList();
                    final reservas =
                        controller.filteredPlayers
                            .where((p) => p.reserva)
                            .toList();
                    return Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (child, animation) => SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1.0,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                          child:
                              _showFilters
                                  ? FiltersPlayerList(
                                    tabIndex: _currentTabIndex,
                                  )
                                  : const SizedBox.shrink(
                                    key: ValueKey('empty'),
                                  ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              TitularesList(
                                group: widget.group,
                                players: titulares,
                                onRefresh: (ctx) => _refreshPlayers(),
                                onEdit: (player) async {
                                  await _refreshPlayers();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddPlayer(
                                            player: player,
                                            group: widget.group,
                                          ),
                                    ),
                                  );
                                },
                                onDelete: (player) async {
                                  await context.read<PlayerController>().delete(
                                    context,
                                    player,
                                  );
                                  await _refreshPlayers();
                                },
                                onSwap: (player) async {
                                  final reservasDisponiveis =
                                      reservas
                                          .where(
                                            (r) =>
                                                player.isGoalkeeper
                                                    ? player.position ==
                                                        r.position
                                                    : true,
                                          )
                                          .toList();
                                  await _showSwapScreen(
                                    context,
                                    player,
                                    reservasDisponiveis,
                                  );
                                  await _refreshPlayers();
                                },
                              ),
                              ReservasList(
                                group: widget.group,
                                players: reservas,
                                onRefresh: (ctx) => _refreshPlayers(),
                                onEdit: (player) async {
                                  await _refreshPlayers();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddPlayer(
                                            player: player,
                                            group: widget.group,
                                          ),
                                    ),
                                  );
                                },
                                onDelete: (player) async {
                                  await context.read<PlayerController>().delete(
                                    context,
                                    player,
                                  );
                                  await _refreshPlayers();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPlayer(group: widget.group),
                ),
              ).then((_) => _refreshPlayers());
            },
            tooltip: 'Adicionar Jogador',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshPlayers() async {
    await context.read<PlayerController>().getAllByGroupId(
      context,
      widget.group.id,
    );
  }

  Future<void> _showSwapScreen(
    BuildContext context,
    Player titular,
    List<Player> reservas,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Substituir Jogador')),
            body:
                reservas.isEmpty
                    ? const Center(
                      child: Text(
                        'Nenhum reserva disponível para substituição.',
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: reservas.length,
                      itemBuilder: (context, index) {
                        final res = reservas[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GestureDetector(
                            onTap: () async {
                              final confirm = await showModalBottomSheet<bool>(
                                context: context,
                                builder:
                                    (ctx) => Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Substituir titular por ${res.nome}?',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(false),
                                                  child: const Text('Cancelar'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: FilledButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(true),
                                                  child: const Text('Substituir'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                              );
                              if (confirm == true) {
                                Navigator.of(context).pop(res);
                              }
                            },
                            child: PlayerCard(
                              player: res,
                              isSelected: false,
                              onEdit: () {},
                              onDelete: () {},
                              onSwap: null,
                            ),
                          ),
                        );
                      },
                    ),
          );
        },
      ),
    ).then((reservaSelecionada) async {
      if (reservaSelecionada != null && reservaSelecionada is Player) {
        final playerController = context.read<PlayerController>();
        final titularAtualizado = titular.copyWith(reserva: true);
        final reservaAtualizado = reservaSelecionada.copyWith(reserva: false);
        await playerController.update(context, titularAtualizado);
        await playerController.update(context, reservaAtualizado);
        await playerController.getAllByGroupId(context, widget.group.id);
        setState(() {});
      }
    });
  }
}
