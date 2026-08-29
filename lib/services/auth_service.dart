import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'auth_user_name';
  static const _userEmailKey = 'auth_user_email';
  static const _lastEmailKey = 'auth_last_email';
  static const _isProKey = 'auth_is_pro';

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  // Emite true quando a sessão é encerrada por expiração de token (401).
  final sessionExpiredNotifier = ValueNotifier<bool>(false);

  String? get token => _prefs.getString(_tokenKey);
  String? get userName => _prefs.getString(_userNameKey);
  String? get userEmail => _prefs.getString(_userEmailKey);
  String? get lastEmail => _prefs.getString(_lastEmailKey);
  bool get isPro => _prefs.getBool(_isProKey) ?? false;
  bool get isLoggedIn => token != null;

  Future<void> saveSession({
    required String token,
    required String nome,
    required String email,
    bool isPro = false,
  }) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userNameKey, nome);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_lastEmailKey, email);
    await _prefs.setBool(_isProKey, isPro);
    sessionExpiredNotifier.value = false;
  }

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
    // _lastEmailKey é preservado intencionalmente para pré-preencher o campo de email no próximo login.
  }

  // Chamado pelo interceptor em 401: limpa a sessão e sinaliza expiração.
  Future<void> expireSession() async {
    await clearSession();
    sessionExpiredNotifier.value = true;
  }
}
