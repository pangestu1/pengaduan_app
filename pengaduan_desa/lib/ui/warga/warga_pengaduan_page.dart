import 'package:flutter/material.dart';
import 'package:pengaduan_desa/provider/pengaduan_provider.dart';
import 'package:pengaduan_desa/ui/pengaduan_detail_page.dart';
import 'package:provider/provider.dart';

class WargaPengaduanPage extends StatefulWidget {
  const WargaPengaduanPage({super.key});

  @override
  State<WargaPengaduanPage> createState() => _WargaPengaduanPageState();
}

class _WargaPengaduanPageState extends State<WargaPengaduanPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<PengaduanProvider>().fetchPengaduan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PengaduanProvider>();

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchPengaduan(),
              child: provider.list.isEmpty
                  ? const Center(child: Text('Belum ada pengaduan'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.list.length,
                      itemBuilder: (_, i) {
                        final p = provider.list[i];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                          PengaduanDetailPage(pengaduan: p),
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(p.judul),
                              subtitle: Text(p.deskripsi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                              trailing: const Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
