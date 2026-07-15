import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session.dart';
import '../models/auth_user.dart';

/// Secure token and session storage backed by [FlutterSecureStorage].
///
/// Responsibilities:
/// - Persist access token, refresh token, and user profile
/// - Clear all auth data on logout
/// - Restore session on app restart
///
/// Never stores secrets in SharedPreferences or plain text.
class SecureStorageService {
  SecureStorageService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'phx_auth_access_token';
  static const _keyRefreshToken = 'phx_auth_refresh_token';
  static const _keyUser = 'phx_auth_user';
  static const _keyExpiresAt = 'phx_auth_expires_at';

  // ── Session Persistence ──────────────────────────────────────────

  /// Persists the full session to secure storage.
  Future<void> saveSession(AuthSession session) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: session.accessToken),
      if (session.refreshToken != null)
        _storage.write(key: _keyRefreshToken, value: session.refreshToken),
      _storage.write(key: _keyUser, value: session.user.toJson()),
      if (session.expiresAt != null)
        _storage.write(
          key: _keyExpiresAt,
          value: session.expiresAt!.toIso8601String(),
        ),
    ]);
  }

  /// Reads the persisted session from secure storage.
  ///
  /// Returns `null` if no session exists or data is corrupted.
  Future<AuthSession?> restoreSession() async {
    try {
      final accessToken = await _storage.read(key: _keyAccessToken);
      final refreshToken = await _storage.read(key: _keyRefreshToken);
      final userJson = await _storage.read(key: _keyUser);
      final expiresAtStr = await _storage.read(key: _keyExpiresAt);

      if (accessToken == null || accessToken.isEmpty) return null;
      if (userJson == null || userJson.isEmpty) return null;

      final user = AuthUser.fromJson(userJson);
      DateTime? expiresAt;
      if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
        expiresAt = DateTime.parse(expiresAtStr);
      }

      return AuthSession(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );
    } catch (e) {
      debugPrint('SecureStorageService: failed to restore session: $e');
      return null;
    }
  }

  /// Updates the access token and optional expiry in secure storage.
  Future<void> updateAccessToken(String accessToken, {DateTime? expiresAt}) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
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
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUser),
      _storage.delete(key: _keyExpiresAt),
    ]);
  }

  /// Whether a session exists in secure storage.
  Future<bool> hasSession() async {
    final token = await _storage.read(key: _keyAccessToken);
    return token != null && token.isNotEmpty;
  }

  // ── Diagnostics ─────────────────────────────────────────────────

  /// Returns diagnostic info about the secure storage state.
  /// Does NOT expose token values for security.
  Future<Map<String, dynamic>> diagnostics() async {
    final hasToken = await hasSession();
    final hasRefresh = await _storage.containsKey(key: _keyRefreshToken);
    final hasUser = await _storage.containsKey(key: _keyUser);
    return {
      'hasSession': hasToken,
      'hasRefreshToken': hasRefresh,
      'hasUser': hasUser,
    };
  }
}