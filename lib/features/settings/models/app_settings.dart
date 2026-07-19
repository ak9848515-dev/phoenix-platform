/// Theme mode preference.
enum ThemeModePreference {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case ThemeModePreference.light:
        return 'Light';
      case ThemeModePreference.dark:
        return 'Dark';
      case ThemeModePreference.system:
        return 'System';
    }
  }
}

/// Notification preferences.
class NotificationSettings {
  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.inAppEnabled = true,
    this.dailyReminderTime = '09:00',
    this.weeklyDigest = false,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool inAppEnabled;
  final String dailyReminderTime;
  final bool weeklyDigest;

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? inAppEnabled,
    String? dailyReminderTime,
    bool? weeklyDigest,
  }) =>
      NotificationSettings(
        pushEnabled: pushEnabled ?? this.pushEnabled,
        emailEnabled: emailEnabled ?? this.emailEnabled,
        inAppEnabled: inAppEnabled ?? this.inAppEnabled,
        dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
        weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      );

  Map<String, dynamic> toMap() => {
        'pushEnabled': pushEnabled,
        'emailEnabled': emailEnabled,
        'inAppEnabled': inAppEnabled,
        'dailyReminderTime': dailyReminderTime,
        'weeklyDigest': weeklyDigest,
      };

  factory NotificationSettings.fromMap(Map<String, dynamic> map) =>
      NotificationSettings(
        pushEnabled: map['pushEnabled'] as bool? ?? true,
        emailEnabled: map['emailEnabled'] as bool? ?? false,
        inAppEnabled: map['inAppEnabled'] as bool? ?? true,
        dailyReminderTime: map['dailyReminderTime'] as String? ?? '09:00',
        weeklyDigest: map['weeklyDigest'] as bool? ?? false,
      );
}

/// Sync preferences.
class SyncSettings {
  const SyncSettings({
    this.autoSync = true,
    this.syncIntervalMinutes = 15,
    this.syncOnWifiOnly = true,
  });

  final bool autoSync;
  final int syncIntervalMinutes;
  final bool syncOnWifiOnly;

  SyncSettings copyWith({
    bool? autoSync,
    int? syncIntervalMinutes,
    bool? syncOnWifiOnly,
  }) =>
      SyncSettings(
        autoSync: autoSync ?? this.autoSync,
        syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
        syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      );

  Map<String, dynamic> toMap() => {
        'autoSync': autoSync,
        'syncIntervalMinutes': syncIntervalMinutes,
        'syncOnWifiOnly': syncOnWifiOnly,
      };

  factory SyncSettings.fromMap(Map<String, dynamic> map) => SyncSettings(
        autoSync: map['autoSync'] as bool? ?? true,
        syncIntervalMinutes: map['syncIntervalMinutes'] as int? ?? 15,
        syncOnWifiOnly: map['syncOnWifiOnly'] as bool? ?? true,
      );
}

/// Privacy preferences.
class PrivacySettings {
  const PrivacySettings({
    this.collectAnalytics = true,
    this.shareUsageData = false,
    this.crashReporting = true,
  });

  final bool collectAnalytics;
  final bool shareUsageData;
  final bool crashReporting;

  PrivacySettings copyWith({
    bool? collectAnalytics,
    bool? shareUsageData,
    bool? crashReporting,
  }) =>
      PrivacySettings(
        collectAnalytics: collectAnalytics ?? this.collectAnalytics,
        shareUsageData: shareUsageData ?? this.shareUsageData,
        crashReporting: crashReporting ?? this.crashReporting,
      );

  Map<String, dynamic> toMap() => {
        'collectAnalytics': collectAnalytics,
        'shareUsageData': shareUsageData,
        'crashReporting': crashReporting,
      };

  factory PrivacySettings.fromMap(Map<String, dynamic> map) => PrivacySettings(
        collectAnalytics: map['collectAnalytics'] as bool? ?? true,
        shareUsageData: map['shareUsageData'] as bool? ?? false,
        crashReporting: map['crashReporting'] as bool? ?? true,
      );
}

/// Learning preferences.
class LearningPreferences {
  const LearningPreferences({
    this.preferredLearningStyle = 'visual',
    this.dailyGoalMinutes = 30,
    this.showHints = true,
    this.autoplayVideos = false,
  });

  final String preferredLearningStyle;
  final int dailyGoalMinutes;
  final bool showHints;
  final bool autoplayVideos;

  LearningPreferences copyWith({
    String? preferredLearningStyle,
    int? dailyGoalMinutes,
    bool? showHints,
    bool? autoplayVideos,
  }) =>
      LearningPreferences(
        preferredLearningStyle:
            preferredLearningStyle ?? this.preferredLearningStyle,
        dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
        showHints: showHints ?? this.showHints,
        autoplayVideos: autoplayVideos ?? this.autoplayVideos,
      );

  Map<String, dynamic> toMap() => {
        'preferredLearningStyle': preferredLearningStyle,
        'dailyGoalMinutes': dailyGoalMinutes,
        'showHints': showHints,
        'autoplayVideos': autoplayVideos,
      };

  factory LearningPreferences.fromMap(Map<String, dynamic> map) =>
      LearningPreferences(
        preferredLearningStyle:
            map['preferredLearningStyle'] as String? ?? 'visual',
        dailyGoalMinutes: map['dailyGoalMinutes'] as int? ?? 30,
        showHints: map['showHints'] as bool? ?? true,
        autoplayVideos: map['autoplayVideos'] as bool? ?? false,
      );
}

/// AI provider preferences stored in settings.
class AIProviderPreferences {
  const AIProviderPreferences({
    this.defaultProvider,
    this.enableOfflineMode = false,
    this.enableFallback = true,
  });

  final String? defaultProvider;
  final bool enableOfflineMode;
  final bool enableFallback;

  AIProviderPreferences copyWith({
    String? defaultProvider,
    bool? enableOfflineMode,
    bool? enableFallback,
  }) =>
      AIProviderPreferences(
        defaultProvider: defaultProvider ?? this.defaultProvider,
        enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
        enableFallback: enableFallback ?? this.enableFallback,
      );

  Map<String, dynamic> toMap() => {
        'defaultProvider': defaultProvider,
        'enableOfflineMode': enableOfflineMode,
        'enableFallback': enableFallback,
      };

  factory AIProviderPreferences.fromMap(Map<String, dynamic> map) =>
      AIProviderPreferences(
        defaultProvider: map['defaultProvider'] as String?,
        enableOfflineMode: map['enableOfflineMode'] as bool? ?? false,
        enableFallback: map['enableFallback'] as bool? ?? true,
      );
}

/// Accessibility preferences.
class AccessibilitySettings {
  const AccessibilitySettings({
    this.fontScale = 1.0,
    this.reduceMotion = false,
    this.highContrast = false,
  });

  final double fontScale;
  final bool reduceMotion;
  final bool highContrast;

  AccessibilitySettings copyWith({
    double? fontScale,
    bool? reduceMotion,
    bool? highContrast,
  }) =>
      AccessibilitySettings(
        fontScale: fontScale ?? this.fontScale,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        highContrast: highContrast ?? this.highContrast,
      );

  Map<String, dynamic> toMap() => {
        'fontScale': fontScale,
        'reduceMotion': reduceMotion,
        'highContrast': highContrast,
      };

  factory AccessibilitySettings.fromMap(Map<String, dynamic> map) =>
      AccessibilitySettings(
        fontScale: (map['fontScale'] as num?)?.toDouble() ?? 1.0,
        reduceMotion: map['reduceMotion'] as bool? ?? false,
        highContrast: map['highContrast'] as bool? ?? false,
      );
}

/// Diagnostics preferences.
class DiagnosticsSettings {
  const DiagnosticsSettings({
    this.crashReporting = true,
    this.debugLogging = false,
    this.performanceMonitoring = false,
  });

  final bool crashReporting;
  final bool debugLogging;
  final bool performanceMonitoring;

  DiagnosticsSettings copyWith({
    bool? crashReporting,
    bool? debugLogging,
    bool? performanceMonitoring,
  }) =>
      DiagnosticsSettings(
        crashReporting: crashReporting ?? this.crashReporting,
        debugLogging: debugLogging ?? this.debugLogging,
        performanceMonitoring:
            performanceMonitoring ?? this.performanceMonitoring,
      );

  Map<String, dynamic> toMap() => {
        'crashReporting': crashReporting,
        'debugLogging': debugLogging,
        'performanceMonitoring': performanceMonitoring,
      };

  factory DiagnosticsSettings.fromMap(Map<String, dynamic> map) =>
      DiagnosticsSettings(
        crashReporting: map['crashReporting'] as bool? ?? true,
        debugLogging: map['debugLogging'] as bool? ?? false,
        performanceMonitoring:
            map['performanceMonitoring'] as bool? ?? false,
      );
}

/// Storage management settings.
class StorageSettings {
  const StorageSettings({
    this.cacheSizeMB = 0,
    this.autoClearCache = false,
    this.keepLocalBackups = true,
  });

  final int cacheSizeMB;
  final bool autoClearCache;
  final bool keepLocalBackups;

  StorageSettings copyWith({
    int? cacheSizeMB,
    bool? autoClearCache,
    bool? keepLocalBackups,
  }) =>
      StorageSettings(
        cacheSizeMB: cacheSizeMB ?? this.cacheSizeMB,
        autoClearCache: autoClearCache ?? this.autoClearCache,
        keepLocalBackups: keepLocalBackups ?? this.keepLocalBackups,
      );

  Map<String, dynamic> toMap() => {
        'cacheSizeMB': cacheSizeMB,
        'autoClearCache': autoClearCache,
        'keepLocalBackups': keepLocalBackups,
      };

  factory StorageSettings.fromMap(Map<String, dynamic> map) => StorageSettings(
        cacheSizeMB: map['cacheSizeMB'] as int? ?? 0,
        autoClearCache: map['autoClearCache'] as bool? ?? false,
        keepLocalBackups: map['keepLocalBackups'] as bool? ?? true,
      );
}

/// Version metadata.
class VersionInfo {
  const VersionInfo({
    this.appVersion = '2.6.0',
    this.buildNumber = '1',
    this.lastUpdateCheck,
  });

  final String appVersion;
  final String buildNumber;
  final DateTime? lastUpdateCheck;

  VersionInfo copyWith({
    String? appVersion,
    String? buildNumber,
    DateTime? lastUpdateCheck,
  }) =>
      VersionInfo(
        appVersion: appVersion ?? this.appVersion,
        buildNumber: buildNumber ?? this.buildNumber,
        lastUpdateCheck: lastUpdateCheck ?? this.lastUpdateCheck,
      );

  Map<String, dynamic> toMap() => {
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'lastUpdateCheck': lastUpdateCheck?.toIso8601String(),
      };

  factory VersionInfo.fromMap(Map<String, dynamic> map) => VersionInfo(
        appVersion: map['appVersion'] as String? ?? '2.6.0',
        buildNumber: map['buildNumber'] as String? ?? '1',
        lastUpdateCheck: map['lastUpdateCheck'] != null
            ? DateTime.parse(map['lastUpdateCheck'] as String)
            : null,
      );
}

/// Complete application settings model.
///
/// Immutable. Use [copyWith] to produce modified instances.
/// Widgets must never access this directly — use [SettingsSnapshot] instead.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeModePreference.system,
    this.accentColor = 'default',
    this.notifications = const NotificationSettings(),
    this.sync = const SyncSettings(),
    this.privacy = const PrivacySettings(),
    this.learning = const LearningPreferences(),
    this.aiProvider = const AIProviderPreferences(),
    this.diagnostics = const DiagnosticsSettings(),
    this.storage = const StorageSettings(),
    this.accessibility = const AccessibilitySettings(),
    this.language = 'en',
    this.locale = 'en-US',
    this.version = const VersionInfo(),
    this.onboardingComplete = false,
  });

  /// Theme mode: light, dark, or system.
  final ThemeModePreference themeMode;

  /// Accent color identifier.
  final String accentColor;

  /// Notification preferences.
  final NotificationSettings notifications;

  /// Sync preferences.
  final SyncSettings sync;

  /// Privacy preferences.
  final PrivacySettings privacy;

  /// Learning preferences.
  final LearningPreferences learning;

  /// AI provider preferences.
  final AIProviderPreferences aiProvider;

  /// Diagnostics preferences.
  final DiagnosticsSettings diagnostics;

  /// Storage management.
  final StorageSettings storage;

  /// Accessibility preferences.
  final AccessibilitySettings accessibility;

  /// Language code (e.g. 'en', 'es').
  final String language;

  /// Locale code (e.g. 'en-US').
  final String locale;

  /// Version metadata.
  final VersionInfo version;

  /// Whether onboarding has been completed.
  final bool onboardingComplete;

  /// Creates a copy with the given fields replaced.
  AppSettings copyWith({
    ThemeModePreference? themeMode,
    String? accentColor,
    NotificationSettings? notifications,
    SyncSettings? sync,
    PrivacySettings? privacy,
    LearningPreferences? learning,
    AIProviderPreferences? aiProvider,
    DiagnosticsSettings? diagnostics,
    StorageSettings? storage,
    AccessibilitySettings? accessibility,
    String? language,
    String? locale,
    VersionInfo? version,
    bool? onboardingComplete,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        accentColor: accentColor ?? this.accentColor,
        notifications: notifications ?? this.notifications,
        sync: sync ?? this.sync,
        privacy: privacy ?? this.privacy,
        learning: learning ?? this.learning,
        aiProvider: aiProvider ?? this.aiProvider,
        diagnostics: diagnostics ?? this.diagnostics,
        storage: storage ?? this.storage,
        accessibility: accessibility ?? this.accessibility,
        language: language ?? this.language,
        locale: locale ?? this.locale,
        version: version ?? this.version,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.name,
        'accentColor': accentColor,
        'notifications': notifications.toMap(),
        'sync': sync.toMap(),
        'privacy': privacy.toMap(),
        'learning': learning.toMap(),
        'aiProvider': aiProvider.toMap(),
        'diagnostics': diagnostics.toMap(),
        'storage': storage.toMap(),
        'accessibility': accessibility.toMap(),
        'language': language,
        'locale': locale,
        'version': version.toMap(),
        'onboardingComplete': onboardingComplete,
      };

  /// Deserializes from a JSON-compatible map.
  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        themeMode: ThemeModePreference.values.firstWhere(
          (e) => e.name == (map['themeMode'] as String? ?? 'system'),
          orElse: () => ThemeModePreference.system,
        ),
        accentColor: map['accentColor'] as String? ?? 'default',
        notifications: map['notifications'] != null
            ? NotificationSettings.fromMap(
                Map<String, dynamic>.from(map['notifications'] as Map))
            : const NotificationSettings(),
        sync: map['sync'] != null
            ? SyncSettings.fromMap(
                Map<String, dynamic>.from(map['sync'] as Map))
            : const SyncSettings(),
        privacy: map['privacy'] != null
            ? PrivacySettings.fromMap(
                Map<String, dynamic>.from(map['privacy'] as Map))
            : const PrivacySettings(),
        learning: map['learning'] != null
            ? LearningPreferences.fromMap(
                Map<String, dynamic>.from(map['learning'] as Map))
            : const LearningPreferences(),
        aiProvider: map['aiProvider'] != null
            ? AIProviderPreferences.fromMap(
                Map<String, dynamic>.from(map['aiProvider'] as Map))
            : const AIProviderPreferences(),
        diagnostics: map['diagnostics'] != null
            ? DiagnosticsSettings.fromMap(
                Map<String, dynamic>.from(map['diagnostics'] as Map))
            : const DiagnosticsSettings(),
        storage: map['storage'] != null
            ? StorageSettings.fromMap(
                Map<String, dynamic>.from(map['storage'] as Map))
            : const StorageSettings(),
        accessibility: map['accessibility'] != null
            ? AccessibilitySettings.fromMap(
                Map<String, dynamic>.from(map['accessibility'] as Map))
            : const AccessibilitySettings(),
        language: map['language'] as String? ?? 'en',
        locale: map['locale'] as String? ?? 'en-US',
        version: map['version'] != null
            ? VersionInfo.fromMap(
                Map<String, dynamic>.from(map['version'] as Map))
            : const VersionInfo(),
        onboardingComplete: map['onboardingComplete'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);

  @override
  String toString() =>
      'AppSettings(themeMode: ${themeMode.name}, '
      'language: $language, onboardingComplete: $onboardingComplete)';
}
