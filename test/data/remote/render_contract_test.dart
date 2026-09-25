import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futdraw/controllers/auth_controller.dart';
import 'package:futdraw/data/remote/auth_remote_datasource.dart';
import 'package:futdraw/data/remote/member_remote_datasource.dart';
import 'package:futdraw/data/remote/sorteio_ia_remote_datasource.dart';
import 'package:futdraw/data/models/requests/sortear_ia_request.dart';
import 'package:futdraw/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cadastro sem e-mail salva a sessão devolvida pela API', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'POST');
          expect(options.path, '/api/auth/registrar');
          expect(options.data, {
            'nome': 'Pessoa',
            'email': 'pessoa@example.test',
            'senha': 'senha123',
          });
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'token': 'jwt-do-teste',
                'expiracao': '2026-09-25T12:00:00Z',
                'nome': 'Pessoa',
                'email': 'pessoa@example.test',
                'isPro': true,
              },
            ),
          );
        },
      ),
    );
    final controller = AuthController(
      AuthRemoteDataSource(dio),
      AuthService(prefs),
    );

    expect(
      await controller.register('Pessoa', 'pessoa@example.test', 'senha123'),
      isTrue,
    );
    expect(controller.isLoggedIn, isTrue);
    expect(controller.userEmail, 'pessoa@example.test');
    expect(controller.isPro, isTrue);
    expect(prefs.getString('auth_token'), 'jwt-do-teste');
    controller.dispose();
  });

  test('atribui jogador pela rota de membro da API', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'PUT');
          expect(options.path, '/api/grupos/grupo-1/membros/membro-2/jogador');
          expect(options.data, {'jogadorId': 'jogador-3'});
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: true),
          );
        },
      ),
    );

    final result = await MemberRemoteDataSource(
      dio,
    ).assignPlayer('grupo-1', 'membro-2', 'jogador-3');
    expect(result.isSuccess, isTrue);
  });

  test('sorteio com IA envia quantidade e instruções ao endpoint da API', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.method, 'POST');
      expect(options.path, '/api/grupos/grupo-1/sorteios/sortear/ia');
      expect(options.data, {
        'numeroTimes': 3,
        'instrucoes': 'Separar os goleiros',
      });
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: [
          {'nome': 'Time 1', 'jogadores': [], 'mediaNota': 7.5},
        ],
      ));
    }));

    final result = await SorteioIARemoteDataSource(dio).sortearIA(
      'grupo-1',
      const SortearIARequest(
        numeroTimes: 3,
        instrucoes: 'Separar os goleiros',
      ),
    );
    expect(result.isSuccess, isTrue);
    result.when(
      success: (teams) => expect(teams.single.name, 'Time 1'),
      error: fail,
    );
  });
}
