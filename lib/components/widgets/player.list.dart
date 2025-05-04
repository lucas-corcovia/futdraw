import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/components/widgets/player.card.dart';
import 'package:futdraw/components/widgets/players.list.empty.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/group.dart';
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
            icon: const Icon(Icons.sports_soccer),
            onPressed: () {},
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
                : PlayerList(group: widget.group),
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }

  Future<void> _refreshPlayers() async {}
}

class PlayerList extends StatelessWidget {
  const PlayerList({super.key, required this.group});
  final Group group;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, controller, child) {
        if (controller.players.isEmpty) {
          return Center(child: ListPlayersEmpty());
        }

        controller.players.sort((p1, p2) {
          if (p1.position == PlayerPosition.goalkeeper &&
              p2.position == PlayerPosition.goalkeeper) {
            return 0; // p1 vem antes de p2
          }
          if (p1.position == PlayerPosition.goalkeeper) {
            return -1; // p1 vem antes de p2
          }

          return 1; // p1 vem depois de p2
        });

        return RefreshIndicator(
          onRefresh: () => _refreshPlayers(context),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: controller.players.length,
            itemBuilder: (context, index) {
              final player = controller.players[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: PlayerCard(
                  player: player,
                  onEdit: () {
                    _refreshPlayers(context).then((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AddPlayer(player: player, group: group),
                        ),
                      );
                    });
                  },
                  onDelete: () async {
                    context
                        .read<PlayerController>()
                        .delete(context, player)
                        .then((_) {
                          Toast.show(
                            context,
                            'Jogador excluído com sucesso!',
                            false,
                          );
                        });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _refreshPlayers(BuildContext context) async {
    context.read<PlayerController>().getAllByGroupId(context, group.id);
  }
}
