import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/core/supabase_client.dart';
import '../../providers/admin_providers.dart';
import '../../services/moderation_service.dart';
import 'dart:io';

class ScenariosTab extends ConsumerWidget {
  const ScenariosTab({super.key});

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
          await ModerationService.logModerationEvent(
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
          await ModerationService.logModerationEvent(
            targetType: 'scenario',
            targetId: scenarioId,
            actionType: 'hide',
          );
          break;
        case 'archive':
          await supabase.from('scenarios').update({
            'status': 'archived',
          }).eq('id', scenarioId);
          await ModerationService.logModerationEvent(
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
