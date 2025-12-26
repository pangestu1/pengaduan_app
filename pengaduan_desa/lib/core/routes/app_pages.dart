import 'package:flutter/material.dart';
import 'package:pengaduan_desa/core/routes/app_routes.dart';

import '../../ui/auth/login_page.dart';
import '../../ui/auth/register_page.dart';
import '../../ui/admin/admin_home_page.dart';
import '../../ui/warga/warga_home_page.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.register: (_) => const RegisterPage(),

    AppRoutes.adminHome: (_) => const AdminHomePage(),
    AppRoutes.wargaHome: (_) => const WargaHomePage(),
  };
}
