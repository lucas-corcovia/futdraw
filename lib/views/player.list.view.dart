import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/components/widgets/filters.player.list.dart';
import 'package:futdraw/components/widgets/player.list.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/views/team_generator_view.dart';
import 'package:provider/provider.dart';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key, required this.group});
  final Group group;

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isLoading = true;
  bool _showFilters = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<PlayerController>()
          .getAllByGroupId(context, widget.group.id)
          .then((_) {
            setState(() {
              _isLoading = false;
            });
          });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.nome),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<GroupController>().getAll().then((_) {
              Navigator.pop(context);
            });
          },
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
                      (context) => TeamGenerationScreen(
                        // Obter Pelo Provider
                        preselectedGroup: widget.group,
                      ),
                ),
              );
            },
            tooltip: 'Gerar Times',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return FadeTransition(opacity: _animation, child: child);
        },
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
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
                                key: const ValueKey('filters'),
                              )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                    Expanded(child: PlayerList(group: widget.group)),
                  ],
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
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
}
