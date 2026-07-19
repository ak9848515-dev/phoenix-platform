import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/provider_config.dart';

/// Callback invoked when a provider's health status changes.
///
/// [providerId] identifies the provider, [newStatus] is the updated
/// health state, and [previousStatus] is the state before the change.
typedef HealthStatusChangeCallback = void Function(
  String providerId,
  ProviderHealthStatus newStatus,
  ProviderHealthStatus previousStatus,
);

/// Monitors the health of AI providers.
///
/// Tracks health state transitions and provides a single source
/// of truth for provider availability. Supports periodic health
/// checks and listener notifications on state changes.
///
/// Health states:
/// - [ProviderHealthStatus.healthy]
/// - [ProviderHealthStatus.unavailable]
/// - [ProviderHealthStatus.authenticationFailed]
/// - [ProviderHealthStatus.rateLimited]
/// - [ProviderHealthStatus.offline]
/// - [ProviderHealthStatus.unknown]
///
/// No UI. No persistence. Pure state tracking.
class HealthMonitor {
  HealthMonitor({this.checkInterval = const Duration(minutes: 5)});

  /// Interval between automatic health checks.
  final Duration checkInterval;

  final PhoenixLogger _logger = PhoenixLogger.shared;
  final Map<String, ProviderHealthStatus> _healthStates = {};
  final Map<String, DateTime> _lastCheckTimes = {};
  final List<HealthStatusChangeCallback> _listeners = [];
  Timer? _periodicTimer;

  // ── Accessors ────────────────────────────────────────────────────

  /// Returns the current health status for a provider.
  ProviderHealthStatus getHealth(String providerId) =>
      _healthStates[providerId] ?? ProviderHealthStatus.unknown;

  /// Returns all tracked provider health statuses.
  Map<String, ProviderHealthStatus> get allHealth =>
      Map.unmodifiable(_healthStates);

  /// Returns only providers with error statuses.
  Map<String, ProviderHealthStatus> get errorProviders =>
      Map.fromEntries(_healthStates.entries.where((e) => e.value.isError));

  /// Returns only providers with operational statuses.
  Map<String, ProviderHealthStatus> get operationalProviders =>
      Map.fromEntries(
          _healthStates.entries.where((e) => e.value.isOperational));

  /// Whether any provider has an error status.
  bool get hasErrors => _healthStates.values.any((s) => s.isError);

  /// When a provider was last checked.
  DateTime? lastCheckTime(String providerId) => _lastCheckTimes[providerId];

  /// How long since a provider was last checked.
  Duration? timeSinceLastCheck(String providerId) {
    final last = _lastCheckTimes[providerId];
    if (last == null) return null;
    return DateTime.now().difference(last);
  }

  // ── Lifecycle ────────────────────────────────────────────────────

  /// Initializes the monitor with initial health states for a set
  /// of providers. Does not start periodic checks.
  void initialize(List<String> providerIds) {
    for (final id in providerIds) {
      _healthStates.putIfAbsent(id, () => ProviderHealthStatus.unknown);
    }
    _logger.info('HealthMonitor initialized with ${providerIds.length} providers',
        category: LogCategory.diagnostics, source: 'HealthMonitor');
  }

  /// Starts periodic health checks. Call [stopPeriodicChecks] to cancel.
  void startPeriodicChecks({VoidCallback? onCheck}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(checkInterval, (_) {
      _performPeriodicCheck(onCheck: onCheck);
    });
    _logger.info('HealthMonitor periodic checks started (interval: ${checkInterval.inMinutes}m)',
        category: LogCategory.diagnostics, source: 'HealthMonitor');
  }

  /// Stops periodic health checks.
  void stopPeriodicChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _logger.info('HealthMonitor periodic checks stopped',
        category: LogCategory.diagnostics, source: 'HealthMonitor');
  }

  /// Disposes all resources.
  void dispose() {
    stopPeriodicChecks();
    _listeners.clear();
    _healthStates.clear();
    _lastCheckTimes.clear();
  }

  // ── Status Updates ───────────────────────────────────────────────

  /// Updates the health status for a provider and notifies listeners
  /// if the status changed.
  void reportHealth({
    required String providerId,
    required ProviderHealthStatus status,
  }) {
    final previous = _healthStates[providerId] ?? ProviderHealthStatus.unknown;
    _healthStates[providerId] = status;
    _lastCheckTimes[providerId] = DateTime.now();

    if (previous != status) {
      _notifyListeners(providerId, status, previous);
      _logger.info('Health status changed for $providerId: ${previous.displayName} -> ${status.displayName}',
          category: LogCategory.diagnostics, source: 'HealthMonitor');
    }
  }

  /// Resets a provider's health status to unknown.
  void resetHealth(String providerId) {
    reportHealth(
      providerId: providerId,
      status: ProviderHealthStatus.unknown,
    );
  }

  /// Resets all provider health statuses to unknown.
  void resetAll() {
    for (final id in _healthStates.keys.toList()) {
      reportHealth(providerId: id, status: ProviderHealthStatus.unknown);
    }
  }

  // ── Listeners ────────────────────────────────────────────────────

  /// Registers a listener for health status changes.
  void addListener(HealthStatusChangeCallback listener) {
    _listeners.add(listener);
  }

  /// Removes a previously registered listener.
  void removeListener(HealthStatusChangeCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(
    String providerId,
    ProviderHealthStatus newStatus,
    ProviderHealthStatus previousStatus,
  ) {
    for (final listener in _listeners) {
      listener(providerId, newStatus, previousStatus);
    }
  }

  // ── Internal ─────────────────────────────────────────────────────

  void _performPeriodicCheck({VoidCallback? onCheck}) {
    _logger.debug('HealthMonitor periodic check',
        category: LogCategory.diagnostics, source: 'HealthMonitor');
    onCheck?.call();
  }
}
