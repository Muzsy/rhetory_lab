import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/core/supabase_client.dart';
import '../../admin/providers/admin_providers.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = supabase.auth.currentUser;
    final profileAsync = ref.watch(currentUserProfileProvider);
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        children: [
          // Avatar + display name header
          profileAsync.when(
            data: (profile) {
              final displayName = profile?['display_name'] as String?;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(_firstChar(displayName ?? '')),
                ),
                title: Text(displayName?.isNotEmpty == true ? displayName! : '—'),
                subtitle: const Text('Megjelenítendő név'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Név szerkesztése',
                  onPressed: () => _showEditDisplayNameDialog(context, ref,
                      currentName: displayName ?? ''),
                ),
              );
            },
            loading: () => const ListTile(
              leading: CircleAvatar(child: CircularProgressIndicator()),
              title: Text('Betöltés...'),
            ),
            error: (err, st) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.error)),
              title: Text(user?.email ?? 'Ismeretlen'),
              subtitle: const Text('Nem sikerült betölteni a profilt'),
            ),
          ),

          // Email row
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(user?.email ?? '—'),
            subtitle: const Text('Email'),
          ),

          if (isAdmin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin felület'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/admin'),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Kijelentkezés'),
            onTap: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  String _firstChar(String s) {
    if (s.isEmpty) return '?';
    return s.substring(0, 1).toUpperCase();
  }

  void _showEditDisplayNameDialog(BuildContext context, WidgetRef ref,
      {required String currentName}) {
    final controller = TextEditingController(text: currentName);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Megjelenítendő név szerkesztése'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Név',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              await updateDisplayName(ref, newName);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Mentés'),
          ),
        ],
      ),
    );
  }
}
