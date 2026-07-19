import '../models/journey_history.dart';
import '../models/journey_snapshot.dart';

/// Data access boundary for the Continue Journey Engine.
abstract class JourneyRepositoryInterface {
  /// Loads the most recent cached journey snapshot, or `null` if none.
  Future<JourneySnapshot?> loadCachedSnapshot();

  /// Caches the current journey snapshot for fast restart.
  Future<void> cacheSnapshot(JourneySnapshot snapshot);

  /// Loads journey history, or empty history if none.
  Future<JourneyHistory> loadHistory();

  /// Saves the full journey history.
  Future<void> saveHistory(JourneyHistory history);

  /// Clears all persisted journey data.
  Future<void> clear();
}
