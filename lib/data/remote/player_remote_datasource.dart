import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/player_request.dart';
import 'package:futdraw/data/models/responses/player_response.dart';

class PlayerRemoteDataSource {
  final Dio _dio;

  PlayerRemoteDataSource(this._dio);

  Future<AppResult<List<PlayerResponse>>> getAllByGrupoId(String grupoId) async {
    try {
      final response = await _dio.get(ApiConstants.grupoJogadores(grupoId));
      final list = (response.data as List<dynamic>)
          .map((j) => PlayerResponse.fromJson(j as Map<String, dynamic>))
          .toList();
      return AppResult.success(list);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<PlayerResponse>> add(
    String grupoId,
    PlayerRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.grupoJogadores(grupoId),
        data: request.toJson(),
      );
      return AppResult.success(
        PlayerResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<List<PlayerResponse>>> addMany(
    String grupoId,
    List<PlayerRequest> requests,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.grupoImportar(grupoId),
        data: requests.map((r) => r.toJson()).toList(),
      );
      final list = (response.data as List<dynamic>)
          .map((j) => PlayerResponse.fromJson(j as Map<String, dynamic>))
          .toList();
      return AppResult.success(list);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<PlayerResponse>> update(
    String id,
    PlayerRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.jogadorById(id),
        data: request.toJson(),
      );
      return AppResult.success(
        PlayerResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<void>> delete(String id) async {
    try {
      await _dio.delete(ApiConstants.jogadorById(id));
      return AppResult.success(null);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
