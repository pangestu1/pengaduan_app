// pages/pengaduan_detail_page.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pengaduan_desa/ui/edit_pengaduan_page.dart';
import 'package:provider/provider.dart';

import '../data/models/pengaduan_model.dart';
import '../provider/pengaduan_provider.dart';
import '../core/services/token_storage.dart';

class PengaduanDetailPage extends StatelessWidget {
  final Pengaduan pengaduan;

  const PengaduanDetailPage({
    super.key,
    required this.pengaduan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Detail Pengaduan'),
  actions: [
    FutureBuilder<String?>(
      future: TokenStorage.getRole(),
      builder: (context, snapshot) {
        if (snapshot.data != 'warga') {
          return const SizedBox();
        }

        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditPengaduanPage(pengaduan: pengaduan),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        );
      },
    ),
  ],
),
      body: Consumer<PengaduanProvider>(
        builder: (context, provider, child) {
          // Cari pengaduan terbaru dari list provider berdasarkan ID
          final updatedPengaduan = provider.list.firstWhere(
            (item) => item.id == pengaduan.id,
            orElse: () => pengaduan, // Fallback ke original jika tidak ditemukan
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                updatedPengaduan.judul,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              /// FOTO
              if (updatedPengaduan.imageUrl != null && updatedPengaduan.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    updatedPengaduan.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Gambar tidak dapat dimuat'),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const CircularProgressIndicator(),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Tidak ada foto'),
                ),

              const SizedBox(height: 16),

              Text(
                updatedPengaduan.deskripsi.isNotEmpty ? updatedPengaduan.deskripsi : 'Tidak ada deskripsi',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(updatedPengaduan.status),
                    backgroundColor: _statusColor(updatedPengaduan.status),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              

              /// ======================
              /// ADMIN ONLY BUTTON
              /// ======================
              FutureBuilder<String?>(
                future: TokenStorage.getRole(),
                builder: (context, snapshot) {
                  // Hanya tampilkan jika role adalah admin
                  if (snapshot.data != 'admin') {
                    return const SizedBox();
                  }

                  // Tampilkan pesan error jika ada
                  if (provider.errorMessage != null) {
                    return Column(
                      children: [
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearErrorMessage();
                          },
                          child: const Text('Tutup Pesan Error'),
                        ),
                      ],
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.edit),
                      label: Text(provider.isLoading ? 'Memproses...' : 'Ubah Status'),
                      // Nonaktifkan tombol saat proses berlangsung
                      onPressed: provider.isLoading ? null : () => _showStatusDialog(context),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// ======================
  /// DIALOG PILIH STATUS
  /// ======================
  void _showStatusDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusItem(context, 'menunggu'),
            _statusItem(context, 'diproses'),
            _statusItem(context, 'selesai'),
          ],
        );
      },
    );
  }

  Widget _statusItem(BuildContext context, String status) {
    return ListTile(
      title: Text(
        status,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        // Tutup bottom sheet dulu
        Navigator.pop(context);

        // Tampilkan loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        try {
          // Panggil provider untuk update status
          await context.read<PengaduanProvider>().updateStatus(
                id: pengaduan.id,
                status: status,
              );

          // Tutup loading indicator
          if (context.mounted) Navigator.pop(context);

          // Tampilkan pesan sukses
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Status berhasil diubah menjadi "$status"'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // Tutup loading indicator
          if (context.mounted) Navigator.pop(context);

          // Tampilkan pesan error
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengubah status: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'menunggu':
        return Colors.orange.shade200;
      case 'diproses':
        return Colors.blue.shade200;
      case 'selesai':
        return Colors.green.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  void _confirmDelete(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Hapus Pengaduan'),
      content: const Text('Apakah Anda yakin ingin menghapus pengaduan ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);

            await context
                .read<PengaduanProvider>()
                .deletePengaduan(pengaduan.id);

            if (context.mounted) {
              Navigator.pop(context); // balik ke list
            }
          },
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}

}
