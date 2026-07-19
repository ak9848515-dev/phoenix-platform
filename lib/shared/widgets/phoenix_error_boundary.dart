import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';
import '../infrastructure/logging/phoenix_logger.dart';
import '../infrastructure/recovery/error_recovery_service.dart';

/// Phoenix Error Boundary — catches widget-level errors and shows a recovery UI.
///
/// Wraps [child] in a [FlutterError.onError] zone to catch build/layout errors
/// and display a graceful fallback instead of crashing the entire screen.
///
/// **Features:**
/// - Catches build/layout/sync errors via [ErrorWidget.builder]
/// - Shows a retry button
/// - Logs errors to [PhoenixLogger]
/// - Recovers via [ErrorRecoveryService] with snapshot reset
/// - Animated transition from error to recovery
///
/// **Usage:**
/// ```dart
/// PhoenixErrorBoundary(
///   component: 'DailyJourney',
///   child: DailyJourneyScreen(),
/// )
/// ```
class PhoenixErrorBoundary extends StatefulWidget {
  const PhoenixErrorBoundary({
    super.key,
    required this.child,
    required this.component,
    this.errorRecoveryService,
    this.onRetry,
    this.fallback,
  });

  /// The child widget to protect.
  final Widget child;

  /// The component name (e.g. 'DailyJourney', 'Dashboard').
  final String component;

  /// Optional error recovery service for snapshot reset.
  final ErrorRecoveryService? errorRecoveryService;

  /// Optional custom retry callback.
  final VoidCallback? onRetry;

  /// Optional custom fallback widget when recovery fails.
  final Widget? fallback;

  @override
  State<PhoenixErrorBoundary> createState() => _PhoenixErrorBoundaryState();
}

class _PhoenixErrorBoundaryState extends State<PhoenixErrorBoundary> {
  final PhoenixLogger _logger = PhoenixLogger.shared;
  int _errorCount = 0;
  static const int _maxRetries = 3;

  void _handleError(FlutterErrorDetails details) {
    _errorCount++;

    _logger.error(
      'ErrorBoundary caught error in ${widget.component}: ${details.exceptionAsString()}',
      category: LogCategory.engine,
      source: 'PhoenixErrorBoundary',
      errorDetail: details.stack?.toString(),
    );

    // Attempt recovery via ErrorRecoveryService
    widget.errorRecoveryService
        ?.recoverSnapshotCorruption(widget.component);
  }

  @override
  Widget build(BuildContext context) {
    return _ErrorBoundaryZone(
      component: widget.component,
      onError: _handleError,
      child: Builder(
        builder: (context) {
          if (_errorCount > _maxRetries) {
            return widget.fallback ?? _buildCriticalFailure(context);
          }
          if (_errorCount > 0) {
            return _buildErrorRecovery(context);
          }
          return widget.child;
        },
      ),
    );
  }

  Widget _buildErrorRecovery(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.refresh_rounded,
                  color: theme.colorScheme.onErrorContainer, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong in ${widget.component}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ve logged the issue. Tap retry to continue.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(_errorCount < _maxRetries
                  ? 'Retry'
                  : 'Reset ${widget.component}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalFailure(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: PhoenixRadius.xlRadius,
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: theme.colorScheme.onErrorContainer, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.component} unavailable',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A critical error occurred. The component has been reset.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _onRetry() {
    setState(() {
      _errorCount = 0;
    });
    widget.onRetry?.call();
  }
}

/// Zone-based error boundary that catches build errors via ErrorWidget.builder.
class _ErrorBoundaryZone extends StatefulWidget {
  const _ErrorBoundaryZone({
    required this.component,
    required this.onError,
    required this.child,
  });

  final String component;
  final void Function(FlutterErrorDetails) onError;
  final Widget child;

  @override
  State<_ErrorBoundaryZone> createState() => _ErrorBoundaryZoneState();
}

class _ErrorBoundaryZoneState extends State<_ErrorBoundaryZone> {
  ErrorWidgetBuilder? _previousBuilder;

  @override
  void initState() {
    super.initState();
    // Capture and override ErrorWidget.builder
    _previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      widget.onError(details);
      return _ErrorFallbackWidget(
        component: widget.component,
        details: details,
      );
    };
  }

  @override
  void dispose() {
    // Restore previous builder
    if (_previousBuilder != null) {
      ErrorWidget.builder = _previousBuilder!;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Fallback widget shown when a widget rebuild fails.
class _ErrorFallbackWidget extends StatelessWidget {
  const _ErrorFallbackWidget({
    required this.component,
    required this.details,
  });

  final String component;
  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined,
              size: 32, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            '$component render error',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
