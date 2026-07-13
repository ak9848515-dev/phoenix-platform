import '../../core/repository.dart';
import '../../core/sample_repository.dart';
import 'mission_engine.dart';
import 'mission_progress.dart';
import 'mission_statistics.dart';

/// Central service for deriving mission progress and statistics from seeded data.
class MissionService {
  MissionService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  List<Mission> get dailyMissions => repository.dailyMissions;

  List<Mission> get weeklyMissions => repository.weeklyMissions;

  Mission get featuredMission {
    final missions = <Mission>[...dailyMissions, ...weeklyMissions];
    return missions.firstWhere(
      (mission) => !mission.completed,
      orElse: () => missions.first,
    );
  }

  MissionProgress buildProgress() {
    final missions = <Mission>[...dailyMissions, ...weeklyMissions];
    final completedCount = missions
        .where((mission) => mission.completed)
        .length;
    final pendingCount = missions.length - completedCount;
    final completionPercentage = missions.isEmpty
        ? 0.0
        : completedCount / missions.length;
    final streak = _calculateStreak(missions);

    return MissionProgress(
      dailyMissions: dailyMissions,
      weeklyMissions: weeklyMissions,
      completionPercentage: completionPercentage,
      completedCount: completedCount,
      pendingCount: pendingCount,
      streak: streak,
      summary: '$completedCount of ${missions.length} missions complete',
      featuredMission: featuredMission,
    );
  }

  MissionStatistics buildStatistics() {
    final progress = buildProgress();

    return MissionStatistics(
      totalMissions:
          progress.dailyMissions.length + progress.weeklyMissions.length,
      completedCount: progress.completedCount,
      pendingCount: progress.pendingCount,
      completionPercentage: progress.completionPercentage,
      streak: progress.streak,
      summary: progress.summary,
    );
  }

  int _calculateStreak(List<Mission> missions) {
    var streak = 0;

    for (final mission in missions) {
      if (mission.completed) {
        streak += 1;
      } else {
        break;
      }
    }

    return streak;
  }
}
