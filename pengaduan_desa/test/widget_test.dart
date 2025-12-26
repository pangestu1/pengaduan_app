import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pengaduan_desa/ui/auth/login_page.dart';
import 'helpers/test_app.dart';

void main() {
  testWidgets('LoginPage tampil dengan benar', (tester) async {
    await tester.pumpWidget(
      testApp(const LoginPage()),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}
