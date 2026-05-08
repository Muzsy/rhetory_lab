import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhetorium/features/profile/providers/profile_provider.dart';
import 'package:rhetorium/shared/core/supabase_client.dart';
import '../../mocks/mock_supabase.dart';

void main() {
  group('currentUserProfileProvider', () {
    test('returns null when no user is logged in', () async {
      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(MockSupabaseClient()),
        ],
      );
      addTearDown(container.dispose);

      final profile =
          await container.read(currentUserProfileProvider.future);
      expect(profile, isNull);
    });
  });
}
