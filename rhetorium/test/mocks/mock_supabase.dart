import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSupabaseClient extends Fake implements SupabaseClient {
  @override
  final GoTrueClient auth = MockGoTrueClient();

  @override
  SupabaseQueryBuilder from(String table) => MockSupabaseQueryBuilder();
}

class MockGoTrueClient extends Fake implements GoTrueClient {
  @override
  Session? get currentSession => null;

  @override
  User? get currentUser => null;

  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
}

class MockSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  // Simple implementation to avoid type issues for now
}
