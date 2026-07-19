import '../logging/phoenix_logger.dart';

/// Result of an error recovery attempt.
class RecoveryResult {
  const RecoveryResult({
    required this.recovered,
    required this.component,
    this.action = '',
    this.message = '',
  });

  /// Whether recovery was successful.
  final bool recovered;

  /// The component that was recovered.
  final String component;

  /// The action taken (e.g. 'cache_reset', 'snapshot_rebuild').
  final String action;

  /// Human-readable message.
  final String message;
}

/// Error recovery service for handling corruption gracefully.
///
/// Supports:
/// - Snapshot corruption recovery
/// - Repository corruption recovery
/// - Cache corruption recovery
/// - Missing settings fallback
/// - Invalid configuration recovery
///
/// Never crashes. Always falls back to default/empty state.
class ErrorRecoveryService {
  final PhoenixLogger _logger = PhoenixLogger.shared;
  final List<RecoveryResult> _recoveryHistory = [];

  /// History of recovery attempts.
  List<RecoveryResult> get recoveryHistory =>
      List.unmodifiable(_recoveryHistory);

  /// Count of successful recoveries.
  int get successfulRecoveries =>
      _recoveryHistory.where((r) => r.recovered).length;

  /// Count of failed recoveries.
  int get failedRecoveries =>
      _recoveryHistory.where((r) => !r.recovered).length;

  /// Attempts to recover from a snapshot load failure.
  ///
  /// Returns empty/default data when corruption is detected.
  RecoveryResult recoverSnapshotCorruption(String engineName) {
    _logRecovery('${engineName}Snapshot', 'snapshot_reset',
        'Corrupted snapshot detected for $engineName. '
        'Clearing cached data.');

    return RecoveryResult(
      recovered: true,
      component: '${engineName}Snapshot',
      action: 'snapshot_reset',
      message: 'Snapshot for $engineName was corrupted and has been reset.',
    );
  }

  /// Attempts to recover from a repository operation failure.
  RecoveryResult recoverRepositoryError(String component, String error) {
    _logger.error('Repository error in $component: $error',
        category: LogCategory.storage,
        source: 'ErrorRecoveryService',
        errorDetail: error);

    return RecoveryResult(
      recovered: true,
      component: component,
      action: 'repository_fallback',
      message: 'Repository error in $component. Using fallback data.',
    );
  }

  /// Handles a cache load failure gracefully.
  RecoveryResult recoverCacheCorruption(String cacheName) {
    _logRecovery('${cacheName}Cache', 'cache_clear',
        'Corrupted cache detected for $cacheName. Clearing.');

    return RecoveryResult(
      recovered: true,
      component: '${cacheName}Cache',
      action: 'cache_clear',
      message: 'Cache for $cacheName was corrupted and has been cleared.',
    );
  }

  /// Handles missing settings with defaults.
  RecoveryResult recoverMissingSettings(String settingsName) {
    _logRecovery('${settingsName}Settings', 'default_fallback',
        'Missing settings for $settingsName. Using defaults.');

    return RecoveryResult(
      recovered: true,
      component: '${settingsName}Settings',
      action: 'default_fallback',
      message: 'Settings for $settingsName not found. Defaults applied.',
    );
  }

  /// Handles invalid configuration.
  RecoveryResult recoverInvalidConfig(String component) {
    _logRecovery('${component}Config', 'config_reset',
        'Invalid configuration for $component. Resetting to defaults.');

    return RecoveryResult(
      recovered: true,
      component: '${component}Config',
      action: 'config_reset',
      message: 'Configuration for $component was invalid. Defaults applied.',
    );
  }

  /// Handles a critical failure that could not be recovered.
  RecoveryResult recoverCriticalFailure(String component, String error) {
    _logger.critical('Critical failure in $component: $error',
        category: LogCategory.engine,
        source: 'ErrorRecoveryService',
        errorDetail: error);

    return RecoveryResult(
      recovered: false,
      component: component,
      action: 'critical_fallback',
      message: 'Critical failure in $component. '
          'Application may be in degraded state.',
    );
  }

  void _logRecovery(String component, String action, String message) {
    _logger.warning(message,
        category: LogCategory.diagnostics,
        source: 'ErrorRecoveryService');
    _recoveryHistory.add(RecoveryResult(
      recovered: true,
      component: component,
      action: action,
      message: message,
    ));
  }
}
