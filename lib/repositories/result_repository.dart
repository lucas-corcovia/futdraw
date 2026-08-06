import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/result_request.dart';
import 'package:futdraw/data/remote/result_remote_datasource.dart';
import 'package:futdraw/models/match_result.dart';

class ResultRepository {
  final ResultRemoteDataSource _dataSource;

  ResultRepository(this._dataSource);

  Future<AppResult<MatchResult>> register(
    String partidaId,
    ResultRequest request,
  ) async {
    final result = await _dataSource.register(partidaId, request);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<MatchResult>> getByPartida(String partidaId) async {
    final result = await _dataSource.getByPartida(partidaId);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<MatchResult>> update(
    String partidaId,
    ResultRequest request,
  ) async {
    final result = await _dataSource.update(partidaId, request);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }
}
