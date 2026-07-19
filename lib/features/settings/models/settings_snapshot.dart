import 'app_settings.dart';

/// Immutable, read-only representation of the current settings state.
///
/// Widgets consume ONLY this object. They must never access
/// [AppSettings] directly or modify settings state.
///
/// This is the widget contract — it defines exactly what the UI
/// can observe about the current settings.
class SettingsSnapshot {
  const SettingsSnapshot({
    required this.settings,
    required this.lastUpdated,
    required this.isDirty,
    required this.isInitialized,
  });

  /// The current application settings.
  final AppSettings settings;

  /// When the settings were last updated.
  final DateTime lastUpdated;

  /// Whether there are unsaved changes.
  final bool isDirty;

  /// Whether the settings engine has been initialized.
  final bool isInitialized;

  /// Theme mode convenience.
  ThemeModePreference get themeMode => settings.themeMode;

  /// Accent color convenience.
  String get accentColor => settings.accentColor;

  /// Notification settings convenience.
  NotificationSettings get notifications => settings.notifications;

  /// Sync settings convenience.
  SyncSettings get sync => settings.sync;

  /// Privacy settings convenience.
  PrivacySettings get privacy => settings.privacy;

  /// Learning preferences convenience.
  LearningPreferences get learning => settings.learning;

  /// AI provider preferences convenience.
  AIProviderPreferences get aiProvider => settings.aiProvider;

  /// Diagnostics settings convenience.
  DiagnosticsSettings get diagnostics => settings.diagnostics;

  /// Storage settings convenience.
  StorageSettings get storage => settings.storage;

  /// Accessibility settings convenience.
  AccessibilitySettings get accessibility => settings.accessibility;

  /// Language convenience.
  String get language => settings.language;

  /// Version info convenience.
  VersionInfo get version => settings.version;

  /// Onboarding status convenience.
  bool get onboardingComplete => settings.onboardingComplete;

  /// Whether dark mode is active.
  bool get isDarkMode => settings.themeMode == ThemeModePreference.dark;

  @override
  String toString() =>
      'SettingsSnapshot(isInitialized: $isInitialized, '
      'isDirty: $isDirty, themeMode: ${settings.themeMode.name})';

  /// Creates an uninitialized snapshot for use before engine init.
  factory SettingsSnapshot.uninitialized() => SettingsSnapshot(
        settings: const AppSettings(),
        lastUpdated: DateTime.now(),
        isDirty: false,
        isInitialized: false,
      );
}
