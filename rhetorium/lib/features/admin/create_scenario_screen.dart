import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/core/supabase_client.dart';

class CreateScenarioScreen extends ConsumerStatefulWidget {
  const CreateScenarioScreen({super.key});

  @override
  ConsumerState<CreateScenarioScreen> createState() => _CreateScenarioScreenState();
}

class _CreateScenarioScreenState extends ConsumerState<CreateScenarioScreen> {
  final _titleController = TextEditingController();
  final _briefController = TextEditingController();
  bool _isPublished = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _briefController.dispose();
    super.dispose();
  }

  Future<void> _createScenario() async {
    if (_titleController.text.trim().isEmpty || _briefController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Töltsd ki a cím és brief mezőket!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser!.id;
      
      await supabase.from('scenarios').insert({
        'title': _titleController.text.trim(),
        'brief': _briefController.text.trim(),
        'created_by': userId,
        'status': _isPublished ? 'published' : 'draft',
        if (_isPublished) 'published_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Szituáció létrehozva!')),
        );
        context.go('/admin');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Új szituáció'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Cím',
                hintText: 'pl. Sportolói botrány',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _briefController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Brief',
                hintText: 'Írd le a szituációt részletesen...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Azonnal publikálás'),
              subtitle: const Text('Ha kikapcsolod, draft állapotban marad.'),
              value: _isPublished,
              onChanged: (value) => setState(() => _isPublished = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createScenario,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Létrehozás'),
            ),
          ],
        ),
      ),
    );
  }
}