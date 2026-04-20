import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/core/supabase_client.dart';

final adminScenariosProvider = FutureProvider((ref) async {
  final response = await supabase
      .from('scenarios')
      .select()
      .order('created_at', ascending: false);
  return response;
});

final adminSubmissionsProvider = FutureProvider((ref) async {
  final response = await supabase
      .from('submissions')
      .select('*, profiles(display_name), scenarios(title)')
      .order('created_at', ascending: false);
  return response;
});

final adminUsersProvider = FutureProvider((ref) async {
  final response = await supabase
      .from('profiles')
      .select()
      .order('created_at', ascending: false);
  return response;
});

final isAdminProvider = FutureProvider((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return false;
  
  final profile = await supabase
      .from('profiles')
      .select('is_admin')
      .eq('id', user.id)
      .maybeSingle();
  
  return profile?['is_admin'] == true;
});

final openReportsProvider = FutureProvider((ref) async {
  final response = await supabase
      .from('reports')
      .select('*, profiles!reporter_id(display_name)')
      .eq('status', 'open')
      .order('created_at', ascending: false);
  return response;
});

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdminAsync = ref.watch(isAdminProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: isAdminAsync.when(
        data: (isAdmin) {
          if (!isAdmin) {
            return const Center(
              child: Text('Nincs jogosultságod az admin felülethez.'),
            );
          }
          switch (_selectedIndex) {
            case 0:
              return _ScenariosList(ref: ref);
            case 1:
              return _SubmissionsList(ref: ref);
            case 2:
              return _ReportsList(ref: ref);
            case 3:
              return _UsersList(ref: ref);
            default:
              return _ScenariosList(ref: ref);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Hiba: $error')),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Szituációk',
          ),
          NavigationDestination(
            icon: Icon(Icons.comment_outlined),
            label: 'Reakciók',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            label: 'Jelentések',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            label: 'Userek',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.go('/admin/create-scenario'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _ScenariosList extends ConsumerWidget {
  final WidgetRef ref;
  
  const _ScenariosList({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(adminScenariosProvider);
    
    return scenariosAsync.when(
      data: (scenarios) {
        if (scenarios.isEmpty) {
          return const Center(child: Text('Nincs szituáció.'));
        }
        return ListView.builder(
          itemCount: scenarios.length,
          itemBuilder: (context, index) {
            final scenario = scenarios[index];
            return ListTile(
              title: Text(scenario['title'] ?? ''),
              subtitle: Text('Státusz: ${scenario['status']}'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (context) => [
                  if (scenario['status'] == 'draft')
                    const PopupMenuItem(value: 'publish', child: Text('Publikálás')),
                  if (scenario['status'] == 'published')
                    const PopupMenuItem(value: 'hide', child: Text('Elrejtés')),
                  if (scenario['status'] == 'hidden')
                    const PopupMenuItem(value: 'publish', child: Text('Visszaállítás')),
                  const PopupMenuItem(value: 'archive', child: Text('Archiválás')),
                ],
                onSelected: (action) => _handleScenarioAction(
                  context, ref, scenario['id'], action,
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

  Future<void> _handleScenarioAction(
    BuildContext context,
    WidgetRef ref,
    String scenarioId,
    String action,
  ) async {
    try {
      switch (action) {
        case 'publish':
          await supabase.from('scenarios').update({
            'status': 'published',
            'published_at': DateTime.now().toIso8601String(),
          }).eq('id', scenarioId);
          await _logModerationEvent(
            targetType: 'scenario',
            targetId: scenarioId,
            actionType: 'unhide',
          );
          break;
        case 'hide':
          await supabase.from('scenarios').update({
            'status': 'hidden',
            'hidden_at': DateTime.now().toIso8601String(),
          }).eq('id', scenarioId);
          await _logModerationEvent(
            targetType: 'scenario',
            targetId: scenarioId,
            actionType: 'hide',
          );
          break;
        case 'archive':
          await supabase.from('scenarios').update({
            'status': 'archived',
          }).eq('id', scenarioId);
          await _logModerationEvent(
            targetType: 'scenario',
            targetId: scenarioId,
            actionType: 'archive',
          );
          break;
      }
      ref.invalidate(adminScenariosProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: $e')),
        );
      }
    }
  }
}

class _SubmissionsList extends ConsumerWidget {
  final WidgetRef ref;
  
  const _SubmissionsList({required this.ref});

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
          await _logModerationEvent(
            targetType: 'submission',
            targetId: submissionId,
            actionType: 'hide',
          );
          break;
        case 'remove':
          await supabase.from('submissions').update({
            'status': 'removed',
          }).eq('id', submissionId);
          await _logModerationEvent(
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
          await _logModerationEvent(
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

class _ReportsList extends ConsumerWidget {
  final WidgetRef ref;
  
  const _ReportsList({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(openReportsProvider);
    
    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return const Center(child: Text('Nincs függő jelentés.'));
        }
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return ListTile(
              title: Text('Típus: ${report['target_type']}'),
              subtitle: Text('Ok: ${report['reason_code']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    tooltip: 'Moderálás',
                    onPressed: () => _showModerationDialog(context, ref, report),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: 'Elfogadás',
                    onPressed: () => _resolveReport(context, ref, report['id'], true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Elutasítás',
                    onPressed: () => _resolveReport(context, ref, report['id'], false),
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

  void _showModerationDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Moderálás'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Típus: ${report['target_type']}'),
            Text('ID: ${report['target_id']}'),
            Text('Ok: ${report['reason_code']}'),
            if (report['details'] != null)
              Text('Részletek: ${report['details']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mégse'),
          ),
          if (report['target_type'] == 'submission')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _moderateSubmission(
                  context, ref, report['target_id'], 'hide',
                  resolveReportId: report['id'],
                );
              },
              child: const Text('Elrejtés'),
            ),
          if (report['target_type'] == 'submission')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _moderateSubmission(
                  context, ref, report['target_id'], 'remove',
                  resolveReportId: report['id'],
                );
              },
              child: const Text('Törlés'),
            ),
        ],
      ),
    );
  }

  Future<void> _moderateSubmission(
    BuildContext context,
    WidgetRef ref,
    String submissionId,
    String action, {
    String? resolveReportId,
  }) async {
    try {
      final newStatus = action == 'hide' ? 'hidden' : 'removed';
      await supabase.from('submissions').update({
        'status': newStatus,
        if (action == 'hide') 'hidden_at': DateTime.now().toIso8601String(),
      }).eq('id', submissionId);
      await _logModerationEvent(
        targetType: 'submission',
        targetId: submissionId,
        actionType: action == 'hide' ? 'hide' : 'remove',
      );

      if (resolveReportId != null) {
        await supabase.from('reports').update({
          'status': 'resolved',
          'handled_by': supabase.auth.currentUser!.id,
          'handled_at': DateTime.now().toIso8601String(),
        }).eq('id', resolveReportId);
        await _logModerationEvent(
          targetType: 'report',
          targetId: resolveReportId,
          actionType: 'resolve_report',
        );
        ref.invalidate(openReportsProvider);
      }

      ref.invalidate(adminSubmissionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Moderálás sikeres!')),
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

  Future<void> _resolveReport(
    BuildContext context,
    WidgetRef ref,
    String reportId,
    bool resolved,
  ) async {
    try {
      await supabase.from('reports').update({
        'status': resolved ? 'resolved' : 'dismissed',
        'handled_by': supabase.auth.currentUser!.id,
        'handled_at': DateTime.now().toIso8601String(),
      }).eq('id', reportId);
      await _logModerationEvent(
        targetType: 'report',
        targetId: reportId,
        actionType: resolved ? 'resolve_report' : 'dismiss_report',
      );
      ref.invalidate(openReportsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: $e')),
        );
      }
    }
  }
}

class _UsersList extends ConsumerWidget {
  final WidgetRef ref;
  
  const _UsersList({required this.ref});

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
          await _logModerationEvent(
            targetType: 'user',
            targetId: userId,
            actionType: 'ban_user',
          );
          break;
        case 'unban':
          await supabase.from('profiles').update({
            'is_banned': false,
          }).eq('id', userId);
          await _logModerationEvent(
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

Future<void> _logModerationEvent({
  required String targetType,
  required String targetId,
  required String actionType,
}) async {
  try {
    await supabase.from('moderation_events').insert({
      'target_type': targetType,
      'target_id': targetId,
      'action_type': actionType,
      'actor_id': supabase.auth.currentUser!.id,
    });
  } catch (e) {
    // Silent fail for logging - don't break the main flow
    debugPrint('Moderation event logging failed: $e');
  }
}
