import '../logging/phoenix_logger.dart';

/// A single performance measurement.
class PerformanceMetric {
  const PerformanceMetric({
    required this.name,
    required this.elapsedMs,
    this.timestamp,
    this.category = '',
    this.success = true,
  });

  final String name;
  final int elapsedMs;
  final DateTime? timestamp;
  final String category;
  final bool success;

  @override
  String toString() => '$name: ${elapsedMs}ms (${success ? "OK" : "FAIL"})';
}

/// Aggregated statistics for a performance metric.
class MetricStats {
  const MetricStats({
    required this.name,
    required this.count,
    required this.minMs,
    required this.maxMs,
    required this.avgMs,
    required this.totalMs,
    this.lastMs = 0,
  });

  final String name;
  final int count;
  final int minMs;
  final int maxMs;
  final double avgMs;
  final int totalMs;
  final int lastMs;
}

/// Performance monitor for engine operations.
///
/// Measures and tracks timing of engine startup, refresh, observer events,
/// snapshot builds, memory search, recommendation evaluation, and more.
class PerformanceMonitor {
  final PhoenixLogger _logger = PhoenixLogger.shared;
  final List<PerformanceMetric> _metrics = [];

  /// All recorded metrics (unmodifiable).
  List<PerformanceMetric> get metrics => List.unmodifiable(_metrics);

  /// Recent metrics.
  List<PerformanceMetric> recent([int count = 50]) =>
      _metrics.length <= count
          ? List.unmodifiable(_metrics)
          : List.unmodifiable(_metrics.sublist(_metrics.length - count));

  /// Metrics for a specific category.
  List<PerformanceMetric> forCategory(String category) =>
      _metrics.where((m) => m.category == category).toList();

  /// Metrics for a specific name.
  List<PerformanceMetric> forName(String name) =>
      _metrics.where((m) => m.name == name).toList();

  /// Statistics for a specific metric name.
  MetricStats stats(String name) {
    final matching = _metrics.where((m) => m.name == name).toList();
    if (matching.isEmpty) {
      return MetricStats(name: name, count: 0, minMs: 0, maxMs: 0, avgMs: 0, totalMs: 0);
    }
    final min = matching.map((m) => m.elapsedMs).reduce((a, b) => a < b ? a : b);
    final max = matching.map((m) => m.elapsedMs).reduce((a, b) => a > b ? a : b);
    final total = matching.fold<int>(0, (s, m) => s + m.elapsedMs);
    return MetricStats(
      name: name,
      count: matching.length,
      minMs: min,
      maxMs: max,
      avgMs: total / matching.length,
      totalMs: total,
      lastMs: matching.last.elapsedMs,
    );
  }

  /// Records a measurement and logs it.
  void record(String name, int elapsedMs, {String category = '', bool success = true, bool logToConsole = true}) {
    final metric = PerformanceMetric(
      name: name,
      elapsedMs: elapsedMs,
      timestamp: DateTime.now(),
      category: category,
      success: success,
    );
    _metrics.add(metric);

    if (logToConsole) {
      _logger.info('$name completed in ${elapsedMs}ms',
          category: LogCategory.performance,
          source: category.isNotEmpty ? category : name,
          elapsedMs: elapsedMs);
    }
  }

  /// Times an async operation and records the result.
  Future<T> time<T>(String name, Future<T> Function() operation, {String category = ''}) async {
    final start = DateTime.now();
    try {
      final result = await operation();
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      record(name, elapsed, category: category, success: true);
      return result;
    } catch (e) {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      record(name, elapsed, category: category, success: false);
      rethrow;
    }
  }

  /// All unique metric names.
  List<String> get metricNames =>
      _metrics.map((m) => m.name).toSet().toList();

  /// All unique categories.
  List<String> get categories =>
      _metrics.map((m) => m.category).toSet().toList();

  /// Count of recorded metrics.
  int get count => _metrics.length;

  /// Clears all metrics.
  void clear() => _metrics.clear();
}
