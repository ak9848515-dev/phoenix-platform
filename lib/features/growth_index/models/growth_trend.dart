/// Direction of growth trend for a specific dimension.
///
/// Computed by [GrowthIndexEngine] by comparing current and previous scores.
enum GrowthTrend {
  /// Score is increasing over the measured period.
  improving('Improving'),

  /// Score is relatively unchanged over the measured period.
  stable('Stable'),

  /// Score is decreasing over the measured period.
  declining('Declining');

  const GrowthTrend(this.displayName);

  /// Human-readable label for the trend.
  final String displayName;

  /// Parse from string, returning [stable] for unknown values.
  factory GrowthTrend.fromString(String value) {
    return GrowthTrend.values.firstWhere(
      (t) => t.name == value || t.displayName == value,
      orElse: () => GrowthTrend.stable,
    );
  }

  /// Computes [GrowthTrend] by comparing [current] vs [previous] score.
  ///
  /// Uses a threshold of 0.03 to avoid noise (scores are 0.0–1.0).
  factory GrowthTrend.fromScores(double current, double previous) {
    final delta = current - previous;
    if (delta > 0.03) return GrowthTrend.improving;
    if (delta < -0.03) return GrowthTrend.declining;
    return GrowthTrend.stable;
  }
}
