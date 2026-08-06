import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/member_request.dart';
import 'package:futdraw/data/remote/member_remote_datasource.dart';
import 'package:futdraw/models/group_member.dart';

class MemberRepository {
  final MemberRemoteDataSource _dataSource;

  MemberRepository(this._dataSource);

  Future<AppResult<List<GroupMember>>> getAll(String grupoId) async {
    final result = await _dataSource.getAll(grupoId);
    return result.when(
      success: (data) =>
          AppResult.success(data.map((r) => r.toModel()).toList()),
      error: AppResult.error,
    );
  }

  Future<AppResult<GroupMember>> invite(
    String grupoId,
    InviteMemberRequest request,
  ) async {
    final result = await _dataSource.invite(grupoId, request);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<GroupMember>> changePapel(
    String membroId,
    ChangePapelRequest request,
  ) async {
    final result = await _dataSource.changePapel(membroId, request);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<void>> remove(String membroId) async {
    return _dataSource.remove(membroId);
  }

  Future<AppResult<void>> claimPlayer(
    String grupoId,
    String jogadorId,
  ) async {
    return _dataSource.claimPlayer(grupoId, jogadorId);
  }
}
