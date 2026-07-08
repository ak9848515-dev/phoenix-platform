import 'package:shared_preferences/shared_preferences.dart';

/// Thin adapter around shared_preferences for local key-value persistence.
class LocalStorageService {
  const LocalStorageService();

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<bool?> getBool(String key) async {
    final preferences = await _preferences;
    return preferences.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    final preferences = await _preferences;
    await preferences.setBool(key, value);
  }

  Future<double?> getDouble(String key) async {
    final preferences = await _preferences;
    return preferences.getDouble(key);
  }

  Future<void> setDouble(String key, double value) async {
    final preferences = await _preferences;
    await preferences.setDouble(key, value);
  }

  Future<int?> getInt(String key) async {
    final preferences = await _preferences;
    return preferences.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final preferences = await _preferences;
    await preferences.setInt(key, value);
  }

  Future<String?> getString(String key) async {
    final preferences = await _preferences;
    return preferences.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final preferences = await _preferences;
    await preferences.setString(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    final preferences = await _preferences;
    return preferences.getStringList(key) ?? <String>[];
  }

  Future<void> setStringList(String key, List<String> value) async {
    final preferences = await _preferences;
    await preferences.setStringList(key, value);
  }

  Future<Object?> getValue(String key) async {
    final preferences = await _preferences;
    return preferences.get(key);
  }

  Future<Set<String>> getKeys() async {
    final preferences = await _preferences;
    return preferences.getKeys();
  }

  Future<void> remove(String key) async {
    final preferences = await _preferences;
    await preferences.remove(key);
  }
}
