import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../features/user_state/engine/user_state_engine.dart';
import '../features/user_state/repository/user_state_repository.dart';
import '../features/user_state/services/user_state_service.dart';
import '../routes/app_router.dart';
import '../theme/theme.dart';
import 'storage_service.dart';

/// Application bootstrap and startup orchestration.
///
/// Separates startup responsibilities into clearly named methods
/// so the application entry point remains focused and testable.
///
/// Current responsibilities:
///   - Application widget creation
///   - Storage service lifecycle
///
/// Future responsibilities may include:
///   - Service initialization
///   - Persistence setup
///   - Logging configuration
///   - Environment detection
class AppBootstrap {
  AppBootstrap._();

  /// The application-wide [StorageService] instance.
  ///
  /// Initialized once during [init] and accessible throughout the app.
  static StorageService? _storageService;

  /// Returns the initialized [StorageService] instance.
  ///
  /// Throws if [init] has not been called yet.
  static StorageService get storageService {
    assert(
      _storageService != null,
      'StorageService not initialized. Call AppBootstrap.init() first.',
    );
    return _storageService!;
  }

  /// The application-wide [UserStateService] instance.
  ///
  /// Initialized once during [init] and accessible throughout the app.
  /// All feature modules read and write user state through this service.
  static UserStateService? _userStateService;

  /// Returns the initialized [UserStateService] instance.
  ///
  /// Throws if [init] has not been called yet.
  static UserStateService get userStateService {
    assert(
      _userStateService != null,
      'UserStateService not initialized. Call AppBootstrap.init() first.',
    );
    return _userStateService!;
  }

  /// Returns the [UserStateService] instance or `null` if not initialized.
  ///
  /// Safe for use in screens and widgets that may render before
  /// [init] completes.
  static UserStateService? get maybeUserStateService => _userStateService;

  /// Initializes all app-wide services.
  ///
  /// Must be called once before [createApp]. Currently initializes:
  ///   - [SharedPreferencesStorageService]
  ///   - [UserStateService]
  static Future<void> init() async {
    final storage = SharedPreferencesStorageService();
    await storage.init();
    _storageService = storage;

    final userStateRepo = UserStateRepository();
    final userStateEngine = UserStateEngine(repository: userStateRepo);
    final userStateService = UserStateService(engine: userStateEngine);
    await userStateService.init();
    _userStateService = userStateService;
  }

  /// Creates the root [PhoenixApp] widget with all required configuration.
  ///
  /// This is the single entry point for building the application tree.
  /// All app-wide dependencies must be initialized before this call.
  static Widget createApp() {
    return const PhoenixApp();
  }
}

/// The root widget of the Phoenix Platform application.
///
/// Owns the MaterialApp configuration including theme,
/// routing, and display settings.
class PhoenixApp extends StatelessWidget {
  const PhoenixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppConfig.initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
