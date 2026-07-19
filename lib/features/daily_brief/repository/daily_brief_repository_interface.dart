import '../models/daily_brief_snapshot.dart';
import '../models/daily_history.dart';

/// Data access boundary for the Daily Brief Engine.
abstract class DailyBriefRepositoryInterface {
  /// Loads the most recent cached snapshot, or `null` if none.
  Future<DailyBriefSnapshot?> loadCachedSnapshot();

  /// Caches the current snapshot for fast restart.
  Future<void> cacheSnapshot(DailyBriefSnapshot snapshot);

  /// Loads daily history, or empty history if none.
  Future<DailyHistory> loadHistory();

  /// Saves the full daily history.
  Future<void> saveHistory(DailyHistory history);

  /// Clears all persisted daily brief data.
  Future<void> clear();
}
