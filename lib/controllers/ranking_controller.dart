import 'package:flutter/material.dart';
import 'package:futdraw/components/toast.dart';
import 'package:futdraw/models/player_stats.dart';
import 'package:futdraw/models/ranking_item.dart';
import 'package:futdraw/repositories/stats_repository.dart';

class RankingController extends ChangeNotifier {
  final StatsRepository repository;

  RankingController(this.repository);

  List<RankingItem> ranking = [];
  PlayerStats? selectedPlayerStats;

  Future<void> loadRanking(
    BuildContext context,
    String grupoId, {
    DateTime? desde,
    DateTime? ate,
  }) async {
    final result = await repository.getRanking(grupoId, desde: desde, ate: ate);
    result.when(
      success: (data) {
        ranking = data;
        notifyListeners();
      },
      error: (message) => Toast.show(context, message, true),
    );
  }

  Future<void> loadPlayerStats(
    BuildContext context,
    String jogadorId, {
    DateTime? desde,
    DateTime? ate,
  }) async {
    final result = await repository.getPlayerStats(
      jogadorId,
      desde: desde,
      ate: ate,
    );
    result.when(
      success: (data) {
        selectedPlayerStats = data;
        notifyListeners();
      },
      error: (message) => Toast.show(context, message, true),
    );
  }
}
