/// Supported authentication providers for the Phoenix Cloud platform.
enum AuthProvider {
  /// Email and password authentication.
  email,

  /// Google Sign-In (OAuth 2.0).
  google,

  /// Apple Sign-In (OAuth 2.0, available on iOS/macOS).
  apple,

  /// Anonymous/guest mode — no account required.
  anonymous;

  /// Human-readable label for display.
  String get label {
    switch (this) {
      case AuthProvider.email:
        return 'Email';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.anonymous:
        return 'Guest';
    }
  }

  /// Whether this provider requires OAuth flow.
  bool get isOAuth =>
      this == AuthProvider.google || this == AuthProvider.apple;
}
