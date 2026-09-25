import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/core/errors/app_exception.dart';

void main() {
  test('mostra a mensagem de indisponibilidade enviada pela API de IA', () {
    final request = RequestOptions(path: '/api/grupos/1/sorteios/sortear/ia');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: request,
        statusCode: 503,
        data: {'mensagem': 'Sorteio por IA indisponível.'},
      ),
    );

    expect(AppException.fromDio(error).message, 'Sorteio por IA indisponível.');
  });
}
