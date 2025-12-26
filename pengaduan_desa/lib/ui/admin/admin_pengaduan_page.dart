import 'package:flutter/material.dart';
import 'package:pengaduan_desa/provider/pengaduan_provider.dart';
import 'package:pengaduan_desa/ui/pengaduan_detail_page.dart';
import 'package:provider/provider.dart';

class AdminPengaduanPage extends StatelessWidget {
  const AdminPengaduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PengaduanProvider>();

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.list.isEmpty
              ? const Center(child: Text('Belum ada pengaduan'))
              : ListView.builder(
                  itemCount: provider.list.length,
                  itemBuilder: (_, i) {
                    final p = provider.list[i];
                    return ListTile(
                      title: Text(
                        p.judul,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Status: ${p.status}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                  PengaduanDetailPage(pengaduan: p),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
