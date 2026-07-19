/// Determined confidence level for a single forecast.
///
/// Confidence is calculated deterministically based on data quality,
/// sample size, consistency, and trend stability.
enum ForecastConfidenceLevel {
  veryHigh('Very High', 0.85),
  high('High', 0.70),
  moderate('Moderate', 0.50),
  low('Low', 0.30),
  veryLow('Very Low', 0.15),
  insufficient('Insufficient Data', 0.05);

  const ForecastConfidenceLevel(this.displayName, this.minScore);

  final String displayName;
  final double minScore;
}

/// Immutable confidence score for a single prediction.
///
/// - [overall] (0-100): combined confidence from multiple factors
/// - [level]: human-readable [ForecastConfidenceLevel]
/// - [dataQuality] (0.0-1.0): how much data is available
/// - [trendStability] (0.0-1.0): how stable the trend is
/// - [sampleSize] (0.0-1.0): how many data points are available
class ForecastConfidence {
  const ForecastConfidence({
    required this.overall,
    required this.dataQuality,
    required this.trendStability,
    required this.sampleSize,
  });

  /// Combined confidence score (0-100).
  final int overall;

  /// Quality of available data (0.0-1.0).
  final double dataQuality;

  /// Stability of the observed trend (0.0-1.0).
  final double trendStability;

  /// Number of data points relative to ideal (0.0-1.0).
  final double sampleSize;

  /// Human-readable confidence level.
  ForecastConfidenceLevel get level {
    for (final l in ForecastConfidenceLevel.values) {
      if ((overall / 100) >= l.minScore) return l;
    }
    return ForecastConfidenceLevel.insufficient;
  }

  @override
  String toString() =>
      'ForecastConfidence(${level.displayName}: $overall%)';
}
