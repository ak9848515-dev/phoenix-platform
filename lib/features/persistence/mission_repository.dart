abstract class MissionRepository {
  Future<List<String>> loadCompletedMissionIds();

  Future<void> saveCompletedMissionIds(List<String> missionIds);

  Future<void> markMissionCompleted(String missionId);

  Future<void> clearCompletedMissions();
}
