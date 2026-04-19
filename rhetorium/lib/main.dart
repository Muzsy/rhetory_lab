import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'env.dart';
import 'app/app.dart';

class HiveLocalStorage extends LocalStorage {
  const HiveLocalStorage();

  @override
  Future<void> initialize() async {
    await Hive.initFlutter('auth');
  }

  @override
  Future<String?> accessToken() async {
    final box = Hive.box('auth');
    return box.get('supabase_auth_token') as String?;
  }

  @override
  Future<bool> hasAccessToken() async {
    final box = Hive.box('auth');
    return box.containsKey('supabase_auth_token');
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    final box = Hive.box('auth');
    await box.put('supabase_auth_token', persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    final box = Hive.box('auth');
    await box.delete('supabase_auth_token');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter('auth');
  
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: const HiveLocalStorage(),
    ),
  );
  
  runApp(
    const ProviderScope(
      child: RhetoriumApp(),
    ),
  );
}