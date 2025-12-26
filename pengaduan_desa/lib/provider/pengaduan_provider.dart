// provider/pengaduan_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/api/pengaduan_api.dart';
import '../data/models/pengaduan_model.dart';

class PengaduanProvider extends ChangeNotifier {
  final _api = PengaduanApi();

  List<Pengaduan> list = [];
  bool isLoading = false;
  String? errorMessage;

  /// ======================
  /// CLEAR ERROR MESSAGE
  /// ======================
  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
  }

  /// ======================
  /// GET PENGADUAN 
  /// ======================
  Future<void> fetchPengaduan() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _api.getAll();
      
      // Tambahkan logging untuk debugging
      debugPrint('API Response: $data');
      
      // Periksa apakah data tidak null dan merupakan List
      list = data.map((e) {
        try {
          return Pengaduan.fromJson(e);
        } catch (e) {
          debugPrint('Error parsing item: $e');
          debugPrint('Item data: $e');
          // Kembalikan objek default jika parsing gagal
          return Pengaduan(
            id: 0,
            judul: 'Error Loading Data',
            deskripsi: 'Could not parse this item',
            status: 'error',
            createdAt: DateTime.now(),
          );
        }
      }).where((item) => item.id != 0).toList(); // Filter out error items
    // ignore: dead_code
        } catch (e) {
      debugPrint('ERROR FETCH PENGADUAN: $e');
      errorMessage = 'Gagal memuat data pengaduan: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ======================
  /// CREATE PENGADUAN 
  /// ======================
  Future<void> createPengaduan({
    required String judul,
    required String deskripsi,
    required XFile image,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final formData = FormData.fromMap({
        'judul': judul,
        'isi': deskripsi, // Use 'isi' to match backend schema
        'foto': MultipartFile.fromBytes(
      await image.readAsBytes(),       // 🔥 WEB SAFE
      filename: image.name,
        ),
      });

      await _api.createPengaduan(formData);

      
      await fetchPengaduan();
    } catch (e) {
      debugPrint('ERROR CREATE PENGADUAN: $e');
      errorMessage = 'Gagal membuat pengaduan: ${e.toString()}';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


// UPDATE PENGADUAN
  Future<void> updatePengaduan({
  required int id,
  required String judul,
  required String deskripsi,
}) async {
  isLoading = true;
  notifyListeners();

  await _api.updatePengaduan(
    id: id,
    judul: judul,
    deskripsi: deskripsi,
  );

  final index = list.indexWhere((e) => e.id == id);
  if (index != -1) {
    list[index] = list[index].copyWith(
      judul: judul,
      deskripsi: deskripsi,
    );
  }

  isLoading = false;
  notifyListeners();
}

  /// ======================
  /// UPDATE STATUS
  /// ======================
  Future<void> updateStatus({
    required int id,
    required String status,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // 1. Panggil API untuk update status di backend
      await _api.updateStatus(id: id, status: status);

      // 2. Update status di list lokal AGAR UI BERUBAH TANPA PERLU FETCH ULANG
      final index = list.indexWhere((item) => item.id == id);
      if (index != -1) {
        // Buat objek baru dengan status yang diperbarui
        list[index] = list[index].copyWith(status: status);
      }
    } catch (e) {
      debugPrint('ERROR UPDATE STATUS: $e');
      errorMessage = 'Gagal mengubah status: ${e.toString()}';
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePengaduan(int id) async {
  isLoading = true;
  notifyListeners();

  await _api.deletePengaduan(id);

  list.removeWhere((e) => e.id == id);

  isLoading = false;
  notifyListeners();
}
}
