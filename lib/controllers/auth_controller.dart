import 'package:flutter/material.dart';
import 'package:futdraw/data/models/requests/auth_request.dart';
import 'package:futdraw/data/remote/auth_remote_datasource.dart';
import 'package:futdraw/services/auth_service.dart';

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

  Future<void> logout() async {
    await _authService.clearSession();
    status = AuthStatus.idle;
    notifyListeners();
  }
}
