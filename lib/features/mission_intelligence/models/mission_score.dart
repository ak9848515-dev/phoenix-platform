/// Numeric score for a mission recommendation, used for ranking.
///
/// Produced by [MissionRule.evaluate] and aggregated by
/// [MissionIntelligenceEngine] to determine the top mission.
class MissionScore {
  const MissionScore({
    required this.score,
    required this.weight,
    required this.confidence,
  });

  /// Normalized score (0.0–1.0) indicating relevance.
  final double score;

  /// Weight of the rule that generated this score (higher = more important).
  final int weight;

  /// Confidence in this recommendation (0.0–1.0).
  final double confidence;

  /// Combined weighted score used for ranking.
  double get weightedScore => score * weight * confidence;

  @override
  String toString() =>
      'MissionScore(score: ${(score * 100).round()}%, '
      'weight: $weight, confidence: ${(confidence * 100).round()}%)';
}
