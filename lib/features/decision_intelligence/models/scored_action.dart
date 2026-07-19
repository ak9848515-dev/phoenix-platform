/// Source engine that generated a candidate action.
enum ActionSource {
  career,
  portfolio,
  resume,
  interview,
  opportunity,
  mission,
  growth,
  knowledge,
  recommendation,
  review,
  memory,
  identity,
}

/// Scoring dimensions for a decision candidate.
///
/// Each dimension is scored 0.0–1.0 and contributes to the composite score.
class ActionScore {
  const ActionScore({
    this.careerImpact = 0.0,
    this.learningDependency = 0.0,
    this.deadline = 0.0,
    this.difficulty = 0.0,
    this.roi = 0.0,
    this.skillGap = 0.0,
    this.momentum = 0.0,
    this.recentActivity = 0.0,
    this.userGoals = 0.0,
  });

  /// Career impact (0.0–1.0): how much this action advances career readiness.
  final double careerImpact;

  /// Learning dependency (0.0–1.0): whether other learning must happen first.
  final double learningDependency;

  /// Deadline urgency (0.0–1.0): how time-sensitive this action is.
  final double deadline;

  /// Difficulty (0.0–1.0): how hard the action is (higher = harder).
  final double difficulty;

  /// ROI (0.0–1.0): expected return on investment of time/effort.
  final double roi;

  /// Skill gap closure (0.0–1.0): how much this closes identified gaps.
  final double skillGap;

  /// Momentum (0.0–1.0): whether this leverages current streaks/habits.
  final double momentum;

  /// Recent activity (0.0–1.0): whether user has recently engaged this area.
  final double recentActivity;

  /// User goals alignment (0.0–1.0): how well this matches stated goals.
  final double userGoals;

  /// Composite weighted score (0.0–1.0).
  ///
  /// Weights prioritize career impact, ROI, and momentum over deadline
  /// and difficulty.
  double get composite {
    const weights = {
      'careerImpact': 0.20,
      'roi': 0.15,
      'momentum': 0.15,
      'skillGap': 0.12,
      'userGoals': 0.12,
      'learningDependency': 0.08,
      'deadline': 0.08,
      'difficulty': 0.05,
      'recentActivity': 0.05,
    };
    return (careerImpact * weights['careerImpact']!) +
        (roi * weights['roi']!) +
        (momentum * weights['momentum']!) +
        (skillGap * weights['skillGap']!) +
        (userGoals * weights['userGoals']!) +
        (learningDependency * weights['learningDependency']!) +
        (deadline * weights['deadline']!) +
        (difficulty * weights['difficulty']!) +
        (recentActivity * weights['recentActivity']!);
  }

  /// Confidence in this score (0.0–1.0), derived from score spread.
  ///
  /// Normalized by dividing by max possible variance (0.25 for [0,1] values).
  /// Low variance = high confidence (all scores agree on the direction).
  double get confidence {
    final scores = [
      careerImpact, roi, momentum, skillGap, userGoals,
      learningDependency, deadline, difficulty, recentActivity,
    ];
    final avg = scores.fold(0.0, (a, b) => a + b) / scores.length;
    final variance = scores.fold(0.0, (a, b) => a + (b - avg) * (b - avg)) / scores.length;
    // Max possible variance for [0,1] values is 0.25 (half at 0, half at 1)
    return (1.0 - (variance / 0.25).clamp(0.0, 1.0)).clamp(0.0, 1.0);
  }

  /// Estimated time in minutes (derived from difficulty).
  int get estimatedMinutes {
    if (difficulty < 0.2) return 5;
    if (difficulty < 0.4) return 15;
    if (difficulty < 0.6) return 30;
    if (difficulty < 0.8) return 60;
    return 120;
  }

  @override
  String toString() =>
      'ActionScore(composite: ${(composite * 100).round()}%, '
      'career: ${(careerImpact * 100).round()}%, roi: ${(roi * 100).round()}%)';
}

/// A scored action candidate from any intelligence engine.
///
/// Immutable. Produced by [DecisionIntelligenceOrchestrator].
class ScoredAction {
  const ScoredAction({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.score,
    this.reasoning = '',
    this.route = '',
    this.category = '',
    this.goalType = 'shortTerm', // 'shortTerm', 'quickWin', 'longTerm'
  });

  /// Unique identifier.
  final String id;

  /// Short, actionable title.
  final String title;

  /// Detailed description.
  final String description;

  /// Which engine produced this candidate.
  final ActionSource source;

  /// Multi-dimensional score.
  final ActionScore score;

  /// Human-readable reasoning for this action.
  final String reasoning;

  /// Navigation route for this action.
  final String route;

  /// Category label for display.
  final String category;

  /// Goal type classification.
  final String goalType;

  /// Whether this is a quick win (high roi, low difficulty).
  bool get isQuickWin => score.roi > 0.6 && score.difficulty < 0.4;

  /// Whether this is a long-term goal (high career impact, high difficulty).
  bool get isLongTermGoal => score.careerImpact > 0.6 && score.difficulty > 0.6;

  /// Whether this is suitable for today (high momentum, low recency).
  bool get isSuitableForToday => score.momentum > 0.5 || score.recentActivity < 0.3;

  @override
  String toString() =>
      'ScoredAction(id: $id, title: $title, '
      'composite: ${(score.composite * 100).round()}%, source: ${source.name})';
}
