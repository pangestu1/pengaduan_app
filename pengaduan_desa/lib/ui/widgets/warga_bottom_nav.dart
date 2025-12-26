import 'package:flutter/material.dart';

class WargaBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const WargaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Pengaduan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: 'Buat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
