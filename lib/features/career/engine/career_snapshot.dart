/// Immutable snapshot of the user's career readiness state.
///
/// Single source of truth for career data consumed by CareerScreen,
/// Dashboard, Progress, and AI recommendations.
///
/// Produced by [CareerEngine]. Widgets read this snapshot only.
class CareerSnapshot {
  const CareerSnapshot({
    this.careerScore = 0.0,
    this.jobReadiness = 'Starting Out',
    this.strengths = const [],
    this.skillGaps = const [],
    this.nextGoal = '',
    this.estimatedWeeks = 12,
    this.portfolioProgress = 0.0,
    this.resumeProgress = 0.0,
    this.interviewReadiness = 0.0,
    this.applicationCount = 0,
    this.offerCount = 0,
    this.careerTimeline = const [],
    this.lastUpdated,
  });

  /// Overall career readiness score from 0.0 to 1.0.
  final double careerScore;

  /// Job readiness label (e.g. "Exploring", "Building", "Ready").
  final String jobReadiness;

  /// Top skills the user can confidently demonstrate.
  final List<String> strengths;

  /// Skills that need improvement.
  final List<String> skillGaps;

  /// The next recommended goal.
  final String nextGoal;

  /// Estimated weeks remaining to job readiness.
  final int estimatedWeeks;

  /// Portfolio completion progress (0.0–1.0).
  final double portfolioProgress;

  /// Resume completion progress (0.0–1.0).
  final double resumeProgress;

  /// Interview readiness score (0.0–1.0).
  final double interviewReadiness;

  /// Number of job applications tracked.
  final int applicationCount;

  /// Number of offers received.
  final int offerCount;

  /// Key career events or milestones.
  final List<String> careerTimeline;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  /// Whether career data has been populated.
  bool get hasData => careerScore > 0.0;

  /// Whether the user is job-ready.
  bool get isReady => careerScore >= 0.8;

  /// Whether progress needs urgent attention (score < 0.4).
  bool get needsAttention => careerScore < 0.4;

  @override
  String toString() =>
      'CareerSnapshot(score: $careerScore, readiness: $jobReadiness, '
      'weeks: $estimatedWeeks)';
}
