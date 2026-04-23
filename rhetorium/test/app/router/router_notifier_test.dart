import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rhetorium/app/router/router_notifier.dart';
import 'package:rhetorium/shared/core/supabase_client.dart';
import 'package:rhetorium/features/admin/providers/admin_providers.dart';
import '../../mocks/mock_supabase.dart';

class MockGoRouterState extends Fake implements GoRouterState {
  @override
  final String matchedLocation;

  MockGoRouterState(this.matchedLocation);
}

class MockAuthWithSession extends MockGoTrueClient {
  final Session? _session;
  @override
  Session? get currentSession => _session;
  @override
  User? get currentUser => _session?.user;

  MockAuthWithSession(this._session);
}

class MockSupabaseWithSession extends MockSupabaseClient {
  @override
  final GoTrueClient auth;
  MockSupabaseWithSession(Session? session) : auth = MockAuthWithSession(session);
}

void main() {
  group('RouterNotifier redirect tests', () {
    test('signed-out user -> protected route -> login redirect', () async {
      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(MockSupabaseWithSession(null)),
          isAdminProvider.overrideWith((ref) => Future.value(false)),
        ],
      );
      
      final notifier = container.read(routerNotifierProvider);
      final state = MockGoRouterState('/home');
      
      final result = await notifier.redirect(FakeBuildContext(), state);
      expect(result, '/login');
    });

    test('signed-in user -> login route -> home redirect', () async {
      final mockSession = Session(
        accessToken: 'abc',
        tokenType: 'bearer',
        user: User(
          id: '123',
          appMetadata: {},
          userMetadata: {},
          aud: 'aud',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      
      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(MockSupabaseWithSession(mockSession)),
          isAdminProvider.overrideWith((ref) => Future.value(false)),
        ],
      );
      
      final notifier = container.read(routerNotifierProvider);
      final state = MockGoRouterState('/login');
      
      final result = await notifier.redirect(FakeBuildContext(), state);
      expect(result, '/home');
    });

    test('non-admin user -> admin route -> home redirect', () async {
      final mockSession = Session(
        accessToken: 'abc',
        tokenType: 'bearer',
        user: User(
          id: '123',
          appMetadata: {},
          userMetadata: {},
          aud: 'aud',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      
      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(MockSupabaseWithSession(mockSession)),
          isAdminProvider.overrideWith((ref) => Future.value(false)),
        ],
      );
      
      final notifier = container.read(routerNotifierProvider);
      final state = MockGoRouterState('/admin');
      
      final result = await notifier.redirect(FakeBuildContext(), state);
      expect(result, '/home');
    });

    test('admin user -> admin route -> access granted', () async {
      final mockSession = Session(
        accessToken: 'abc',
        tokenType: 'bearer',
        user: User(
          id: '123',
          appMetadata: {},
          userMetadata: {},
          aud: 'aud',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      
      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(MockSupabaseWithSession(mockSession)),
          isAdminProvider.overrideWith((ref) => Future.value(true)),
        ],
      );
      
      final notifier = container.read(routerNotifierProvider);
      final state = MockGoRouterState('/admin');
      
      final result = await notifier.redirect(FakeBuildContext(), state);
      expect(result, isNull);
    });
  });
}

class FakeBuildContext extends Fake implements BuildContext {}
