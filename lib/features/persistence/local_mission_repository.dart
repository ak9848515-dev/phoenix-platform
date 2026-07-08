import 'local_storage_service.dart';
import 'mission_repository.dart';
import 'storage_keys.dart';

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
  Future<void> clearCompletedMissions() {
    return storageService.remove(StorageKeys.completedMissionIds);
  }
}
