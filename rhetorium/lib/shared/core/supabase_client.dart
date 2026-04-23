import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Old top-level getter for backward compatibility if needed, 
// but we should prefer the provider.
SupabaseClient get supabase => Supabase.instance.client;

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
