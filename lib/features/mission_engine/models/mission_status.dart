/// The completion status of a mission.
///
/// Replaces the simple boolean `completed` with a richer status model
/// that supports partial progress, skipped missions, and recurrence.
enum MissionStatus {
  /// Mission is pending — not yet started.
  pending,

  /// Mission is in progress with some completion.
  inProgress,

  /// Mission has been completed successfully.
  completed,

  /// Mission was skipped or declined.
  skipped,

  /// Mission is blocked by an unmet dependency.
  blocked,

  /// Mission is available for a new recurrence cycle.
  available;
}
