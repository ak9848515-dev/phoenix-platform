/// Interview progress tracking across all sessions and time.
///
/// Tracks session counts, accuracy trends, confidence growth,
/// topic performance, and improvement velocity.
class InterviewProgress {
  const InterviewProgress({
    this.totalSessions = 0,
    this.completedSessions = 0,
    this.averageScore = 0.0,
    this.bestScore = 0.0,
    this.recentScores = const [],
    this.accuracyTrend = const [],
    this.confidenceGrowth = const [],
    this.practiceFrequencyDays = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.topicsCovered = const [],
    this.topicsWeak = const [],
    this.topicsStrong = const [],
    this.improvementRate = 0.0,
    this.lastPracticedAt,
    this.startedAt,
  });

  /// Total number of sessions started.
  final int totalSessions;

  /// Number of sessions completed.
  final int completedSessions;

  /// Average score across all completed sessions (0.0 – 1.0).
  final double averageScore;

  /// Best single session score (0.0 – 1.0).
  final double bestScore;

  /// Recent session scores for charting (newest first).
  final List<double> recentScores;

  /// Accuracy over time for charting (newest first).
  final List<double> accuracyTrend;

  /// Confidence scores over time for charting (newest first).
  final List<double> confidenceGrowth;

  /// Average days between practice sessions.
  final int practiceFrequencyDays;

  /// Current consecutive practice days.
  final int streakDays;

  /// Longest ever consecutive practice streak.
  final int longestStreak;

  /// Topics covered across all sessions.
  final List<String> topicsCovered;

  /// Weak topics identified.
  final List<String> topicsWeak;

  /// Strong topics identified.
  final List<String> topicsStrong;

  /// Overall improvement rate (positive = improving, 0.0 – 1.0).
  final double improvementRate;

  /// When the user last practiced.
  final DateTime? lastPracticedAt;

  /// When the user started interview preparation.
  final DateTime? startedAt;

  /// Completion rate (completed / total).
  double get completionRate =>
      totalScores > 0 ? completedSessions / totalSessions : 0.0;

  int get totalScores => recentScores.length;

  /// Whether there is any practice history.
  bool get hasHistory => completedSessions > 0;

  /// Whether the user is consistently practicing (at least once every 3 days).
  bool get isConsistent => practiceFrequencyDays <= 3 && streakDays >= 3;

  /// Whether the user is improving (improvementRate > 0.1).
  bool get isImproving => improvementRate > 0.1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewProgress &&
          totalSessions == other.totalSessions &&
          completedSessions == other.completedSessions;

  @override
  int get hashCode => Object.hash(totalSessions, completedSessions);

  @override
  String toString() =>
      'InterviewProgress(sessions: $completedSessions/$totalSessions, avg: $averageScore, improving: $isImproving)';
}
