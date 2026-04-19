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
      .select('*, profiles(display_name)')
      .eq('status', 'open')
      .order('created_at', ascending: false);
  return response;
});

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Új szituáció létrehozása'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/admin/create-scenario'),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Szituációk',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _ScenariosList(),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Jelentések',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _ReportsList(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Hiba: $error')),
      ),
    );
  }
}

class _ScenariosList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(adminScenariosProvider);
    
    return scenariosAsync.when(
      data: (scenarios) {
        if (scenarios.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Nincs szituáció.'),
          );
        }
        return Column(
          children: scenarios.map<Widget>((scenario) {
            return ListTile(
              title: Text(scenario['title'] ?? ''),
              subtitle: Text('Státusz: ${scenario['status']}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  if (scenario['status'] != 'published')
                    const PopupMenuItem(value: 'publish', child: Text('Publikálás')),
                  if (scenario['status'] == 'published')
                    const PopupMenuItem(value: 'hide', child: Text('Elrejtés')),
                  const PopupMenuItem(value: 'delete', child: Text('Törlés')),
                ],
                onSelected: (action) => _handleScenarioAction(
                  context,
                  ref,
                  scenario['id'],
                  action,
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Hiba: $error'),
      ),
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
          break;
        case 'hide':
          await supabase.from('scenarios').update({
            'status': 'hidden',
            'hidden_at': DateTime.now().toIso8601String(),
          }).eq('id', scenarioId);
          break;
        case 'delete':
          await supabase.from('scenarios').update({
            'status': 'archived',
          }).eq('id', scenarioId);
          break;
      }
      ref.refresh(adminScenariosProvider);
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(openReportsProvider);
    
    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Nincs függő jelentés.'),
          );
        }
        return Column(
          children: reports.map<Widget>((report) {
            return ListTile(
              title: Text('Típus: ${report['target_type']}'),
              subtitle: Text('Ok: ${report['reason_code']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _resolveReport(context, ref, report['id'], true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _resolveReport(context, ref, report['id'], false),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Hiba: $error'),
      ),
    );
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
      ref.refresh(openReportsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: $e')),
        );
      }
    }
  }
}