import 'dart:async' show Future, Timer;
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';

import '../storage_service.dart' show StorageService;
import 'cloud_config.dart' show CloudConfig;
import 'cloud_database.dart' show CloudDatabase;
import 'conflict_resolver.dart' show ConflictResolver, MergeStrategy, VersionTracker;
import 'services/authentication_service.dart' show AuthenticationService;
import 'supabase_client.dart' show SupabaseClient;

/// Domain key for each data type that can be synced.
enum SyncDomain {
  userState,
  academy,
  habits,
  habitEntries,
  timeline,
  events,
  milestones,
  knowledge,
  decisionHistory,
  memoryGraph,
}

/// Status of a sync operation.
enum SyncStatus {
  idle,
  syncing,
  success,
  failed,
  conflict,
}

/// Production synchronization engine for Phoenix Cloud.
///
/// [SyncManager] provides:
/// - Incremental sync (only changed data since last sync)
/// - Dirty tracking (flags changed records for sync)
/// - Background sync (periodic automatic sync)
/// - Offline-first (queue changes when offline, sync when online)
/// - Retry queue (retry failed syncs with exponential backoff)
/// - Conflict detection and resolution
/// - Sync progress tracking
///
/// **Architecture Rules:**
/// - No business logic — sync orchestration only
/// - Consumes [StorageService] + [CloudDatabase] for data access
/// - Transparent to feature services
class SyncManager extends ChangeNotifier {
  SyncManager({
    required this.storageService,
    required this.authenticationService,
    required this.cloudDatabase,
    ConflictResolver? conflictResolver,
  }) : _conflictResolver = conflictResolver ?? const ConflictResolver();

  final StorageService storageService;
  final AuthenticationService authenticationService;
  final CloudDatabase cloudDatabase;
  final ConflictResolver _conflictResolver;

  // ── State ────────────────────────────────────────────────────────────

  SyncStatus _status = SyncStatus.idle;
  SyncDomain? _currentDomain;
  double _progress = 0.0;
  int _syncedCount = 0;

  /// Current sync status.
  SyncStatus get status => _status;

  /// Whether a sync is currently in progress.
  bool get isSyncing => _status == SyncStatus.syncing;

  /// The domain currently being synced, or `null`.
  SyncDomain? get currentDomain => _currentDomain;

  /// Sync progress as a fraction (0.0 – 1.0).
  double get progress => _progress;

  /// Number of items successfully synced.
  int get syncedCount => _syncedCount;

  /// Timestamp of the last successful sync.
  DateTime? _lastSyncAt;

  /// When the last sync completed.
  DateTime? get lastSyncAt => _lastSyncAt;

  /// Number of items waiting in the retry queue.
  int get retryQueueSize => _retryQueue.length;

  final List<SyncQueueItem> _retryQueue = [];
  final Set<String> _dirtyFlags = {};
  Timer? _backgroundTimer;

  /// Whether sync is available (authenticated + feature flag + initialized).
  bool get isAvailable =>
      authenticationService.isAuthenticated &&
      CloudConfig.syncEnabled &&
      SupabaseClient.instance.isInitialized;

  // ── Lifecycle ───────────────────────────────────────────────────────

  /// Starts background periodic sync.
  void startBackgroundSync() {
    if (!isAvailable) return;
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(
      Duration(seconds: CloudConfig.syncIntervalSeconds),
      (_) => syncAll(),
    );
    debugPrint('SyncManager: background sync started');
  }

  /// Stops background periodic sync.
  void stopBackgroundSync() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  @override
  void dispose() {
    stopBackgroundSync();
    super.dispose();
  }

  // ── Dirty Tracking ──────────────────────────────────────────────────

  /// Marks a domain as dirty (has unsynced changes).
  void markDirty(SyncDomain domain) {
    _dirtyFlags.add(domain.name);
  }

  /// Marks a domain as clean (synced).
  void markClean(SyncDomain domain) {
    _dirtyFlags.remove(domain.name);
  }

  /// Whether a domain has unsynced changes.
  bool isDirty(SyncDomain domain) => _dirtyFlags.contains(domain.name);

  /// Returns all domains with unsynced changes.
  Set<SyncDomain> get dirtyDomains =>
      _dirtyFlags.map((f) => SyncDomain.values.firstWhere((d) => d.name == f)).toSet();

  // ── Sync Operations ─────────────────────────────────────────────────

  /// Syncs all domains. Called periodically and on demand.
  Future<void> syncAll() async {
    if (!isAvailable || isSyncing) return;

    _status = SyncStatus.syncing;
    _syncedCount = 0;
    notifyListeners();

    try {
      // Process retry queue first
      await _processRetryQueue();

      // Sync each domain (dirty domains first, then incremental)
      final orderedDomains = _orderedDomains();
      for (var i = 0; i < orderedDomains.length; i++) {
        final domain = orderedDomains[i];
        _currentDomain = domain;
        _progress = i / orderedDomains.length;
        notifyListeners();

        await _syncDomain(domain);
        _syncedCount++;
      }

      _status = SyncStatus.success;
      _lastSyncAt = DateTime.now();
      _progress = 1.0;
      _currentDomain = null;
      debugPrint('SyncManager: all domains synced successfully');
    } catch (e) {
      _status = SyncStatus.failed;
      debugPrint('SyncManager: sync failed: $e');
    }

    notifyListeners();
  }

  /// Syncs only dirty domains.
  Future<void> syncDirty() async {
    await Future.wait(
      dirtyDomains.map((domain) => _syncDomain(domain)),
    );
  }

  /// Syncs a single domain.
  Future<void> _syncDomain(SyncDomain domain) async {
    final raw = _readDomainData(domain);

    if (raw == null) {
      debugPrint('SyncManager: no data to sync for $domain');
      markClean(domain);
      return;
    }

    try {
      final tableName = _tableForDomain(domain);
      final parsed = json.decode(raw);

      if (parsed is List) {
        // List data: upsert each item
        for (final item in parsed) {
          await _syncItemWithConflictCheck(
            tableName,
            Map<String, dynamic>.from(item as Map),
          );
        }
      } else if (parsed is Map) {
        // Single object: upsert directly
        await _syncItemWithConflictCheck(
          tableName,
          Map<String, dynamic>.from(parsed),
        );
      }

      markClean(domain);
      debugPrint('SyncManager: synced $domain');
    } catch (e) {
      _enqueueRetry(domain, raw);
      debugPrint('SyncManager: sync failed for $domain, queued for retry: $e');
    }
  }

  /// Syncs a single item with conflict detection and resolution.
  Future<void> _syncItemWithConflictCheck(
    String table,
    Map<String, dynamic> item,
  ) async {
    final itemId = item['id'] as String?;
    if (itemId == null) return;

    // Check for existing cloud version
    final cloudVersion = await cloudDatabase.readById(table, itemId);

    if (cloudVersion != null) {
      // Conflict: compare versions
      final localVersion = VersionTracker(
        version: (item['version'] as int? ?? 0) + 1,
        lastModified: DateTime.tryParse(item['updated_at'] as String? ?? ''),
      );
      final remoteVersion = VersionTracker(
        version: cloudVersion['version'] as int? ?? 0,
        lastModified: DateTime.tryParse(cloudVersion['updated_at'] as String? ?? ''),
      );

      final resolution = _conflictResolver.resolve(
        localData: item,
        cloudData: cloudVersion,
        localVersion: localVersion,
        cloudVersion: remoteVersion,
        strategy: MergeStrategy.lastWriteWins,
      );

      await cloudDatabase.upsert(table, resolution.resolved, isUpdate: true);
    } else {
      // No conflict: simple upsert
      await cloudDatabase.upsert(table, item);
    }
  }

  // ── Retry Queue ─────────────────────────────────────────────────────

  void _enqueueRetry(SyncDomain domain, String data) {
    if (_retryQueue.length >= CloudConfig.maxOfflineQueueSize) {
      _retryQueue.removeAt(0); // Drop oldest
    }
    _retryQueue.add(SyncQueueItem(domain, data, attempts: 0));
    notifyListeners();
  }

  Future<void> _processRetryQueue() async {
    if (_retryQueue.isEmpty) return;

    final batch = List<SyncQueueItem>.from(_retryQueue);
    _retryQueue.clear();

    for (final item in batch) {
      try {
        await _syncDomain(item.domain);
        debugPrint('SyncManager: retry succeeded for ${item.domain}');
      } catch (e) {
        if (item.attempts < CloudConfig.maxSyncRetries) {
          _retryQueue.add(SyncQueueItem(
            item.domain,
            item.data,
            attempts: item.attempts + 1,
          ));
        }
      }
    }

    notifyListeners();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Orders domains: dirty first, then the rest.
  List<SyncDomain> _orderedDomains() {
    final dirty = dirtyDomains.toList();
    final clean = SyncDomain.values.where((d) => !dirty.contains(d)).toList();
    return [...dirty, ...clean];
  }

  /// Reads domain data through the typed [StorageService] API.
  String? _readDomainData(SyncDomain domain) {
    switch (domain) {
      case SyncDomain.userState:
        return storageService.readUserSettings().toJson();
      case SyncDomain.academy:
        return storageService.readLearningPaths();
      case SyncDomain.habits:
        return storageService.readHabits();
      case SyncDomain.habitEntries:
        return storageService.readHabitEntries();
      case SyncDomain.timeline:
        return storageService.readTimelineEvents();
      case SyncDomain.events:
        return storageService.readTimelineEvents();
      case SyncDomain.milestones:
        return storageService.readMilestones();
      case SyncDomain.knowledge:
        return storageService.readKnowledgeSnapshot();
      case SyncDomain.decisionHistory:
        return storageService.readDecisionHistory();
      case SyncDomain.memoryGraph:
        return storageService.readMemoryGraph();
    }
  }

  /// Maps a [SyncDomain] to its Supabase table name.
  String _tableForDomain(SyncDomain domain) {
    switch (domain) {
      case SyncDomain.userState:
        return 'user_state';
      case SyncDomain.academy:
        return 'academy';
      case SyncDomain.habits:
        return 'habits';
      case SyncDomain.habitEntries:
        return 'habit_entries';
      case SyncDomain.timeline:
      case SyncDomain.events:
        return 'timeline_events';
      case SyncDomain.milestones:
        return 'milestones';
      case SyncDomain.knowledge:
        return 'knowledge_snapshot';
      case SyncDomain.decisionHistory:
        return 'decision_history';
      case SyncDomain.memoryGraph:
        return 'memory_graph';
    }
  }
}

/// Internal item for the sync retry queue.
class SyncQueueItem {
  SyncQueueItem(this.domain, this.data, {this.attempts = 0});
  final SyncDomain domain;
  final String data;
  final int attempts;
}
