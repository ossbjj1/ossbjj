/// Environment configuration for OSS (Sprint 2).
///
/// Uses compile-time environment variables (--dart-define).
/// Example: flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co
///
/// IMPORTANT: Never commit secrets directly in code.
class Env {
  const Env._();

  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anon/public key.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Sentry DSN for error tracking (optional).
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// PostHog API key (optional).
  static const String posthogApiKey = String.fromEnvironment(
    'POSTHOG_API_KEY',
    defaultValue: '',
  );

  /// PostHog host URL (optional).
  static const String posthogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://app.posthog.com',
  );

  /// Check if Supabase is configured.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Check if Sentry is configured.
  static bool get hasSentry => sentryDsn.isNotEmpty;

  /// Check if PostHog is configured.
  static bool get hasPosthog => posthogApiKey.isNotEmpty;
}
