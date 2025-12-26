import 'package:flutter/material.dart';
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
