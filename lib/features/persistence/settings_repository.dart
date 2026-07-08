class UserPreferences {
  const UserPreferences({required this.values});

  final Map<String, Object> values;

  Object? operator [](String key) => values[key];
}

abstract class SettingsRepository {
  Future<UserPreferences> loadUserPreferences();

  Future<Object?> loadUserPreference(String key);

  Future<void> saveBoolPreference(String key, bool value);

  Future<void> saveDoublePreference(String key, double value);

  Future<void> saveIntPreference(String key, int value);

  Future<void> saveStringPreference(String key, String value);

  Future<void> removeUserPreference(String key);
}
