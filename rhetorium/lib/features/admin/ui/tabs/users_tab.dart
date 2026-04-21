import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/core/supabase_client.dart';
import '../../providers/admin_providers.dart';
import '../../services/moderation_service.dart';

class UsersTab extends ConsumerWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    
    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('Nincs felhasználó.'));
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isBanned = user['is_banned'] == true;
            
            return ListTile(
              title: Text(user['display_name'] ?? 'Névtelen'),
              subtitle: Text(user['is_admin'] == true ? 'Admin' : 'Felhasználó'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBanned)
                    Chip(
                      label: const Text('Tiltva'),
                      backgroundColor: Colors.red.shade100,
                    )
                  else
                    Chip(
                      label: const Text('Aktív'),
                      backgroundColor: Colors.green.shade100,
                    ),
                  const SizedBox(width: 8),
                  if (user['is_admin'] != true)
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        if (isBanned)
                          const PopupMenuItem(value: 'unban', child: Text('Feloldás')),
                        if (!isBanned)
                          const PopupMenuItem(value: 'ban', child: Text('Tiltás')),
                      ],
                      onSelected: (action) => _handleUserAction(
                        context, ref, user['id'], action,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Hiba: $error')),
    );
  }

  Future<void> _handleUserAction(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String action,
  ) async {
    try {
      switch (action) {
        case 'ban':
          await supabase.from('profiles').update({
            'is_banned': true,
          }).eq('id', userId);
          await ModerationService.logModerationEvent(
            targetType: 'user',
            targetId: userId,
            actionType: 'ban_user',
          );
          break;
        case 'unban':
          await supabase.from('profiles').update({
            'is_banned': false,
          }).eq('id', userId);
          await ModerationService.logModerationEvent(
            targetType: 'user',
            targetId: userId,
            actionType: 'unban_user',
          );
          break;
      }
      ref.invalidate(adminUsersProvider);
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
