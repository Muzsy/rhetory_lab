import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/scenario_providers.dart';

class ScenarioListScreen extends ConsumerWidget {
  const ScenarioListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenariosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szituációk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(scenariosProvider),
          ),
        ],
      ),
      body: scenariosAsync.when(
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return const Center(
              child: Text('Még nincs szituáció. Légy az első!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scenarios.length,
            itemBuilder: (context, index) {
              final scenario = scenarios[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    scenario['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    (scenario['brief'] ?? '').toString().length > 100
                        ? '${scenario['brief'].toString().substring(0, 100)}...'
                        : scenario['brief'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/scenario/${scenario['id']}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hiba: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(scenariosProvider),
                child: const Text('Újra'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
