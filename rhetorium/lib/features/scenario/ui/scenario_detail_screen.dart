import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/core/supabase_client.dart';

final scenarioDetailProvider = FutureProvider.family((ref, String scenarioId) async {
  final response = await supabase
      .from('scenarios')
      .select()
      .eq('id', scenarioId)
      .single();
  return response;
});

final scenarioSubmissionsProvider = FutureProvider.family((ref, String scenarioId) async {
  final userId = supabase.auth.currentUser?.id;
  
  final submissions = await supabase
      .from('submissions')
      .select('*, profiles!author_id(display_name)')
      .eq('scenario_id', scenarioId)
      .eq('status', 'active')
      .order('created_at', ascending: true);

  final submissionsWithLikes = await Future.wait(
    (submissions as List).map((submission) async {
      final response = await supabase
          .from('submission_likes')
          .select()
          .eq('submission_id', submission['id'])
          .count(CountOption.exact);
      final likes = response.count;
      
      final myLike = userId != null
          ? await supabase
              .from('submission_likes')
              .select()
              .eq('submission_id', submission['id'])
              .eq('user_id', userId)
              .maybeSingle()
          : null;

      return {
        ...submission,
        'like_count': likes,
        'my_like': myLike != null,
      };
    }).toList(),
  );

  return submissionsWithLikes;
});

final mySubmissionProvider = FutureProvider.family((ref, String scenarioId) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return null;
  
  return await supabase
      .from('submissions')
      .select()
      .eq('scenario_id', scenarioId)
      .eq('author_id', userId)
      .maybeSingle();
});

class ScenarioDetailScreen extends ConsumerStatefulWidget {
  final String scenarioId;

  const ScenarioDetailScreen({super.key, required this.scenarioId});

  @override
  ConsumerState<ScenarioDetailScreen> createState() => _ScenarioDetailScreenState();
}

class _ScenarioDetailScreenState extends ConsumerState<ScenarioDetailScreen> {
  final _submissionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _submissionController.dispose();
    super.dispose();
  }

  Future<void> _submitReaction() async {
    if (_submissionController.text.trim().isEmpty) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      await supabase.from('submissions').insert({
        'scenario_id': widget.scenarioId,
        'author_id': supabase.auth.currentUser!.id,
        'body': _submissionController.text.trim(),
      });
      
      _submissionController.clear();
      ref.invalidate(scenarioSubmissionsProvider(widget.scenarioId));
      ref.invalidate(mySubmissionProvider(widget.scenarioId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _toggleLike(String submissionId, bool isLiked) async {
    final userId = supabase.auth.currentUser!.id;
    
    try {
      if (isLiked) {
        await supabase.from('submission_likes').delete().match({
          'submission_id': submissionId,
          'user_id': userId,
        });
      } else {
        await supabase.from('submission_likes').insert({
          'submission_id': submissionId,
          'user_id': userId,
        });
      }
      ref.invalidate(scenarioSubmissionsProvider(widget.scenarioId));
    } catch (e) {
      // Ignore errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenarioAsync = ref.watch(scenarioDetailProvider(widget.scenarioId));
    final mySubmissionAsync = ref.watch(mySubmissionProvider(widget.scenarioId));
    final submissionsAsync = ref.watch(scenarioSubmissionsProvider(widget.scenarioId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szituáció'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: scenarioAsync.when(
        data: (scenario) => Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenario['title'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    scenario['brief'] ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            mySubmissionAsync.when(
              data: (mySubmission) => mySubmission == null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _submissionController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Írd le a reakciódat...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitReaction,
                            child: _isSubmitting
                                ? const CircularProgressIndicator()
                                : const Text('Beküldés'),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        '✓ Már beküldtél egy reakciót erre a szituációra.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => const SizedBox(),
            ),
            const Divider(),
            Expanded(
              child: submissionsAsync.when(
                data: (submissions) {
                  if (submissions.isEmpty) {
                    return const Center(
                      child: Text('Még nincs reakció. Légy az első!'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      final isOwnSubmission = submission['author_id'] == supabase.auth.currentUser?.id;
                      final isLiked = submission['my_like'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    child: Text(
                                      ((submission['profiles']?['display_name'] ?? '?') as String).substring(0, 1).toUpperCase(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    submission['profiles']?['display_name'] ?? 'Ismeretlen',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(submission['body'] ?? ''),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.red : null,
                                    ),
                                    onPressed: isOwnSubmission
                                        ? null
                                        : () => _toggleLike(submission['id'], isLiked),
                                  ),
                                  Text('${submission['like_count'] ?? 0}'),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.flag_outlined),
                                    onPressed: () => _showReportDialog(submission['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Hiba: $error')),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Hiba: $error')),
      ),
    );
  }

  void _showReportDialog(String submissionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jelentés'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Spam'),
              onTap: () => _submitReport(submissionId, 'spam'),
            ),
            ListTile(
              title: const Text('Sértő tartalom'),
              onTap: () => _submitReport(submissionId, 'abuse'),
            ),
            ListTile(
              title: const Text('Gyűlöletkeltés'),
              onTap: () => _submitReport(submissionId, 'hate'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(String submissionId, String reasonCode) async {
    Navigator.of(context).pop();
    
    try {
      await supabase.from('reports').insert({
        'target_type': 'submission',
        'target_id': submissionId,
        'reporter_id': supabase.auth.currentUser!.id,
        'reason_code': reasonCode,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Köszönjük a jelentést!')),
        );
      }
    } catch (e) {
      // Ignore
    }
  }
}