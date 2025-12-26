import 'package:flutter/material.dart';
import 'package:pengaduan_desa/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/warga_bottom_nav.dart';
import 'warga_pengaduan_page.dart';
import 'warga_create_pengaduan_page.dart';
import 'warga_profile_page.dart';

class WargaHomePage extends StatefulWidget {
  const WargaHomePage({super.key});

  @override
  State<WargaHomePage> createState() => _WargaHomePageState();
}

class _WargaHomePageState extends State<WargaHomePage> {
  int _index = 0;

  final pages = const [
    WargaPengaduanPage(),
    WargaCreatePengaduanPage(),
    WargaProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_index == 0 ? 'Daftar Pengaduan' : _index == 1 ? 'Buat Pengaduan' : 'Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: WargaBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
