/// Immutable statistics for mission completion and momentum.
class MissionStatistics {
  const MissionStatistics({
    required this.totalMissions,
    required this.completedCount,
    required this.pendingCount,
    required this.completionPercentage,
    required this.streak,
    required this.summary,
  });

  final int totalMissions;
  final int completedCount;
  final int pendingCount;
  final double completionPercentage;
  final int streak;
  final String summary;
}
