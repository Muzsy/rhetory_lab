import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/core/supabase_client.dart';

final scenariosProvider = FutureProvider((ref) async {
  final response = await supabase
      .from('scenarios')
      .select()
      .eq('status', 'published')
      .order('created_at', ascending: false);
  return response;
});
