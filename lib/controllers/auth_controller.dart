import 'package:flutter/material.dart';
import 'package:futdraw/data/models/requests/auth_request.dart';
import 'package:futdraw/data/remote/auth_remote_datasource.dart';
import 'package:futdraw/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus { idle, loading, success, error }

class AuthController extends ChangeNotifier {
  final AuthRemoteDataSource _dataSource;
  final AuthService _authService;

  AuthController(this._dataSource, this._authService);

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;

  bool get isLoggedIn => _authService.isLoggedIn;
  String? get userName => _authService.userName;

  Future<bool> login(String email, String senha) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _dataSource.login(LoginRequest(email: email, senha: senha));

    return result.when(
      success: (data) async {
        await _authService.saveSession(
          token: data.token,
          nome: data.nome,
          email: data.email,
        );
        status = AuthStatus.success;
        notifyListeners();
        return true;
      },
      error: (message) {
        errorMessage = message;
        status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> register(String nome, String email, String senha) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _dataSource.register(
      RegisterRequest(nome: nome, email: email, senha: senha),
    );

    return result.when(
      success: (_) {
        status = AuthStatus.success;
        notifyListeners();
        return true;
      },
      error: (message) {
        errorMessage = message;
        status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> confirmarEmail(String email, String codigo) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _dataSource.confirmarEmail(
      ConfirmarEmailRequest(email: email, codigo: codigo),
    );

    return result.when(
      success: (data) async {
        await _authService.saveSession(
          token: data.token,
          nome: data.nome,
          email: data.email,
        );
        status = AuthStatus.success;
        notifyListeners();
        return true;
      },
      error: (message) {
        errorMessage = message;
        status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> reenviarCodigo(String email) async {
    final result = await _dataSource.reenviarCodigo(
      ReenviarCodigoRequest(email: email),
    );
    result.when(
      success: (_) {
        errorMessage = null;
        notifyListeners();
      },
      error: (message) {
        errorMessage = message;
        notifyListeners();
      },
    );
  }

  Future<bool> loginWithGoogle() async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '461202599388-l587j3gunnfablfq7u2bg6mi5ehpg99c.apps.googleusercontent.com',
      );

      final account = await googleSignIn.signIn();
      if (account == null) {
        status = AuthStatus.idle;
        notifyListeners();
        return false;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        errorMessage = 'Não foi possível obter o token do Google.';
        status = AuthStatus.error;
        notifyListeners();
        return false;
      }

      final result = await _dataSource.googleLogin(
        GoogleLoginRequest(idToken: idToken),
      );

      return result.when(
        success: (data) async {
          await _authService.saveSession(
            token: data.token,
            nome: data.nome,
            email: data.email,
          );
          status = AuthStatus.success;
          notifyListeners();
          return true;
        },
        error: (message) {
          errorMessage = message;
          status = AuthStatus.error;
          notifyListeners();
          return false;
        },
      );
    } catch (_) {
      errorMessage = 'Erro ao autenticar com Google.';
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.clearSession();
    status = AuthStatus.idle;
    notifyListeners();
  }
}
