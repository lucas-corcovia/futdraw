import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/group_request.dart';
import 'package:futdraw/data/remote/group_remote_datasource.dart';
import 'package:futdraw/models/group.dart';

class GroupRepository {
  final GroupRemoteDataSource _dataSource;

  GroupRepository(this._dataSource);

  Future<AppResult<List<Group>>> getAll() async {
    final result = await _dataSource.getAll();
    return result.when(
      success: (data) => AppResult.success(data.map((r) => r.toModel()).toList()),
      error: AppResult.error,
    );
  }

  Future<AppResult<Group>> getById(String id) async {
    final result = await _dataSource.getById(id);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<Group>> add(Group group) async {
    final result = await _dataSource.add(_toRequest(group));
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<Group>> update(Group group) async {
    final result = await _dataSource.update(group.id, _toRequest(group));
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<void>> delete(String id) async {
    return _dataSource.delete(id);
  }

  GroupRequest _toRequest(Group group) => GroupRequest(
    nome: group.nome,
    diasDeJogo: group.diasDeJogo,
    horarioJogo: group.horarioJogo,
    localPadrao: group.localPadrao,
    tipoCampo: group.tipoCampo,
    jogadoresPorTime: group.jogadoresPorTime,
    duracaoJogoMinutos: group.duracaoJogoMinutos,
    limiteTitulares: group.limiteTitulares,
    goleirosFixos: group.goleirosFixos,
    urlAvatar: group.urlAvatar,
    taticaGoleiros: group.taticaGoleiros,
    taticaDefensores: group.taticaDefensores,
    taticaMeias: group.taticaMeias,
    taticaAtacantes: group.taticaAtacantes,
  );
}
