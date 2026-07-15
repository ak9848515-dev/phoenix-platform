import 'dart:convert';

import 'auth_user.dart';

/// Immutable model representing an authenticated session.
///
/// Owns access token, refresh token, expiry, and the user profile.
/// All fields are read-only. Use [copyWith] for modifications.
class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  /// The authenticated user.
  final AuthUser user;

  /// The current access token (JWT or opaque).
  final String accessToken;

  /// Optional refresh token for obtaining new access tokens.
  final String? refreshToken;

  /// Optional expiry time for the access token.
  final DateTime? expiresAt;

  /// Whether the access token has expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Whether the session is still valid (not expired or has refresh token).
  bool get isValid => !isExpired || refreshToken != null;

  /// Whether a refresh token is available for silent re-authentication.
  bool get canRefresh => refreshToken != null && refreshToken!.isNotEmpty;

  /// Creates a copy with the given fields replaced.
  AuthSession copyWith({
    AuthUser? user,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    bool clearExpiry = false,
    bool clearRefreshToken = false,
  }) {
    return AuthSession(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: clearRefreshToken ? null : (refreshToken ?? this.refreshToken),
      expiresAt: clearExpiry ? null : (expiresAt ?? this.expiresAt),
    );
  }

  /// Serializes to a JSON-compatible map.
  /// Note: For security, tokens should never be stored in plain text
  /// outside of secure storage. This is used for in-memory serialization
  /// only, not for persistent storage.
  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }

  /// Creates from a JSON-compatible map.
  factory AuthSession.fromMap(Map<String, dynamic> map) {
    return AuthSession(
      user: AuthUser.fromMap(map['user'] as Map<String, dynamic>),
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String?,
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
    );
  }

  /// Serializes to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates from a JSON string.
  factory AuthSession.fromJson(String source) =>
      AuthSession.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          other.user == user &&
          other.accessToken == accessToken;

  @override
  int get hashCode => Object.hash(user, accessToken);

  @override
  String toString() => 'AuthSession(user: $user, expiresAt: $expiresAt)';
}