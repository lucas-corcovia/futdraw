import 'package:flutter/material.dart';
import 'package:futdraw/components/widgets/player.card.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/group.dart';
import 'package:futdraw/models/player.dart';

abstract class PlayerList extends StatelessWidget {
  final Group group;
  final List<Player> players;
  final Future<void> Function(BuildContext) onRefresh;
  final void Function(Player) onEdit;
  final void Function(Player) onDelete;
  final void Function(Player)? onSwap;
  const PlayerList({
    super.key,
    required this.group,
    required this.players,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
    this.onSwap,
  });

  String get emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    final sortedPlayers = List<Player>.from(players);
    sortedPlayers.sort((p1, p2) {
      if (p1.position == PlayerPosition.goalkeeper &&
          p2.position == PlayerPosition.goalkeeper) {
        return 0;
      }
      if (p1.position == PlayerPosition.goalkeeper) {
        return -1;
      }
      return 1;
    });
    return RefreshIndicator(
      onRefresh: () => onRefresh(context),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: sortedPlayers.length,
        itemBuilder: (context, index) {
          final player = sortedPlayers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PlayerCard(
              player: player,
              onEdit: () => onEdit(player),
              onDelete: () => onDelete(player),
              onSwap: onSwap,
            ),
          );
        },
      ),
    );
  }
}

class ReservasList extends PlayerList {
  const ReservasList({
    super.key,
    required super.group,
    required super.players,
    required super.onRefresh,
    required super.onEdit,
    required super.onDelete,
    super.onSwap,
  });

  @override
  String get emptyMessage => 'Nenhum reserva encontrado.';
}

class TitularesList extends PlayerList {
  const TitularesList({
    super.key,
    required super.group,
    required super.players,
    required super.onRefresh,
    required super.onEdit,
    required super.onDelete,
    super.onSwap,
  });

  @override
  String get emptyMessage => 'Nenhum titular encontrado.';
}
