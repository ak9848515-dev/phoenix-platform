import 'journey_activity.dart';
import 'journey_history.dart';
import 'journey_resume_point.dart';

/// Read-only snapshot of the user's journey state for consumers.
///
/// Dashboard, Daily Brief, Notifications, etc. read this snapshot
/// instead of querying engines directly.
///
/// Immutable. Produced by [ContinueJourneyEngine].
class JourneySnapshot {
  const JourneySnapshot({
    this.currentJourney = '',
    this.currentStage = '',
    this.resumePoint,
    this.lastActivity,
    this.nextActivity,
    this.completionPercent = 0.0,
    this.estimatedRemainingMinutes = 0,
    this.priority = 0,
    this.reason = '',
    this.resumeCandidates = const [],
    this.lastUpdated,
    this.history = const JourneyHistory(),
  });

  /// Label for the current journey (e.g. "Flutter Developer Path").
  final String currentJourney;

  /// Current stage label (e.g. "Fundamentals").
  final String currentStage;

  /// The single highest-priority activity to resume.
  final JourneyActivity? resumePoint;

  /// The user's most recent activity.
  final JourneyActivity? lastActivity;

  /// Recommended next activity after the current one completes.
  final JourneyActivity? nextActivity;

  /// Overall journey completion percentage.
  final double completionPercent;

  /// Estimated remaining time for the current resume point.
  final int estimatedRemainingMinutes;

  /// Resume priority score (higher = more important).
  final int priority;

  /// Human-readable reason for the resume recommendation.
  final String reason;

  /// All resume candidates ranked by priority.
  final List<JourneyActivity> resumeCandidates;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  /// Journey history.
  final JourneyHistory history;

  /// Whether there are activities to resume.
  bool get hasResumePoint => resumePoint != null;

  /// Whether there are any resume candidates.
  bool get hasCandidates => resumeCandidates.isNotEmpty;

  /// The single most important resume type, if any.
  JourneyResumePoint? get resumeType => resumePoint?.type;

  @override
  String toString() =>
      'JourneySnapshot(journey: $currentJourney, '
      'resume: ${resumePoint?.title ?? "none"}, '
      'candidates: ${resumeCandidates.length})';
}
