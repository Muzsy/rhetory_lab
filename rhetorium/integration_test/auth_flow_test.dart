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
      const testPassword = 'TestPassword123!';
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

    testWidgets('Login with existing account', (WidgetTester tester) async {
      const testEmail = 'akos.muller@gmail.com';
      const testPassword = 'beeL3-fegor';

      app.main();
      
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Rhetorium'), findsOneWidget);

      final loginButton = find.text('Bejelentkezés');
      expect(loginButton, findsOneWidget);
      
      await tester.enterText(find.byType(TextField).at(0), testEmail);
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField).at(1), testPassword);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Bejelentkezés'));
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Szituációk'), findsOneWidget);
    });

    testWidgets('Create scenario after login', (WidgetTester tester) async {
      const testEmail = 'akos.muller@gmail.com';
      const testPassword = 'beeL3-fegor';

      app.main();
      
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Rhetorium'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), testEmail);
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField).at(1), testPassword);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Bejelentkezés'));
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Szituációk'), findsOneWidget);

      final adminNavItem = find.text('Admin');
      if (adminNavItem.evaluate().isNotEmpty) {
        await tester.tap(adminNavItem);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Admin Felület'), findsOneWidget);

        final createButton = find.text('Új szituáció létrehozása');
        expect(createButton, findsOneWidget);
        await tester.tap(createButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(find.text('Új szituáció'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextField, 'Cím'),
          'Teszt szituáció integrációs tesztből',
        );
        await tester.pump(const Duration(seconds: 1));

        await tester.enterText(
          find.widgetWithText(TextField, 'Brief'),
          'Ez egy teszt brief szöveg az integrációs teszthez.',
        );
        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Létrehozás'));
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle(const Duration(seconds: 10));

        expect(find.text('Admin Felület'), findsOneWidget);
      }
    });
  });
}
