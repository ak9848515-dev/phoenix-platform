import 'local_storage_service.dart';
import 'settings_repository.dart';
import 'storage_keys.dart';

class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository({
    this.storageService = const LocalStorageService(),
  });

  final LocalStorageService storageService;

  @override
  Future<UserPreferences> loadUserPreferences() async {
    final storageKeys = await storageService.getKeys();
    final preferenceKeys = storageKeys.where(
      (key) => key.startsWith(StorageKeys.userPreferencePrefix),
    );
    final preferences = <String, Object>{};

    for (final storageKey in preferenceKeys) {
      final value = await storageService.getValue(storageKey);
      if (value != null) {
        preferences[_preferenceName(storageKey)] = value;
      }
    }

    return UserPreferences(values: Map<String, Object>.unmodifiable(preferences));
  }

  @override
  Future<Object?> loadUserPreference(String key) {
    return storageService.getValue(_storageKey(key));
  }

  @override
  Future<void> saveBoolPreference(String key, bool value) {
    return storageService.setBool(_storageKey(key), value);
  }

  @override
  Future<void> saveDoublePreference(String key, double value) {
    return storageService.setDouble(_storageKey(key), value);
  }

  @override
  Future<void> saveIntPreference(String key, int value) {
    return storageService.setInt(_storageKey(key), value);
  }

  @override
  Future<void> saveStringPreference(String key, String value) {
    return storageService.setString(_storageKey(key), value);
  }

  @override
  Future<void> removeUserPreference(String key) {
    return storageService.remove(_storageKey(key));
  }

  String _storageKey(String key) {
    return '${StorageKeys.userPreferencePrefix}$key';
  }

  String _preferenceName(String storageKey) {
    return storageKey.replaceFirst(StorageKeys.userPreferencePrefix, '');
  }
}
