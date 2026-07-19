import '../achievement_snapshot.dart';

/// Repository interface for achievement snapshot persistence.
abstract class AchievementRepositoryInterface {
  /// Loads the cached achievement snapshot from persistent storage.
  Future<AchievementSnapshot?> loadCachedSnapshot();

  /// Saves the current achievement snapshot to persistent storage.
  Future<void> cacheSnapshot(AchievementSnapshot snapshot);

  /// Clears all cached achievement data.
  Future<void> clear();
}
