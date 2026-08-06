import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/responses/player_stats_response.dart';
import 'package:futdraw/data/models/responses/ranking_response.dart';

class StatsRemoteDataSource {
  final Dio _dio;

  StatsRemoteDataSource(this._dio);

  Future<AppResult<List<RankingItemResponse>>> getRanking(
    String grupoId, {
    DateTime? desde,
    DateTime? ate,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.grupoRanking(grupoId),
        queryParameters: {
          if (desde != null) 'desde': desde.toIso8601String(),
          if (ate != null) 'ate': ate.toIso8601String(),
        },
      );
      final list = (response.data as List<dynamic>)
          .map(
            (j) => RankingItemResponse.fromJson(j as Map<String, dynamic>),
          )
          .toList();
      return AppResult.success(list);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<PlayerStatsResponse>> getPlayerStats(
    String jogadorId, {
    DateTime? desde,
    DateTime? ate,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.jogadorEstatisticas(jogadorId),
        queryParameters: {
          if (desde != null) 'desde': desde.toIso8601String(),
          if (ate != null) 'ate': ate.toIso8601String(),
        },
      );
      return AppResult.success(
        PlayerStatsResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
