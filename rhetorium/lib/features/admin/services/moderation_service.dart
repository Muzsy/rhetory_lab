import '../../../shared/core/supabase_client.dart';

class ModerationService {
  static Future<void> logModerationEvent({
    required String targetType,
    required String targetId,
    required String actionType,
  }) async {
    await supabase.from('moderation_events').insert({
      'target_type': targetType,
      'target_id': targetId,
      'action_type': actionType,
      'actor_id': supabase.auth.currentUser!.id,
    });
  }
}
