import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'auth_user_name';
  static const _userEmailKey = 'auth_user_email';

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  String? get token => _prefs.getString(_tokenKey);
  String? get userName => _prefs.getString(_userNameKey);
  String? get userEmail => _prefs.getString(_userEmailKey);
  bool get isLoggedIn => token != null;

  Future<void> saveSession({
    required String token,
    required String nome,
    required String email,
  }) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userNameKey, nome);
    await _prefs.setString(_userEmailKey, email);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
  }
}
