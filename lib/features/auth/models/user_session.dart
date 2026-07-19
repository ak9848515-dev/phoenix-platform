import 'dart:convert';

import 'authenticated_user.dart';

/// Production-ready user session model for Phoenix.
///
/// Represents an active auth session with full token management.
/// Owns the [AuthenticatedUser] and session metadata.
///
/// **Architecture:**
/// - Created by [AuthenticationService] after successful auth
/// - Persisted to secure storage for session restore
/// - Consumed by widgets via [AuthenticationService]
class UserSession {
  const UserSession({
    required this.user,
    this.idToken,
    this.refreshToken,
    this.expiresAt,
    this.lastAuthenticatedAt,
  });

  /// The authenticated user.
  final AuthenticatedUser user;

  /// Firebase Auth ID token (JWT).
  final String? idToken;

  /// Firebase Auth refresh token.
  final String? refreshToken;

  /// Session expiry timestamp.
  final DateTime? expiresAt;

  /// When the user last authenticated.
  final DateTime? lastAuthenticatedAt;

  /// Whether the session has expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Whether a refresh token is available.
  bool get canRefresh =>
      refreshToken != null && refreshToken!.isNotEmpty;

  /// Whether the session is valid (not expired or can refresh).
  bool get isValid => !isExpired || canRefresh;

  /// Creates a copy with the given fields replaced.
  UserSession copyWith({
    AuthenticatedUser? user,
    String? idToken,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? lastAuthenticatedAt,
    bool clearExpiry = false,
    bool clearRefreshToken = false,
  }) {
    return UserSession(
      user: user ?? this.user,
      idToken: idToken ?? this.idToken,
      refreshToken: clearRefreshToken ? null : (refreshToken ?? this.refreshToken),
      expiresAt: clearExpiry ? null : (expiresAt ?? this.expiresAt),
      lastAuthenticatedAt:
          lastAuthenticatedAt ?? this.lastAuthenticatedAt,
    );
  }

  /// Serializes to a JSON-compatible map.
  /// Uses secure storage for persistence (not plain text).
  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      if (idToken != null) 'idToken': idToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      if (lastAuthenticatedAt != null)
        'lastAuthenticatedAt': lastAuthenticatedAt!.toIso8601String(),
    };
  }

  /// Creates from a JSON-compatible map.
  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      user: AuthenticatedUser.fromMap(
        map['user'] as Map<String, dynamic>,
      ),
      idToken: map['idToken'] as String?,
      refreshToken: map['refreshToken'] as String?,
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
      lastAuthenticatedAt: map['lastAuthenticatedAt'] != null
          ? DateTime.parse(map['lastAuthenticatedAt'] as String)
          : null,
    );
  }

  /// Serializes to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates from a JSON string.
  factory UserSession.fromJson(String source) =>
      UserSession.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSession && other.user == user;

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() =>
      'UserSession(user: $user, expired: $isExpired)';
}