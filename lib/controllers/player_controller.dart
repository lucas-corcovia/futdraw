import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/repositories/player_repository.dart';

class PlayerController extends ChangeNotifier {
  final repository = PlayerRepository();
  String searched = "";
  List<PlayerPosition> showedPositions = PlayerPosition.values.toList();
  List<Player> players = [];

  List<Player> get filteredPlayers {
    return players
        .where(
          (p) =>
              (searched == "" || p.filterByName(searched)) &&
              showedPositions.contains(p.position),
        )
        .toList();
  }

  void filter(String? input) {
    searched = input ?? "";
    notifyListeners();
  }

  add(BuildContext context, Player player) async {
    try {
      await repository.add(player);
      await getAllByGroupId(context, player.grupoId);
    } catch (e) {
      Toast.show(context, 'Erro ao adicionar jogador: $e', true);
    }
  }

  Future<void> addMany(
    BuildContext context,
    List<Player> players,
    int groupId,
  ) async {
    try {
      await repository.addMany(players);
      await getAllByGroupId(context, groupId);
    } catch (e) {
      Toast.show(context, 'Erro ao adicionar jogadores: $e', true);
    }
  }

  Future<List<Player>> getAll(BuildContext context) async {
    try {
      var result = await repository.getAll();
      players = result;
      notifyListeners();

      return result;
    } catch (e) {
      Toast.show(context, 'Erro ao obter jogadores: $e', true);
      return [];
    }
  }

  Future<List<Player>> getAllByGroupId(
    BuildContext context,
    int groupId,
  ) async {
    try {
      var result = await repository.getAllByGroupId(groupId);
      players = result;
      notifyListeners();

      return result;
    } catch (e) {
      Toast.show(context, 'Erro ao obter jogadores: $e', true);
      return [];
    }
  }

  delete(BuildContext context, Player player) async {
    try {
      await repository.delete(player);
      await getAllByGroupId(context, player.grupoId);
    } catch (e) {
      Toast.show(context, 'Erro ao excluir jogador: $e', true);
    }
  }

  update(BuildContext context, Player player) async {
    try {
      await repository.update(player);
      await getAllByGroupId(context, player.grupoId);
    } catch (e) {
      Toast.show(context, 'Erro ao atualizar jogador: $e', true);
    }
  }

  Future<Player?> getById(BuildContext context, int id) async {
    try {
      return await repository.getById(id);
    } catch (e) {
      Toast.show(context, 'Erro ao obter jogador: $e', true);
      return null;
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
