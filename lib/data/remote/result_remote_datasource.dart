import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/result_request.dart';
import 'package:futdraw/data/models/responses/result_response.dart';

class ResultRemoteDataSource {
  final Dio _dio;

  ResultRemoteDataSource(this._dio);

  Future<AppResult<ResultResponse>> register(
    String partidaId,
    ResultRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.partidaResultado(partidaId),
        data: request.toJson(),
      );
      return AppResult.success(
        ResultResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<ResultResponse>> getByPartida(String partidaId) async {
    try {
      final response =
          await _dio.get(ApiConstants.partidaResultado(partidaId));
      return AppResult.success(
        ResultResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<ResultResponse>> update(
    String partidaId,
    ResultRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.partidaResultado(partidaId),
        data: request.toJson(),
      );
      return AppResult.success(
        ResultResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
