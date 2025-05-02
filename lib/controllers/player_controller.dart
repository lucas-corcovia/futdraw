import 'package:flutter/material.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/repositories/player_repository.dart';

class PlayerController extends ChangeNotifier {
  final repository = PlayerRepository();
  List<Player> players = [];

  add(Player player) async {
    print("Adicionando Repo");
    await repository.add(player);
    await getAll();
    //notifyListeners();
  }

  Future<List<Player>> getAll() async {
    var result = await repository.getAll();
    players = result;
    notifyListeners();

    return result;
  }

  delete(int id) async {
    await repository.delete(id);
    getAll();
  }

  update(Player player) async {
    await repository.update(player);
    await getAll();
    //notifyListeners();
  }

  Future<Player?> getById(int id) async {
    return await repository.getById(id);
  }
}
