import 'package:flutter/material.dart';
import 'package:futdraw/core/di/service_locator.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';

class ReservePlayerController extends ChangeNotifier {
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

  Future<void> getAllByGroupId(BuildContext context, String groupId) async {
    final result =
        await ServiceLocator().playerRepository.getAllByGroupId(groupId);
    result.when(
      success: (data) {
        players = data;
        notifyListeners();
      },
      error: (_) {},
    );
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
