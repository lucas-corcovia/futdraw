import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/data/models/requests/result_request.dart';
import 'package:futdraw/models/match_result.dart';
import 'package:futdraw/repositories/result_repository.dart';

class ResultController extends ChangeNotifier {
  final ResultRepository repository;

  ResultController(this.repository);

  MatchResult? result;

  Future<void> loadByPartida(BuildContext context, String partidaId) async {
    final res = await repository.getByPartida(partidaId);
    res.when(
      success: (data) {
        result = data;
        notifyListeners();
      },
      error: (_) {},
    );
  }

  Future<bool> register(
    BuildContext context,
    String partidaId,
    ResultRequest request,
  ) async {
    final res = await repository.register(partidaId, request);
    return res.when(
      success: (data) {
        result = data;
        notifyListeners();
        Toast.show(context, 'Resultado registrado com sucesso!', false);
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
    String partidaId,
    ResultRequest request,
  ) async {
    final res = await repository.update(partidaId, request);
    return res.when(
      success: (data) {
        result = data;
        notifyListeners();
        Toast.show(context, 'Resultado atualizado com sucesso!', false);
        return true;
      },
      error: (message) {
        Toast.show(context, message, true);
        return false;
      },
    );
  }
}
