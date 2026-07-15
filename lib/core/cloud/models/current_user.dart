import 'auth_provider.dart' show AuthProvider;

/// Profile data for the currently authenticated user.
///
/// Contains the user's public profile information separate from
/// the session tokens held in [UserSession]. Created by
/// [AuthenticationService] and cached for the lifetime of the session.
///
/// Immutable. No session secrets — profile data only.
class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
    this.isEmailVerified = false,
    this.createdAt,
    this.lastLoginAt,
    this.preferences = const {},
  });

  /// Unique user identifier.
  final String id;

  /// Email address.
  final String email;

  /// Display name.
  final String? displayName;

  /// Profile photo URL.
  final String? photoUrl;

  /// Authentication provider.
  final AuthProvider provider;

  /// Whether the email has been verified.
  final bool isEmailVerified;

  /// When the account was created.
  final DateTime? createdAt;

  /// When the user last logged in.
  final DateTime? lastLoginAt;

  /// User preferences (theme, notifications, etc.).
  final Map<String, dynamic> preferences;

  /// Whether this is an anonymous user.
  bool get isAnonymous => provider == AuthProvider.anonymous;

  /// Initials derived from display name or email.
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  CurrentUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProvider? provider,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return CurrentUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentUser && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CurrentUser(id: $id, email: $email, provider: $provider)';
}
