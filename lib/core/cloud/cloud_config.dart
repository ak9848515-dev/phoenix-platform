/// Environment for cloud service configuration.
enum CloudEnvironment {
  development,
  staging,
  production;

  String get label {
    switch (this) {
      case CloudEnvironment.development:
        return 'Development';
      case CloudEnvironment.staging:
        return 'Staging';
      case CloudEnvironment.production:
        return 'Production';
    }
  }
}

/// Centralized cloud infrastructure configuration.
///
/// All Supabase connection strings, feature flags, and environment settings
/// are defined here. The configuration is loaded once during
/// [AppBootstrap.init] and accessible throughout the app.
///
/// **Architecture Rules:**
/// - Configuration isolated — no hardcoded URLs inside services
/// - Environment-aware — switches between dev/staging/production
/// - Feature flags — all cloud features can be toggled
class CloudConfig {
  CloudConfig._();

  // ── Environment ──────────────────────────────────────────────────────

  /// The current cloud environment.
  static CloudEnvironment environment = CloudEnvironment.development;

  /// Whether we are running in production mode.
  static bool get isProduction => environment == CloudEnvironment.production;

  /// Whether we are running in development mode.
  static bool get isDevelopment => environment == CloudEnvironment.development;

  // ── Supabase Connection ─────────────────────────────────────────────

  /// Supabase project URL.
  /// Override via `--dart-define=SUPABASE_URL=...` at build time.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// Supabase publishable (anonymous) API key.
  /// Override via `--dart-define=SUPABASE_PUBLISHABLE_KEY=...` at build time.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'your-anon-key',
  );

  /// Supabase project reference (used for storage URLs).
  static const String supabaseProjectRef = String.fromEnvironment(
    'SUPABASE_PROJECT_REF',
    defaultValue: 'your-project-ref',
  );

  // ── Feature Flags ───────────────────────────────────────────────────

  /// Whether authentication is enabled.
  static bool authEnabled = true;

  /// Whether cloud sync is enabled.
  static bool syncEnabled = true;

  /// Whether automatic backups are enabled.
  static bool autoBackupEnabled = true;

  /// Whether analytics collection is enabled.
  static bool analyticsEnabled = !isProduction;

  /// Whether crash reporting is enabled.
  static bool crashReportingEnabled = isProduction;

  /// Whether performance monitoring is enabled.
  static bool performanceMonitoringEnabled = isProduction;

  /// Feature flag for the Intelligence Layer.
  static bool intelligenceEnabled = true;

  // ── Sync Configuration ──────────────────────────────────────────────

  /// Interval in seconds between background sync operations.
  static const int syncIntervalSeconds = 300; // 5 minutes

  /// Maximum number of retry attempts for failed sync operations.
  static const int maxSyncRetries = 3;

  /// Maximum number of items in the offline queue.
  static const int maxOfflineQueueSize = 1000;

  // ── Backup Configuration ────────────────────────────────────────────

  /// Maximum number of automatic backups to retain.
  static const int maxAutoBackups = 10;

  /// Interval in seconds between automatic backups.
  static const int autoBackupIntervalSeconds = 86400; // 24 hours
}
