import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/growth_index/repository/growth_repository_interface.dart';

/// Mock [GrowthRepositoryInterface] for testing.
class MockGrowthRepository implements GrowthRepositoryInterface {
  GrowthSnapshot? lastCachedSnapshot;
  bool shouldReturnNull = false;

  @override
  Future<GrowthSnapshot?> loadCachedSnapshot() async {
    if (shouldReturnNull) return null;
    return lastCachedSnapshot;
  }

  @override
  Future<void> cacheSnapshot(GrowthSnapshot snapshot) async {
    lastCachedSnapshot = snapshot;
  }

  @override
  Future<void> clear() async {
    lastCachedSnapshot = null;
  }
}
