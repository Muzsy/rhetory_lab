/// Auth/profile bootstrap smoke script.
///
/// Default mode: dry-run (no Supabase write operations).
/// Execute mode requires explicit --execute flag.
///
/// Usage:
///   dart run lib/scripts/auth_profile_bootstrap_smoke.dart --dry-run
///   dart run lib/scripts/auth_profile_bootstrap_smoke.dart --execute
///
/// Environment variables (only presence is checked, values are never logged):
///   SUPABASE_URL               (required)
///   SUPABASE_ANON_KEY          (required)
///   SUPABASE_SERVICE_ROLE_KEY  (required for execute mode cleanup)
///   TEST_EMAIL_DOMAIN          (default: example.com)
///   SMOKE_EMAIL_PREFIX         (default: smoke)
///
/// Exit codes:
///   0 = PASS / DRY_RUN_PASS
///   1 = smoke failed
///   2 = missing required config
///   3 = cleanup failed
///   4 = execute mode not fully implemented / unsafe

import 'dart:io';

// ============================================================================
// Exit codes
// ============================================================================
const int exitPass = 0;
const int exitFailed = 1;
const int exitMissingConfig = 2;
const int exitCleanupFailed = 3;
const int exitExecuteNotImplemented = 4;

// ============================================================================
// Mode
// ============================================================================
enum RunMode { dryRun, execute }

// ============================================================================
// Config
// ============================================================================
class SmokeConfig {
  final String supabaseUrl;
  final String anonKey;
  final String serviceRoleKey;
  final String testEmailDomain;
  final String smokeEmailPrefix;

  const SmokeConfig({
    required this.supabaseUrl,
    required this.anonKey,
    required this.serviceRoleKey,
    required this.testEmailDomain,
    required this.smokeEmailPrefix,
  });

  static SmokeConfig fromEnvironment() {
    return SmokeConfig(
      supabaseUrl: Platform.environment['SUPABASE_URL'] ?? '',
      anonKey: Platform.environment['SUPABASE_ANON_KEY'] ?? '',
      serviceRoleKey: Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ?? '',
      testEmailDomain: Platform.environment['TEST_EMAIL_DOMAIN'] ?? 'example.com',
      smokeEmailPrefix: Platform.environment['SMOKE_EMAIL_PREFIX'] ?? 'smoke',
    );
  }

  /// Returns true only when all three Supabase env vars are present.
  /// SUPABASE_URL and SUPABASE_ANON_KEY are always required.
  /// SUPABASE_SERVICE_ROLE_KEY is required only for execute-mode cleanup.
  bool get hasRequiredEnvVars =>
      supabaseUrl.isNotEmpty && anonKey.isNotEmpty;

  bool get hasServiceRole => serviceRoleKey.isNotEmpty;
}

// ============================================================================
// Smoke identity
// ============================================================================
class SmokeIdentity {
  final String email;
  final String displayName;
  final String password;

  const SmokeIdentity({
    required this.email,
    required this.displayName,
    required this.password,
  });
}

// ============================================================================
// Identity generation — pure function, no side effects, unit-testable
// ============================================================================
SmokeIdentity generateSmokeIdentity({
  required String emailPrefix,
  required String emailDomain,
}) {
  final now = DateTime.now();
  final datePart =
      '${now.year}${_pad(now.month)}${_pad(now.day)}-${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
  final randPart = _randomAlphanumeric(8);
  final email = '$emailPrefix-$datePart-$randPart@$emailDomain';
  final displayName = 'SmokeBot-$datePart-$randPart';
  // Fixed dummy password for smoke testing — not a real credential
  const password = 'smoke-test-password-not-real';
  return SmokeIdentity(email: email, displayName: displayName, password: password);
}

String _pad(int n) => n.toString().padLeft(2, '0');

String _randomAlphanumeric(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  // Deterministic pseudo-random from microtime — good enough for smoke test
  final seed = DateTime.now().microsecondsSinceEpoch;
  final buf = StringBuffer();
  for (var i = 0; i < length; i++) {
    buf.write(chars[(seed + i * 7) % chars.length]);
  }
  return buf.toString();
}

// ============================================================================
// Precheck
// ============================================================================
class PrecheckResult {
  final String key;
  final bool present;

  const PrecheckResult({required this.key, required this.present});
}

List<PrecheckResult> runPrechecks(SmokeConfig config, RunMode mode) {
  final results = <PrecheckResult>[
    PrecheckResult(key: 'SUPABASE_URL', present: config.supabaseUrl.isNotEmpty),
    PrecheckResult(key: 'SUPABASE_ANON_KEY', present: config.anonKey.isNotEmpty),
    PrecheckResult(key: 'SUPABASE_SERVICE_ROLE_KEY', present: config.serviceRoleKey.isNotEmpty),
  ];

  for (final r in results) {
    _log('PRECHECK', '${r.key}: ${r.present ? "present" : "missing"}');
  }

  // Migration / trigger checks are always skipped in dry-run.
  // In execute mode they would be implemented with service role client.
  if (mode == RunMode.dryRun) {
    _log('PRECHECK', 'migration_007_verification: skipped_in_dry_run');
    _log('PRECHECK', 'trigger_on_auth_user_insert: skipped_in_dry_run');
    _log('PRECHECK', 'auth_settings: skipped_in_dry_run');
  } else {
    _log('PRECHECK', 'migration_007_verification: planned');
    _log('PRECHECK', 'trigger_on_auth_user_insert: planned');
    _log('PRECHECK', 'auth_settings: planned');
  }

  return results;
}

// ============================================================================
// Output
// ============================================================================
void _log(String tag, String message) {
  print('[$tag] $message');
}

void _logResult(String result) {
  print('[RESULT] $result');
}

// ============================================================================
// Execute mode — safety-gated skeleton
// ============================================================================
Future<int> runExecute(SmokeConfig config, SmokeIdentity identity) async {
  _log('EXECUTE', 'Would verify handle_new_user function in public schema');
  // TODO: Implement with Supabase service-role client SQL query
  // If not verified → throw UnimplementedError

  _log('EXECUTE', 'Would verify on_auth_user_insert trigger on auth.users');
  // TODO: Implement with Supabase service-role client SQL query

  _log('EXECUTE', 'Would call Supabase Auth signUp for ${identity.email}');
  // TODO: Implement actual signUp:
  //   final client = SupabaseClient(config.supabaseUrl, config.anonKey);
  //   final session = await client.auth.signUp(
  //     email: identity.email,
  //     password: identity.password,
  //     data: {'display_name': identity.displayName},
  //   );

  _log('EXECUTE', 'Would verify public.profiles row auto-created by trigger');

  _log('EXECUTE', 'Would verify profile display_name matches metadata');

  _log('EXECUTE', 'Would cleanup auth user and profile via service role');

  throw UnimplementedError(
    'Execute mode is not fully implemented. '
    'Do NOT run --execute without manual review and approval. '
    'Next step: implement signUp + profile verification + cleanup.',
  );
}

// ============================================================================
// Dry-run mode
// ============================================================================
Future<int> runDryRun(
    SmokeConfig config, SmokeIdentity identity, List<PrecheckResult> prechecks) async {
  _log('MODE', 'dry-run');

  _log('DRY-RUN', 'Would call signUp with display_name metadata: ${identity.displayName}');
  _log('DRY-RUN', 'Would verify public.profiles row exists after signUp');
  _log('DRY-RUN', 'Would verify profile display_name matches metadata');
  _log('DRY-RUN', 'Would cleanup smoke auth user and profile');

  final hasSrv = prechecks.any((r) =>
      r.key == 'SUPABASE_SERVICE_ROLE_KEY' && r.present);

  if (!hasSrv) {
    _log('PRECHECK', 'SUPABASE_SERVICE_ROLE_KEY: missing — cleanup will be skipped');
  } else {
    _log('DRY-RUN', 'Cleanup plan: DELETE from auth.users + DELETE from public.profiles');
  }

  return exitPass;
}

// ============================================================================
// Argument parsing
// ============================================================================
(RunMode, String?) parseArgs(List<String> args) {
  // Default: dry-run
  var mode = RunMode.dryRun;
  String? error;

  for (final arg in args) {
    if (arg == '--dry-run') {
      mode = RunMode.dryRun;
    } else if (arg == '--execute') {
      mode = RunMode.execute;
    } else if (arg.startsWith('--')) {
      print('[WARN] Unknown flag: $arg — ignoring');
    }
  }

  // Reject conflicting flags
  if (args.contains('--dry-run') && args.contains('--execute')) {
    return (RunMode.dryRun, 'Cannot combine --dry-run and --execute');
  }

  return (mode, error);
}

// ============================================================================
// Main
// ============================================================================
Future<int> main(List<String> args) async {
  final (mode, argError) = parseArgs(args);
  if (argError != null) {
    _log('ERROR', argError);
    return exitFailed;
  }

  _log('MODE', mode == RunMode.dryRun ? 'dry-run' : 'execute');

  // Load configuration from environment
  final config = SmokeConfig.fromEnvironment();

  // Generate smoke identity
  final identity = generateSmokeIdentity(
    emailPrefix: config.smokeEmailPrefix,
    emailDomain: config.testEmailDomain,
  );
  _log('IDENTITY', 'email=${identity.email}');
  _log('IDENTITY', 'display_name=${identity.displayName}');

  // Run prechecks
  final prechecks = runPrechecks(config, mode);

  // Validate required config
  if (!config.hasRequiredEnvVars) {
    _log('ERROR', 'Missing required environment variables (SUPABASE_URL, SUPABASE_ANON_KEY)');
    return exitMissingConfig;
  }

  // Mode-specific run
  if (mode == RunMode.dryRun) {
    final rc = await runDryRun(config, identity, prechecks);
    _logResult(rc == exitPass ? 'DRY_RUN_PASS' : 'DRY_RUN_FAIL');
    return rc;
  } else {
    // Execute mode requires service role for cleanup
    if (!config.hasServiceRole) {
      _log('ERROR', 'SUPABASE_SERVICE_ROLE_KEY is required for execute mode (used for cleanup)');
      return exitMissingConfig;
    }
    try {
      await runExecute(config, identity);
      _logResult('EXECUTE_PASS');
      return exitPass;
    } on UnimplementedError catch (e) {
      _log('ERROR', e.message ?? 'UnimplementedError with no message');
      _logResult('EXECUTE_NOT_IMPLEMENTED');
      return exitExecuteNotImplemented;
    } catch (e) {
      _log('ERROR', 'Unexpected error: $e');
      return exitFailed;
    }
  }
}