import 'package:flutter_test/flutter_test.dart';

import 'package:phoenix_platform/core/cloud/firestore_sync_adapter.dart';

void main() {
  group('FirestoreSyncAdapter', () {
    late FirestoreSyncAdapter adapter;

    setUp(() {
      adapter = FirestoreSyncAdapter(syncIntervalSeconds: 999);
    });

    tearDown(() {
      adapter.dispose();
    });

    // ── Initial State ──────────────────────────────────────────────

    test('initial state is idle', () {
      expect(adapter.status, FirestoreSyncStatus.idle);
      expect(adapter.isSyncing, false);
      expect(adapter.syncedCount, 0);
      expect(adapter.conflictCount, 0);
      expect(adapter.lastSyncAt, isNull);
      expect(adapter.offlineQueueSize, 0);
    });

    test('status label returns human-readable strings', () {
      expect(adapter.statusLabel, 'Idle');
    });

    test('last sync label returns Never when never synced', () {
      expect(adapter.lastSyncLabel, 'Never');
    });

    // ── Dirty Tracking ─────────────────────────────────────────────

    test('markDirty tracks dirty domains', () {
      expect(adapter.hasDirtyData, false);
      expect(adapter.dirtyDomains, isEmpty);

      adapter.markDirty(FirestoreSyncDomain.identity);
      expect(adapter.hasDirtyData, true);
      expect(adapter.isDirty(FirestoreSyncDomain.identity), true);
      expect(adapter.dirtyDomains, contains(FirestoreSyncDomain.identity));
    });

    test('markClean removes dirty domain', () {
      adapter.markDirty(FirestoreSyncDomain.portfolio);
      expect(adapter.isDirty(FirestoreSyncDomain.portfolio), true);

      adapter.markClean(FirestoreSyncDomain.portfolio);
      expect(adapter.isDirty(FirestoreSyncDomain.portfolio), false);
      expect(adapter.hasDirtyData, false);
    });

    test('multiple dirty domains are tracked independently', () {
      adapter.markDirty(FirestoreSyncDomain.career);
      adapter.markDirty(FirestoreSyncDomain.interview);
      adapter.markDirty(FirestoreSyncDomain.opportunity);

      expect(adapter.dirtyDomains.length, 3);
      expect(adapter.isDirty(FirestoreSyncDomain.career), true);
      expect(adapter.isDirty(FirestoreSyncDomain.interview), true);
      expect(adapter.isDirty(FirestoreSyncDomain.opportunity), true);
      expect(adapter.isDirty(FirestoreSyncDomain.resume), false);

      adapter.markClean(FirestoreSyncDomain.career);
      expect(adapter.dirtyDomains.length, 2);
    });

    test('intelligenceDomains returns expected list', () {
      final domains = FirestoreSyncAdapter.intelligenceDomains;
      expect(domains, contains(FirestoreSyncDomain.identity));
      expect(domains, contains(FirestoreSyncDomain.resume));
      expect(domains, contains(FirestoreSyncDomain.portfolio));
      expect(domains, contains(FirestoreSyncDomain.career));
      expect(domains, contains(FirestoreSyncDomain.interview));
      expect(domains, contains(FirestoreSyncDomain.opportunity));
      expect(domains, contains(FirestoreSyncDomain.knowledge));
      expect(domains, contains(FirestoreSyncDomain.memory));
      expect(domains, contains(FirestoreSyncDomain.progress));
      expect(domains, contains(FirestoreSyncDomain.journey));
      expect(domains, contains(FirestoreSyncDomain.review));
      expect(domains, contains(FirestoreSyncDomain.notifications));
      expect(domains.length, 12);
    });

    // ── Sync Status ────────────────────────────────────────────────

    test('syncAll transitions to offline when firestore is unavailable', () async {
      // Firestore is not initialized in test environment
      await adapter.syncAll();
      expect(adapter.status, FirestoreSyncStatus.offline);
      expect(adapter.lastSyncAt, isNull);
    });

    test('sync status changes through notifyListeners on dirty mark', () {
      var notifiedCount = 0;
      adapter.addListener(() {
        notifiedCount++;
      });

      adapter.markDirty(FirestoreSyncDomain.identity);
      expect(notifiedCount, greaterThanOrEqualTo(1));
    });

    // ── Offline Queue ──────────────────────────────────────────────

    test('offline queue is empty initially', () {
      expect(adapter.offlineQueueSize, 0);
    });

    test('syncAll when offline sets status to offline', () async {
      // Ensures offline status is properly set when no Firestore available
      await adapter.syncAll();
      expect(adapter.status, FirestoreSyncStatus.offline);
      expect(adapter.offlineQueueSize, 0); // No items queued because no dirty data
    });

    // ── Firestore Availability ─────────────────────────────────────

    test('isFirestoreAvailable is false when Firebase not initialized', () {
      expect(adapter.isFirestoreAvailable, false);
    });

    // ── Background Sync ────────────────────────────────────────────

    test('background sync can be started and stopped', () {
      // Should not throw
      adapter.startBackgroundSync();
      adapter.startBackgroundSync(); // Should be idempotent
      adapter.stopBackgroundSync();
      adapter.stopBackgroundSync(); // Should be idempotent
    });

    test('dispose stops background sync', () {
      final testAdapter = FirestoreSyncAdapter(syncIntervalSeconds: 999);
      testAdapter.startBackgroundSync();
      testAdapter.dispose();
      // Should not throw or cause issues
    });
  });

  // ── FirestoreSyncDomain Enum Tests ──────────────────────────────

  group('FirestoreSyncDomain', () {
    test('all enum values are unique', () {
      final values = FirestoreSyncDomain.values;
      final names = values.map((v) => v.name).toSet();
      expect(names.length, values.length);
    });

    test('contains all expected domains', () {
      final values = FirestoreSyncDomain.values.toSet();
      expect(values, contains(FirestoreSyncDomain.identity));
      expect(values, contains(FirestoreSyncDomain.resume));
      expect(values, contains(FirestoreSyncDomain.portfolio));
      expect(values, contains(FirestoreSyncDomain.career));
      expect(values, contains(FirestoreSyncDomain.interview));
      expect(values, contains(FirestoreSyncDomain.opportunity));
      expect(values, contains(FirestoreSyncDomain.knowledge));
      expect(values, contains(FirestoreSyncDomain.memory));
      expect(values, contains(FirestoreSyncDomain.progress));
      expect(values, contains(FirestoreSyncDomain.journey));
      expect(values, contains(FirestoreSyncDomain.review));
      expect(values, contains(FirestoreSyncDomain.notifications));
      expect(values, contains(FirestoreSyncDomain.userSettings));
      expect(values, contains(FirestoreSyncDomain.academy));
      expect(values, contains(FirestoreSyncDomain.habits));
      expect(values, contains(FirestoreSyncDomain.habitEntries));
      expect(values, contains(FirestoreSyncDomain.timeline));
      expect(values, contains(FirestoreSyncDomain.decisions));
      expect(values, contains(FirestoreSyncDomain.milestones));
      expect(values, contains(FirestoreSyncDomain.memoryGraph));
      expect(values.length, 20);
    });
  });

  // ── FirestoreSyncStatus Enum Tests ──────────────────────────────

  group('FirestoreSyncStatus', () {
    test('values are complete', () {
      expect(FirestoreSyncStatus.values.length, 6);
      expect(FirestoreSyncStatus.values,
          containsAll([FirestoreSyncStatus.idle, FirestoreSyncStatus.syncing,
            FirestoreSyncStatus.success, FirestoreSyncStatus.failed,
            FirestoreSyncStatus.offline, FirestoreSyncStatus.conflict]));
    });
  });

  // ── FirestoreSyncQueueItem Tests ────────────────────────────────

  group('FirestoreSyncQueueItem', () {
    test('creates with default attempts 0', () {
      final item = FirestoreSyncQueueItem(
        domain: FirestoreSyncDomain.career,
        data: {'key': 'value'},
      );
      expect(item.domain, FirestoreSyncDomain.career);
      expect(item.data, {'key': 'value'});
      expect(item.attempts, 0);
      expect(item.lastAttemptAt, isNull);
    });

    test('attempts can be incremented', () {
      final item = FirestoreSyncQueueItem(
        domain: FirestoreSyncDomain.identity,
        data: {},
        attempts: 1,
      );
      expect(item.attempts, 1);
      item.attempts++;
      expect(item.attempts, 2);
    });
  });
}
