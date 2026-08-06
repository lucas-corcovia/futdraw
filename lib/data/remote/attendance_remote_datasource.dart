import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/attendance_request.dart';
import 'package:futdraw/data/models/responses/attendance_panel_response.dart';
import 'package:futdraw/data/models/responses/attendance_response.dart';

class AttendanceRemoteDataSource {
  final Dio _dio;

  AttendanceRemoteDataSource(this._dio);

  Future<AppResult<AttendancePanelResponse>> getPanel(
    String partidaId,
  ) async {
    try {
      final response = await _dio.get(ApiConstants.partidaPresencas(partidaId));
      return AppResult.success(
        AttendancePanelResponse.fromJson(
          response.data as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<AttendanceResponse>> respond(
    String partidaId,
    AttendanceRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.partidaPresenca(partidaId),
        data: request.toJson(),
      );
      return AppResult.success(
        AttendanceResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
