import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:phoenix_platform/features/auth/models/auth_user.dart';
import 'package:phoenix_platform/features/auth/models/auth_session.dart';
import 'package:phoenix_platform/features/auth/models/authenticated_user.dart';
import 'package:phoenix_platform/features/auth/models/user_session.dart';
import 'package:phoenix_platform/features/auth/services/auth_service.dart';
import 'package:phoenix_platform/features/auth/services/secure_storage_service.dart';

/// Creates a test [SecureStorageService] backed by the mock platform.
SecureStorageService createTestStorage() {
  return SecureStorageService(
    storage: const FlutterSecureStorage(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AuthUser', () {
    test('creates with required fields', () {
      final user = AuthUser(id: 'usr_001', email: 'test@example.com');
      expect(user.id, equals('usr_001'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, isNull);
      expect(user.hasDisplayName, isFalse);
    });

    test('creates with all fields', () {
      final user = AuthUser(
        id: 'usr_001',
        email: 'test@example.com',
        displayName: 'Test User',
        avatarUrl: 'https://example.com/avatar.png',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(user.hasDisplayName, isTrue);
      expect(user.hasAvatar, isTrue);
    });

    test('copyWith replaces fields', () {
      final user = AuthUser(id: 'usr_001', email: 'test@example.com');
      final updated = user.copyWith(displayName: 'Updated');
      expect(updated.displayName, equals('Updated'));
      expect(updated.email, equals('test@example.com'));
    });

    test('serialization round-trips through toMap/fromMap', () {
      final user = AuthUser(
        id: 'usr_001',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final map = user.toMap();
      final restored = AuthUser.fromMap(map);
      expect(restored, equals(user));
    });

    test('serialization round-trips through toJson/fromJson', () {
      final user = AuthUser(
        id: 'usr_001',
        email: 'test@example.com',
        createdAt: DateTime(2026, 1, 1),
      );
      final json = user.toJson();
      final restored = AuthUser.fromJson(json);
      expect(restored, equals(user));
    });

    test('equality based on id and email', () {
      final a = AuthUser(id: 'usr_001', email: 'a@test.com');
      final b = AuthUser(id: 'usr_001', email: 'a@test.com');
      final c = AuthUser(id: 'usr_002', email: 'b@test.com');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hasDisplayName returns false for empty string', () {
      final user = AuthUser(
        id: 'usr_001',
        email: 'test@example.com',
        displayName: '',
      );
      expect(user.hasDisplayName, isFalse);
    });

    test('hasAvatar returns false for empty string', () {
      final user = AuthUser(
        id: 'usr_001',
        email: 'test@example.com',
        avatarUrl: '',
      );
      expect(user.hasAvatar, isFalse);
    });
  });

  group('AuthSession', () {
    final user = AuthUser(id: 'usr_001', email: 'test@example.com');

    test('isExpired returns false when no expiry set', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
      );
      expect(session.isExpired, isFalse);
    });

    test('isExpired returns true for past expiry', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
        expiresAt: DateTime(2020, 1, 1),
      );
      expect(session.isExpired, isTrue);
    });

    test('isExpired returns false for future expiry', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
        expiresAt: DateTime(2099, 1, 1),
      );
      expect(session.isExpired, isFalse);
    });

    test('canRefresh returns true when refresh token exists', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
        refreshToken: 'refresh_123',
      );
      expect(session.canRefresh, isTrue);
    });

    test('canRefresh returns false when no refresh token', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
      );
      expect(session.canRefresh, isFalse);
    });

    test('isValid returns true when not expired', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
        expiresAt: DateTime(2099, 1, 1),
      );
      expect(session.isValid, isTrue);
    });

    test('isValid returns true when expired but has refresh token', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
        refreshToken: 'refresh_123',
        expiresAt: DateTime(2020, 1, 1),
      );
      expect(session.isValid, isTrue);
    });

    test('copyWith clearRefreshToken sets refreshToken to null', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
        refreshToken: 'refresh_123',
      );
      final cleared = session.copyWith(clearRefreshToken: true);
      expect(cleared.refreshToken, isNull);
    });

    test('copyWith clearExpiry sets expiresAt to null', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
        expiresAt: DateTime(2099, 1, 1),
      );
      final cleared = session.copyWith(clearExpiry: true);
      expect(cleared.expiresAt, isNull);
    });

    test('serialization round-trips through toMap/fromMap', () {
      final session = AuthSession(
        user: user,
        accessToken: 'token_123',
        refreshToken: 'refresh_123',
        expiresAt: DateTime(2099, 1, 1),
      );
      final map = session.toMap();
      final restored = AuthSession.fromMap(map);
      expect(restored.user, equals(session.user));
      expect(restored.accessToken, equals(session.accessToken));
    });
  });

  // ── AuthService ──────────────────────────────────────────────────────

  group('AuthService', () {
    late AuthService authService;
    late SecureStorageService sharedStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      sharedStorage = createTestStorage();
      authService = AuthService(secureStorage: sharedStorage);
    });

    test('initial state is unknown before init', () {
      expect(authService.state, equals(AuthState.unknown));
      expect(authService.isUnknown, isTrue);
    });

    test('init sets unauthenticated when no session exists', () async {
      await authService.init();
      expect(authService.state, equals(AuthState.unauthenticated));
      expect(authService.isAuthenticated, isFalse);
      expect(authService.isUnknown, isFalse);
    });

    test('login succeeds with valid credentials', () async {
      await authService.init();
      final success = await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(success, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser!.email, equals('test@example.com'));
    });

    test('login fails with invalid email format', () async {
      await authService.init();
      final success = await authService.login(
        email: 'invalid-email',
        password: 'password123',
      );
      expect(success, isFalse);
      expect(authService.state, equals(AuthState.error));
      expect(authService.lastError, isNotEmpty);
    });

    test('login fails with empty email', () async {
      await authService.init();
      final success = await authService.login(
        email: '',
        password: 'password123',
      );
      expect(success, isFalse);
      expect(authService.state, equals(AuthState.error));
    });

    test('login fails with short password', () async {
      await authService.init();
      final success = await authService.login(
        email: 'test@example.com',
        password: '123',
      );
      expect(success, isFalse);
      expect(authService.state, equals(AuthState.error));
    });

    test('login loading state is set during authentication', () async {
      await authService.init();
      final loginFuture = authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(authService.state, equals(AuthState.loading));
      await loginFuture;
    });

    test('logout clears session', () async {
      await authService.init();
      await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(authService.isAuthenticated, isTrue);

      await authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.state, equals(AuthState.unauthenticated));
      expect(authService.currentUser, isNull);
    });

    test('session restores after re-init', () async {
      await authService.init();
      await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(authService.isAuthenticated, isTrue);

      // Same storage instance = session survives the "restart"
      final restoredService = AuthService(secureStorage: sharedStorage);
      await restoredService.init();
      expect(restoredService.isAuthenticated, isTrue);
      expect(restoredService.currentUser, isNotNull);
      expect(restoredService.currentUser!.email, equals('test@example.com'));
    });

    test('token refresh maintains session', () async {
      await authService.init();
      await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );

      final refreshed = await authService.refreshToken();
      expect(refreshed, isTrue);
      expect(authService.isAuthenticated, isTrue);
    });

    test('token refresh returns false when no refresh token', () async {
      // Create a session without refresh token via storage directly
      final session = UserSession(
        user: AuthenticatedUser(id: 'usr_001', email: 'test@example.com'),
        idToken: 'token_without_refresh',
      );
      await sharedStorage.saveSession(session);
      await authService.init();
      expect(authService.isAuthenticated, isTrue);

      final refreshed = await authService.refreshToken();
      // Returns false because canRefresh is false (no refresh token),
      // but user remains authenticated since the session still exists.
      expect(refreshed, isFalse);
      expect(authService.isAuthenticated, isTrue);
    });

    test('supportsOffline returns true for valid session', () async {
      await authService.init();
      await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(authService.supportsOffline, isTrue);
    });

    test('supportsOffline returns false before login', () async {
      await authService.init();
      expect(authService.supportsOffline, isFalse);
    });

    test('getAccessToken returns token for valid session', () async {
      await authService.init();
      await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      final token = await authService.getAccessToken();
      expect(token, isNotNull);
      expect(token, isNotEmpty);
      expect(token!.startsWith('phx_'), isTrue);
    });

    test('getAccessToken returns null when not authenticated', () async {
      await authService.init();
      final token = await authService.getAccessToken();
      expect(token, isNull);
    });

    test('lastError is null after successful login', () async {
      await authService.init();
      await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(authService.lastError, isNull);
    });

    test('diagnostics returns correct structure', () async {
      await authService.init();
      final diag = authService.diagnostics();
      expect(diag['state'], equals('unauthenticated'));
      expect(diag['isAuthenticated'], isFalse);
      expect(diag['hasSession'], isFalse);
    });

    test('diagnostics reflects authenticated state after login', () async {
      await authService.init();
      await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );
      final diag = authService.diagnostics();
      expect(diag['state'], equals('authenticated'));
      expect(diag['isAuthenticated'], isTrue);
      expect(diag['hasSession'], isTrue);
    });
  });

  // ── SecureStorageService ─────────────────────────────────────────────

  group('SecureStorageService', () {
    late SecureStorageService secureStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      secureStorage = createTestStorage();
    });

    test('hasSession returns false initially', () async {
      final has = await secureStorage.hasSession();
      expect(has, isFalse);
    });

    test('hasSession returns true after saving session', () async {
      final user = AuthenticatedUser(id: 'usr_001', email: 'test@example.com');
      final session = UserSession(
        user: user,
        idToken: 'token_123',
        refreshToken: 'refresh_123',
      );
      await secureStorage.saveSession(session);
      final has = await secureStorage.hasSession();
      expect(has, isTrue);
    });

    test('restoreSession returns null when no session', () async {
      final session = await secureStorage.restoreSession();
      expect(session, isNull);
    });

    test('restoreSession returns saved session', () async {
      final user = AuthenticatedUser(id: 'usr_001', email: 'test@example.com');
      final session = UserSession(
        user: user,
        idToken: 'token_123',
        refreshToken: 'refresh_123',
      );
      await secureStorage.saveSession(session);

      final restored = await secureStorage.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.user.email, equals('test@example.com'));
      expect(restored.idToken, equals('token_123'));
    });

    test('restoreSession restores session without refresh token', () async {
      final user = AuthenticatedUser(id: 'usr_001', email: 'test@example.com');
      final session = UserSession(
        user: user,
        idToken: 'token_no_refresh',
      );
      await secureStorage.saveSession(session);

      final restored = await secureStorage.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.refreshToken, isNull);
      expect(restored.canRefresh, isFalse);
    });

    test('clearSession removes all data', () async {
      final user = AuthenticatedUser(id: 'usr_001', email: 'test@example.com');
      final session = UserSession(
        user: user,
        idToken: 'token_123',
      );
      await secureStorage.saveSession(session);
      expect(await secureStorage.hasSession(), isTrue);

      await secureStorage.clearSession();
      expect(await secureStorage.hasSession(), isFalse);
    });

    test('updateIdToken updates token in storage', () async {
      final user = AuthenticatedUser(id: 'usr_001', email: 'test@example.com');
      final session = UserSession(
        user: user,
        idToken: 'original_token',
      );
      await secureStorage.saveSession(session);

      await secureStorage.updateIdToken('updated_token');
      final restored = await secureStorage.restoreSession();
      expect(restored!.idToken, equals('updated_token'));
    });

    test('updateRefreshToken updates refresh token in storage', () async {
      final user = AuthenticatedUser(id: 'usr_001', email: 'test@example.com');
      final session = UserSession(
        user: user,
        idToken: 'token_123',
        refreshToken: 'original_refresh',
      );
      await secureStorage.saveSession(session);

      await secureStorage.updateRefreshToken('updated_refresh');
      final restored = await secureStorage.restoreSession();
      expect(restored!.refreshToken, equals('updated_refresh'));
    });

    test('diagnostics returns correct structure', () async {
      final diag = await secureStorage.diagnostics();
      expect(diag['hasUser'], isFalse);
      expect(diag['hasRefreshToken'], isFalse);
      expect(diag['hasIdToken'], isFalse);
    });
  });
}
