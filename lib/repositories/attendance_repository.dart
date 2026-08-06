import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/attendance_request.dart';
import 'package:futdraw/data/remote/attendance_remote_datasource.dart';
import 'package:futdraw/models/attendance.dart';
import 'package:futdraw/models/attendance_panel.dart';

class AttendanceRepository {
  final AttendanceRemoteDataSource _dataSource;

  AttendanceRepository(this._dataSource);

  Future<AppResult<AttendancePanel>> getPanel(String partidaId) async {
    final result = await _dataSource.getPanel(partidaId);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }

  Future<AppResult<Attendance>> respond(
    String partidaId,
    AttendanceRequest request,
  ) async {
    final result = await _dataSource.respond(partidaId, request);
    return result.when(
      success: (data) => AppResult.success(data.toModel()),
      error: AppResult.error,
    );
  }
}
