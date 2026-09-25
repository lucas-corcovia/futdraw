import 'package:dio/dio.dart';
import 'package:futdraw/core/constants/api_constants.dart';
import 'package:futdraw/core/network/auth_interceptor.dart';
import 'package:futdraw/services/auth_service.dart';

class DioClient {
  DioClient._();

  static Dio create(AuthService authService) {
    return _build(
      authService,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  // Ollama/local LLM pode demorar bem mais do que 30s
  static Dio createForAI(AuthService authService) {
    return _build(
      authService,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 3),
    );
  }

  static Dio _build(
    AuthService authService, {
    required Duration connectTimeout,
    required Duration receiveTimeout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        // Names may contain Portuguese characters; declare the JSON encoding
        // explicitly so every request preserves them end to end.
        contentType: 'application/json; charset=utf-8',
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(AuthInterceptor(authService));

    return dio;
  }
}
