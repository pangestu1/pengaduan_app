import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pengaduan_desa/provider/pengaduan_provider.dart';
import 'package:provider/provider.dart';

class WargaCreatePengaduanPage extends StatefulWidget {
  const WargaCreatePengaduanPage({super.key});

  @override
  State<WargaCreatePengaduanPage> createState() =>
      _WargaCreatePengaduanPageState();
}

class _WargaCreatePengaduanPageState extends State<WargaCreatePengaduanPage> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  XFile? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PengaduanProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            /// JUDUL
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(hintText: 'Judul Pengaduan'),
            ),
            const SizedBox(height: 16),

            /// DESKRIPSI
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Deskripsi Pengaduan',
              ),
            ),
            const SizedBox(height: 16),

            /// IMAGE PICKER
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40),
                          SizedBox(height: 8),
                          Text('Pilih Foto'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(
                                _image!.path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Image.file(
                                File(_image!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            /// SUBMIT
            ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (_judulController.text.isEmpty ||
                          _deskripsiController.text.isEmpty ||
                          _image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field wajib diisi'),
                          ),
                        );
                        return;
                      }

                      await provider.createPengaduan(
                        judul: _judulController.text,
                        deskripsi: _deskripsiController.text,
                        image: _image!,
                      );

                      if (!mounted) return;

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengaduan berhasil dikirim'),
                        ),
                      );

                      _judulController.clear();
                      _deskripsiController.clear();
                      setState(() => _image = null);
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Kirim Pengaduan'),
            ),
          ],
        ),
      ),
    );
  }
}
