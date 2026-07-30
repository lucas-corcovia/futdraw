import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/models/enums/player.position.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/repositories/player_repository.dart';

class PlayerController extends ChangeNotifier {
  final PlayerRepository repository;

  PlayerController(this.repository);

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

  Future<void> add(BuildContext context, Player player) async {
    final result = await repository.add(player);
    if (result.isSuccess) {
      await getAllByGroupId(context, player.grupoId);
      Toast.show(context, 'Jogador adicionado com sucesso!', false);
    } else {
      Toast.show(context, 'Erro ao adicionar jogador: ${result.errorMessage}', true);
    }
  }

  Future<void> addMany(
    BuildContext context,
    List<Player> players,
    String groupId,
  ) async {
    final result = await repository.addMany(players, groupId);
    if (result.isSuccess) {
      await getAllByGroupId(context, groupId);
      Toast.show(context, 'Jogadores adicionados com sucesso!', false);
    } else {
      Toast.show(context, 'Erro ao adicionar jogadores: ${result.errorMessage}', true);
    }
  }

  Future<List<Player>> getAll(BuildContext context) async {
    final result = await repository.getAll();
    if (result is AppSuccess<List<Player>>) {
      players = result.data;
      notifyListeners();
      return result.data;
    }
    return [];
  }

  Future<List<Player>> getAllByGroupId(
    BuildContext context,
    String groupId,
  ) async {
    final result = await repository.getAllByGroupId(groupId);
    if (result is AppSuccess<List<Player>>) {
      players = result.data;
      notifyListeners();
      return result.data;
    }
    Toast.show(context, 'Erro ao obter jogadores: ${result.errorMessage}', true);
    return [];
  }

  Future<void> delete(BuildContext context, Player player) async {
    final result = await repository.delete(player);
    if (result.isSuccess) {
      await getAllByGroupId(context, player.grupoId);
      Toast.show(context, 'Jogador excluído com sucesso!', false);
    } else {
      Toast.show(context, 'Erro ao excluir jogador: ${result.errorMessage}', true);
    }
  }

  Future<void> update(BuildContext context, Player player) async {
    final result = await repository.update(player);
    if (result.isSuccess) {
      await getAllByGroupId(context, player.grupoId);
      Toast.show(context, 'Jogador atualizado com sucesso!', false);
    } else {
      Toast.show(context, 'Erro ao atualizar jogador: ${result.errorMessage}', true);
    }
  }

  Future<Player?> getById(BuildContext context, String id) async {
    final result = await repository.getById(id);
    if (result is AppSuccess<Player?>) return result.data;
    Toast.show(context, 'Erro ao obter jogador: ${result.errorMessage}', true);
    return null;
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

  Future<void> copyPlayersToClipboard(BuildContext context) async {
    final buffer = StringBuffer();
    for (final player in players) {
      buffer.writeln(
        '${player.nome} - Nota: ${player.nota.toStringAsFixed(1)}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    Toast.show(context, 'Jogadores copiados para a área de transferência!', false);
  }

  Future<void> exportPlayersToJson(BuildContext context, String groupId) async {
    try {
      final jsonData = Player.fromListToJson(players);
      final jsonString = jsonEncode(jsonData);
      await Clipboard.setData(ClipboardData(text: jsonString));
      Toast.show(context, 'JSON gerado e copiado para a área de transferência!', false);
    } catch (e) {
      Toast.show(context, 'Erro ao exportar jogadores: $e', true);
    }
  }

  Future<void> importPlayersToJson(
    BuildContext context,
    String jsonString,
    String groupId,
  ) async {
    try {
      List<dynamic> jsonList = jsonDecode(jsonString);
      final importedPlayers = Player.fromJsonToList(jsonList);

      for (var player in importedPlayers) {
        player.grupoId = groupId;
      }

      await addMany(context, importedPlayers, groupId);
    } catch (e) {
      Toast.show(context, 'Erro ao importar jogadores: $e', true);
    }
  }
}
