import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/authenticated_user.dart';
import '../models/user_session.dart';
import 'secure_storage_service.dart';

/// Legacy auth states for the app-wide auth flow.
///
/// @deprecated Use [AuthenticationState] from the new AuthenticationService.
enum AuthState {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Legacy auth service maintained for backward compatibility.
///
/// @deprecated Use [AuthenticationService] for all new code.
class AuthService extends ChangeNotifier {
  AuthService({
    SecureStorageService? secureStorage,
  }) : _secureStorage = secureStorage ?? SecureStorageService();

  final SecureStorageService _secureStorage;

  AuthState _state = AuthState.unknown;
  UserSession? _currentSession;
  String? _lastError;

  AuthState get state => _state;
  UserSession? get currentSession => _currentSession;
  AuthenticatedUser? get currentUser => _currentSession?.user;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isUnknown => _state == AuthState.unknown;
  String? get lastError => _lastError;

  Future<void> init() async {
    try {
      final session = await _secureStorage.restoreSession();
      if (session != null) {
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

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _lastError = null;
    notifyListeners();

    try {
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

    await logout();
    return false;
  }

  bool get supportsOffline {
    final session = _currentSession;
    return session != null && session.isValid;
  }

  Future<String?> getAccessToken() async {
    final session = _currentSession;
    if (session == null) return null;

    if (session.isExpired && session.canRefresh) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return _currentSession?.idToken;
      }
      return null;
    }

    return session.idToken;
  }

  Future<UserSession?> _performAuthentication({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) return null;
    if (!_isValidEmail(email)) return null;
    if (password.length < 6) return null;

    await Future.delayed(const Duration(milliseconds: 800));

    final userId = _generateUserId(email);
    final user = AuthenticatedUser(
      id: userId,
      email: email.trim().toLowerCase(),
      displayName: email.split('@').first,
      createdAt: DateTime.now(),
    );

    return UserSession(
      user: user,
      idToken: _generateToken(userId, email),
      refreshToken: _generateToken('refresh-$userId', email),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      lastAuthenticatedAt: DateTime.now(),
    );
  }

  Future<UserSession?> _performTokenRefresh(UserSession session) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return UserSession(
      user: session.user,
      idToken: _generateToken(session.user.id, session.user.email),
      refreshToken: session.refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      lastAuthenticatedAt: DateTime.now(),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  String _generateUserId(String email) {
    return 'usr_${email.hashCode.toRadixString(16).padLeft(8, '0')}';
  }

  String _generateToken(String salt, String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final raw = '$salt:$email:$timestamp';
    return 'phx_${base64Encode(utf8.encode(raw))}';
  }

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