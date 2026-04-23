import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhetorium/features/auth/ui/login_screen.dart';
import 'package:rhetorium/shared/core/supabase_client.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_supabase.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        child: const LoginScreen(),
        overrides: [
          supabaseClientProvider.overrideWithValue(MockSupabaseClient()),
        ],
      ),
    );

    expect(find.text('Rhetorium'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Bejelentkezés'), findsOneWidget);
    expect(find.text('Nincs még fiókod? Regisztrálj!'), findsOneWidget);
  });
}
