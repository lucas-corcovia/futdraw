import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  factory AppException.fromDio(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      const AppException('Tempo de conexão esgotado. Verifique sua rede.'),
    DioExceptionType.connectionError =>
      const AppException('Não foi possível conectar ao servidor.'),
    DioExceptionType.badResponse => AppException._fromResponse(e.response),
    _ => const AppException('Erro inesperado. Tente novamente.'),
  };

  factory AppException._fromResponse(Response? response) {
    if (response == null) return const AppException('Sem resposta do servidor.');

    final code = response.statusCode;
    final data = response.data;

    final message = switch (data) {
      List list => list.join(', '),
      Map map when map.containsKey('message') => map['message'] as String,
      _ => _defaultMessage(code),
    };

    return AppException(message, statusCode: code);
  }

  static String _defaultMessage(int? code) => switch (code) {
    400 => 'Requisição inválida.',
    401 => 'Não autorizado. Faça login novamente.',
    403 => 'Acesso negado.',
    404 => 'Recurso não encontrado.',
    409 => 'Conflito: recurso já existe.',
    500 => 'Erro interno do servidor.',
    _ => 'Erro inesperado.',
  };

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}
