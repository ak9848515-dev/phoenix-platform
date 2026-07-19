/// Production-ready authentication states for Phoenix OS.
///
/// Reflects every phase of the auth lifecycle — from initializing
/// through to error or graceful offline recovery.
///
/// **States:**
/// - [initializing]  — Firebase Auth is being checked
/// - [anonymous]     — User is in anonymous/guest mode
/// - [authenticated] — User has a valid authenticated session
/// - [expired]       — Session token expired, refresh needed
/// - [offline]       — Previously authenticated, now offline
/// - [error]         — Authentication failure
enum AuthenticationState {
  /// Auth service is initializing (splash/startup).
  initializing,

  /// User is authenticated anonymously (guest mode).
  anonymous,

  /// User is authenticated with a valid session.
  authenticated,

  /// Session token has expired (graceful recovery possible).
  expired,

  /// Previously authenticated user in offline mode.
  offline,

  /// Authentication error occurred.
  error,

  /// User is not authenticated.
  unauthenticated;

  /// Whether the user has any form of active session.
  bool get hasSession =>
      this == authenticated || this == anonymous || this == offline;

  /// Whether the user can access protected features.
  bool get canAccessFeatures =>
      this == authenticated || this == offline;

  /// Whether the user is in a transient state (not yet resolved).
  bool get isTransient => this == initializing;
}