import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase_options.dart';
import '../logging/phoenix_logger.dart';

/// Status of an individual Firebase service.
enum FirebaseServiceStatus {
  /// Service is connected and operational.
  connected('Connected'),

  /// Service is not configured or unavailable.
  unavailable('Unavailable'),

  /// Service initialization failed.
  error('Error');

  const FirebaseServiceStatus(this.displayName);
  final String displayName;

  bool get isOperational => this == FirebaseServiceStatus.connected;
}

/// Result of a Firebase service health check.
class FirebaseHealthResult {
  const FirebaseHealthResult({
    required this.service,
    required this.status,
    this.message = '',
  });

  final String service;
  final FirebaseServiceStatus status;
  final String message;

  bool get isHealthy => status.isOperational;
}

/// Firebase Service — wraps Firebase initialization and provides health
/// monitoring for all configured Firebase services.
///
/// **Architecture:**
/// ```text
/// main()
///   ↓
/// FirebaseService.ensureInitialized()
///   ↓
/// AppBootstrap.init()
///   ↓
/// DiagnosticsService (via FirebaseService.health)
/// ```
///
/// **Rules:**
/// - No widgets access Firebase directly
/// - Initialization is optional — graceful failure if not configured
/// - All services are optional — only report connected/unavailable
/// - Offline persistence is always enabled for Firestore
///
/// **Environment Support:**
/// - Development: firebase_options_dev.dart (future)
/// - Staging: firebase_options_staging.dart (future)
/// - Production: firebase_options.dart
class FirebaseService {
  FirebaseService._();
  static final PhoenixLogger _logger = PhoenixLogger.shared;

  static bool _initialized = false;
  static bool _initAttempted = false;
  static String? _initError;
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static FirebaseRemoteConfig? _remoteConfig;
  static FirebasePerformance? _performance;

  // ── Accessors ─────────────────────────────────────────────────────

  /// Whether Firebase has been initialized.
  static bool get isInitialized => _initialized;

  /// Whether an initialization attempt was made.
  static bool get wasInitAttempted => _initAttempted;

  /// The initialization error message, if any.
  static String? get initError => _initError;

  /// The Firebase app instance.
  static FirebaseApp? get app => _app;

  /// Firebase Auth instance (null if unavailable).
  static FirebaseAuth? get auth => _auth;

  /// Cloud Firestore instance (null if unavailable).
  static FirebaseFirestore? get firestore => _firestore;

  /// Cloud Storage instance (null if unavailable).
  static FirebaseStorage? get storage => _storage;

  /// Firebase Analytics instance (null if unavailable).
  static FirebaseAnalytics? get analytics => _analytics;

  /// Firebase Crashlytics instance (null if unavailable).
  static FirebaseCrashlytics? get crashlytics => _crashlytics;

  /// Firebase Remote Config instance (null if unavailable).
  static FirebaseRemoteConfig? get remoteConfig => _remoteConfig;

  /// Firebase Performance instance (null if unavailable).
  static FirebasePerformance? get performance => _performance;

  // ── Initialization ────────────────────────────────────────────────

  /// Ensures Firebase is initialized.
  ///
  /// Must be called once before [AppBootstrap.init()].
  /// Gracefully handles initialization failures — never crashes.
  ///
  /// Returns `true` if initialization succeeded, `false` otherwise.
  static Future<bool> ensureInitialized() async {
    if (_initAttempted) return _initialized;
    _initAttempted = true;

    try {
      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize optional services with graceful failure
      await _initOptionalServices();

      // Enable Firestore offline persistence
      try {
        if (_firestore != null) {
          _firestore!.settings = _firestore!.settings.copyWith(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
          _logger.info('Firebase: Firestore offline persistence enabled',
              category: LogCategory.diagnostics, source: 'FirebaseService');
        }
      } catch (e) {
        _logger.warning('Firebase: Firestore persistence setup failed: $e',
            category: LogCategory.diagnostics, source: 'FirebaseService');
      }

      // Enable Crashlytics crash collection in non-debug mode
      try {
        if (_crashlytics != null && !kDebugMode) {
          FlutterError.onError = (errorDetails) {
            _crashlytics!.recordFlutterFatalError(errorDetails);
          };
          PlatformDispatcher.instance.onError = (error, stack) {
            _crashlytics!.recordError(error, stack, fatal: true);
            return true;
          };
          _logger.info('Firebase: Crashlytics enabled',
              category: LogCategory.diagnostics, source: 'FirebaseService');
        }
      } catch (e) {
        _logger.warning('Firebase: Crashlytics setup failed: $e',
            category: LogCategory.diagnostics, source: 'FirebaseService');
      }

      _initialized = true;
      _logger.info('Firebase initialized successfully',
          category: LogCategory.diagnostics, source: 'FirebaseService');
      return true;
    } catch (e) {
      _initError = e.toString();
      _logger.error('Firebase initialization failed: $e',
          category: LogCategory.diagnostics, source: 'FirebaseService');
      return false;
    }
  }

  /// Attempts to initialize each optional Firebase service independently.
  ///
  /// If a service is not configured (e.g. no Firebase project support),
  /// it is simply skipped — no crash or warning.
  static Future<void> _initOptionalServices() async {
    // Firebase Authentication (optional)
    try {
      _auth = FirebaseAuth.instance;
      _logger.info('Firebase Auth available',
          category: LogCategory.diagnostics, source: 'FirebaseService');
    } catch (_) {
      _auth = null;
    }

    // Cloud Firestore (optional)
    try {
      _firestore = FirebaseFirestore.instance;
      _logger.info('Cloud Firestore available',
          category: LogCategory.diagnostics, source: 'FirebaseService');
    } catch (_) {
      _firestore = null;
    }

    // Cloud Storage (optional)
    try {
      _storage = FirebaseStorage.instance;
      _logger.info('Cloud Storage available',
          category: LogCategory.diagnostics, source: 'FirebaseService');
    } catch (_) {
      _storage = null;
    }

    // Firebase Analytics (optional)
    try {
      _analytics = FirebaseAnalytics.instance;
      _logger.info('Firebase Analytics available',
          category: LogCategory.diagnostics, source: 'FirebaseService');
    } catch (_) {
      _analytics = null;
    }

    // Firebase Crashlytics (optional)
    try {
      _crashlytics = FirebaseCrashlytics.instance;
      // Set crashlytics collection enabled
      await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);
      _logger.info('Firebase Crashlytics available',
          category: LogCategory.diagnostics, source: 'FirebaseService');
    } catch (_) {
      _crashlytics = null;
    }

    // Firebase Remote Config (optional)
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setDefaults(const {});
      _logger.info('Firebase Remote Config available',
          category: LogCategory.diagnostics, source: 'FirebaseService');
    } catch (_) {
      _remoteConfig = null;
    }

    // Firebase Performance (optional)
    try {
      _performance = FirebasePerformance.instance;
      _logger.info('Firebase Performance available',
          category: LogCategory.diagnostics, source: 'FirebaseService');
    } catch (_) {
      _performance = null;
    }
  }

  // ── Health Checks ─────────────────────────────────────────────────

  /// Returns health status for all Firebase services.
  static List<FirebaseHealthResult> checkHealth() {
    return [
      FirebaseHealthResult(
        service: 'Firebase Core',
        status: _initialized
            ? FirebaseServiceStatus.connected
            : _initAttempted
                ? FirebaseServiceStatus.error
                : FirebaseServiceStatus.unavailable,
        message: _initialized ? 'Connected' : (_initError ?? 'Not initialized'),
      ),
      FirebaseHealthResult(
        service: 'Authentication',
        status: _auth != null
            ? FirebaseServiceStatus.connected
            : FirebaseServiceStatus.unavailable,
      ),
      FirebaseHealthResult(
        service: 'Cloud Firestore',
        status: _firestore != null
            ? FirebaseServiceStatus.connected
            : FirebaseServiceStatus.unavailable,
        message: _firestore != null
            ? 'Persistence enabled'
            : 'Not configured',
      ),
      FirebaseHealthResult(
        service: 'Cloud Storage',
        status: _storage != null
            ? FirebaseServiceStatus.connected
            : FirebaseServiceStatus.unavailable,
      ),
      FirebaseHealthResult(
        service: 'Analytics',
        status: _analytics != null
            ? FirebaseServiceStatus.connected
            : FirebaseServiceStatus.unavailable,
      ),
      FirebaseHealthResult(
        service: 'Crashlytics',
        status: _crashlytics != null
            ? FirebaseServiceStatus.connected
            : FirebaseServiceStatus.unavailable,
        message: _crashlytics != null
            ? 'Collection ${!kDebugMode ? "enabled" : "disabled (debug)"}'
            : 'Not configured',
      ),
      FirebaseHealthResult(
        service: 'Remote Config',
        status: _remoteConfig != null
            ? FirebaseServiceStatus.connected
            : FirebaseServiceStatus.unavailable,
      ),
      FirebaseHealthResult(
        service: 'Performance',
        status: _performance != null
            ? FirebaseServiceStatus.connected
            : FirebaseServiceStatus.unavailable,
      ),
    ];
  }

  /// Returns a map of Firebase health data for diagnostics export.
  static Map<String, dynamic> exportHealth() {
    final results = checkHealth();
    return {
      'initialized': _initialized,
      'initAttempted': _initAttempted,
      'initError': _initError,
      'services': {
        for (final r in results) r.service: {
          'status': r.status.displayName,
          'message': r.message,
          'healthy': r.isHealthy,
        },
      },
    };
  }
}
