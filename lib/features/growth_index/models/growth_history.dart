import 'growth_metrics.dart';

/// Tracks growth metrics snapshots over different time periods.
///
/// Each list contains [GrowthMetrics] collected during its respective
/// period, allowing the [GrowthIndexEngine] to compute trends and
/// visualize growth progression over time.
class GrowthHistory {
  const GrowthHistory({
    this.daily = const <GrowthMetrics>[],
    this.weekly = const <GrowthMetrics>[],
    this.monthly = const <GrowthMetrics>[],
  });

  /// Snapshots collected during the current day (one per refresh).
  final List<GrowthMetrics> daily;

  /// Per-dimension averages aggregated weekly.
  final List<GrowthMetrics> weekly;

  /// Per-dimension averages aggregated monthly.
  final List<GrowthMetrics> monthly;

  /// The most recent daily metrics, or `null` if no history.
  List<GrowthMetrics>? get latestDaily => daily.isNotEmpty ? daily : null;

  /// Returns a copy with the given fields replaced.
  GrowthHistory copyWith({
    List<GrowthMetrics>? daily,
    List<GrowthMetrics>? weekly,
    List<GrowthMetrics>? monthly,
  }) {
    return GrowthHistory(
      daily: daily ?? this.daily,
      weekly: weekly ?? this.weekly,
      monthly: monthly ?? this.monthly,
    );
  }

  @override
  String toString() =>
      'GrowthHistory(daily: ${daily.length}, '
      'weekly: ${weekly.length}, monthly: ${monthly.length})';
}
