import '../mission_engine/mission_progress.dart';

class PersistedMissionProgress {
  const PersistedMissionProgress({
    required this.completedCount,
    required this.pendingCount,
    required this.completionPercentage,
    required this.streak,
    required this.summary,
  });

  final int completedCount;
  final int pendingCount;
  final double completionPercentage;
  final int streak;
  final String summary;
}

abstract class MissionRepository {
  Future<List<String>> loadCompletedMissionIds();

  Future<void> saveCompletedMissionIds(List<String> missionIds);

  Future<void> markMissionCompleted(String missionId);

  Future<PersistedMissionProgress> loadMissionProgress();

  Future<void> saveMissionProgress(MissionProgress progress);
}
