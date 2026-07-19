import '../models/growth_snapshot.dart';

/// Abstract interface for growth data persistence.
///
/// Supports caching the latest [GrowthSnapshot] for fast startup
/// and offline operation.
abstract class GrowthRepositoryInterface {
  /// Persists the latest growth snapshot for fast startup caching.
  Future<void> cacheSnapshot(GrowthSnapshot snapshot);

  /// Loads the cached snapshot, or `null` if none exists.
  Future<GrowthSnapshot?> loadCachedSnapshot();

  /// Clears all cached growth data.
  Future<void> clear();
}
