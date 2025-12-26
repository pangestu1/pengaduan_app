import 'package:flutter/material.dart';
import 'package:pengaduan_desa/provider/pengaduan_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/summary_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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

    final total = provider.list.length;
    final menunggu =
        provider.list.where((e) => e.status == 'menunggu').length;
    final diproses =
        provider.list.where((e) => e.status == 'diproses').length;
    final selesai =
        provider.list.where((e) => e.status == 'selesai').length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.fetchPengaduan(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SummaryCard(
              title: 'Total Pengaduan',
              total: total,
              color: Colors.blue,
              icon: Icons.report,
            ),
            SummaryCard(
              title: 'Menunggu',
              total: menunggu,
              color: Colors.orange,
              icon: Icons.hourglass_empty,
            ),
            SummaryCard(
              title: 'Diproses',
              total: diproses,
              color: Colors.purple,
              icon: Icons.sync,
            ),
            SummaryCard(
              title: 'Selesai',
              total: selesai,
              color: Colors.green,
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }
}
