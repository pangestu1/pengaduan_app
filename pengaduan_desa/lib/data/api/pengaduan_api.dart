import 'package:dio/dio.dart';
import '../../core/config/dio_client.dart';

class PengaduanApi {
  final Dio _dio = DioClient.create();

  Future<List<dynamic>> getAll() async {
    final res = await _dio.get('/pengaduan');
    return res.data['data']; // ⬅️ PENTING
  }

  Future<void> createPengaduan(FormData data) async {
    await _dio.post('/pengaduan', data: data);
  }

  Future<void> updatePengaduan({
    required int id,
    required String judul,
    required String deskripsi,
  }) async {
    await _dio.put(
      '/pengaduan/warga/$id',
      data: {'judul': judul, 'deskripsi': deskripsi},
    );
  }

  Future<void> updateStatus({required int id, required String status}) async {
    await _dio.put('/pengaduan/$id', data: {'status': status});
  }

  Future<void> deletePengaduan(int id) async {
    await _dio.delete('/pengaduan/warga/$id');
  }
}
