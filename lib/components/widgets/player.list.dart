import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/components/widgets/add.player.dart';
import 'package:futdraw/components/widgets/player.card.dart';
import 'package:futdraw/components/widgets/players.list.empty.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/group.dart';
import 'package:provider/provider.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({super.key, required this.group});
  final Group group;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, controller, child) {
        if (controller.filteredPlayers.isEmpty) {
          return Center(child: ListPlayersEmpty());
        }

        var playersFiltered = controller.filteredPlayers;

        playersFiltered.sort((p1, p2) {
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
            itemCount: playersFiltered.length,
            itemBuilder: (context, index) {
              final player = playersFiltered[index];
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
