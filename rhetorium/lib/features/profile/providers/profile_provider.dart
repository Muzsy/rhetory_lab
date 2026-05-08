import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/core/supabase_client.dart';

/// Profile row fetched from public.profiles for the currently authenticated user.
final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  final profile = await client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  return profile;
});

/// Updates the display_name of the current user's profile.
Future<void> updateDisplayName(WidgetRef ref, String displayName) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  await client
      .from('profiles')
      .update({'display_name': displayName})
      .eq('id', user.id);

  // Invalidate so next read picks up the new value.
  ref.invalidate(currentUserProfileProvider);
}
