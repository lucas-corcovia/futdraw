import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/repositories/player_repository.dart';

class PlayerController extends ChangeNotifier {
  final repository = PlayerRepository();

  List<Player> players = [];

  add(BuildContext context, Player player) async {
    try {
      await repository.add(player);
      await getAllByGroupId(context, player.grupoId);
    } catch (e) {
      Toast.show(context, 'Erro ao adicionar jogador: $e', true);
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
}
