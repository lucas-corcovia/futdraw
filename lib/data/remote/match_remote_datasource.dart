import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/match_request.dart';
import 'package:futdraw/data/models/responses/match_response.dart';

class MatchRemoteDataSource {
  final Dio _dio;

  MatchRemoteDataSource(this._dio);

  Future<AppResult<List<MatchResponse>>> getAll(String grupoId) async {
    try {
      final response = await _dio.get(ApiConstants.grupoPartidas(grupoId));
      final list = (response.data as List<dynamic>)
          .map((j) => MatchResponse.fromJson(j as Map<String, dynamic>))
          .toList();
      return AppResult.success(list);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<MatchResponse>> getById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.partidaById(id));
      return AppResult.success(
        MatchResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<MatchResponse>> create(
    String grupoId,
    MatchRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.grupoPartidas(grupoId),
        data: request.toJson(),
      );
      return AppResult.success(
        MatchResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<MatchResponse>> update(
    String id,
    MatchRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.partidaById(id),
        data: request.toJson(),
      );
      return AppResult.success(
        MatchResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<void>> delete(String id) async {
    try {
      await _dio.delete(ApiConstants.partidaById(id));
      return AppResult.success(null);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
