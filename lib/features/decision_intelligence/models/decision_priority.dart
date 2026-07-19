/// Priority level for a decision recommendation.
///
/// Calculated deterministically by the Decision Intelligence Engine.
enum DecisionPriority {
  critical('Critical', 4, 90),
  high('High', 3, 70),
  medium('Medium', 2, 40),
  low('Low', 1, 10),
  none('None', 0, 0);

  const DecisionPriority(this.displayName, this.weight, this.minScore);

  /// Human-readable name.
  final String displayName;

  /// Numeric weight for ranking (higher = more important).
  final int weight;

  /// Minimum score threshold for this priority.
  final int minScore;

  /// Returns the priority for a given score (0–100).
  static DecisionPriority forScore(int score) {
    if (score >= 90) return DecisionPriority.critical;
    if (score >= 70) return DecisionPriority.high;
    if (score >= 40) return DecisionPriority.medium;
    if (score >= 10) return DecisionPriority.low;
    return DecisionPriority.none;
  }
}

/// Immutable scoring details for a single recommendation.
///
/// All values are deterministic — no randomness.
class DecisionScore {
  const DecisionScore({
    required this.overall,
    required this.urgency,
    required this.impact,
    required this.confidence,
    this.estimatedXp = 0,
    this.estimatedMinutes = 0,
  });

  /// Overall score (0–100).
  final int overall;

  /// Urgency component (0–100).
  final int urgency;

  /// Expected impact component (0–100).
  final int impact;

  /// Confidence in this recommendation (0–100).
  final int confidence;

  /// Estimated XP reward.
  final int estimatedXp;

  /// Estimated time to complete in minutes.
  final int estimatedMinutes;

  /// Derived priority from the overall score.
  DecisionPriority get priority => DecisionPriority.forScore(overall);

  @override
  String toString() =>
      'DecisionScore(overall: $overall, urgency: $urgency, '
      'impact: $impact, confidence: $confidence)';
}
