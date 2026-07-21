import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/group_request.dart';
import 'package:futdraw/data/models/responses/group_response.dart';

class GroupRemoteDataSource {
  final Dio _dio;

  GroupRemoteDataSource(this._dio);

  Future<AppResult<List<GroupResponse>>> getAll() async {
    try {
      final response = await _dio.get(ApiConstants.grupos);
      final list = (response.data as List<dynamic>)
          .map((j) => GroupResponse.fromJson(j as Map<String, dynamic>))
          .toList();
      return AppResult.success(list);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<GroupDetailedResponse>> getById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.grupoById(id));
      return AppResult.success(
        GroupDetailedResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<GroupResponse>> add(GroupRequest request) async {
    try {
      final response = await _dio.post(ApiConstants.grupos, data: request.toJson());
      return AppResult.success(
        GroupResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<GroupResponse>> update(
    String id,
    GroupRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.grupoById(id),
        data: request.toJson(),
      );
      return AppResult.success(
        GroupResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<void>> delete(String id) async {
    try {
      await _dio.delete(ApiConstants.grupoById(id));
      return AppResult.success(null);
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
