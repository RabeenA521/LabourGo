import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:labourgo_app/main.dart';
import 'package:labourgo_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('Shows splash then login when logged out', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const LabourGoApp());

    // Splash is shown immediately.
    expect(find.text('LabourGo'), findsOneWidget);

    // Allow splash animations + login check + transition to complete.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
