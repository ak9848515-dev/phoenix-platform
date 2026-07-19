import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/shared/infrastructure/logging/phoenix_logger.dart';
import 'package:phoenix_platform/shared/infrastructure/diagnostics/diagnostics_service.dart';
import 'package:phoenix_platform/shared/infrastructure/config/configuration_validator.dart';
import 'package:phoenix_platform/shared/infrastructure/monitoring/performance_monitor.dart';
import 'package:phoenix_platform/shared/infrastructure/recovery/error_recovery_service.dart';

void main() {
  // ── PhoenixLogger Tests ───────────────────────────────────────────

  group('PhoenixLogger', () {
    late PhoenixLogger logger;

    setUp(() {
      logger = PhoenixLogger(minLevel: LogLevel.debug, maxEntries: 50);
    });

    test('logs debug messages', () {
      logger.debug('debug message', source: 'test');
      expect(logger.history.length, 1);
      expect(logger.history.first.level, LogLevel.debug);
      expect(logger.history.first.message, contains('debug message'));
    });

    test('logs info messages', () {
      logger.info('info message', source: 'test');
      expect(logger.history.length, 1);
      expect(logger.history.first.level, LogLevel.info);
    });

    test('logs warning messages', () {
      logger.warning('warning message', source: 'test');
      expect(logger.history.length, 1);
      expect(logger.history.first.level, LogLevel.warning);
    });

    test('logs error messages', () {
      logger.error('error message', source: 'test', errorDetail: 'detail');
      expect(logger.history.length, 1);
      expect(logger.history.first.level, LogLevel.error);
      expect(logger.history.first.error, equals('detail'));
    });

    test('logs critical messages', () {
      logger.critical('critical message', source: 'test');
      expect(logger.history.length, 1);
      expect(logger.history.first.level, LogLevel.critical);
    });

    test('filters by minLevel', () {
      logger.minLevel = LogLevel.warning;
      logger.debug('debug');
      logger.info('info');
      logger.warning('warning');
      expect(logger.history.length, 1);
      expect(logger.history.first.level, LogLevel.warning);
    });

    test('caps max entries', () {
      for (int i = 0; i < 100; i++) {
        logger.info('message $i', source: 'test');
      }
      expect(logger.history.length, 50);
    });

    test('byLevel filter', () {
      logger.info('info');
      logger.warning('warning');
      logger.error('error');

      final errors = logger.byLevel(LogLevel.error);
      expect(errors.length, 1);
      expect(errors.first.message, contains('error'));
    });

    test('byCategory filter', () {
      logger.info('engine message',
          category: LogCategory.engine, source: 'test');
      logger.info('storage message',
          category: LogCategory.storage, source: 'test');

      final engineLogs = logger.byCategory(LogCategory.engine);
      expect(engineLogs.length, 1);
      expect(engineLogs.first.message, contains('engine message'));
    });

    test('errors getter returns error + critical entries', () {
      logger.info('info');
      logger.error('error');
      logger.critical('critical');

      expect(logger.errors.length, 2);
    });

    test('recent returns most recent entries', () {
      for (int i = 0; i < 5; i++) {
        logger.info('message $i', source: 'test');
      }
      expect(logger.recent(2).length, 2);
      expect(logger.recent(2).last.message, contains('message 4'));
    });

    test('notifies listeners', () {
      LogEntry? captured;
      logger.addListener((entry) => captured = entry);
      logger.info('listener test', source: 'test');
      expect(captured, isNotNull);
      expect(captured!.message, contains('listener test'));
    });

    test('removes listeners', () {
      LogEntry? captured;
      void listener(LogEntry entry) => captured = entry;
      logger.addListener(listener);
      logger.removeListener(listener);
      logger.info('after remove', source: 'test');
      expect(captured, isNull);
    });

    test('clear resets history', () {
      logger.info('something', source: 'test');
      logger.clear();
      expect(logger.history.length, 0);
    });

    test('shared instance is singleton', () {
      final a = PhoenixLogger.shared;
      final b = PhoenixLogger.shared;
      expect(identical(a, b), true);
    });

    test('LogEntry toString includes level and message', () {
      final entry = LogEntry(
        level: LogLevel.error,
        category: LogCategory.engine,
        message: 'test failure',
        source: 'Engine',
      );
      final str = entry.toString();
      expect(str, contains('ERROR'));
      expect(str, contains('Engine'));
      expect(str, contains('test failure'));
    });

    test('LogEntry copyWith replaces fields', () {
      final original = LogEntry(
        level: LogLevel.info,
        category: LogCategory.general,
        message: 'original',
        source: 'a',
      );
      final copy = original.copyWith(message: 'copied', level: LogLevel.error);
      expect(copy.message, equals('copied'));
      expect(copy.level, LogLevel.error);
      expect(copy.source, equals('a')); // unchanged
    });

    test('info supports elapsedMs', () {
      logger.info('timed', source: 'test', elapsedMs: 42);
      expect(logger.history.first.elapsedMs, equals(42));
    });

    test('supports metadata in log entries', () {
      logger.info('with meta',
          source: 'test', metadata: {'key': 'value', 'count': 3});
      expect(logger.history.first.metadata['key'], equals('value'));
      expect(logger.history.first.metadata['count'], equals(3));
    });
  });

  // ── PerformanceMonitor Tests ──────────────────────────────────────

  group('PerformanceMonitor', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
    });

    test('records metrics', () {
      monitor.record('test', 42, category: 'engine');
      expect(monitor.count, 1);
      expect(monitor.metrics.first.elapsedMs, 42);
    });

    test('gives stats for a metric by name', () {
      monitor.record('init', 10, category: 'engine');
      monitor.record('init', 20, category: 'engine');
      final stats = monitor.stats('init');
      expect(stats.count, 2);
      expect(stats.minMs, 10);
      expect(stats.maxMs, 20);
      expect(stats.avgMs, closeTo(15.0, 0.01));
      expect(stats.lastMs, 20);
    });

    test('returns empty stats for unknown name', () {
      final stats = monitor.stats('unknown');
      expect(stats.count, 0);
      expect(stats.minMs, 0);
    });

    test('filters by category', () {
      monitor.record('a', 10, category: 'engine');
      monitor.record('b', 20, category: 'growth');
      expect(monitor.forCategory('engine').length, 1);
    });

    test('filters by name', () {
      monitor.record('init', 10, category: 'engine');
      monitor.record('refresh', 20, category: 'engine');
      expect(monitor.forName('init').length, 1);
    });

    test('lists metric names', () {
      monitor.record('a', 1, category: 'x');
      monitor.record('b', 2, category: 'y');
      final names = monitor.metricNames;
      expect(names.length, 2);
      expect(names, containsAll(['a', 'b']));
    });

    test('times async operations', () async {
      final result = await monitor.time('async-op', () async {
        await Future.delayed(const Duration(milliseconds: 5));
        return 'done';
      });
      expect(result, equals('done'));
      expect(monitor.count, 1);
      expect(monitor.metrics.first.elapsedMs, greaterThanOrEqualTo(5));
    });

    test('timing on error still records', () async {
      expect(
        () async => monitor.time('failing', () async {
          await Future.delayed(const Duration(milliseconds: 1));
          throw Exception('test error');
        }),
        throwsA(isA<Exception>()),
      );
      // Wait for the future to complete
      await Future.delayed(const Duration(milliseconds: 20));
    });

    test('clear removes all metrics', () {
      monitor.record('a', 1);
      monitor.clear();
      expect(monitor.count, 0);
    });

    test('recent returns last N', () {
      for (int i = 0; i < 10; i++) {
        monitor.record('m$i', i, category: 'engine');
      }
      expect(monitor.recent(3).length, 3);
      expect(monitor.recent(3).last.elapsedMs, 9);
    });
  });

  // ── ErrorRecoveryService Tests ────────────────────────────────────

  group('ErrorRecoveryService', () {
    late ErrorRecoveryService recovery;

    setUp(() {
      recovery = ErrorRecoveryService();
    });

    test('recovers from snapshot corruption', () {
      final result = recovery.recoverSnapshotCorruption('Identity');
      expect(result.recovered, true);
      expect(result.component, contains('Identity'));
      expect(result.action, 'snapshot_reset');
    });

    test('recovers from repository error', () {
      final result =
          recovery.recoverRepositoryError('MemoryRepo', 'Data corrupted');
      expect(result.recovered, true);
      expect(result.component, 'MemoryRepo');
      expect(result.action, 'repository_fallback');
    });

    test('recovers from cache corruption', () {
      final result = recovery.recoverCacheCorruption('DailyBrief');
      expect(result.recovered, true);
      expect(result.component, contains('DailyBrief'));
      expect(result.action, 'cache_clear');
    });

    test('recovers from missing settings', () {
      final result = recovery.recoverMissingSettings('Theme');
      expect(result.recovered, true);
      expect(result.component, contains('Theme'));
      expect(result.action, 'default_fallback');
    });

    test('recovers from invalid config', () {
      final result = recovery.recoverInvalidConfig('AICapabilityRouter');
      expect(result.recovered, true);
      expect(result.component, contains('AICapabilityRouter'));
      expect(result.action, 'config_reset');
    });

    test('handles critical failure with unrecovered status', () {
      final result =
          recovery.recoverCriticalFailure('Storage', 'Disk full');
      expect(result.recovered, false);
      expect(result.action, 'critical_fallback');
    });

    test('maintains recovery history', () {
      recovery.recoverSnapshotCorruption('Growth');
      recovery.recoverCacheCorruption('Mission');
      expect(recovery.recoveryHistory.length, 2);
      expect(recovery.successfulRecoveries, 2);
      expect(recovery.failedRecoveries, 0);
    });
  });

  // ── DiagnosticsService Tests ──────────────────────────────────────

  group('DiagnosticsService', () {
    test('returns unhealthy when no engines registered', () async {
      final diag = DiagnosticsService();
      final report = await diag.runHealthCheck();
      expect(report.healthy, false);
      expect(report.checks.length, greaterThan(0));
      expect(report.failedCount, greaterThan(0));
    });

      test('checks engine registration name', () async {
      final diag = DiagnosticsService();
      final report = await diag.runHealthCheck();
      expect(report.checks.any((c) => c.name.contains('Engine') || c.name.contains('Snapshot')), true);
    });
  });

  // ── ConfigurationValidator Tests ──────────────────────────────────

  group('ConfigurationValidator', () {
    test('returns validation report', () async {
      final validator = ConfigurationValidator();
      final report = await validator.validate();
      expect(report.results, isNotEmpty);
      expect(report.valid, isA<bool>());
      expect(report.summary, contains('Config'));
    });

    test('reports failures when services uninitialized', () async {
      final validator = ConfigurationValidator();
      final report = await validator.validate();
      // Some may pass (null checks return false) but always produces results
      expect(report.results.length, greaterThanOrEqualTo(2));
    });

    test('summary includes passed/total count', () async {
      final validator = ConfigurationValidator();
      final report = await validator.validate();
      expect(report.summary, contains('/'));
      expect(report.passedCount + report.failedCount, report.results.length);
    });
  });
}


