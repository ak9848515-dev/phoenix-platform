/// A single history entry tracking a mission recommendation lifecycle.
///
/// Records when a recommendation was made, accepted, rejected, or completed
/// so the engine can track acceptance rates, completion rates, and averages.
class MissionHistoryEntry {
  const MissionHistoryEntry({
    required this.missionId,
    required this.missionTitle,
    required this.recommendationId,
    required this.ruleName,
    required this.recommendedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.completedAt,
    this.accepted = false,
    this.rejected = false,
    this.completed = false,
    this.xpEarned,
    this.completionTimeMinutes,
  });

  /// ID of the mission entity.
  final String missionId;

  /// Title of the mission.
  final String missionTitle;

  /// ID of the recommendation that produced this mission.
  final String recommendationId;

  /// Which rule generated the recommendation.
  final String ruleName;

  /// When the recommendation was made.
  final DateTime recommendedAt;

  /// When the user accepted the mission.
  final DateTime? acceptedAt;

  /// When the user rejected the mission.
  final DateTime? rejectedAt;

  /// When the mission was completed.
  final DateTime? completedAt;

  /// Whether the mission was accepted.
  final bool accepted;

  /// Whether the mission was rejected.
  final bool rejected;

  /// Whether the mission was completed.
  final bool completed;

  /// XP earned on completion.
  final int? xpEarned;

  /// Minutes taken to complete.
  final int? completionTimeMinutes;

  /// Whether this entry represents an accepted mission.
  bool get isAccepted => accepted && acceptedAt != null;

  /// Whether this entry represents a completed mission.
  bool get isCompleted => completed && completedAt != null;

  @override
  String toString() =>
      'MissionHistoryEntry(mission: $missionTitle, '
      'accepted: $accepted, completed: $completed)';
}
