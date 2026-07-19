import 'growth_dimension.dart';
import 'growth_trend.dart';

/// Immutable metrics for a single growth dimension.
///
/// Each [GrowthDimension] produces one [GrowthMetrics] instance containing
/// its current score (0.0–1.0), trend direction, and optional metadata.
class GrowthMetrics {
  const GrowthMetrics({
    required this.dimension,
    required this.score,
    this.trend = GrowthTrend.stable,
    this.previousScore,
    this.label = '',
    this.detail = '',
  });

  /// Which dimension these metrics describe.
  final GrowthDimension dimension;

  /// Current score (0.0–1.0) for this dimension.
  final double score;

  /// Trend direction compared to the previous measurement.
  final GrowthTrend trend;

  /// The previous score before [score], used for trend calculation.
  final double? previousScore;

  /// Short human-readable label (e.g. "8/10 skills").
  final String label;

  /// Optional detailed description of the metrics.
  final String detail;

  /// Returns a copy with the given fields replaced.
  GrowthMetrics copyWith({
    GrowthDimension? dimension,
    double? score,
    GrowthTrend? trend,
    double? previousScore,
    String? label,
    String? detail,
  }) {
    return GrowthMetrics(
      dimension: dimension ?? this.dimension,
      score: score ?? this.score,
      trend: trend ?? this.trend,
      previousScore: previousScore ?? this.previousScore,
      label: label ?? this.label,
      detail: detail ?? this.detail,
    );
  }

  @override
  String toString() =>
      'GrowthMetrics(${dimension.displayName}: ${(score * 100).round()}%, '
      'trend: ${trend.displayName})';
}
