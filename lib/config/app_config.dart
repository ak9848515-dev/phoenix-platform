/// Centralized application configuration.
///
/// All app-wide constants and settings are defined here
/// to keep configuration discoverable and maintainable.
class AppConfig {
  AppConfig._();

  /// The display name for the application.
  static const String appTitle = 'Phoenix Platform';

  /// The initial route shown on app launch.
  ///
  /// Splash screen checks authentication state and routes to
  /// login or dashboard accordingly.
  static const String initialRoute = '/splash';

  /// Whether Material 3 is enabled.
  static const bool useMaterial3 = true;

  /// Whether to use adaptive platform density.
  static const bool useAdaptiveDensity = true;
}
