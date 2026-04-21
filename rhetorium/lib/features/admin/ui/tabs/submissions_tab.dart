import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/core/supabase_client.dart';
import '../../providers/admin_providers.dart';
import '../../services/moderation_service.dart';

class SubmissionsTab extends ConsumerWidget {
  const SubmissionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(adminSubmissionsProvider);
    
    return submissionsAsync.when(
      data: (submissions) {
        if (submissions.isEmpty) {
          return const Center(child: Text('Nincs reakció.'));
        }
        return ListView.builder(
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final submission = submissions[index];
            final status = submission['status'] as String? ?? 'active';
            final isHidden = status == 'hidden';
            final isRemoved = status == 'removed';
            
            return ListTile(
              title: Text(
                submission['body']?.toString().substring(0, 50) ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Szerző: ${submission['profiles']?['display_name'] ?? 'ismeretlen'}'),
                  Text('Szituáció: ${submission['scenarios']?['title'] ?? 'ismeretlen'}'),
                  Text('Státusz: $status',
                    style: TextStyle(
                      color: isRemoved ? Colors.red : (isHidden ? Colors.orange : Colors.green),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => [
                  if (status == 'active') ...[
                    const PopupMenuItem(value: 'hide', child: Text('Elrejtés')),
                    const PopupMenuItem(value: 'remove', child: Text('Törlés')),
                  ],
                  if (isHidden) ...[
                    const PopupMenuItem(value: 'restore', child: Text('Visszaállítás')),
                    const PopupMenuItem(value: 'remove', child: Text('Törlés')),
                  ],
                  if (isRemoved)
                    const PopupMenuItem(value: 'restore', child: Text('Visszaállítás')),
                ],
                onSelected: (action) => _handleSubmissionAction(
                  context, ref, submission['id'], action,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Hiba: $error')),
    );
  }

  Future<void> _handleSubmissionAction(
    BuildContext context,
    WidgetRef ref,
    String submissionId,
    String action,
  ) async {
    try {
      switch (action) {
        case 'hide':
          await supabase.from('submissions').update({
            'status': 'hidden',
            'hidden_at': DateTime.now().toIso8601String(),
          }).eq('id', submissionId);
          await ModerationService.logModerationEvent(
            targetType: 'submission',
            targetId: submissionId,
            actionType: 'hide',
          );
          break;
        case 'remove':
          await supabase.from('submissions').update({
            'status': 'removed',
          }).eq('id', submissionId);
          await ModerationService.logModerationEvent(
            targetType: 'submission',
            targetId: submissionId,
            actionType: 'remove',
          );
          break;
        case 'restore':
          await supabase.from('submissions').update({
            'status': 'active',
            'hidden_at': null,
          }).eq('id', submissionId);
          await ModerationService.logModerationEvent(
            targetType: 'submission',
            targetId: submissionId,
            actionType: 'unhide',
          );
          break;
      }
      ref.invalidate(adminSubmissionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Művelet sikeres!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: $e')),
        );
      }
    }
  }
}
