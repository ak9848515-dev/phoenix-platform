/// Centralised constants for the Phoenix Supabase backend.
///
/// Every table, storage bucket, and key used to communicate with
/// Supabase lives here. No hardcoded strings inside services.
///
/// **Architecture:** Cloud constants are referenced by CloudRepository,
/// SyncEngines, BackupService, and MigrationService. Feature services
/// never read these constants directly.
abstract final class CloudConstants {
  CloudConstants._();

  // ── Database Tables ─────────────────────────────────────────────────

  /// Users table (auth.users is managed by Supabase Auth).
  static const String tableProfiles = 'profiles';

  /// User state table (xp, level, settings, etc.).
  static const String tableUserState = 'user_state';

  /// Academy / learning paths table.
  static const String tableAcademy = 'academy';

  /// Habits table.
  static const String tableHabits = 'habits';

  /// Habit entries table.
  static const String tableHabitEntries = 'habit_entries';

  /// Timeline events table.
  static const String tableTimelineEvents = 'timeline_events';

  /// Milestones table.
  static const String tableMilestones = 'milestones';

  /// Decision history table.
  static const String tableDecisionHistory = 'decision_history';

  /// Knowledge snapshot table.
  static const String tableKnowledgeSnapshot = 'knowledge_snapshot';

  /// Memory graph table.
  static const String tableMemoryGraph = 'memory_graph';

  // ── Storage Buckets ─────────────────────────────────────────────────

  /// Bucket for user profile photos.
  static const String bucketAvatars = 'avatars';

  /// Bucket for backup snapshots.
  static const String bucketBackups = 'backups';

  /// Bucket for exported data.
  static const String bucketExports = 'exports';

  // ── Shared Columns ─────────────────────────────────────────────────

  /// Every table MUST include these columns.
  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colVersion = 'version';
  static const String colLastSynced = 'last_synced';
  static const String colDeletedAt = 'deleted_at';

  // ── Storage Keys ───────────────────────────────────────────────────

  /// SharedPreferences / flutter_secure_storage key prefix.
  static const String keyPrefix = 'phx_';

  /// Secure storage key for the Supabase session persistence.
  static const String keySecureSession = '${keyPrefix}supabase_session';

  /// Local storage key for the migration flag (local → cloud).
  static const String keyMigrationComplete = '${keyPrefix}migration_complete';

  /// Local storage key for dirty-tracking flags.
  static const String keyDirtyFlags = '${keyPrefix}dirty_flags';

  /// Local storage key for the sync queue.
  static const String keySyncQueue = '${keyPrefix}sync_queue';

  /// Secure storage key for encryption key used in backups.
  static const String keyEncryptionKey = '${keyPrefix}encryption_key';

  // ── Auth Provider Identifiers ──────────────────────────────────────

  /// Supabase OAuth provider identifiers.
  static const String providerGoogle = 'google';
  static const String providerApple = 'apple';
}
