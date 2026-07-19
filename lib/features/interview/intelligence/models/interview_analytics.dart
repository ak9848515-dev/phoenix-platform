import 'interview_readiness.dart';

/// Analytics for interview performance over time.
///
/// Provides trend data for charts and insights on readiness,
/// accuracy, confidence, topic performance, and improvement timeline.
class InterviewAnalytics {
  const InterviewAnalytics({
    this.readinessTrend = const [],
    this.readinessLabels = const [],
    this.practiceSessionsCount = 0,
    this.questionAccuracyTrend = const [],
    this.questionAccuracyLabels = const [],
    this.confidenceGrowthTrend = const [],
    this.confidenceGrowthLabels = const [],
    this.topicPerformance = const {},
    this.improvementTimeline = const [],
    this.improvementLabels = const [],
    this.currentReadiness,
    this.readinessChange = 0.0,
    this.averageScore = 0.0,
    this.scoreChange = 0.0,
    this.weakTopicCount = 0,
    this.strongTopicCount = 0,
  });

  /// Readiness score over time for charting (newest first).
  final List<double> readinessTrend;

  /// Labels for readiness data points.
  final List<String> readinessLabels;

  /// Total number of practice sessions.
  final int practiceSessionsCount;

  /// Question accuracy over time (newest first).
  final List<double> questionAccuracyTrend;

  /// Labels for accuracy data points.
  final List<String> questionAccuracyLabels;

  /// Confidence growth over time (newest first).
  final List<double> confidenceGrowthTrend;

  /// Labels for confidence data points.
  final List<String> confidenceGrowthLabels;

  /// Per-topic accuracy rates keyed by topic name.
  final Map<String, double> topicPerformance;

  /// Improvement timeline values (newest first).
  final List<double> improvementTimeline;

  /// Labels for improvement data points.
  final List<String> improvementLabels;

  /// Current overall readiness (0.0 – 1.0).
  final InterviewReadiness? currentReadiness;

  /// Change in readiness since last check (positive = improved).
  final double readinessChange;

  /// Average session score (0.0 – 1.0).
  final double averageScore;

  /// Change in average score since last check.
  final double scoreChange;

  /// Number of topics identified as weak.
  final int weakTopicCount;

  /// Number of topics identified as strong.
  final int strongTopicCount;

  /// Whether analytics has enough data for trending.
  bool get hasTrendData => readinessTrend.length >= 2;

  /// Whether the user is generally trending positive.
  bool get isTrendingPositive => readinessChange > 0 && scoreChange > 0;

  /// Top weak topics sorted by performance (worst first).
  List<MapEntry<String, double>> get weakestTopics =>
      topicPerformance.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

  /// Top strong topics sorted by performance (best first).
  List<MapEntry<String, double>> get strongestTopics =>
      topicPerformance.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewAnalytics &&
          practiceSessionsCount == other.practiceSessionsCount &&
          averageScore == other.averageScore;

  @override
  int get hashCode => Object.hash(practiceSessionsCount, averageScore);

  @override
  String toString() =>
      'InterviewAnalytics(sessions: $practiceSessionsCount, avg: $averageScore, '
      'trending: $isTrendingPositive)';
}
