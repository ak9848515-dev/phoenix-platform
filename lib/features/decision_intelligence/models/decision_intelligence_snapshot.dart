import 'scored_action.dart';

/// Structured explanation for a decision recommendation.
///
/// Provides user-facing reasoning that explains:
/// - WHY this action is recommended
/// - Career impact
/// - Estimated time commitment
/// - Priority level
/// - Confidence in the recommendation
/// - Dependencies / prerequisites
/// - Quick wins available
/// - Long-term benefit
/// - Expected outcome
/// - Risk level
class DecisionExplanation {
  const DecisionExplanation({
    this.why = '',
    this.careerImpactLabel = '',
    this.estimatedTime = '',
    this.priority = 'medium',
    this.confidence = 0.5,
    this.dependencies = const [],
    this.quickWins = const [],
    this.longTermBenefit = '',
    this.expectedOutcome = '',
    this.risk = 'low',
  });

  /// WHY this action is recommended (user-facing explanation).
  final String why;

  /// Career impact description (e.g. "High — closes skill gap in React").
  final String careerImpactLabel;

  /// Estimated time (e.g. "15 minutes", "2 hours", "This week").
  final String estimatedTime;

  /// Priority level: 'critical', 'high', 'medium', 'low'.
  final String priority;

  /// Confidence score (0.0–1.0) for this explanation.
  final double confidence;

  /// Dependencies / prerequisites to complete before this action.
  final List<String> dependencies;

  /// Quick wins available alongside this action.
  final List<String> quickWins;

  /// Long-term benefit description.
  final String longTermBenefit;

  /// Expected outcome if this action is completed.
  final String expectedOutcome;

  /// Risk level: 'low', 'medium', 'high'.
  final String risk;

  /// Creates an explanation from a [ScoredAction].
  factory DecisionExplanation.fromScoredAction(ScoredAction action) {
    final score = action.score;
    final mins = score.estimatedMinutes;

    String time;
    if (mins < 10) {
      time = '$mins minutes';
    } else if (mins < 60) {
      time = '$mins minutes';
    } else {
      time = '${(mins / 60).round()} hours';
    }

    String risk;
    if (score.difficulty < 0.3) {
      risk = 'low';
    } else if (score.difficulty < 0.7) {
      risk = 'medium';
    } else {
      risk = 'high';
    }

    String priority;
    final composite = score.composite;
    if (composite >= 0.7) {
      priority = 'critical';
    } else if (composite >= 0.5) {
      priority = 'high';
    } else if (composite >= 0.3) {
      priority = 'medium';
    } else {
      priority = 'low';
    }

    return DecisionExplanation(
      why: action.reasoning,
      careerImpactLabel: '${(score.careerImpact * 100).round()}% career alignment',
      estimatedTime: time,
      priority: priority,
      confidence: score.confidence,
      longTermBenefit: score.careerImpact > 0.6
          ? 'Significant career advancement potential'
          : 'Supports current career trajectory',
      expectedOutcome: action.description,
      risk: risk,
    );
  }

  @override
  String toString() =>
      'DecisionExplanation(priority: $priority, '
      'confidence: ${(confidence * 100).round()}%, '
      'risk: $risk)';
}

/// Immutable snapshot produced by [DecisionIntelligenceOrchestrator].
///
/// Represents the final decision layer of Phoenix — the single source of
/// truth for what the user should do next.
///
/// **Outputs:**
/// - Top Priority: single highest-value action
/// - Second Priority: alternative if top is not actionable
/// - Quick Wins: high ROI, low difficulty actions (up to 3)
/// - Long-Term Goal: high career impact, high difficulty action
/// - Reasoning: structured explanation
/// - Explanation: user-facing structured explanation with why, risk, dependencies
/// - Confidence Score: aggregate confidence across all scored actions
/// - Career Impact: aggregate career impact
class DecisionIntelligenceSnapshot {
  const DecisionIntelligenceSnapshot({
    required this.topPriority,
    this.secondPriority,
    this.quickWins = const [],
    this.longTermGoal,
    this.reasoning = '',
    this.allScored = const [],
    this.confidence = 0.0,
    this.careerImpact = 0.0,
    this.generatedAt,
    this.isInitialized = false,
    this.explanation,
  });

  /// The single highest-value action for the user right now.
  final ScoredAction topPriority;

  /// The alternative if top is not actionable today.
  final ScoredAction? secondPriority;

  /// Quick wins: high ROI, low difficulty (up to 3).
  final List<ScoredAction> quickWins;

  /// Long-term goal: high career impact, requires sustained effort.
  final ScoredAction? longTermGoal;

  /// Human-readable reasoning for the top priority.
  final String reasoning;

  /// All scored actions, ranked by composite score descending.
  final List<ScoredAction> allScored;

  /// Aggregate confidence (0.0–1.0) across all scored actions.
  final double confidence;

  /// Aggregate career impact (0.0–1.0) of the top actions.
  final double careerImpact;

  /// When this snapshot was generated.
  final DateTime? generatedAt;

  /// Whether the orchestrator has been initialized.
  final bool isInitialized;

  /// Structured, user-facing explanation for the top recommendation.
  ///
  /// Contains why, career impact, estimated time, priority level,
  /// dependencies, quick wins, expected outcome, and risk.
  final DecisionExplanation? explanation;

  /// Whether the snapshot has valid data.
  bool get hasData => isInitialized && allScored.isNotEmpty;

  /// Whether quick wins are available.
  bool get hasQuickWins => quickWins.isNotEmpty;

  /// Whether a long-term goal is defined.
  bool get hasLongTermGoal => longTermGoal != null;

  /// Whether a second priority exists.
  bool get hasSecondPriority => secondPriority != null;

  /// Whether a structured explanation is available.
  bool get hasExplanation => explanation != null;

  /// Top 3 actions for constrained layouts.
  List<ScoredAction> get top3 =>
      [topPriority, ?secondPriority, ...quickWins.take(1)];

  @override
  String toString() =>
      'DecisionIntelligenceSnapshot(top: ${topPriority.title}, '
      'confidence: ${(confidence * 100).round()}%, '
      'quickWins: ${quickWins.length}, '
      'all: ${allScored.length})';
}
