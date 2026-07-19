import '../models/mission_recommendation.dart';
import '../models/mission_score.dart';

/// Result of evaluating all [MissionRule]s in a single evaluation cycle.
///
/// Produced by [MissionIntelligenceEngine.evaluate].
class MissionEvaluation {
  const MissionEvaluation({
    required this.topMission,
    this.alternatives = const [],
    this.rejectedRules = const [],
    this.allScores = const [],
    this.evaluationTime,
    this.ruleCount = 0,
    this.totalRules = 0,
  });

  /// The highest-ranked mission recommendation.
  final MissionRecommendation topMission;

  /// Up to 3 alternative recommendations for the user to choose from.
  final List<MissionRecommendation> alternatives;

  /// Reasons why rules were rejected (empty input, conditions not met, etc.).
  final List<String> rejectedRules;

  /// All scores from all evaluated rules.
  final List<MissionScore> allScores;

  /// When this evaluation was performed.
  final DateTime? evaluationTime;

  /// How many rules produced a recommendation.
  final int ruleCount;

  /// Total rules evaluated.
  final int totalRules;

  /// Whether any recommendations were produced.
  bool get hasRecommendations => topMission.isAvailable || alternatives.isNotEmpty;

  /// Whether the evaluation considered at least some data.
  bool get hasData => totalRules > 0;

  @override
  String toString() =>
      'MissionEvaluation(top: ${topMission.title}, '
      'alternatives: ${alternatives.length}, '
      'rules: $ruleCount/$totalRules)';
}
