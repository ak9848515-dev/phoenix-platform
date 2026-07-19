import '../engine/career_snapshot.dart';

/// Repository interface for career snapshot persistence.
///
/// Implementations may use SharedPreferences, SQLite, or cloud storage.
abstract class CareerRepositoryInterface {
  /// Loads the cached career snapshot from persistent storage.
  Future<CareerSnapshot?> loadCachedSnapshot();

  /// Saves the current career snapshot to persistent storage.
  Future<void> cacheSnapshot(CareerSnapshot snapshot);

  /// Clears all cached career data.
  Future<void> clear();
}
