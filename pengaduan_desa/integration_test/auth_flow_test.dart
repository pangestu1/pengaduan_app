import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pengaduan_desa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User bisa login dan masuk dashboard', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // input email
    await tester.enterText(
      find.byKey(const Key('email')),
      'sigit@test.com.com',
    );

    // input password
    await tester.enterText(
      find.byKey(const Key('password')),
      'sigit123',
    );

    // tap login
    await tester.tap(find.byKey(const Key('login_btn')));
    await tester.pumpAndSettle();

    // verifikasi masuk dashboard
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
