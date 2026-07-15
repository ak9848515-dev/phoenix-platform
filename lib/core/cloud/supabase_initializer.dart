import 'package:flutter/foundation.dart';

import 'cloud_config.dart' show CloudConfig;
import 'supabase_client.dart' show SupabaseClient;

/// Initialises the Supabase backend connection.
///
/// Called once during [AppBootstrap.init] before any cloud operation.
/// Gracefully falls back to local-only mode if the cloud is unreachable.
///
/// **Architecture Rules:**
/// - Called once during bootstrap — never accessed by features
/// - Provides environment-aware configuration via [CloudConfig]
/// - Falls back silently to local-only if cloud init fails
class SupabaseInitializer {
  SupabaseInitializer._();

  static final SupabaseInitializer _instance = SupabaseInitializer._();

  /// Singleton instance.
  static SupabaseInitializer get instance => _instance;

  bool _initialized = false;
  bool _hasError = false;
  String? _errorMessage;

  /// Whether the Supabase backend was successfully initialised.
  bool get isInitialized => _initialized;

  /// Whether the initialisation encountered an error.
  bool get hasError => _hasError;

  /// Error message from a failed initialisation, or `null`.
  String? get errorMessage => _errorMessage;

  /// Initialises the Supabase backend.
  ///
  /// 1. Reads the active environment from [CloudConfig]
  /// 2. Attempts to initialise the [SupabaseClient]
  /// 3. Attempts to restore any previous session
  /// 4. On failure, sets [hasError] to `true` and returns `false`
  ///
  /// Returns `true` on success, `false` on failure (local-only fallback).
  Future<bool> init() async {
    if (_initialized) return true;

    debugPrint('SupabaseInitializer: initialising for ${CloudConfig.environment.label}');

    try {
      await SupabaseClient.instance.init();

      // Attempt to restore previous session
      await SupabaseClient.instance.tryRefreshSession();

      _initialized = true;
      _hasError = false;
      _errorMessage = null;
      debugPrint('SupabaseInitializer: initialised successfully');
      return true;
    } catch (e) {
      _initialized = false;
      _hasError = true;
      _errorMessage = e.toString();
      debugPrint('SupabaseInitializer: init failed — falling back to local-only: $e');
      return false;
    }
  }

  /// Resets the initialiser state (for testing or environment switching).
  void reset() {
    _initialized = false;
    _hasError = false;
    _errorMessage = null;
  }
}
