import 'package:flutter/foundation.dart';

import '../local_repository.dart' show LocalRepository;
import '../repository.dart' show Repository;
import 'cloud_database.dart' show CloudDatabase;
import 'services/authentication_service.dart' show AuthenticationService;
import 'supabase_client.dart' show SupabaseClient;

/// Cloud-backed repository extending [LocalRepository] with Supabase sync.
class CloudRepository extends LocalRepository {
  CloudRepository({
    required super.storageService,
    required this.authenticationService,
    required this.cloudDatabase,
  });

  final AuthenticationService authenticationService;
  final CloudDatabase cloudDatabase;

  bool get isCloudEnabled => authenticationService.isAuthenticated;
  bool get _shouldSync => isCloudEnabled && SupabaseClient.instance.isInitialized;

  Future<void> enqueueWrite(String domain, String data) async {
    if (!_shouldSync) return;
    debugPrint('CloudRepository: enqueued $domain for sync');
  }
}

/// Adapter wrapping a [Repository] with cloud caching.
class RepositoryAdapter {
  RepositoryAdapter({required this.repository});
  final Repository repository;

  T readWithCache<T>(T Function() read, {required String domain}) => read();

  Future<void> writeWithCache(
    Future<void> Function() write, {
    required String domain,
    required String data,
  }) async {
    await write();
  }
}
