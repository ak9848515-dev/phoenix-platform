import 'recommendation_category.dart';
import 'recommendation_result.dart';
import 'recommendation_history.dart';
import 'recommendation_reason.dart';

/// Read-only snapshot of the current recommendation state.
///
/// Consumers (Dashboard, Daily Brief, AI Mentor, etc.) read this snapshot
/// instead of querying rules directly.
///
/// Immutable. Produced by [RecommendationEngine.evaluate].
class RecommendationSnapshot {
  const RecommendationSnapshot({
    this.primary,
    this.alternatives = const [],
    this.hidden = const [],
    this.allRanked = const [],
    this.reason,
    this.priority = 0,
    this.urgencyScore = 0.0,
    this.confidence = 0.0,
    this.estimatedBenefit = 0.0,
    this.estimatedDuration = 0,
    this.category,
    this.missionLink = '',
    this.growthImpact = 0.0,
    this.careerImpact = 0.0,
    this.learningImpact = 0.0,
    this.lastUpdated,
    this.history = const RecommendationHistory(),
    this.rejectedRules = const [],
    this.totalRules = 0,
  });

  /// The primary (top-ranked) recommendation.
  final RecommendationResult? primary;

  /// Alternative recommendations (up to 5).
  final List<RecommendationResult> alternatives;

  /// Recommendations below the visibility threshold.
  final List<RecommendationResult> hidden;

  /// All ranked recommendations in order.
  final List<RecommendationResult> allRanked;

  /// Explanation for the primary recommendation.
  final RecommendationReason? reason;

  /// Priority level of the primary recommendation (1–10).
  final int priority;

  /// Urgency score (0.0–1.0).
  final double urgencyScore;

  /// Confidence score (0.0–1.0).
  final double confidence;

  /// Estimated benefit (0.0–1.0).
  final double estimatedBenefit;

  /// Estimated time in minutes.
  final int estimatedDuration;

  /// Category of the primary recommendation.
  final RecommendationCategory? category;

  /// Linked mission ID if applicable.
  final String missionLink;

  /// Growth impact (0.0–1.0).
  final double growthImpact;

  /// Career impact (0.0–1.0).
  final double careerImpact;

  /// Learning impact (0.0–1.0).
  final double learningImpact;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  /// Recommendation history.
  final RecommendationHistory history;

  /// Rules that produced no recommendation (with reasons).
  final List<String> rejectedRules;

  /// Total rules evaluated.
  final int totalRules;

  /// Whether a primary recommendation exists.
  bool get hasRecommendation => primary != null;

  /// Whether alternatives exist.
  bool get hasAlternatives => alternatives.isNotEmpty;

  /// Whether any recommendations were produced.
  bool get hasAny => hasRecommendation || hasAlternatives || hidden.isNotEmpty;

  @override
  String toString() =>
      'RecommendationSnapshot(primary: ${primary?.title ?? 'none'}, '
      'alternatives: ${alternatives.length}, '
      'confidence: ${(confidence * 100).round()}%)';
}
