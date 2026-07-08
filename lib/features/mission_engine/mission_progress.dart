import 'mission_engine.dart';

/// Immutable summary for daily and weekly mission progress.
class MissionProgress {
  const MissionProgress({
    required this.dailyMissions,
    required this.weeklyMissions,
    required this.completionPercentage,
    required this.completedCount,
    required this.pendingCount,
    required this.streak,
    required this.summary,
    required this.featuredMission,
  });

  final List<Mission> dailyMissions;
  final List<Mission> weeklyMissions;
  final double completionPercentage;
  final int completedCount;
  final int pendingCount;
  final int streak;
  final String summary;
  final Mission featuredMission;
}
