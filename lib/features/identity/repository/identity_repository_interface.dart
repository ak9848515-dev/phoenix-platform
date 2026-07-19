import '../models/identity_profile.dart';
import '../models/identity_snapshot.dart';

/// Data access boundary for the Identity Engine.
///
/// Implementations handle persistence and caching of [IdentityProfile] and
/// [IdentitySnapshot] data. The engine writes through this interface;
/// consumers read the engine's in-memory snapshot.
///
/// Consistent with the existing [Repository] pattern — all identity data
/// flows through this single interface.
abstract class IdentityRepositoryInterface {
  /// Loads the persisted identity profile, or `null` on first launch.
  Future<IdentityProfile?> loadProfile();

  /// Persists the identity profile.
  Future<void> saveProfile(IdentityProfile profile);

  /// Loads the most recent cached snapshot, or `null` if none.
  Future<IdentitySnapshot?> loadCachedSnapshot();

  /// Caches the current snapshot for fast restart.
  Future<void> cacheSnapshot(IdentitySnapshot snapshot);

  /// Clears all persisted identity data.
  Future<void> clear();
}
