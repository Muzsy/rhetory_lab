import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/core/supabase_client.dart';

final scenariosProvider = FutureProvider((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('scenarios')
      .select()
      .eq('status', 'published')
      .order('created_at', ascending: false);
  return response;
});
