class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dcvioxuxjkbsxccnoszl.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjdmlveHV4amtic3hjY25vc3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1ODUyNTMsImV4cCI6MjA5MjE2MTI1M30.vP3_iiY-WP-pRG64fvCXv1IEzOX6zRmAL9EblA6L0Wc',
  );
}
