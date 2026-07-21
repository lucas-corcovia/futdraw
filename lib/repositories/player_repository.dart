import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/player_request.dart';
import 'package:futdraw/data/remote/player_remote_datasource.dart';
import 'package:futdraw/models/player.dart';

class PlayerRepository {
  final PlayerRemoteDataSource _dataSource;

  PlayerRepository(this._dataSource);

  PlayerRequest _toRequest(Player player) => PlayerRequest(
    nome: player.nome,
    nota: player.nota,
    urlFoto: player.urlFoto,
    posicao: player.position.index,
    ehCapitao: player.ehCapitao,
    reserva: player.reserva,
  );

  Future<AppResult<List<Player>>> getAllByGroupId(String groupId) async {
    final result = await _dataSource.getAllByGrupoId(groupId);
    return result.when(
      success: (data) =>
          AppResult.success(data.map((r) => r.toModel(groupId)).toList()),
      error: AppResult.error,
    );
  }

  Future<AppResult<List<Player>>> getAll() async {
    return AppResult.success([]);
  }

  Future<AppResult<void>> add(Player player) async {
    final result = await _dataSource.add(player.grupoId, _toRequest(player));
    return result.when(success: (_) => AppResult.success(null), error: AppResult.error);
  }

  Future<AppResult<void>> addMany(List<Player> players, String grupoId) async {
    final requests = players.map(_toRequest).toList();
    final result = await _dataSource.addMany(grupoId, requests);
    return result.when(success: (_) => AppResult.success(null), error: AppResult.error);
  }

  Future<AppResult<void>> update(Player player) async {
    final result = await _dataSource.update(player.id, _toRequest(player));
    return result.when(success: (_) => AppResult.success(null), error: AppResult.error);
  }

  Future<AppResult<void>> delete(Player player) async {
    return _dataSource.delete(player.id);
  }

  Future<AppResult<Player?>> getById(String id) async {
    return AppResult.success(null);
  }
}
