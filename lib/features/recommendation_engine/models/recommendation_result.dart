import 'recommendation_category.dart';
import 'recommendation_reason.dart';
import 'recommendation_score.dart';

/// A single recommendation produced by the [RecommendationEngine].
///
/// Contains all metadata for presentation: what, why, when, and how
/// the user should act on it.
class RecommendationResult {
  const RecommendationResult({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.score,
    required this.reason,
    this.missionId,
    this.estimatedDuration = 0,
    this.careerImpact = 0.0,
    this.learningImpact = 0.0,
    this.growthImpact = 0.0,
    this.ruleName = '',
  });

  /// Unique identifier.
  final String id;

  /// Short, actionable title.
  final String title;

  /// Detailed description.
  final String description;

  /// Recommendation category.
  final RecommendationCategory category;

  /// Scoring details for ranking.
  final RecommendationScore score;

  /// Structured explanation.
  final RecommendationReason reason;

  /// Optional linked mission ID.
  final String? missionId;

  /// Estimated time to complete in minutes.
  final int estimatedDuration;

  /// Expected career impact (0.0–1.0).
  final double careerImpact;

  /// Expected learning impact (0.0–1.0).
  final double learningImpact;

  /// Expected overall growth impact (0.0–1.0).
  final double growthImpact;

  /// Which rule generated this recommendation.
  final String ruleName;

  /// Whether this recommendation is a mission-level recommendation.
  bool get isMissionLinked => missionId != null;

  @override
  String toString() =>
      'RecommendationResult(id: $id, title: $title, '
      'category: ${category.displayName}, priority: ${score.priority})';
}
