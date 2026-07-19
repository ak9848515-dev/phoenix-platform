import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/authenticated_user.dart';
import '../models/user_session.dart';

/// Secure token and session storage backed by [FlutterSecureStorage].
///
/// Responsibilities:
/// - Persist ID token, refresh token, and user profile
/// - Clear all auth data on logout
/// - Restore session on app restart
///
/// Never stores secrets in SharedPreferences or plain text.
class SecureStorageService {
  SecureStorageService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyIdToken = 'phx_auth_id_token';
  static const _keyRefreshToken = 'phx_auth_refresh_token';
  static const _keyUser = 'phx_auth_user';
  static const _keyExpiresAt = 'phx_auth_expires_at';
  static const _keyLastAuth = 'phx_auth_last_authenticated';

  // ── Session Persistence ──────────────────────────────────────────

  /// Persists the full session to secure storage.
  Future<void> saveSession(UserSession session) async {
    await Future.wait([
      if (session.idToken != null)
        _storage.write(key: _keyIdToken, value: session.idToken!),
      if (session.refreshToken != null)
        _storage.write(key: _keyRefreshToken, value: session.refreshToken!),
      _storage.write(key: _keyUser, value: session.user.toJson()),
      if (session.expiresAt != null)
        _storage.write(
          key: _keyExpiresAt,
          value: session.expiresAt!.toIso8601String(),
        ),
      _storage.write(
        key: _keyLastAuth,
        value: session.lastAuthenticatedAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      ),
    ]);
  }

  /// Reads the persisted session from secure storage.
  ///
  /// Returns `null` if no session exists or data is corrupted.
  Future<UserSession?> restoreSession() async {
    try {
      final idToken = await _storage.read(key: _keyIdToken);
      final refreshToken = await _storage.read(key: _keyRefreshToken);
      final userJson = await _storage.read(key: _keyUser);
      final expiresAtStr = await _storage.read(key: _keyExpiresAt);
      final lastAuthStr = await _storage.read(key: _keyLastAuth);

      if (idToken == null && userJson == null) return null;
      if (userJson == null || userJson.isEmpty) return null;

      final user = AuthenticatedUser.fromJson(userJson);
      DateTime? expiresAt;
      if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
        expiresAt = DateTime.parse(expiresAtStr);
      }
      DateTime? lastAuth;
      if (lastAuthStr != null && lastAuthStr.isNotEmpty) {
        lastAuth = DateTime.parse(lastAuthStr);
      }

      return UserSession(
        user: user,
        idToken: idToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
        lastAuthenticatedAt: lastAuth,
      );
    } catch (e) {
      debugPrint('SecureStorageService: failed to restore session: $e');
      return null;
    }
  }

  /// Updates the ID token in secure storage.
  Future<void> updateIdToken(String idToken, {DateTime? expiresAt}) async {
    await _storage.write(key: _keyIdToken, value: idToken);
    if (expiresAt != null) {
      await _storage.write(
        key: _keyExpiresAt,
        value: expiresAt.toIso8601String(),
      );
    }
  }

  /// Updates the refresh token in secure storage.
  Future<void> updateRefreshToken(String refreshToken) async {
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Clears all auth data from secure storage (logout).
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyIdToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUser),
      _storage.delete(key: _keyExpiresAt),
      _storage.delete(key: _keyLastAuth),
    ]);
  }

  /// Whether a session exists in secure storage.
  Future<bool> hasSession() async {
    final userJson = await _storage.read(key: _keyUser);
    return userJson != null && userJson.isNotEmpty;
  }

  // ── Diagnostics ─────────────────────────────────────────────────

  /// Returns diagnostic info about the secure storage state.
  /// Does NOT expose token values for security.
  Future<Map<String, dynamic>> diagnostics() async {
    final hasUser = await _storage.containsKey(key: _keyUser);
    final hasToken = await _storage.containsKey(key: _keyIdToken);
    final hasRefresh = await _storage.containsKey(key: _keyRefreshToken);
    return {
      'hasUser': hasUser,
      'hasIdToken': hasToken,
      'hasRefreshToken': hasRefresh,
    };
  }
}