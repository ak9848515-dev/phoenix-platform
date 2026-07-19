import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../shared/infrastructure/firebase/firebase_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/authenticated_user.dart';
import '../models/authentication_exception.dart';
import '../models/authentication_state.dart';
import '../models/user_session.dart';
import 'secure_storage_service.dart';

/// Production-ready authentication service for Phoenix OS.
///
/// **Architecture:**
/// ```
/// Firebase Authentication
///         ↓
/// AuthenticationService  ←  Widgets use this ONLY
///         ↓
/// UserSession
///         ↓
/// Identity Engine
///         ↓
/// Snapshots → Widgets
/// ```
///
/// **Security Rules:**
/// - Widgets NEVER access FirebaseAuth directly
/// - No authentication logic inside widgets
/// - No secrets in source code
/// - All token storage via [SecureStorageService]
///
/// **Providers:**
/// - Anonymous (guest)
/// - Google Sign-In
/// - Email & Password
/// - Apple Sign-In (future, scaffold ready)
///
/// **Session Management:**
/// - Persist to secure storage on login
/// - Restore automatically on app start
/// - Expire gracefully with token refresh
/// - Handle revoked credentials with logout
class AuthenticationService extends ChangeNotifier {
  AuthenticationService({
    SecureStorageService? secureStorage,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _secureStorage = secureStorage ?? SecureStorageService(),
        _firebaseAuth = firebaseAuth ??
            FirebaseService.auth ??
            firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final SecureStorageService _secureStorage;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final PhoenixLogger _logger = PhoenixLogger.shared;

  // ── State ──────────────────────────────────────────────────────────

  AuthenticationState _state = AuthenticationState.initializing;
  UserSession? _currentSession;
  AuthenticationException? _lastException;

  /// Current authentication state.
  AuthenticationState get state => _state;

  /// Current user session (null if not authenticated).
  UserSession? get currentSession => _currentSession;

  /// Currently authenticated user (null if not authenticated).
  AuthenticatedUser? get currentUser => _currentSession?.user;

  /// Last authentication exception (null if no error).
  AuthenticationException? get lastException => _lastException;

  /// User-friendly error message (null if no error).
  String? get lastErrorMessage => _lastException?.message;

  /// Whether the user is authenticated (not anonymous).
  bool get isAuthenticated => _state == AuthenticationState.authenticated;

  /// Whether the user is in anonymous/guest mode.
  bool get isAnonymous => _state == AuthenticationState.anonymous;

  /// Whether the user has any form of active session.
  bool get hasSession => _state.hasSession;

  // ── Initialization & Session Restore ───────────────────────────────

  /// Initializes the auth service by checking Firebase Auth state
  /// and attempting to restore a persisted session.
  ///
  /// Called once during app bootstrap. Determines the initial
  /// [AuthenticationState] based on:
  /// 1. Firebase Auth currentUser
  /// 2. Persisted session in secure storage
  /// 3. Network availability
  Future<void> init() async {
    _state = AuthenticationState.initializing;
    notifyListeners();

    try {
      // 1. Check Firebase Auth for existing session
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        // User has a Firebase session
        final session = _buildSessionFromFirebaseUser(firebaseUser);
        _currentSession = session;
        await _secureStorage.saveSession(session);

        if (firebaseUser.isAnonymous) {
          _state = AuthenticationState.anonymous;
          _logger.info('Auth: anonymous session restored',
              category: LogCategory.diagnostics, source: 'AuthService');
        } else {
          _state = AuthenticationState.authenticated;
          _logger.info('Auth: authenticated session restored',
              category: LogCategory.diagnostics, source: 'AuthService');
        }
      } else {
        // 2. Try restoring persisted session from secure storage
        final persisted = await _secureStorage.restoreSession();
        if (persisted != null) {
          _currentSession = persisted;

          if (persisted.isExpired && persisted.canRefresh) {
            // Token expired — try silent refresh
            final refreshed = await _trySilentRefresh(persisted);
            if (refreshed) {
              _state = AuthenticationState.authenticated;
            } else {
              // Can't refresh — expired session
              _state = AuthenticationState.expired;
              _logger.warning('Auth: session expired, refresh failed',
                  category: LogCategory.diagnostics, source: 'AuthService');
            }
          } else if (persisted.isExpired) {
            _state = AuthenticationState.expired;
          } else {
            _state = AuthenticationState.offline;
          }

          if (_state.hasSession) {
            _logger.info('Auth: session restored from storage',
                category: LogCategory.diagnostics, source: 'AuthService');
          }
        } else {
          // No session at all
          _state = AuthenticationState.unauthenticated;
          _logger.info('Auth: no existing session',
              category: LogCategory.diagnostics, source: 'AuthService');
        }
      }
    } catch (e) {
      _logger.error('Auth: init failed: $e',
          category: LogCategory.diagnostics, source: 'AuthService');
      _lastException = AuthenticationException(
        code: AuthenticationException.unknown,
        message: 'Failed to restore session. Please sign in again.',
        details: e.toString(),
      );
      _state = AuthenticationState.error;
    }

    notifyListeners();
  }

  // ── Anonymous Login ────────────────────────────────────────────────

  /// Signs in anonymously (guest mode).
  ///
  /// Supports later account linking — no data loss when upgraded.
  Future<bool> signInAnonymously() async {
    _state = AuthenticationState.initializing;
    _lastException = null;
    notifyListeners();

    try {
      final result = await _firebaseAuth.signInAnonymously();
      final firebaseUser = result.user;

      if (firebaseUser != null) {
        final session = _buildSessionFromFirebaseUser(firebaseUser);
        _currentSession = session;
        await _secureStorage.saveSession(session);
        _state = AuthenticationState.anonymous;
        notifyListeners();
        return true;
      }

      _lastException = AuthenticationException(
        code: AuthenticationException.anonymousSignInFailed,
        message: 'Unable to sign in anonymously. Please try again.',
      );
      _state = AuthenticationState.error;
      notifyListeners();
      return false;
    } catch (e) {
      return _handleAuthError(e, 'anonymous sign-in failed');
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────────────

  /// Signs in with Google.
  ///
  /// Supports:
  /// - Google account selection
  /// - Session persistence
  /// - Token refresh
  /// - Logout
  Future<bool> signInWithGoogle() async {
    _state = AuthenticationState.initializing;
    _lastException = null;
    notifyListeners();

    try {
      // Trigger Google Sign-In
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        _lastException = AuthenticationException(
          code: AuthenticationException.googleSignInFailed,
          message: 'Failed to get Google authentication token.',
        );
        _state = AuthenticationState.error;
        notifyListeners();
        return false;
      }

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final result = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = result.user;

      if (firebaseUser != null) {
        final session = _buildSessionFromFirebaseUser(firebaseUser);
        _currentSession = session;
        await _secureStorage.saveSession(session);
        _state = AuthenticationState.authenticated;
        notifyListeners();
        return true;
      }

      _lastException = AuthenticationException(
        code: AuthenticationException.googleSignInFailed,
        message: 'Google Sign-In failed. Please try again.',
      );
      _state = AuthenticationState.error;
      notifyListeners();
      return false;
    } catch (e) {
      return _handleAuthError(e, 'Google Sign-In failed');
    }
  }

  // ── Email & Password ───────────────────────────────────────────────

  /// Creates a new account with email and password.
  Future<bool> createAccount({
    required String email,
    required String password,
  }) async {
    _state = AuthenticationState.initializing;
    _lastException = null;
    notifyListeners();

    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = result.user;

      if (firebaseUser != null) {
        final session = _buildSessionFromFirebaseUser(firebaseUser);
        _currentSession = session;
        await _secureStorage.saveSession(session);
        _state = AuthenticationState.authenticated;
        notifyListeners();
        return true;
      }

      _lastException = AuthenticationException(
        code: AuthenticationException.unknown,
        message: 'Account creation failed. Please try again.',
      );
      _state = AuthenticationState.error;
      notifyListeners();
      return false;
    } catch (e) {
      return _handleAuthError(e, 'account creation failed');
    }
  }

  /// Signs in with email and password.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _state = AuthenticationState.initializing;
    _lastException = null;
    notifyListeners();

    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = result.user;

      if (firebaseUser != null) {
        final session = _buildSessionFromFirebaseUser(firebaseUser);
        _currentSession = session;
        await _secureStorage.saveSession(session);
        _state = AuthenticationState.authenticated;
        notifyListeners();
        return true;
      }

      _lastException = AuthenticationException(
        code: AuthenticationException.invalidCredentials,
        message: 'Invalid email or password.',
      );
      _state = AuthenticationState.error;
      notifyListeners();
      return false;
    } catch (e) {
      return _handleAuthError(e, 'email sign-in failed');
    }
  }

  /// Sends a password reset email.
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      _logger.error('Auth: password reset failed: $e',
          category: LogCategory.diagnostics, source: 'AuthService');
      return false;
    }
  }

  // ── Account Linking ────────────────────────────────────────────────

  /// Links an anonymous account to a Google account.
  Future<bool> linkWithGoogle() async {
    if (_currentSession == null || !_currentSession!.user.isAnonymous) {
      return false;
    }

    try {
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      if (googleAuth.idToken == null) return false;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;

      final result = await firebaseUser.linkWithCredential(credential);
      final updatedUser = result.user;

      if (updatedUser != null) {
        final session = _buildSessionFromFirebaseUser(updatedUser);
        _currentSession = session;
        await _secureStorage.saveSession(session);
        _state = AuthenticationState.authenticated;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _logger.error('Auth: account linking failed: $e',
          category: LogCategory.diagnostics, source: 'AuthService');
      _lastException = AuthenticationException(
        code: AuthenticationException.accountLinkingFailed,
        message: 'Account linking failed. Please try again.',
        details: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  /// Links an anonymous account to an email/password account.
  Future<bool> linkWithEmail({
    required String email,
    required String password,
  }) async {
    if (_currentSession == null || !_currentSession!.user.isAnonymous) {
      return false;
    }

    try {
      final credential = firebase_auth
          .EmailAuthProvider.credential(email: email.trim(), password: password);

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;

      final result = await firebaseUser.linkWithCredential(credential);
      final updatedUser = result.user;

      if (updatedUser != null) {
        final session = _buildSessionFromFirebaseUser(updatedUser);
        _currentSession = session;
        await _secureStorage.saveSession(session);
        _state = AuthenticationState.authenticated;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _logger.error('Auth: account linking failed: $e',
          category: LogCategory.diagnostics, source: 'AuthService');
      _lastException = AuthenticationException(
        code: AuthenticationException.accountLinkingFailed,
        message: 'Account linking failed. Please try again.',
        details: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────

  /// Logs the user out and clears all persisted auth data.
  ///
  /// **Destructive operation.** After calling:
  /// - Session cleared from secure storage
  /// - State set to unauthenticated
  /// - Google Sign-In signed out
  Future<void> logout() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Clear persisted session
      await _secureStorage.clearSession();
    } catch (e) {
      _logger.error('Auth: logout failed: $e',
          category: LogCategory.diagnostics, source: 'AuthService');
    }

    _currentSession = null;
    _lastException = null;
    _state = AuthenticationState.unauthenticated;
    notifyListeners();
  }

  // ── Delete Account ─────────────────────────────────────────────────

  /// Deletes the current user account (confirmation required externally).
  Future<bool> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;

      await firebaseUser.delete();
      await _secureStorage.clearSession();
      _currentSession = null;
      _lastException = null;
      _state = AuthenticationState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.error('Auth: account deletion failed: $e',
          category: LogCategory.diagnostics, source: 'AuthService');
      _lastException = AuthenticationException(
        code: AuthenticationException.requiresRecentLogin,
        message: 'Please sign in again to delete your account.',
        details: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  // ── Token Management ───────────────────────────────────────────────

  /// Gets a valid ID token, refreshing if necessary.
  Future<String?> getIdToken() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final token = await firebaseUser.getIdToken(true);
      return token;
    } catch (e) {
      _logger.error('Auth: get ID token failed: $e',
          category: LogCategory.diagnostics, source: 'AuthService');
      return null;
    }
  }

  /// Attempts silent token refresh from a persisted session.
  Future<bool> _trySilentRefresh(UserSession persisted) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final token = await firebaseUser.getIdToken(true);
        if (token != null) {
          final session = _buildSessionFromFirebaseUser(firebaseUser);
          _currentSession = session;
          await _secureStorage.saveSession(session);
          return true;
        }
      }
      return false;
    } catch (e) {
      _logger.warning('Auth: silent refresh failed: $e',
          category: LogCategory.diagnostics, source: 'AuthService');
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────

  /// Builds an [UserSession] from a Firebase [User].
  UserSession _buildSessionFromFirebaseUser(
    firebase_auth.User firebaseUser,
  ) {
    final provider = _resolveProvider(firebaseUser);

    return UserSession(
      user: AuthenticatedUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        provider: provider,
        isAnonymous: firebaseUser.isAnonymous,
        createdAt: firebaseUser.metadata.creationTime,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      ),
      idToken: null, // Fetched lazily via getIdToken()
      refreshToken: null, // Managed by Firebase SDK
      expiresAt: null, // Managed by Firebase SDK
      lastAuthenticatedAt: DateTime.now(),
    );
  }

  /// Resolves the authentication provider type from a Firebase user.
  AuthProviderType _resolveProvider(firebase_auth.User firebaseUser) {
    if (firebaseUser.isAnonymous) return AuthProviderType.anonymous;

    final providerData = firebaseUser.providerData;
    if (providerData.isNotEmpty) {
      final providerId = providerData.first.providerId;
      switch (providerId) {
        case 'google.com':
          return AuthProviderType.google;
        case 'password':
          return AuthProviderType.email;
        case 'apple.com':
          return AuthProviderType.apple;
      }
    }

    return AuthProviderType.email;
  }

  /// Handles authentication errors consistently.
  bool _handleAuthError(dynamic error, String context) {
    _logger.error('Auth: $context: $error',
        category: LogCategory.diagnostics, source: 'AuthService');

    if (error is firebase_auth.FirebaseAuthException) {
      _lastException =
          AuthenticationException.fromFirebaseAuthException(error);
    } else if (error is AuthenticationException) {
      _lastException = error;
    } else {
      _lastException = AuthenticationException(
        code: AuthenticationException.unknown,
        message: 'An authentication error occurred. Please try again.',
        details: error.toString(),
      );
    }

    _state = AuthenticationState.error;
    notifyListeners();
    return false;
  }

  // ── Diagnostics ────────────────────────────────────────────────────

  /// Returns diagnostic information about the current auth state.
  Map<String, dynamic> diagnostics() {
    return {
      'authenticationState': _state.name,
      'isAuthenticated': isAuthenticated,
      'isAnonymous': isAnonymous,
      'hasSession': hasSession,
      'currentProvider': _currentSession?.user.provider.name,
      'sessionExists': _currentSession != null,
      'sessionExpired': _currentSession?.isExpired ?? false,
      'canRefresh': _currentSession?.canRefresh ?? false,
      'lastError': _lastException?.code,
      'lastErrorMessage': _lastException?.message,
    };
  }
}