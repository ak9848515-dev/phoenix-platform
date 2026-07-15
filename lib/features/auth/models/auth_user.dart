import 'dart:convert';

/// Immutable model representing an authenticated user.
///
/// This is the single source of truth for user identity after
/// authentication. It is NOT a replacement for the existing
/// [Identity] model used by the Journey engine.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  /// Unique user identifier from the auth provider.
  final String id;

  /// Email address used for authentication.
  final String email;

  /// Optional display name.
  final String? displayName;

  /// Optional avatar URL.
  final String? avatarUrl;

  /// When the account was created.
  final DateTime? createdAt;

  /// Whether the user has a display name set.
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// Whether the user has an avatar.
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Creates a copy with the given fields replaced.
  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  /// Creates from a JSON-compatible map.
  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  /// Serializes to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates from a JSON string.
  factory AuthUser.fromJson(String source) =>
      AuthUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);

  @override
  String toString() => 'AuthUser(id: $id, email: $email)';
}