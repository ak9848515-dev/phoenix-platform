import '../../services/sample_data_service.dart';
import '../persistence/local_mission_repository.dart';
import '../persistence/mission_repository.dart';
import 'mission_engine.dart';
import 'mission_progress.dart';
import 'mission_statistics.dart';

/// Central service for deriving mission progress and statistics from seeded data.
class MissionService {
  MissionService({
    SampleDataService? seedSource,
    MissionRepository? missionRepository,
  })  : seedSource = seedSource ?? const SampleDataService(),
        missionRepository = missionRepository ?? const LocalMissionRepository();

  final SampleDataService seedSource;
  final MissionRepository missionRepository;

  List<Mission> get dailyMissions => seedSource.dailyMissions;

  List<Mission> get weeklyMissions => seedSource.weeklyMissions;

  Mission get featuredMission {
    final missions = <Mission>[...dailyMissions, ...weeklyMissions];
    return missions.firstWhere(
      (mission) => !mission.completed,
      orElse: () => missions.first,
    );
  }

  MissionProgress buildProgress() {
    final missions = <Mission>[...dailyMissions, ...weeklyMissions];
    return _buildProgressFromMissions(missions);
  }

  Future<MissionProgress> initialize() async {
    final missions = await restoreMissions();
    final progress = _buildProgressFromMissions(missions);
    await missionRepository.saveMissionProgress(progress);
    return progress;
  }

  Future<List<Mission>> restoreMissions() async {
    final completedMissionIds = await missionRepository.loadCompletedMissionIds();
    final completedMissionSet = completedMissionIds.toSet();
    final missions = <Mission>[...dailyMissions, ...weeklyMissions];

    return missions
        .map(
          (mission) => completedMissionSet.contains(mission.id)
              ? mission.copyWith(completed: true)
              : mission,
        )
        .toList(growable: false);
  }

  Future<MissionProgress> completeMission(String missionId) async {
    await missionRepository.markMissionCompleted(missionId);
    return initialize();
  }

  Future<PersistedMissionProgress> restoreMissionProgress() {
    return missionRepository.loadMissionProgress();
  }

  MissionProgress _buildProgressFromMissions(List<Mission> missions) {
    final completedCount = missions.where((mission) => mission.completed).length;
    final pendingCount = missions.length - completedCount;
    final completionPercentage = missions.isEmpty ? 0.0 : completedCount / missions.length;
    final streak = _calculateStreak(missions);
    final dailyMissionIds = dailyMissions.map((mission) => mission.id).toSet();
    final restoredDailyMissions = missions
        .where((mission) => dailyMissionIds.contains(mission.id))
        .toList(growable: false);
    final restoredWeeklyMissions = missions
        .where((mission) => !dailyMissionIds.contains(mission.id))
        .toList(growable: false);

    return MissionProgress(
      dailyMissions: restoredDailyMissions,
      weeklyMissions: restoredWeeklyMissions,
      completionPercentage: completionPercentage,
      completedCount: completedCount,
      pendingCount: pendingCount,
      streak: streak,
      summary: '$completedCount of ${missions.length} missions complete',
      featuredMission: _featuredMissionFrom(missions),
    );
  }

  MissionStatistics buildStatistics() {
    final progress = buildProgress();

    return MissionStatistics(
      totalMissions: progress.dailyMissions.length + progress.weeklyMissions.length,
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

  Mission _featuredMissionFrom(List<Mission> missions) {
    return missions.firstWhere(
      (mission) => !mission.completed,
      orElse: () => missions.first,
    );
  }
}
