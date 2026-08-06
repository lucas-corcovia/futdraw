import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/match_request.dart';
import 'package:futdraw/data/remote/match_remote_datasource.dart';
import 'package:futdraw/models/match.dart';

class MatchRepository {
  final MatchRemoteDataSource _dataSource;

  MatchRepository(this._dataSource);

  Future<AppResult<List<Match>>> getAll(String grupoId) async {
    final result = await _dataSource.getAll(grupoId);
    return result.when(
      success: (data) =>
          AppResult.success(data.map((r) => r.toModel()).toList()),
      error: AppResult.error,
    );
  }

  Future<AppResult<Match>> getById(String id) async {
    final result = await _dataSource.getById(id);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<Match>> create(
    String grupoId,
    MatchRequest request,
  ) async {
    final result = await _dataSource.create(grupoId, request);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<Match>> update(String id, MatchRequest request) async {
    final result = await _dataSource.update(id, request);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<void>> delete(String id) async {
    return _dataSource.delete(id);
  }
}
