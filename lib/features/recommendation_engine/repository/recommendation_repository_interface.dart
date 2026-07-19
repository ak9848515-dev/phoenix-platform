import '../models/recommendation_history.dart';
import '../models/recommendation_snapshot.dart';

/// Data access boundary for the Recommendation Engine.
///
/// Consistent with [IdentityRepositoryInterface], [GrowthRepositoryInterface],
/// and [MissionIntelligenceRepositoryInterface] patterns.
abstract class RecommendationRepositoryInterface {
  /// Loads the most recent cached snapshot, or `null` if none.
  Future<RecommendationSnapshot?> loadCachedSnapshot();

  /// Caches the current snapshot for fast restart.
  Future<void> cacheSnapshot(RecommendationSnapshot snapshot);

  /// Loads recommendation history, or empty history if none.
  Future<RecommendationHistory> loadHistory();

  /// Saves the full recommendation history.
  Future<void> saveHistory(RecommendationHistory history);

  /// Clears all persisted recommendation data.
  Future<void> clear();
}
