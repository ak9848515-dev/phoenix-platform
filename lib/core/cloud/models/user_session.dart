import 'auth_provider.dart' show AuthProvider;

/// An authenticated user session on the Phoenix Cloud platform.
///
/// Immutable. Created by [AuthenticationService] after successful
/// authentication and restored on app startup from secure storage.
class UserSession {
  const UserSession({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.createdAt,
    this.isAnonymous = false,
  });

  /// Unique user identifier from the auth provider.
  final String id;

  /// User's email address (may be null for anonymous).
  final String email;

  /// User's display name (if provided by the provider).
  final String? displayName;

  /// User's profile photo URL (if provided by the provider).
  final String? photoUrl;

  /// Authentication provider used.
  final AuthProvider provider;

  /// Current access token for API calls.
  final String accessToken;

  /// Refresh token for obtaining new access tokens.
  final String refreshToken;

  /// When the access token expires.
  final DateTime expiresAt;

  /// When this session was created.
  final DateTime? createdAt;

  /// Whether this is an anonymous/guest session.
  final bool isAnonymous;

  /// Whether the access token has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the session is still valid (not expired).
  bool get isValid => !isExpired;

  /// Whether this is a fully authenticated user (not anonymous).
  bool get isAuthenticated => !isAnonymous && provider != AuthProvider.anonymous;

  /// Creates a copy with the given fields replaced.
  UserSession copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProvider? provider,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? createdAt,
    bool? isAnonymous,
  }) {
    return UserSession(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// Serializes to a JSON-compatible map (for secure storage).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'provider': provider.name,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  /// Creates from a JSON-compatible map.
  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      provider: AuthProvider.values.firstWhere(
        (p) => p.name == (map['provider'] as String? ?? 'anonymous'),
        orElse: () => AuthProvider.anonymous,
      ),
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      isAnonymous: map['isAnonymous'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSession && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserSession(id: $id, provider: $provider, expired: $isExpired)';
}
