import 'interview_analytics.dart';
import 'interview_feedback_detail.dart';
import 'interview_progress.dart';
import 'interview_readiness.dart';
import 'interview_recommendation.dart';
import 'interview_session_detail.dart';
import 'weak_topic.dart';

/// The complete output of the Interview Intelligence Engine.
///
/// Contains everything a widget or downstream engine needs:
/// readiness, sessions, feedback, weak topics, recommendations,
/// analytics, progress, and generated action items.
///
/// **Architecture:**
/// ```text
/// InterviewIntelligenceEngine
///   ↓
/// InterviewIntelligenceSnapshot  ← YOU ARE HERE
///   ↓
/// InterviewScreen | Dashboard | Profile | PhoenixAssistant
/// ```
class InterviewIntelligenceSnapshot {
  const InterviewIntelligenceSnapshot({
    this.readiness = const InterviewReadiness(),
    this.recentSessions = const [],
    this.latestFeedback,
    this.weakTopics = const [],
    this.recommendations = const [],
    this.analytics = const InterviewAnalytics(),
    this.progress = const InterviewProgress(),
    this.actionItems = const [],
    this.aiCoachSummary = '',
    this.nextBestAction = '',
    this.hasData = false,
    this.lastUpdated,
  });

  /// Current interview readiness breakdown.
  final InterviewReadiness readiness;

  /// Recent practice sessions (newest first, max 10).
  final List<InterviewSessionDetail> recentSessions;

  /// Feedback from the most recent completed session.
  final InterviewFeedbackDetail? latestFeedback;

  /// Detected weak topics.
  final List<WeakTopic> weakTopics;

  /// Intelligent recommendations.
  final List<InterviewRecommendation> recommendations;

  /// Performance analytics.
  final InterviewAnalytics analytics;

  /// Progress tracking data.
  final InterviewProgress progress;

  /// Actionable items for the user.
  final List<InterviewRecommendation> actionItems;

  /// AI coach generated summary text.
  final String aiCoachSummary;

  /// The single most important thing the user should do next.
  final String nextBestAction;

  /// Whether the engine has produced meaningful data.
  final bool hasData;

  /// When this snapshot was last updated.
  final DateTime? lastUpdated;

  /// Number of recommendations needing action.
  int get actionableCount =>
      actionItems.where((a) => a.priority >= 0.6).length;

  /// Whether the user is ready for real interviews.
  bool get isReadyForInterviews => readiness.isReady;

  /// Whether there are any weak topics needing attention.
  bool get hasWeakTopics => weakTopics.isNotEmpty;

  /// Whether there are any pending recommendations.
  bool get hasRecommendations => recommendations.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewIntelligenceSnapshot &&
          readiness == other.readiness &&
          hasData == other.hasData;

  @override
  int get hashCode => Object.hash(readiness, hasData);

  @override
  String toString() =>
      'InterviewIntelligenceSnapshot(ready: $isReadyForInterviews, '
      'sessions: ${recentSessions.length}, '
      'weakTopics: ${weakTopics.length})';
}
