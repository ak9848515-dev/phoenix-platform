import 'dart:async' show Future, Timer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../shared/infrastructure/firebase/firebase_service.dart';
import '../../shared/infrastructure/logging/phoenix_logger.dart';
import '../bootstrap.dart';
import '../../features/identity/engine/identity_engine.dart';
import '../../features/career/engine/career_engine.dart';
import '../../features/portfolio/engine/portfolio_engine.dart';
import '../../features/resume_intelligence/engine/resume_intelligence_engine.dart';
import '../../features/interview/intelligence/engine/interview_intelligence_engine.dart';
import '../../features/opportunity/intelligence/engine/opportunity_intelligence_engine.dart';
import '../../features/growth_index/engine/growth_index_engine.dart';
import '../../features/personal_knowledge/engine/knowledge_engine.dart';
import '../../features/memory_engine/engine/memory_engine.dart';
import '../../features/progress_engine/achievement_engine.dart';
import '../../features/continue_journey/engine/continue_journey_engine.dart';
import '../../features/review_engine/engine/review_engine.dart';

/// Domain key for each data type that can be synced via Firestore.
enum FirestoreSyncDomain {
  identity,
  resume,
  portfolio,
  career,
  interview,
  opportunity,
  knowledge,
  memory,
  progress,
  journey,
  review,
  notifications,
  userSettings,
  academy,
  habits,
  habitEntries,
  timeline,
  decisions,
  milestones,
  memoryGraph,
}

/// Status of a Firestore sync operation.
enum FirestoreSyncStatus {
  idle,
  syncing,
  success,
  failed,
  offline,
  conflict,
}

/// Tracks pending sync queue items for offline-first sync.
class FirestoreSyncQueueItem {
  FirestoreSyncQueueItem({
    required this.domain,
    required this.data,
    this.attempts = 0,
    this.lastAttemptAt,
  });

  final FirestoreSyncDomain domain;
  final Map<String, dynamic> data;
  int attempts;
  DateTime? lastAttemptAt;
}

/// Unified Firestore synchronization adapter.
///
/// Provides offline-first sync with Firestore for all Phoenix intelligence
/// engines. Follows the same pattern as [SyncManager] but targets Firestore.
///
/// **Architecture:**
/// ```text
/// Engines → Data changes
///    ↓
/// FirestoreSyncAdapter.markDirty()
///    ↓
/// FirestoreSyncAdapter.syncAll() (manual or background)
///    ↓
/// FirebaseFirestore (offline persistence enabled)
/// ```
///
/// **Rules:**
/// - No business logic — sync orchestration only
/// - Consumes FirebaseService.firestore for all operations
/// - Offline queue with conflict resolution via last-write-wins
/// - Background periodic sync when online
/// - Incremental sync: only dirty domains are synced
/// - Batch writes: multiple domains batched into single commit
class FirestoreSyncAdapter extends ChangeNotifier {
  FirestoreSyncAdapter({
    this.syncIntervalSeconds = 300, // 5 min default
    this.identityEngine,
    this.careerEngine,
    this.portfolioEngine,
    this.resumeEngine,
    this.interviewEngine,
    this.opportunityEngine,
    this.growthEngine,
    this.knowledgeEngine,
    this.memoryEngine,
    this.achievementEngine,
    this.journeyEngine,
    this.reviewEngine,
  });

  final PhoenixLogger _logger = PhoenixLogger.shared;
  final int syncIntervalSeconds;

  // ── Engine References (optional — for snapshot serialization) ──────
  final IdentityEngine? identityEngine;
  final CareerEngine? careerEngine;
  final PortfolioEngine? portfolioEngine;
  final ResumeIntelligenceEngine? resumeEngine;
  final InterviewIntelligenceEngine? interviewEngine;
  final OpportunityIntelligenceEngine? opportunityEngine;
  final GrowthIndexEngine? growthEngine;
  final KnowledgeEngine? knowledgeEngine;
  final MemoryEngine? memoryEngine;
  final AchievementEngine? achievementEngine;
  final ContinueJourneyEngine? journeyEngine;
  final ReviewEngine? reviewEngine;

  // ── State ────────────────────────────────────────────────────────────

  FirestoreSyncStatus _status = FirestoreSyncStatus.idle;
  FirestoreSyncDomain? _currentDomain;
  double _progress = 0.0;
  int _syncedCount = 0;
  int _conflictCount = 0;
  int _skippedCount = 0;
  DateTime? _lastSyncAt;
  final Set<String> _dirtyFlags = {};
  final List<FirestoreSyncQueueItem> _offlineQueue = [];
  Timer? _backgroundTimer;
  bool _syncInProgress = false;

  /// Total sync runs performed.
  int _syncRunCount = 0;

  /// Total latency of sync operations (ms).
  int _totalSyncLatencyMs = 0;

  /// Current sync status.
  FirestoreSyncStatus get status => _status;

  /// Whether a sync is currently in progress.
  bool get isSyncing => _status == FirestoreSyncStatus.syncing;

  /// The domain currently being synced, or `null`.
  FirestoreSyncDomain? get currentDomain => _currentDomain;

  /// Sync progress as a fraction (0.0 – 1.0).
  double get progress => _progress;

  /// Number of items successfully synced.
  int get syncedCount => _syncedCount;

  /// Number of conflicts resolved during last sync.
  int get conflictCount => _conflictCount;

  /// Number of domains skipped during last sync (already clean).
  int get skippedCount => _skippedCount;

  /// Total number of sync runs performed.
  int get syncRunCount => _syncRunCount;

  /// Average sync latency in milliseconds.
  double get averageSyncLatencyMs =>
      _syncRunCount > 0 ? _totalSyncLatencyMs / _syncRunCount : 0.0;

  /// Timestamp of the last successful sync.
  DateTime? get lastSyncAt => _lastSyncAt;

  /// Number of items waiting in the offline queue.
  int get offlineQueueSize => _offlineQueue.length;

  /// Whether Firestore is available.
  bool get isFirestoreAvailable =>
      FirebaseService.isInitialized && FirebaseService.firestore != null;

  /// Human-readable status label.
  String get statusLabel {
    switch (_status) {
      case FirestoreSyncStatus.idle:
        return 'Idle';
      case FirestoreSyncStatus.syncing:
        return 'Syncing...';
      case FirestoreSyncStatus.success:
        return 'Synced';
      case FirestoreSyncStatus.failed:
        return 'Sync Failed';
      case FirestoreSyncStatus.offline:
        return 'Offline';
      case FirestoreSyncStatus.conflict:
        return 'Conflict Detected';
    }
  }

  /// Human-readable last sync label.
  String get lastSyncLabel {
    if (_lastSyncAt == null) return 'Never';
    final diff = DateTime.now().difference(_lastSyncAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ── Lifecycle ───────────────────────────────────────────────────────

  /// Starts background periodic sync.
  void startBackgroundSync() {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(
      Duration(seconds: syncIntervalSeconds),
      (_) => syncAll(),
    );
    _logger.info('FirestoreSyncAdapter: background sync started',
        category: LogCategory.engine, source: 'FirestoreSyncAdapter');
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
  /// Does NOT call [notifyListeners] unless the domain was already clean
  /// — prevents repeated rebuilds when multiple engines fire simultaneously.
  void markDirty(FirestoreSyncDomain domain) {
    final wasClean = !_dirtyFlags.contains(domain.name);
    _dirtyFlags.add(domain.name);
    _status = FirestoreSyncStatus.idle;
    // Only notify if this is a new dirty flag (not already dirty)
    if (wasClean) notifyListeners();
  }

  /// Marks a domain as clean (synced).
  void markClean(FirestoreSyncDomain domain) {
    _dirtyFlags.remove(domain.name);
  }

  /// Whether a domain has unsynced changes.
  bool isDirty(FirestoreSyncDomain domain) =>
      _dirtyFlags.contains(domain.name);

  /// Returns all domains with unsynced changes.
  Set<FirestoreSyncDomain> get dirtyDomains =>
      _dirtyFlags.map((f) => FirestoreSyncDomain.values.firstWhere(
          (d) => d.name == f)).toSet();

  /// Whether any domain has unsynced changes.
  bool get hasDirtyData => _dirtyFlags.isNotEmpty;

  /// Clears all dirty flags without syncing.
  void clearAllDirty() {
    _dirtyFlags.clear();
    notifyListeners();
  }

  // ── Sync Operations ─────────────────────────────────────────────────

  /// Syncs all dirty domains to Firestore.
  /// Returns immediately if no dirty data or sync already in progress.
  ///
  /// **Performance:** Uses [notifyImmediately] pattern — only notifies
  /// listeners at sync start and end (not per-domain during sync).
  Future<void> syncAll() async {
    if (!isFirestoreAvailable) {
      _status = FirestoreSyncStatus.offline;
      notifyListeners();
      return;
    }
    if (_syncInProgress) return;

    // Skip if no dirty data — incremental sync optimization
    if (_dirtyFlags.isEmpty && _offlineQueue.isEmpty) {
      _skippedCount = 0;
      _status = FirestoreSyncStatus.success;
      return;
    }

    _syncInProgress = true;
    final syncStart = DateTime.now();
    int syncElapsed = 0;

    _status = FirestoreSyncStatus.syncing;
    _syncedCount = 0;
    _conflictCount = 0;
    _skippedCount = 0;
    notifyListeners(); // Only 2 listener calls during sync (start + end)

    try {
      // Process offline queue first
      await _processOfflineQueue();

      // Sync each dirty domain — batch writes for efficiency
      final dirty = dirtyDomains.toList();
      _skippedCount = 0;

      // Batch sync all dirty domains — no per-domain notifyListeners calls
      for (var i = 0; i < dirty.length; i++) {
        final domain = dirty[i];
        if (!isDirty(domain)) {
          _skippedCount++;
          continue;
        }
        _currentDomain = domain;
        _progress = dirty.length > 1 ? i / (dirty.length - 1) : 1.0;

        final success = await _syncDomain(domain);
        if (success) {
          markClean(domain);
          _syncedCount++;
        }
      }

      _status = dirty.any((d) => isDirty(d))
          ? FirestoreSyncStatus.failed
          : FirestoreSyncStatus.success;
      if (_status == FirestoreSyncStatus.success) {
        _lastSyncAt = DateTime.now();
      }
      _progress = 1.0;
      _currentDomain = null;

      syncElapsed = DateTime.now().difference(syncStart).inMilliseconds;
      _syncRunCount++;
      _totalSyncLatencyMs += syncElapsed;

      _logger.info('FirestoreSyncAdapter: sync completed',
          category: LogCategory.engine, source: 'FirestoreSyncAdapter',
          elapsedMs: syncElapsed,
          metadata: {
            'syncedCount': _syncedCount,
            'conflictCount': _conflictCount,
            'skippedCount': _skippedCount,
            'dirtyDomains': dirty.length,
            'status': _status.name,
          });
    } catch (e) {
      _status = FirestoreSyncStatus.failed;
      _logger.warning('FirestoreSyncAdapter: sync failed: $e',
          category: LogCategory.engine, source: 'FirestoreSyncAdapter');
    }

    final diag = AppBootstrap.maybeDiagnosticsService;
    diag?.recordSyncDuration(syncElapsed);

    _syncInProgress = false;
    notifyListeners(); // Final notification — only 2 during sync
  }

  /// Syncs a specific domain's data to Firestore.
  Future<bool> _syncDomain(FirestoreSyncDomain domain) async {
    final firestore = FirebaseService.firestore;
    if (firestore == null) return false;

    try {
      final collection = _collectionForDomain(domain);
      final userId = FirebaseService.auth?.currentUser?.uid ?? 'anonymous';
      final batch = firestore.batch();
      var writes = 0;

      // Each domain maps to a Firestore document under user's collection
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection(collection)
          .doc('current');

      // Check for existing data to resolve conflicts
      final readStart = DateTime.now();
      final existing = await docRef.get();
      final readElapsed = DateTime.now().difference(readStart).inMilliseconds;
      final diag = AppBootstrap.maybeDiagnosticsService;
      diag?.recordFirestoreRead(readElapsed);
      if (existing.exists) {
        final existingData = existing.data() as Map<String, dynamic>;
        final existingUpdated = existingData['updatedAt'] as String?;
        if (existingUpdated != null) {
          final existingTime = DateTime.tryParse(existingUpdated);
          final now = DateTime.now();
          // Conflict resolution: last write wins
          if (existingTime != null && existingTime.isAfter(now)) {
            _conflictCount++;
            // Cloud data is newer — skip local push
            _logger.info(
                'FirestoreSyncAdapter: conflict resolved — cloud newer for $domain',
                category: LogCategory.engine, source: 'FirestoreSyncAdapter');
            return true;
          }
        }
      }

      // Serialize engine snapshot data for this domain
      final snapshotData = _serializeSnapshot(domain);

      // Write sync marker with actual snapshot data + timestamp
      final writeStart = DateTime.now();
      batch.set(docRef, {
        'domain': domain.name,
        'data': snapshotData,
        'syncedAt': FieldValue.serverTimestamp(),
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'version': existing.exists
            ? (existing.data()?['version'] ?? 0) + 1
            : 1,
      }, SetOptions(merge: true));
      writes++;

      if (writes > 0) {
        await batch.commit();
        final writeElapsed = DateTime.now().difference(writeStart).inMilliseconds;
        diag?.recordFirestoreWrite(writeElapsed);
      }

      return true;
    } catch (e) {
      _enqueueOffline(domain, {'domain': domain.name, 'error': e.toString()});
      return false;
    }
  }

  // ── Offline Queue ───────────────────────────────────────────────────

  void _enqueueOffline(FirestoreSyncDomain domain, Map<String, dynamic> data) {
    // Dedup: remove existing queued items for the same domain
    _offlineQueue.removeWhere((item) => item.domain == domain);
    if (_offlineQueue.length >= 100) {
      _offlineQueue.removeAt(0); // Drop oldest
    }
    _offlineQueue.add(FirestoreSyncQueueItem(
      domain: domain,
      data: data,
      attempts: 0,
    ));
    _status = FirestoreSyncStatus.offline;
    notifyListeners();
  }

  Future<void> _processOfflineQueue() async {
    if (_offlineQueue.isEmpty) return;
    if (!isFirestoreAvailable) return;

    final batch = List<FirestoreSyncQueueItem>.from(_offlineQueue);
    _offlineQueue.clear();

    for (final item in batch) {
      // Dedup: skip if domain was already synced in this run
      if (!isDirty(item.domain)) continue;
      try {
        await _syncDomain(item.domain);
        markClean(item.domain);
        _logger.info(
            'FirestoreSyncAdapter: offline queue item synced for ${item.domain}',
            category: LogCategory.engine, source: 'FirestoreSyncAdapter');
      } catch (e) {
        if (item.attempts < 3) {
          item.attempts++;
          item.lastAttemptAt = DateTime.now();
          _offlineQueue.add(item);
        }
      }
    }

    notifyListeners();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Maps a [FirestoreSyncDomain] to its Firestore collection name.
  String _collectionForDomain(FirestoreSyncDomain domain) {
    switch (domain) {
      case FirestoreSyncDomain.identity:
        return 'identity';
      case FirestoreSyncDomain.resume:
        return 'resume';
      case FirestoreSyncDomain.portfolio:
        return 'portfolio';
      case FirestoreSyncDomain.career:
        return 'career';
      case FirestoreSyncDomain.interview:
        return 'interview';
      case FirestoreSyncDomain.opportunity:
        return 'opportunity';
      case FirestoreSyncDomain.knowledge:
        return 'knowledge';
      case FirestoreSyncDomain.memory:
        return 'memory';
      case FirestoreSyncDomain.progress:
        return 'progress';
      case FirestoreSyncDomain.journey:
        return 'journey';
      case FirestoreSyncDomain.review:
        return 'review';
      case FirestoreSyncDomain.notifications:
        return 'notifications';
      case FirestoreSyncDomain.userSettings:
        return 'user_settings';
      case FirestoreSyncDomain.academy:
        return 'academy';
      case FirestoreSyncDomain.habits:
        return 'habits';
      case FirestoreSyncDomain.habitEntries:
        return 'habit_entries';
      case FirestoreSyncDomain.timeline:
        return 'timeline';
      case FirestoreSyncDomain.decisions:
        return 'decisions';
      case FirestoreSyncDomain.milestones:
        return 'milestones';
      case FirestoreSyncDomain.memoryGraph:
        return 'memory_graph';
    }
  }

  /// Returns the sync domains relevant for intelligence engines.
  static List<FirestoreSyncDomain> get intelligenceDomains => [
        FirestoreSyncDomain.identity,
        FirestoreSyncDomain.resume,
        FirestoreSyncDomain.portfolio,
        FirestoreSyncDomain.career,
        FirestoreSyncDomain.interview,
        FirestoreSyncDomain.opportunity,
        FirestoreSyncDomain.knowledge,
        FirestoreSyncDomain.memory,
        FirestoreSyncDomain.progress,
        FirestoreSyncDomain.journey,
        FirestoreSyncDomain.review,
        FirestoreSyncDomain.notifications,
      ];

  // ── Snapshot Serialization ─────────────────────────────────────────

  /// Serializes the current engine snapshot for a given domain into a
  /// JSON-compatible map for Firestore storage.
  Map<String, dynamic> _serializeSnapshot(FirestoreSyncDomain domain) {
    switch (domain) {
      case FirestoreSyncDomain.identity:
        final snap = identityEngine?.snapshot;
        if (snap == null) return {};
        return {
          'currentIdentityTitle': snap.currentIdentityTitle,
          'targetIdentityTitle': snap.targetIdentityTitle,
          'currentGoal': snap.currentGoal,
          'currentMissionTitle': snap.currentMissionTitle,
          'completionPercent': snap.completionPercent,
          'activeHabitCount': snap.activeHabitCount,
        };

      case FirestoreSyncDomain.career:
        final snap = careerEngine?.snapshot;
        if (snap == null) return {};
        return {
          'careerScore': snap.careerScore,
          'jobReadiness': snap.jobReadiness,
          'strengths': snap.strengths,
          'skillGaps': snap.skillGaps,
          'nextGoal': snap.nextGoal,
          'estimatedWeeks': snap.estimatedWeeks,
          'interviewReadiness': snap.interviewReadiness,
          'resumeProgress': snap.resumeProgress,
          'portfolioProgress': snap.portfolioProgress,
          'applicationCount': snap.applicationCount,
          'offerCount': snap.offerCount,
          'hasData': snap.hasData,
        };

      case FirestoreSyncDomain.portfolio:
        final snap = portfolioEngine?.snapshot;
        if (snap == null) return {};
        return {
          'portfolioScore': snap.portfolioScore,
          'projectCount': snap.projectCount,
          'skillCount': snap.skillCount,
          'technologyCount': snap.technologyCount,
          'achievementCount': snap.achievementCount,
          'careerReadiness': snap.careerReadiness,
          'strengthAreas': snap.strengthAreas,
          'improvementAreas': snap.improvementAreas,
          'technologies': snap.technologies,
          'hasData': snap.hasData,
        };

      case FirestoreSyncDomain.resume:
        final snap = resumeEngine?.snapshot;
        if (snap == null) return {};
        return {
          'overallScore': snap.overallScore,
          'atsScore': snap.atsScore,
          'technicalScore': snap.technicalScore,
          'projectScore': snap.projectScore,
          'experienceScore': snap.experienceScore,
          'keywordCoverage': snap.keywordCoverage,
          'completeness': snap.completeness,
          'atsCompleteness': snap.atsCompleteness,
          'strengthCount': snap.strengthCount,
          'gapCount': snap.gapCount,
          'hasData': snap.hasData,
          'healthLabel': snap.topGap?.description ?? '',
        };

      case FirestoreSyncDomain.interview:
        final snap = interviewEngine?.snapshot;
        if (snap == null) return {};
        return {
          'readiness': snap.readiness.overall,
          'knowledgeScore': snap.readiness.knowledgeScore,
          'confidenceScore': snap.readiness.confidenceScore,
          'mockInterviewScore': snap.readiness.mockInterviewScore,
          'recentSessions': snap.recentSessions.length,
          'weakTopics': snap.weakTopics.map((t) => t.subject).toList(),
          'totalRecommendations': snap.recommendations.length,
          'actionableCount': snap.actionableCount,
          'isReadyForInterviews': snap.isReadyForInterviews,
          'hasData': snap.hasData,
        };

      case FirestoreSyncDomain.opportunity:
        final snap = opportunityEngine?.snapshot;
        if (snap == null) return {};
        return {
          'opportunityCount': snap.opportunityCount,
          'matchCount': snap.matches.length,
          'activeApplications': snap.activeApplicationCount,
          'offerCount': snap.offerCount,
          'bestMatchScore': snap.bestMatchScore,
          'overallReadiness': snap.overallReadiness,
          'actionItemCount': snap.actionItems.length,
          'topMatchScore': snap.topMatch.matchScore,
          'hasData': snap.hasData,
        };

      case FirestoreSyncDomain.knowledge:
        final snap = knowledgeEngine?.snapshot;
        if (snap == null) return {};
        return {
          'nodeCount': snap.nodeCount,
          'edgeCount': snap.edgeCount,
          'lastIndexedAt': snap.lastIndexedAt?.toIso8601String(),
          'lastSnapshotAt': snap.lastSnapshotAt?.toIso8601String(),
          'version': snap.version,
        };

      case FirestoreSyncDomain.memory:
        final snap = memoryEngine?.snapshot;
        if (snap == null) return {};
        return {
          'totalMemories': snap.totalMemories,
          'totalRelationships': snap.totalRelationships,
          'recentMemoryCount': snap.recentMemories.length,
          'importantMemoryCount': snap.importantMemories.length,
          'activeGoalCount': snap.activeGoals.length,
          'lastUpdated': snap.lastUpdated?.toIso8601String(),
        };

      case FirestoreSyncDomain.progress:
        final snap = achievementEngine?.snapshot;
        if (snap == null) return {};
        return {
          'totalAchievements': snap.totalAchievements,
          'totalBadges': snap.totalBadges,
          'totalMilestones': snap.totalMilestones,
          'totalRewards': snap.totalRewards,
          'totalCertificates': snap.totalCertificates,
          'hasAchievements': snap.hasAchievements,
          'hasRecentActivity': snap.hasRecentActivity,
          'lastUpdated': snap.lastUpdated?.toIso8601String(),
        };

      case FirestoreSyncDomain.journey:
        final snap = journeyEngine?.snapshot;
        if (snap == null) return {};
        return {
          'currentJourney': snap.currentJourney,
          'currentStage': snap.currentStage,
          'completionPercent': snap.completionPercent,
          'priority': snap.priority,
          'estimatedRemainingMinutes': snap.estimatedRemainingMinutes,
          'resumeCandidates': snap.resumeCandidates
              .map((c) => {
                    'id': c.id,
                    'title': c.title,
                    'type': c.type.name,
                    'progressPercent': c.progressPercent,
                  })
              .toList(),
          'lastUpdated': snap.lastUpdated?.toIso8601String(),
        };

      case FirestoreSyncDomain.review:
        final snap = reviewEngine?.snapshot;
        if (snap == null) return {};
        return {
          'reviewType': snap.reviewType.name,
          'title': snap.title,
          'overallScore': snap.overallScore,
          'date': snap.date,
          'periodLabel': snap.periodLabel,
          'overallSummary': snap.overallSummary,
          'topRecommendation': snap.topRecommendation,
          'improvement': snap.improvement,
          'hasItems': snap.hasItems,
          'items': snap.items.map((i) => i.toMap()).toList(),
        };

      case FirestoreSyncDomain.notifications:
      case FirestoreSyncDomain.userSettings:
      case FirestoreSyncDomain.academy:
      case FirestoreSyncDomain.habits:
      case FirestoreSyncDomain.habitEntries:
      case FirestoreSyncDomain.timeline:
      case FirestoreSyncDomain.decisions:
      case FirestoreSyncDomain.milestones:
      case FirestoreSyncDomain.memoryGraph:
        return {};
    }
  }
}
