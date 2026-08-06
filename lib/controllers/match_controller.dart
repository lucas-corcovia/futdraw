import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/data/models/requests/match_request.dart';
import 'package:futdraw/models/match.dart';
import 'package:futdraw/repositories/match_repository.dart';

class MatchController extends ChangeNotifier {
  final MatchRepository repository;

  MatchController(this.repository);

  List<Match> matches = [];
  Match? selectedMatch;

  Future<void> loadByGroup(BuildContext context, String grupoId) async {
    final result = await repository.getAll(grupoId);
    result.when(
      success: (data) {
        matches = data;
        notifyListeners();
      },
      error: (message) => Toast.show(context, message, true),
    );
  }

  Future<bool> schedule(
    BuildContext context,
    String grupoId,
    DateTime dataHora,
    String? local,
  ) async {
    final result = await repository.create(
      grupoId,
      MatchRequest(dataHora: dataHora, local: local),
    );
    return result.when(
      success: (data) {
        matches = [data, ...matches];
        notifyListeners();
        Toast.show(context, 'Partida agendada com sucesso!', false);
        return true;
      },
      error: (message) {
        Toast.show(context, message, true);
        return false;
      },
    );
  }

  Future<bool> update(
    BuildContext context,
    String id,
    DateTime dataHora,
    String? local,
  ) async {
    final result = await repository.update(
      id,
      MatchRequest(dataHora: dataHora, local: local),
    );
    return result.when(
      success: (data) {
        matches = matches.map((m) => m.id == id ? data : m).toList();
        if (selectedMatch?.id == id) selectedMatch = data;
        notifyListeners();
        Toast.show(context, 'Partida atualizada com sucesso!', false);
        return true;
      },
      error: (message) {
        Toast.show(context, message, true);
        return false;
      },
    );
  }

  Future<void> delete(BuildContext context, String id) async {
    final result = await repository.delete(id);
    result.when(
      success: (_) {
        matches = matches.where((m) => m.id != id).toList();
        notifyListeners();
        Toast.show(context, 'Partida excluída com sucesso!', false);
      },
      error: (message) => Toast.show(context, message, true),
    );
  }
}
