import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhetorium/features/auth/ui/signup_screen.dart';
import 'package:rhetorium/shared/core/supabase_client.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_supabase.dart';

void main() {
  testWidgets('SignupScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        child: const SignupScreen(),
        overrides: [
          supabaseClientProvider.overrideWithValue(MockSupabaseClient()),
        ],
      ),
    );

    expect(find.text('Regisztráció'), findsWidgets); // Title + Button
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Megjelenítendő név'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Jelszó'), findsOneWidget);
    expect(find.text('Már van fiókod? Jelentkezz be!'), findsOneWidget);
  });
}
