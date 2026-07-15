import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show UserAttributes;

import '../cloud_config.dart' show CloudConfig;
import '../models/auth_provider.dart' show AuthProvider;
import '../models/user_session.dart' show UserSession;
import '../supabase_client.dart' show SupabaseClient;

/// Production authentication service backed by Supabase Auth.
class AuthenticationService extends ChangeNotifier {
  AuthenticationService();

  UserSession? _currentSession;
  UserSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession?.isValid ?? false;
  bool get isAnonymous => _currentSession?.isAnonymous ?? true;
  bool get isAvailable => CloudConfig.authEnabled;
  String get userEmail => _currentSession?.email ?? '';

  // ── Registration ────────────────────────────────────────────────────

  Future<UserSession> signUp({
    required String email,
    required String password,
  }) async {
    _assertAvailable();
    try {
      final response = await SupabaseClient.instance.auth.signUp(
        email: email,
        password: password,
      );
      if (response.session != null) {
        final session = _mapSession(response.session!);
        _currentSession = session;
        notifyListeners();
        return session;
      }
      if (response.user != null) {
        throw AuthenticationException(
            'Please verify your email before signing in.');
      }
      throw AuthenticationException('Registration failed.');
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException('Registration failed: $e');
    }
  }

  // ── Login ────────────────────────────────────────────────────────────

  Future<UserSession> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _assertAvailable();
    try {
      final response = await SupabaseClient.instance.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session == null) {
        throw AuthenticationException('Login failed.');
      }
      final session = _mapSession(response.session!);
      _currentSession = session;
      notifyListeners();
      return session;
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException('Login failed: $e');
    }
  }

  /// Initiates Google OAuth sign-in.
  ///
  /// **Platform setup required:** Configure your Supabase project's OAuth
  /// redirect URL and the app's deep link scheme in Android/iOS manifests.
  /// After the OAuth redirect completes, call [restoreSession] to obtain
  /// the authenticated session.
  Future<void> loginWithGoogle() async {
    _assertAvailable();
    // OAuth redirect flow requires platform-specific deep link setup.
    // See https://supabase.com/docs/guides/auth/social-login/auth-google
    throw UnsupportedError(
      'Google OAuth requires platform-specific URL scheme configuration. '
      'Call restoreSession() after the auth callback completes.',
    );
  }

  /// Initiates Apple OAuth sign-in (architecture ready).
  Future<void> loginWithApple() async {
    _assertAvailable();
    throw UnsupportedError(
      'Apple OAuth requires platform-specific URL scheme configuration. '
      'Call restoreSession() after the auth callback completes.',
    );
  }

  Future<UserSession> loginAnonymously() async {
    _assertAvailable();
    try {
      final response = await SupabaseClient.instance.auth.signInAnonymously();
      if (response.session == null) {
        throw AuthenticationException('Anonymous login failed.');
      }
      final s = response.session!;
      final session = UserSession(
        id: s.user.id,
        email: '',
        provider: AuthProvider.anonymous,
        accessToken: s.accessToken,
        refreshToken: s.refreshToken ?? '',
        expiresAt: s.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(s.expiresAt! * 1000)
            : DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        isAnonymous: true,
      );
      _currentSession = session;
      notifyListeners();
      return session;
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException('Anonymous login failed: $e');
    }
  }

  Future<UserSession> upgradeAnonymousAccount({
    required String email,
    required String password,
  }) async {
    if (!isAnonymous) {
      throw AuthenticationException('Only anonymous accounts can be upgraded.');
    }
    try {
      await SupabaseClient.instance.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
      return _currentSession!;
    } catch (e) {
      throw AuthenticationException('Account upgrade failed: $e');
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────

  Future<void> logout() async {
    if (_currentSession == null) return;
    try {
      await SupabaseClient.instance.auth.signOut();
    } catch (_) {}
    _currentSession = null;
    notifyListeners();
  }

  // ── Password Management ──────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    _assertAvailable();
    try {
      await SupabaseClient.instance.auth.resetPasswordForEmail(
        email,
        redirectTo: _getRedirectUrl(),
      );
    } catch (e) {
      throw AuthenticationException('Password reset failed: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await SupabaseClient.instance.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthenticationException('Password update failed: $e');
    }
  }

  // ── Email Verification ───────────────────────────────────────────────

  bool get isEmailVerified =>
      SupabaseClient.instance.auth.currentUser?.emailConfirmedAt != null;

  // ── Session Restore ──────────────────────────────────────────────────

  Future<bool> restoreSession() async {
    try {
      final restored = await SupabaseClient.instance.tryRefreshSession();
      if (!restored) return false;
      final session = SupabaseClient.instance.auth.currentSession;
      if (session == null) return false;
      _currentSession = _mapSession(session);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserSession> refreshToken() async {
    if (_currentSession == null) {
      throw AuthenticationException('No active session to refresh');
    }
    try {
      final refreshed = await SupabaseClient.instance.tryRefreshSession();
      if (!refreshed) {
        throw AuthenticationException('Token refresh failed.');
      }
      final session = SupabaseClient.instance.auth.currentSession;
      if (session == null) {
        throw AuthenticationException('Session lost after refresh.');
      }
      _currentSession = _mapSession(session);
      notifyListeners();
      return _currentSession!;
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException('Token refresh failed: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  void _assertAvailable() {
    if (!isAvailable) {
      throw AuthenticationException('Authentication is not available');
    }
  }

  UserSession _mapSession(dynamic session) {
    final user = session.user;
    final metadata = user?.userMetadata ?? {};
    return UserSession(
      id: user?.id ?? '',
      email: user?.email ?? '',
      displayName: metadata['full_name'] as String? ?? user?.email ?? '',
      photoUrl: metadata['avatar_url'] as String?,
      provider: _resolveProvider(session),
      accessToken: session.accessToken ?? '',
      refreshToken: session.refreshToken ?? '',
      expiresAt: session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : DateTime.now().add(const Duration(days: 30)),
      createdAt: user?.createdAt != null
          ? DateTime.parse(user!.createdAt!)
          : DateTime.now(),
      isAnonymous: user?.isAnonymous ?? true,
    );
  }

  AuthProvider _resolveProvider(dynamic session) {
    if (session.user?.isAnonymous ?? true) return AuthProvider.anonymous;
    final provider = session.user?.appMetadata?['provider'] as String?;
    switch (provider) {
      case 'google': return AuthProvider.google;
      case 'apple': return AuthProvider.apple;
      default: return AuthProvider.email;
    }
  }

  String _getRedirectUrl() => 'phoenixos://auth/callback';
}

class AuthenticationException implements Exception {
  AuthenticationException(this.message);
  final String message;
  @override
  String toString() => 'AuthenticationException: $message';
}
