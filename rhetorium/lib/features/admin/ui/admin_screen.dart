import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_providers.dart';
import 'tabs/scenarios_tab.dart';
import 'tabs/submissions_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/users_tab.dart';

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
              return const ScenariosTab();
            case 1:
              return const SubmissionsTab();
            case 2:
              return const ReportsTab();
            case 3:
              return const UsersTab();
            default:
              return const ScenariosTab();
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
