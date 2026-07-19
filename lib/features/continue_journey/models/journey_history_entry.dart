import 'journey_resume_point.dart';

/// A single journey history entry tracking an activity lifecycle.
///
/// Records when an activity was started, resumed, paused,
/// completed, or cancelled.
class JourneyHistoryEntry {
  const JourneyHistoryEntry({
    required this.activityId,
    required this.activityTitle,
    required this.activityType,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.resumeCount = 0,
    this.totalMinutesSpent = 0,
    this.xpEarned = 0,
  });

  /// The activity identifier.
  final String activityId;

  /// The activity title at the time of recording.
  final String activityTitle;

  /// The type of activity.
  final JourneyResumePoint activityType;

  /// Current status of this activity.
  final String status;

  /// When the activity was first started.
  final DateTime? startedAt;

  /// When the activity was completed or cancelled.
  final DateTime? completedAt;

  /// How many times this activity was resumed.
  final int resumeCount;

  /// Total minutes spent on this activity.
  final int totalMinutesSpent;

  /// XP earned from this activity.
  final int xpEarned;

  /// Whether this activity is still in progress.
  bool get isInProgress => status == 'started' || status == 'resumed';

  /// Whether this activity was completed successfully.
  bool get isCompleted => status == 'completed';

  /// Whether this activity was cancelled.
  bool get isCancelled => status == 'cancelled';

  @override
  String toString() =>
      'JourneyHistoryEntry(activity: $activityTitle, '
      'status: $status, resumes: $resumeCount)';
}
