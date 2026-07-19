import '../models/mission_history.dart';
import '../models/mission_snapshot.dart';

/// Data access boundary for the Mission Intelligence Engine.
///
/// Handles persistence of mission recommendation history and cached snapshots.
/// Consistent with [IdentityRepositoryInterface] and [GrowthRepositoryInterface].
abstract class MissionIntelligenceRepositoryInterface {
  /// Loads the most recent cached mission snapshot, or `null` if none.
  Future<MissionSnapshot?> loadCachedSnapshot();

  /// Caches the current snapshot for fast restart.
  Future<void> cacheSnapshot(MissionSnapshot snapshot);

  /// Loads mission recommendation history, or empty history if none.
  Future<MissionHistory> loadHistory();

  /// Saves the full mission history.
  Future<void> saveHistory(MissionHistory history);

  /// Clears all persisted mission intelligence data.
  Future<void> clear();
}
