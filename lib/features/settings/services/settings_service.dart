import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/app_settings.dart';
import '../repository/settings_repository.dart';

/// Callback for settings change notifications.
typedef SettingsChangeCallback = void Function(AppSettings settings);

/// Business logic layer for application settings.
///
/// Coordinates between [SettingsRepository] and the [SettingsEngine].
/// Widgets must never access repositories directly.
///
/// Responsibilities:
/// - Update settings with validation
/// - Reset sections to defaults
/// - Notify listeners of changes
/// - Coordinate import/export
class SettingsService {
  SettingsService({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository();

  final SettingsRepository _repository;
  final PhoenixLogger _logger = PhoenixLogger.shared;
  final List<SettingsChangeCallback> _listeners = [];

  // ── Listeners ────────────────────────────────────────────────────

  /// Registers a listener for settings changes.
  void addListener(SettingsChangeCallback listener) {
    _listeners.add(listener);
  }

  /// Removes a previously registered listener.
  void removeListener(SettingsChangeCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(AppSettings settings) {
    for (final listener in _listeners) {
      listener(settings);
    }
  }

  // ── Load / Save ──────────────────────────────────────────────────

  /// Loads settings from the repository.
  ///
  /// Returns persisted settings, or defaults if none exist.
  Future<AppSettings> load() async {
    final settings = await _repository.load();
    return settings ?? const AppSettings();
  }

  /// Saves settings to the repository and notifies listeners.
  Future<void> save(AppSettings settings) async {
    await _repository.save(settings);
    _logger.info('Settings saved',
        category: LogCategory.config, source: 'SettingsService');
    _notifyListeners(settings);
  }

  // ── Update Sections ──────────────────────────────────────────────

  /// Updates the theme mode and persists.
  Future<AppSettings> updateThemeMode(
    AppSettings current,
    ThemeModePreference mode,
  ) async {
    final updated = current.copyWith(themeMode: mode);
    await save(updated);
    return updated;
  }

  /// Updates the accent color and persists.
  Future<AppSettings> updateAccentColor(
    AppSettings current,
    String color,
  ) async {
    final updated = current.copyWith(accentColor: color);
    await save(updated);
    return updated;
  }

  /// Updates notification settings and persists.
  Future<AppSettings> updateNotifications(
    AppSettings current,
    NotificationSettings notifications,
  ) async {
    final updated = current.copyWith(notifications: notifications);
    await save(updated);
    return updated;
  }

  /// Updates sync settings and persists.
  Future<AppSettings> updateSync(
    AppSettings current,
    SyncSettings sync,
  ) async {
    final updated = current.copyWith(sync: sync);
    await save(updated);
    return updated;
  }

  /// Updates privacy settings and persists.
  Future<AppSettings> updatePrivacy(
    AppSettings current,
    PrivacySettings privacy,
  ) async {
    final updated = current.copyWith(privacy: privacy);
    await save(updated);
    return updated;
  }

  /// Updates learning preferences and persists.
  Future<AppSettings> updateLearning(
    AppSettings current,
    LearningPreferences learning,
  ) async {
    final updated = current.copyWith(learning: learning);
    await save(updated);
    return updated;
  }

  /// Updates AI provider preferences and persists.
  Future<AppSettings> updateAIProvider(
    AppSettings current,
    AIProviderPreferences aiProvider,
  ) async {
    final updated = current.copyWith(aiProvider: aiProvider);
    await save(updated);
    return updated;
  }

  /// Updates accessibility settings and persists.
  Future<AppSettings> updateAccessibility(
    AppSettings current,
    AccessibilitySettings accessibility,
  ) async {
    final updated = current.copyWith(accessibility: accessibility);
    await save(updated);
    return updated;
  }

  /// Updates storage settings and persists.
  Future<AppSettings> updateStorage(
    AppSettings current,
    StorageSettings storage,
  ) async {
    final updated = current.copyWith(storage: storage);
    await save(updated);
    return updated;
  }

  /// Updates diagnostics settings and persists.
  Future<AppSettings> updateDiagnostics(
    AppSettings current,
    DiagnosticsSettings diagnostics,
  ) async {
    final updated = current.copyWith(diagnostics: diagnostics);
    await save(updated);
    return updated;
  }

  // ── Reset Sections ───────────────────────────────────────────────

  /// Resets all settings to defaults.
  Future<AppSettings> resetAll() async {
    await _repository.clear();
    const defaults = AppSettings();
    _logger.info('Settings reset to defaults',
        category: LogCategory.config, source: 'SettingsService');
    _notifyListeners(defaults);
    return defaults;
  }

  /// Resets only the theme section.
  Future<AppSettings> resetTheme(AppSettings current) async {
    return updateThemeMode(current, ThemeModePreference.system);
  }

  /// Resets only the notification section.
  Future<AppSettings> resetNotifications(AppSettings current) async {
    return updateNotifications(current, const NotificationSettings());
  }

  /// Resets only the privacy section.
  Future<AppSettings> resetPrivacy(AppSettings current) async {
    return updatePrivacy(current, const PrivacySettings());
  }

  // ── Import / Export ──────────────────────────────────────────────

  /// Exports settings as a JSON string.
  Future<String> exportJson() => _repository.exportJson();

  /// Imports settings from a JSON string.
  ///
  /// Returns `true` if the import was successful.
  Future<bool> importJson(String jsonString) async {
    final success = await _repository.importJson(jsonString);
    if (success) {
      final settings = await load();
      _notifyListeners(settings);
      _logger.info('Settings imported successfully',
          category: LogCategory.config, source: 'SettingsService');
    }
    return success;
  }

  // ── Validation ───────────────────────────────────────────────────

  /// Validates a setting value and returns an error message, or `null`.
  static String? validateAccentColor(String color) {
    if (color.isEmpty) return 'Accent color cannot be empty';
    return null;
  }

  /// Validates a sync interval in minutes.
  static String? validateSyncInterval(int minutes) {
    if (minutes < 1) return 'Interval must be at least 1 minute';
    if (minutes > 1440) return 'Interval cannot exceed 1440 minutes (24h)';
    return null;
  }

  /// Validates a daily goal in minutes.
  static String? validateDailyGoal(int minutes) {
    if (minutes < 5) return 'Goal must be at least 5 minutes';
    if (minutes > 480) return 'Goal cannot exceed 480 minutes (8h)';
    return null;
  }
}
