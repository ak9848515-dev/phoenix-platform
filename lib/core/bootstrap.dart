import 'package:flutter/material.dart';

import '../config/app_config.dart';
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

  /// Initializes all app-wide services.
  ///
  /// Must be called once before [createApp]. Currently initializes:
  ///   - [SharedPreferencesStorageService]
  static Future<void> init() async {
    final storage = SharedPreferencesStorageService();
    await storage.init();
    _storageService = storage;
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
