import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pengaduan_desa/provider/auth_provider.dart';

Widget testApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
      ),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}
