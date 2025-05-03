import 'package:flutter/material.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/repositories/player_repository.dart';

class PlayerController extends ChangeNotifier {
  final repository = PlayerRepository();
  List<Player> players = [];

  add(Player player) async {
    await repository.add(player);
    await getAllByGroupIdAll(player.grupoId);
  }

  Future<List<Player>> getAll() async {
    var result = await repository.getAll();
    players = result;
    notifyListeners();

    return result;
  }

  Future<List<Player>> getAllByGroupIdAll(int groupId) async {
    var result = await repository.getAllByGroupId(groupId);
    players = result;
    notifyListeners();

    return result;
  }

  delete(Player player) async {
    await repository.delete(player);
    await getAllByGroupIdAll(player.grupoId);
  }

  update(Player player) async {
    await repository.update(player);
    await getAllByGroupIdAll(player.grupoId);
  }

  Future<Player?> getById(int id) async {
    return await repository.getById(id);
  }
}
