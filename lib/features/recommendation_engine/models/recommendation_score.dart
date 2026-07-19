import 'recommendation_urgency.dart';

/// Composite score for ranking recommendations.
///
/// Combines priority, urgency, confidence, and estimated benefit into
/// a single weighted score for deterministic ordering.
class RecommendationScore {
  const RecommendationScore({
    required this.priority,
    required this.urgency,
    required this.confidence,
    this.estimatedBenefit = 0.0,
    this.priorityWeight = 1.0,
  });

  /// Priority level (1–10, higher = more important).
  final int priority;

  /// Urgency assessment.
  final RecommendationUrgency urgency;

  /// Confidence in this recommendation (0.0–1.0).
  final double confidence;

  /// Estimated benefit (0.0–1.0).
  final double estimatedBenefit;

  /// Weight multiplier for priority (default 1.0).
  final double priorityWeight;

  /// Combined ranking score used for sorting.
  ///
  /// Formula: (priority × weight) + (urgency.score × 10) + (confidence × 5) + (benefit × 3)
  double get rankingScore =>
      (priority * priorityWeight) +
      (urgency.score * 10) +
      (confidence * 5) +
      (estimatedBenefit * 3);

  @override
  String toString() =>
      'RecommendationScore(priority: $priority, '
      'urgency: ${(urgency.score * 100).round()}%, '
      'confidence: ${(confidence * 100).round()}%)';
}
