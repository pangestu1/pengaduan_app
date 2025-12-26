import 'package:flutter/material.dart';
import '../data/api/auth_api.dart';
import '../core/services/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  final _api = AuthApi();

  bool isLoading = false;

  /// =====================
  /// LOGIN
  /// =====================
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _api.login(
        email: email,
        password: password,
      );

      final token = res['token'];
      final role = res['role'];

      if (token == null || role == null) {
        throw Exception('Token atau role tidak ditemukan');
      }

      await TokenStorage.save(
        token: token,
        role: role,
      );

      return role;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// =====================
  /// REGISTER
  /// =====================
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      /// ⬅️ TIDAK ADA return value
      await _api.register(
        name: name,
        email: email,
        password: password,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// =====================
  /// LOGOUT
  /// =====================
  Future<void> logout() async {
    await TokenStorage.clear();
    notifyListeners();
  }
}
