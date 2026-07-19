import 'package:phoenix_platform/features/identity/models/identity_profile.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/identity/repository/identity_repository_interface.dart';

/// Mock [IdentityRepositoryInterface] for testing.
class MockIdentityRepository implements IdentityRepositoryInterface {
  bool shouldReturnNull = false;

  IdentityProfile? _savedProfile;
  IdentitySnapshot? lastCachedSnapshot;

  @override
  Future<IdentityProfile?> loadProfile() async {
    if (shouldReturnNull) return null;
    return _savedProfile;
  }

  @override
  Future<void> saveProfile(IdentityProfile profile) async {
    _savedProfile = profile;
  }

  @override
  Future<IdentitySnapshot?> loadCachedSnapshot() async {
    if (shouldReturnNull) return null;
    return lastCachedSnapshot;
  }

  @override
  Future<void> cacheSnapshot(IdentitySnapshot snapshot) async {
    lastCachedSnapshot = snapshot;
  }

  @override
  Future<void> clear() async {
    _savedProfile = null;
    lastCachedSnapshot = null;
  }
}
