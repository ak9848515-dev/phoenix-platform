import 'local_storage_service.dart';
import 'mission_repository.dart';
import 'storage_keys.dart';
import '../mission_engine/mission_progress.dart';

class LocalMissionRepository implements MissionRepository {
  const LocalMissionRepository({
    this.storageService = const LocalStorageService(),
  });

  final LocalStorageService storageService;

  @override
  Future<List<String>> loadCompletedMissionIds() {
    return storageService.getStringList(StorageKeys.completedMissionIds);
  }

  @override
  Future<void> saveCompletedMissionIds(List<String> missionIds) {
    final uniqueMissionIds = missionIds.toSet().toList(growable: false);
    return storageService.setStringList(
      StorageKeys.completedMissionIds,
      uniqueMissionIds,
    );
  }

  @override
  Future<void> markMissionCompleted(String missionId) async {
    final missionIds = await loadCompletedMissionIds();
    if (missionIds.contains(missionId)) {
      return;
    }

    await saveCompletedMissionIds(<String>[...missionIds, missionId]);
  }

  @override
  Future<PersistedMissionProgress> loadMissionProgress() async {
    final completedCount = await storageService.getInt(StorageKeys.missionCompletedCount) ?? 0;
    final pendingCount = await storageService.getInt(StorageKeys.missionPendingCount) ?? 0;
    final completionPercentage = await storageService.getDouble(StorageKeys.missionCompletionPercentage) ?? 0.0;
    final streak = await storageService.getInt(StorageKeys.missionStreak) ?? 0;
    final summary = await storageService.getString(StorageKeys.missionSummary) ?? '';

    return PersistedMissionProgress(
      completedCount: completedCount,
      pendingCount: pendingCount,
      completionPercentage: completionPercentage,
      streak: streak,
      summary: summary,
    );
  }

  @override
  Future<void> saveMissionProgress(MissionProgress progress) async {
    await storageService.setInt(StorageKeys.missionCompletedCount, progress.completedCount);
    await storageService.setInt(StorageKeys.missionPendingCount, progress.pendingCount);
    await storageService.setDouble(StorageKeys.missionCompletionPercentage, progress.completionPercentage);
    await storageService.setInt(StorageKeys.missionStreak, progress.streak);
    await storageService.setString(StorageKeys.missionSummary, progress.summary);
  }
}
