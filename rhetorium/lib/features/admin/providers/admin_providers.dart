import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/core/supabase_client.dart';

final isAdminProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return false;
  
  final profile = await client
      .from('profiles')
      .select('is_admin')
      .eq('id', user.id)
      .maybeSingle();
  
  return profile?['is_admin'] == true;
});

final adminScenariosProvider = FutureProvider((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('scenarios')
      .select()
      .order('created_at', ascending: false);
  return response;
});

final adminSubmissionsProvider = FutureProvider((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('submissions')
      .select('*, profiles(display_name), scenarios(title)')
      .order('created_at', ascending: false);
  return response;
});

final adminUsersProvider = FutureProvider((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('profiles')
      .select()
      .order('created_at', ascending: false);
  return response;
});

final openReportsProvider = FutureProvider((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('reports')
      .select('*, profiles!reporter_id(display_name)')
      .eq('status', 'open')
      .order('created_at', ascending: false);
  return response;
});
