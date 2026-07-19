import 'dart:convert';

/// Production-ready authenticated user model for Phoenix.
///
/// Represents a verified user identity from Firebase Authentication.
/// Supports multiple provider types and account linking.
///
/// **Architecture:**
/// - [AuthenticationService] produces this from FirebaseAuth
/// - [IdentityEngine] consumes this for snapshot building
/// - Widgets read via [AuthenticationService] only
class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.provider = AuthProviderType.anonymous,
    this.isAnonymous = false,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Unique Firebase Auth UID.
  final String id;

  /// Primary email address.
  final String email;

  /// Optional display name.
  final String? displayName;

  /// Optional photo/avatar URL.
  final String? photoUrl;

  /// The authentication provider used.
  final AuthProviderType provider;

  /// Whether this user is anonymous/guest.
  final bool isAnonymous;

  /// Account creation timestamp.
  final DateTime? createdAt;

  /// Last login timestamp.
  final DateTime? lastLoginAt;

  /// Whether the user has a display name set.
  bool get hasDisplayName =>
      displayName != null && displayName!.isNotEmpty;

  /// Whether the user has a photo URL.
  bool get hasPhotoUrl => photoUrl != null && photoUrl!.isNotEmpty;

  /// Display-friendly account type label.
  String get accountTypeLabel {
    if (isAnonymous) return 'Guest';
    switch (provider) {
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.email:
        return 'Email & Password';
      case AuthProviderType.apple:
        return 'Apple';
      case AuthProviderType.anonymous:
        return 'Guest';
    }
  }

  /// Creates a copy with the given fields replaced.
  AuthenticatedUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProviderType? provider,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AuthenticatedUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'provider': provider.name,
      'isAnonymous': isAnonymous,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (lastLoginAt != null)
        'lastLoginAt': lastLoginAt!.toIso8601String(),
    };
  }

  /// Creates from a JSON-compatible map.
  factory AuthenticatedUser.fromMap(Map<String, dynamic> map) {
    return AuthenticatedUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      provider: AuthProviderType.values.firstWhere(
        (p) => p.name == map['provider'],
        orElse: () => AuthProviderType.anonymous,
      ),
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
    );
  }

  /// Serializes to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates from a JSON string.
  factory AuthenticatedUser.fromJson(String source) =>
      AuthenticatedUser.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthenticatedUser && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AuthenticatedUser(id: $id, email: $email, provider: $provider)';
}

/// Supported authentication provider types.
enum AuthProviderType {
  /// Google Sign-In.
  google,

  /// Email & Password.
  email,

  /// Apple Sign-In (future compatibility).
  apple,

  /// Anonymous / Guest.
  anonymous,
}