import 'dart:convert';

/// Immutable representation of user settings and preferences.
///
/// Stores application-level configuration that persists across sessions,
/// such as theme preference, notification settings, and onboarding state.
class UserSettings {
  const UserSettings({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.onboardingComplete = false,
    this.dailyReminderTime = '09:00',
    this.locale = 'en',
  });

  /// The preferred theme mode: 'light', 'dark', or 'system'.
  final String themeMode;

  /// Whether push notifications are enabled.
  final bool notificationsEnabled;

  /// Whether the onboarding flow has been completed.
  final bool onboardingComplete;

  /// Preferred daily reminder time in HH:mm format.
  final String dailyReminderTime;

  /// Preferred locale code (e.g. 'en', 'es').
  final String locale;

  /// Creates a copy of this settings object with the given fields replaced.
  UserSettings copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    bool? onboardingComplete,
    String? dailyReminderTime,
    String? locale,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      locale: locale ?? this.locale,
    );
  }

  /// Serializes these settings to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled,
      'onboardingComplete': onboardingComplete,
      'dailyReminderTime': dailyReminderTime,
      'locale': locale,
    };
  }

  /// Creates settings from a JSON-compatible map.
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      themeMode: map['themeMode'] as String? ?? 'system',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      onboardingComplete: map['onboardingComplete'] as bool? ?? false,
      dailyReminderTime: map['dailyReminderTime'] as String? ?? '09:00',
      locale: map['locale'] as String? ?? 'en',
    );
  }

  /// Serializes these settings to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates settings from a JSON string.
  factory UserSettings.fromJson(String source) =>
      UserSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.themeMode == themeMode &&
        other.notificationsEnabled == notificationsEnabled &&
        other.onboardingComplete == onboardingComplete &&
        other.dailyReminderTime == dailyReminderTime &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(
    themeMode,
    notificationsEnabled,
    onboardingComplete,
    dailyReminderTime,
    locale,
  );

  @override
  String toString() {
    return 'UserSettings(themeMode: $themeMode, '
        'notificationsEnabled: $notificationsEnabled, '
        'onboardingComplete: $onboardingComplete)';
  }
}
