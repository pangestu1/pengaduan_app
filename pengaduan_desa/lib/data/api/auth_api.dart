import 'package:dio/dio.dart';
import '../../core/config/dio_client.dart';

class AuthApi {
  final Dio _dio = DioClient.create();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return res.data;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      '/auth/register',
      data: {
        'nama': name, // Use 'nama' to match database schema
        'email': email,
        'password': password,
        'role': 'warga', // Explicitly set role to warga
      },
    );
  }
}
