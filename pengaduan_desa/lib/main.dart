import 'package:flutter/material.dart';
import 'package:pengaduan_desa/provider/auth_provider.dart';
import 'package:pengaduan_desa/provider/pengaduan_provider.dart';
import 'package:pengaduan_desa/ui/auth/login_page.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/config/app_theme.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PengaduanProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme(),
      initialRoute: AppRoutes.login,
      routes: AppPages.routes,
      home: LoginPage(),
    );
  }
}
