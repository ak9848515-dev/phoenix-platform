import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract secure storage boundary for API keys.
///
/// Implementations must encrypt all key values before persisting.
/// Widgets must never access this service directly — use
/// [ProviderConfigurationService] instead.
///
/// The production implementation, [FlutterSecureStorageService], uses
/// platform-native secure storage (Keychain on iOS, EncryptedSharedPreferences
/// on Android). The fallback [SharedPreferencesSecureStorageService] is
/// retained for development/testing environments.
abstract class SecureStorageService {
  /// Stores an encrypted API key for the given provider.
  Future<void> storeApiKey(String providerId, String encryptedKey);

  /// Reads the encrypted API key for the given provider, or `null` if none.
  Future<String?> readApiKey(String providerId);

  /// Deletes the API key for the given provider.
  Future<void> deleteApiKey(String providerId);

  /// Updates the API key for the given provider.
  Future<void> updateApiKey(String providerId, String encryptedKey);

  /// Whether an API key exists for the given provider.
  Future<bool> hasApiKey(String providerId);
}

/// SharedPreferences-backed implementation of [SecureStorageService].
///
/// API keys are stored with a simple Base64 obfuscation as a placeholder
/// for future platform-native secure storage integration.
///
/// **Note:** This is NOT cryptographically secure. For production use,
/// replace with flutter_secure_storage or platform Keychain/Keystore.
class SharedPreferencesSecureStorageService implements SecureStorageService {
  static const String _keyPrefix = 'phx_ai_key_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<void> storeApiKey(String providerId, String encryptedKey) async {
    final prefs = await _prefs;
    await prefs.setString('$_keyPrefix$providerId', encryptedKey);
  }

  @override
  Future<String?> readApiKey(String providerId) async {
    final prefs = await _prefs;
    return prefs.getString('$_keyPrefix$providerId');
  }

  @override
  Future<void> deleteApiKey(String providerId) async {
    final prefs = await _prefs;
    await prefs.remove('$_keyPrefix$providerId');
  }

  @override
  Future<void> updateApiKey(String providerId, String encryptedKey) async {
    final prefs = await _prefs;
    await prefs.setString('$_keyPrefix$providerId', encryptedKey);
  }

  @override
  Future<bool> hasApiKey(String providerId) async {
    final prefs = await _prefs;
    return prefs.containsKey('$_keyPrefix$providerId');
  }
}

/// Production implementation of [SecureStorageService] using
/// platform-native secure storage (Keychain / EncryptedSharedPreferences).
///
/// Uses [FlutterSecureStorage] which encrypts values at rest using
/// the platform's hardware-backed keystore when available.
class FlutterSecureStorageService implements SecureStorageService {
  static const String _keyPrefix = 'phx_ai_key_';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// One-time migration from SharedPreferences to FlutterSecureStorage.
  ///
  /// Reads any existing API keys stored by the old
  /// [SharedPreferencesSecureStorageService] and writes them to
  /// FlutterSecureStorage, then removes the SharedPreferences entries.
  /// Safe to call multiple times — only migrates keys not yet in
  /// FlutterSecureStorage.
  static Future<void> migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final oldKeys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    if (oldKeys.isEmpty) return;

    final storage = const FlutterSecureStorage();
    for (final oldKey in oldKeys) {
      final value = prefs.getString(oldKey);
      if (value != null && value.isNotEmpty) {
        final exists = await storage.containsKey(key: oldKey);
        if (!exists) {
          await storage.write(key: oldKey, value: value);
        }
      }
      await prefs.remove(oldKey);
    }
  }

  @override
  Future<void> storeApiKey(String providerId, String encryptedKey) async {
    await _storage.write(key: '$_keyPrefix$providerId', value: encryptedKey);
  }

  @override
  Future<String?> readApiKey(String providerId) async {
    return _storage.read(key: '$_keyPrefix$providerId');
  }

  @override
  Future<void> deleteApiKey(String providerId) async {
    await _storage.delete(key: '$_keyPrefix$providerId');
  }

  @override
  Future<void> updateApiKey(String providerId, String encryptedKey) async {
    await _storage.write(key: '$_keyPrefix$providerId', value: encryptedKey);
  }

  @override
  Future<bool> hasApiKey(String providerId) async {
    return _storage.containsKey(key: '$_keyPrefix$providerId');
  }
}
