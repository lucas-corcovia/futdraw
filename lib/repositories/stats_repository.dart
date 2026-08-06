import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/remote/stats_remote_datasource.dart';
import 'package:futdraw/models/player_stats.dart';
import 'package:futdraw/models/ranking_item.dart';

class StatsRepository {
  final StatsRemoteDataSource _dataSource;

  StatsRepository(this._dataSource);

  Future<AppResult<List<RankingItem>>> getRanking(
    String grupoId, {
    DateTime? desde,
    DateTime? ate,
  }) async {
    final result =
        await _dataSource.getRanking(grupoId, desde: desde, ate: ate);
    return result.when(
      success: (data) =>
          AppResult.success(data.map((r) => r.toModel()).toList()),
      error: AppResult.error,
    );
  }

  Future<AppResult<PlayerStats>> getPlayerStats(
    String jogadorId, {
    DateTime? desde,
    DateTime? ate,
  }) async {
    final result = await _dataSource.getPlayerStats(
      jogadorId,
      desde: desde,
      ate: ate,
    );
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }
}
