import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/core/supabase_client.dart';
import '../../features/admin/providers/admin_providers.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    final client = _ref.read(supabaseClientProvider);
    _subscription = client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final client = _ref.read(supabaseClientProvider);
    final session = client.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    // 1. Ha nincs bejelentkezve és nem login/signup oldalon van -> login
    if (session == null) {
      return isLoggingIn ? null : '/login';
    }

    // 2. Ha be van jelentkezve de login/signup oldalon van -> home
    if (isLoggingIn) {
      return '/home';
    }

    // 3. Admin útvonalak védelme
    final isAdminPath = state.matchedLocation.startsWith('/admin');
    if (isAdminPath) {
      // Bevárjuk az admin státuszt ha még nem tudjuk
      final isAdmin = await _ref.read(isAdminProvider.future);
      
      if (!isAdmin) {
        // Ha nem admin, de admin útvonalra akar menni -> home
        return '/home';
      }
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
