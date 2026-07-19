/// Production-ready authentication exception model for Phoenix.
///
/// Encapsulates all auth-related errors with user-friendly messages
/// and error codes for diagnostics.
class AuthenticationException implements Exception {
  const AuthenticationException({
    required this.code,
    this.message,
    this.details,
  });

  /// Machine-readable error code.
  final String code;

  /// User-friendly error message.
  final String? message;

  /// Additional diagnostic details.
  final String? details;

  @override
  String toString() =>
      'AuthenticationException($code): ${message ?? "Unknown error"}';

  // ── Common Error Codes ─────────────────────────────────────────────

  /// Invalid credentials provided.
  static const String invalidCredentials = 'invalid-credentials';

  /// Email address is invalid.
  static const String invalidEmail = 'invalid-email';

  /// Password does not meet requirements.
  static const String weakPassword = 'weak-password';

  /// Email already in use by another account.
  static const String emailAlreadyInUse = 'email-already-in-use';

  /// User account has been disabled.
  static const String userDisabled = 'user-disabled';

  /// User account not found.
  static const String userNotFound = 'user-not-found';

  /// Wrong password provided.
  static const String wrongPassword = 'wrong-password';

  /// Too many login attempts (account temporarily locked).
  static const String tooManyRequests = 'too-many-requests';

  /// Network error during authentication.
  static const String networkError = 'network-error';

  /// Google Sign-In was cancelled by the user.
  static const String googleSignInCancelled = 'google-sign-in-cancelled';

  /// Google Sign-In failed.
  static const String googleSignInFailed = 'google-sign-in-failed';

  /// Session expired.
  static const String sessionExpired = 'session-expired';

  /// Token refresh failed.
  static const String refreshFailed = 'refresh-failed';

  /// Anonymous sign-in failed.
  static const String anonymousSignInFailed = 'anonymous-sign-in-failed';

  /// Account linking failed.
  static const String accountLinkingFailed = 'account-linking-failed';

  /// Operation requires recent authentication.
  static const String requiresRecentLogin = 'requires-recent-login';

  /// Unknown or unexpected error.
  static const String unknown = 'unknown';

  // ── Factory Methods ────────────────────────────────────────────────

  /// Creates an [AuthenticationException] from a FirebaseAuthException.
  factory AuthenticationException.fromFirebaseAuthException(
    dynamic exception,
  ) {
    final code = exception.code as String? ?? unknown;
    final message = exception.message as String?;

    return AuthenticationException(
      code: code,
      message: _mapFirebaseMessage(code, message),
      details: message,
    );
  }

  /// Creates a friendly error message from Firebase error codes.
  static String? _mapFirebaseMessage(String code, String? original) {
    switch (code) {
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'invalid-credential':
      case invalidCredentials:
        return 'Invalid email or password. Please try again.';
      case invalidEmail:
        return 'Please enter a valid email address.';
      case weakPassword:
        return 'Password should be at least 6 characters.';
      case emailAlreadyInUse:
        return 'An account with this email already exists.';
      case userDisabled:
        return 'This account has been disabled.';
      case userNotFound:
        return 'No account found with this email.';
      case wrongPassword:
        return 'Incorrect password. Please try again.';
      case tooManyRequests:
        return 'Too many attempts. Please try again later.';
      case networkError:
        return 'Network error. Please check your connection.';
      case googleSignInCancelled:
        return 'Google Sign-In was cancelled.';
      case googleSignInFailed:
        return 'Google Sign-In failed. Please try again.';
      case sessionExpired:
        return 'Your session has expired. Please sign in again.';
      case refreshFailed:
        return 'Session refresh failed. Please sign in again.';
      case anonymousSignInFailed:
        return 'Unable to sign in anonymously. Please try again.';
      case accountLinkingFailed:
        return 'Account linking failed. Please try again.';
      case requiresRecentLogin:
        return 'Please sign in again to continue.';
      default:
        return original ?? 'An authentication error occurred.';
    }
  }

  /// Creates from a generic exception.
  factory AuthenticationException.fromException(Exception exception) {
    return AuthenticationException(
      code: unknown,
      message: 'An unexpected error occurred. Please try again.',
      details: exception.toString(),
    );
  }
}