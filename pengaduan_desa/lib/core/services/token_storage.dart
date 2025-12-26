import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'token';
  static const _roleKey = 'role';

  static Future<void> save({
    required String token,
    required String role,
  }) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_tokenKey, token);
    await pref.setString(_roleKey, role);
  }

  static Future<String?> getToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_tokenKey);
  }

  static Future<String?> getRole() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_roleKey);
  }

  static Future<void> clear() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
