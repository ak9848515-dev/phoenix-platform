import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'secure_storage_service.dart';

/// Authentication states for the app-wide auth flow.
enum AuthState {
  /// Initial state — auth check has not yet completed.
  unknown,

  /// User is authenticated with a valid session.
  authenticated,

  /// User is not authenticated (no session or session expired without refresh).
  unauthenticated,

  /// Authentication is in progress (login loading).
  loading,

  /// An error occurred during authentication.
  error,
}

/// Public API for all authentication functionality in Phoenix OS.
///
/// This is the ONLY entry point for auth operations.
/// Screens and widgets never interact with [SecureStorageService] directly.
///
/// Responsibilities:
/// - Login with email/password (persistent)
/// - Secure logout (clears all auth data)
/// - Session restoration on app start
/// - Token refresh support
/// - Offline session support (cached sessions still work)
/// - Auth state change notifications
///
/// Architecture Rules:
/// - NEVER own UserState, Identity, or Journey logic
/// - NEVER interact with SharedPreferences for auth data
/// - All token storage goes through [SecureStorageService]
class AuthService extends ChangeNotifier {
  AuthService({
    SecureStorageService? secureStorage,
  }) : _secureStorage = secureStorage ?? SecureStorageService();

  final SecureStorageService _secureStorage;

  AuthState _state = AuthState.unknown;
  AuthSession? _currentSession;
  String? _lastError;

  // ── State Access ─────────────────────────────────────────────────

  /// The current authentication state.
  AuthState get state => _state;

  /// The current session, or `null` if not authenticated.
  AuthSession? get currentSession => _currentSession;

  /// The currently authenticated user, or `null`.
  AuthUser? get currentUser => _currentSession?.user;

  /// Whether the user is currently authenticated.
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Whether the authentication state is still being determined.
  bool get isUnknown => _state == AuthState.unknown;

  /// The last error message, or `null` if no error.
  String? get lastError => _lastError;

  // ── Lifecycle ────────────────────────────────────────────────────

  /// Initializes the auth service by attempting to restore a persisted
  /// session from secure storage.
  ///
  /// Called once during app bootstrap. Sets state to:
  /// - [AuthState.authenticated] if a valid session was restored
  /// - [AuthState.unauthenticated] if no session exists
  Future<void> init() async {
    try {
      final session = await _secureStorage.restoreSession();
      if (session != null) {
        // Offline support: even if expired, use cached session
        // (token refresh will happen on next online interaction)
        _currentSession = session;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      debugPrint('AuthService.init: failed to restore session: $e');
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ────────────────────────────────────────────────────────

  /// Authenticates the user with email and password.
  ///
  /// On success:
  /// - Persists the session to secure storage
  /// - Sets state to [AuthState.authenticated]
  ///
  /// On failure:
  /// - Sets state to [AuthState.error]
  /// - Stores the error message in [lastError]
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _lastError = null;
    notifyListeners();

    try {
      // For the initial implementation, we support two modes:
      //
      // 1. Demo mode: any email/password with valid format works
      // 2. Supabase mode: uses Supabase auth client (future)
      //
      // The architecture supports both without changing the public API.
      final session = await _performAuthentication(
        email: email,
        password: password,
      );

      if (session != null) {
        await _secureStorage.saveSession(session);
        _currentSession = session;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }

      _state = AuthState.error;
      _lastError = 'Authentication failed. Please check your credentials.';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AuthService.login: $e');
      _state = AuthState.error;
      _lastError = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────

  /// Logs the user out and clears all persisted auth data.
  ///
  /// **This is a destructive operation.** After calling:
  /// - Session is cleared from secure storage
  /// - State is set to [AuthState.unauthenticated]
  /// - UI should navigate to the login screen
  Future<void> logout() async {
    try {
      await _secureStorage.clearSession();
    } catch (e) {
      debugPrint('AuthService.logout: failed to clear session: $e');
    }
    _currentSession = null;
    _lastError = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  // ── Token Refresh ────────────────────────────────────────────────

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Returns `true` if the token was successfully refreshed.
  /// Returns `false` if no refresh token is available or refresh fails.
  Future<bool> refreshToken() async {
    final session = _currentSession;
    if (session == null || !session.canRefresh) return false;

    try {
      final newSession = await _performTokenRefresh(session);
      if (newSession != null) {
        await _secureStorage.saveSession(newSession);
        _currentSession = newSession;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('AuthService.refreshToken: $e');
    }

    // Token refresh failed — log out for security
    await logout();
    return false;
  }

  // ── Offline Support ──────────────────────────────────────────────

  /// Whether the current session can be used in offline mode.
  ///
  /// Returns `true` if there is a valid session (even if the token is
  /// expired, as long as a refresh token exists for later refresh).
  bool get supportsOffline {
    final session = _currentSession;
    return session != null && session.isValid;
  }

  /// Returns the current access token for API calls.
  ///
  /// If the token is expired and a refresh token is available,
  /// attempts a silent refresh first. Returns `null` if no
  /// valid token can be obtained.
  Future<String?> getAccessToken() async {
    final session = _currentSession;
    if (session == null) return null;

    if (session.isExpired && session.canRefresh) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return _currentSession?.accessToken;
      }
      return null;
    }

    return session.accessToken;
  }

  // ── Authentication Providers ─────────────────────────────────────

  /// Performs the actual authentication against the backend.
  ///
  /// Currently uses demo mode (local validation).
  /// Future: delegate to Supabase auth client.
  Future<AuthSession?> _performAuthentication({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.trim().isEmpty || password.isEmpty) return null;
    if (!_isValidEmail(email)) return null;
    if (password.length < 6) return null;

    // Demo mode: simulate authentication with a mock response.
    // This is replaced by Supabase auth in production.
    await Future.delayed(const Duration(milliseconds: 800));

    final userId = _generateUserId(email);
    final user = AuthUser(
      id: userId,
      email: email.trim().toLowerCase(),
      displayName: email.split('@').first,
      createdAt: DateTime.now(),
    );

    return AuthSession(
      user: user,
      accessToken: _generateToken(userId, email),
      refreshToken: _generateToken('refresh-$userId', email),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  /// Attempts to refresh an expired session.
  ///
  /// Current: generates new demo tokens.
  /// Future: calls Supabase auth refresh endpoint.
  Future<AuthSession?> _performTokenRefresh(AuthSession session) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return AuthSession(
      user: session.user,
      accessToken: _generateToken(
        session.user.id,
        session.user.email,
      ),
      refreshToken: session.refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  String _generateUserId(String email) {
    return 'usr_${email.hashCode.toRadixString(16).padLeft(8, '0')}';
  }

  String _generateToken(String salt, String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final raw = '$salt:$email:$timestamp';
    // In production, this would be a JWT from the auth server.
    // For demo, we return a base64-encoded opaque token.
    return 'phx_${base64Encode(utf8.encode(raw))}';
  }

  // ── Diagnostics ──────────────────────────────────────────────────

  Map<String, dynamic> diagnostics() {
    return {
      'state': _state.name,
      'isAuthenticated': isAuthenticated,
      'hasSession': _currentSession != null,
      'sessionExpired': _currentSession?.isExpired ?? false,
      'canRefresh': _currentSession?.canRefresh ?? false,
      'lastError': _lastError,
    };
  }
}