import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/errors/app_exception.dart';
import 'package:futdraw/core/result/result.dart';
import 'package:futdraw/data/models/requests/auth_request.dart';
import 'package:futdraw/data/models/responses/auth_response.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AppResult<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return AppResult.success(
        AuthResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }

  Future<AppResult<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.registrar,
        data: request.toJson(),
      );
      return AppResult.success(
        AuthResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return AppResult.error(AppException.fromDio(e).message);
    }
  }
}
