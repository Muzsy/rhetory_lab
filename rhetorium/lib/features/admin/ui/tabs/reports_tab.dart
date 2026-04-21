import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/core/supabase_client.dart';
import '../../providers/admin_providers.dart';
import '../../services/moderation_service.dart';

class ReportsTab extends ConsumerWidget {
  const ReportsTab({super.key});

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
            final reporterName = report['profiles']?['display_name'] ?? report['reporter_id'] ?? 'Ismeretlen';
            return ListTile(
              title: Text('${report['target_type']} jelentés (felhasználó: $reporterName)'),
              subtitle: Text('ID: ${report['target_id']}\nOk: ${report['reason_code']}'),
              isThreeLine: true,
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
            Text('Bejelentő: ${report['profiles']?['display_name'] ?? report['reporter_id'] ?? 'Ismeretlen'}'),
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
      await ModerationService.logModerationEvent(
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
        await ModerationService.logModerationEvent(
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
      await ModerationService.logModerationEvent(
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
