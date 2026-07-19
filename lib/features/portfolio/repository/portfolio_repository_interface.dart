import '../engine/portfolio_snapshot.dart';

/// Repository interface for portfolio snapshot persistence.
///
/// Implementations may use SharedPreferences, SQLite, or cloud storage.
abstract class PortfolioRepositoryInterface {
  /// Loads the cached portfolio snapshot from persistent storage.
  Future<PortfolioSnapshot?> loadCachedSnapshot();

  /// Saves the current portfolio snapshot to persistent storage.
  Future<void> cacheSnapshot(PortfolioSnapshot snapshot);

  /// Clears all cached portfolio data.
  Future<void> clear();
}
