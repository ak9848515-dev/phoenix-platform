import 'package:flutter/material.dart';

import 'core/bootstrap.dart';
import 'core/cloud/firestore_sync_adapter.dart';
import 'shared/infrastructure/firebase/firebase_service.dart';
import 'shared/infrastructure/logging/phoenix_logger.dart';
import 'shared/infrastructure/monitoring/performance_monitor.dart';

export 'core/bootstrap.dart' show PhoenixApp;

final PhoenixLogger _logger = PhoenixLogger.shared;
final PerformanceMonitor _perfMonitor = PerformanceMonitor();

/// Global app lifecycle handler for background/foreground state management.
class _AppLifecycleHandler extends WidgetsBindingObserver {
  _AppLifecycleHandler(this._syncAdapter);

  final FirestoreSyncAdapter? _syncAdapter;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Push lifecycle state to diagnostics service
    final diagnostics = AppBootstrap.maybeDiagnosticsService;
    diagnostics?.setLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _logger.info('App resumed from background',
            category: LogCategory.engine, source: 'AppLifecycle');
        _syncAdapter?.startBackgroundSync();
        break;
      case AppLifecycleState.paused:
        _logger.info('App paused — entering background',
            category: LogCategory.engine, source: 'AppLifecycle');
        _syncAdapter?.stopBackgroundSync();
        break;
      case AppLifecycleState.inactive:
        _logger.info('App inactive',
            category: LogCategory.engine, source: 'AppLifecycle');
        break;
      case AppLifecycleState.detached:
        _logger.info('App detached',
            category: LogCategory.engine, source: 'AppLifecycle');
        break;
      case AppLifecycleState.hidden:
        _logger.info('App hidden',
            category: LogCategory.engine, source: 'AppLifecycle');
        break;
    }
  }
}

Future<void> main() async {
  final startupStart = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase MUST be initialized before bootstrap (auth/Firestore deps)
  final firebaseInitialized = await _perfMonitor.time(
    'FirebaseInit',
    () => FirebaseService.ensureInitialized(),
    category: 'startup',
  );
  _logger.info(
    'Firebase initialization: ${firebaseInitialized ? "success" : "skipped (graceful)"}',
    category: LogCategory.diagnostics,
    source: 'main',
  );

  // Bootstrap app services with performance tracking
  await _perfMonitor.time(
    'BootstrapInit',
    () => AppBootstrap.init(),
    category: 'startup',
  );

  final startupMs = DateTime.now().difference(startupStart).inMilliseconds;
  final firebaseMs = _perfMonitor.stats('FirebaseInit').lastMs;
  final bootstrapMs = _perfMonitor.stats('BootstrapInit').lastMs;

  // Store startup metrics on AppBootstrap for DiagnosticsService
  AppBootstrap.startupMs = startupMs;
  AppBootstrap.bootstrapMs = bootstrapMs;
  AppBootstrap.firebaseMs = firebaseMs;

  _logger.info('Phoenix startup completed in ${startupMs}ms'
      ' (Firebase: ${firebaseMs}ms, Bootstrap: ${bootstrapMs}ms)',
      category: LogCategory.performance,
      source: 'main',
      elapsedMs: startupMs);

  // Register lifecycle observer
  final lifecycleHandler = _AppLifecycleHandler(
    AppBootstrap.maybeFirestoreSyncAdapter,
  );
  WidgetsBinding.instance.addObserver(lifecycleHandler);

  runApp(AppBootstrap.createApp());
}
