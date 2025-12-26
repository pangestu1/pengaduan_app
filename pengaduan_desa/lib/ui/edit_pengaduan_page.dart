import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pengaduan_desa/data/models/pengaduan_model.dart';
import 'package:pengaduan_desa/provider/pengaduan_provider.dart';
import 'package:provider/provider.dart';

class EditPengaduanPage extends StatefulWidget {
  final Pengaduan pengaduan;

  const EditPengaduanPage({super.key, required this.pengaduan});

  @override
  State<EditPengaduanPage> createState() => _EditPengaduanPageState();
}

class _EditPengaduanPageState extends State<EditPengaduanPage> {
  late TextEditingController judul;
  late TextEditingController deskripsi;
  XFile? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = picked);
    }
  }

  @override
  void initState() {
    judul = TextEditingController(text: widget.pengaduan.judul);
    deskripsi = TextEditingController(text: widget.pengaduan.deskripsi);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengaduan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: judul),
            const SizedBox(height: 12),
            TextField(controller: deskripsi, maxLines: 4),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
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
            ),

            ElevatedButton(
              onPressed: () async {
                await context.read<PengaduanProvider>().updatePengaduan(
                      id: widget.pengaduan.id,
                      judul: judul.text,
                      deskripsi: deskripsi.text,
                    );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
