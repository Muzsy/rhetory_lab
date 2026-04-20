import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rhetorium/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow Tests', () {
    testWidgets('Register new account', (WidgetTester tester) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'test_$timestamp@test.com';
      final testPassword = 'TestPass${timestamp.toString().substring(5)}!';
      const testDisplayName = 'Teszt User';

      app.main();
      
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Rhetorium'), findsOneWidget);

      final signupButton = find.text('Nincs még fiókod? Regisztrálj!');
      expect(signupButton, findsOneWidget);
      await tester.tap(signupButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Regisztráció'), findsWidgets);

      await tester.enterText(find.byType(TextField).at(0), testDisplayName);
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField).at(1), testEmail);
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField).at(2), testPassword);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Regisztráció').last);
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Szituációk'), findsOneWidget);

      await Supabase.instance.client.auth.signOut();
    });
  });
}
