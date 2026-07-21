import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/network/auth_interceptor.dart';
import 'package:futdraw/services/auth_service.dart';

class DioClient {
  DioClient._();

  static Dio create(AuthService authService) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(authService),
      LogInterceptor(
        request: false,
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);

    return dio;
  }
}
