import 'decision_priority.dart';
import 'decision_reason.dart';
import 'decision_type.dart';

/// A single recommendation produced by the Decision Intelligence Engine.
///
/// Immutable. Contains everything the UI needs to render the recommendation,
/// including the action, reason, scoring, and related content references.
class DecisionRecommendation {
  const DecisionRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reason,
    required this.score,
    this.relatedMissionId,
    this.relatedProjectId,
    this.relatedSkills = const [],
    this.prerequisites = const [],
    this.expiration,
    this.ruleName = '',
  });

  /// Unique identifier.
  final String id;

  /// The type of decision/action.
  final DecisionType type;

  /// Short, actionable title.
  final String title;

  /// Detailed description of what to do.
  final String description;

  /// Structured explanation (why, why now, skip consequence, unlocks).
  final DecisionReason reason;

  /// Deterministic scoring details.
  final DecisionScore score;

  /// Optional linked mission ID.
  final String? relatedMissionId;

  /// Optional linked project ID.
  final String? relatedProjectId;

  /// Related skill names.
  final List<String> relatedSkills;

  /// Prerequisites that must be met before this recommendation.
  final List<String> prerequisites;

  /// When this recommendation expires.
  final DateTime? expiration;

  /// Which rule generated this recommendation.
  final String ruleName;

  /// Whether this recommendation is actionable (not expired, has prerequisites met).
  bool get isActionable =>
      (expiration == null || expiration!.isAfter(DateTime.now()));

  @override
  String toString() =>
      'DecisionRecommendation(type: ${type.displayName}, '
      'score: ${score.overall}, priority: ${score.priority.displayName})';
}
