import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rhetorium/main.dart' as app;
import 'package:rhetorium/env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow Tests', () {
    testWidgets('Register new account', (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'test_$timestamp@test.com';
      const testPassword = 'TestPassword123!';
      const testDisplayName = 'Teszt User';

      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Rhetorium'), findsOneWidget);

      final signupButton = find.text('Nincs még fiókod? Regisztrálj!');
      expect(signupButton, findsOneWidget);
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      expect(find.text('Regisztráció'), findsOneWidget);

      final displayNameField = find.byType(TextField).at(0);
      final emailField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);

      await tester.enterText(displayNameField, testDisplayName);
      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);

      await tester.tap(find.text('Regisztráció'));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.text('Szituációk'), findsOneWidget);

      await Supabase.instance.client.auth.signOut();
    });
  });
}
