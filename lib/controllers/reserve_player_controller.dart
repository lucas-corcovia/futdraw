import 'package:flutter/material.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/repositories/player_repository.dart';

class ReservePlayerController extends ChangeNotifier {
  final repository = PlayerRepository();
  String searched = "";
  List<PlayerPosition> showedPositions = PlayerPosition.values.toList();
  List<Player> players = [];

  List<Player> get filteredPlayers {
    return players
        .where(
          (p) =>
              p.reserva &&
              (searched == "" || p.filterByName(searched)) &&
              showedPositions.contains(p.position),
        )
        .toList();
  }

  void filter(String? input) {
    searched = input ?? "";
    notifyListeners();
  }

  Future<void> getAllByGroupId(BuildContext context, int groupId) async {
    try {
      var result = await repository.getAllByGroupId(groupId);
      players = result;
      notifyListeners();
    } catch (e) {
      // Trate o erro conforme necessário
    }
  }

  void toggleFilter(bool selected, PlayerPosition option) {
    final newList = showedPositions.toList();
    if (selected) {
      if (!newList.contains(option)) {
        newList.add(option);
      }
    } else {
      newList.remove(option);
    }
    showedPositions = newList;
    notifyListeners();
  }

  void toggleAll(bool selected) {
    var newList = showedPositions.toList();
    if (selected) {
      newList = PlayerPosition.values.toList();
    } else {
      newList = [];
    }
    showedPositions = newList;
    notifyListeners();
  }
}
