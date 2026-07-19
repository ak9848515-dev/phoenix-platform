import 'package:flutter/foundation.dart';

import '../../shared/infrastructure/ai_content/ingest_package.dart';
import '../../shared/infrastructure/ai_content/metadata.dart';
import '../../shared/infrastructure/cache/cache_service.dart';
import '../../shared/infrastructure/logging/phoenix_logger.dart';
import '../user_state/services/user_state_service.dart';
import 'achievement_snapshot.dart';
import 'progress_engine.dart' show AchievementProgress;
import 'progress_service.dart';
import 'repository/achievement_repository_interface.dart';

/// The Phoenix Achievement Engine — single source of truth for achievements.
///
/// Owns badges, milestones, rewards, certificates, and unlocked progress.
///
/// Produces an immutable [AchievementSnapshot] consumed by Progress,
/// Dashboard, Profile, and AI Mentor.
///
/// **Architecture:**
/// ```
/// ProgressService + UserStateService → AchievementEngine → AchievementSnapshot → Widgets
/// ```
class AchievementEngine extends ChangeNotifier {
  AchievementEngine({
    required this.repository,
    required this._progressService,
    this._userStateService,
    this._cacheService,
  });

  final AchievementRepositoryInterface repository;
  final ProgressService _progressService;
  final UserStateService? _userStateService;
  final CacheService? _cacheService;
  static const String _cacheKey = 'achievement:snapshot';

  final PhoenixLogger _logger = PhoenixLogger.shared;

  AchievementSnapshot? _cachedSnapshot;
  bool _isInitialized = false;

  /// AI-generated milestones kept separate from user achievements.
  final List<AIMilestoneEntry> _aiMilestones = [];

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current achievement snapshot (may be cached).
  AchievementSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  /// All AI-generated milestones currently stored.
  List<AIMilestoneEntry> get aiMilestones => List.unmodifiable(_aiMilestones);

  /// Whether any AI-generated milestones exist.
  bool get hasAIGeneratedMilestones => _aiMilestones.isNotEmpty;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes by loading cached data and building a fresh snapshot.
  Future<void> init() async {
    _cachedSnapshot = _cacheService?.get<AchievementSnapshot>(_cacheKey);
    _cachedSnapshot ??= await repository.loadCachedSnapshot();
    final fresh = _buildSnapshot();
    if (_cachedSnapshot == null ||
        fresh.totalAchievements != _cachedSnapshot!.totalAchievements) {
      _cachedSnapshot = fresh;
      _cacheService?.cache(_cacheKey, fresh, CacheDomain.progress);
      await repository.cacheSnapshot(fresh);
    }
    _isInitialized = true;
    _logger.info('AchievementEngine initialized',
        category: LogCategory.engine, source: 'AchievementEngine');
    notifyListeners();
  }

  /// Refreshes the snapshot from source data and persists it.
  Future<void> refresh() async {
    _cachedSnapshot = _buildSnapshot();
    _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.progress);
    await repository.cacheSnapshot(_cachedSnapshot!);
    _logger.info('AchievementEngine refreshed',
        category: LogCategory.engine, source: 'AchievementEngine');
    notifyListeners();
  }

  /// Resets all cached achievement data.
  Future<void> reset() async {
    _cachedSnapshot = null;
    _isInitialized = false;
    _cacheService?.invalidate(CacheDomain.progress);
    await repository.clear();
    _logger.info('AchievementEngine reset',
        category: LogCategory.engine, source: 'AchievementEngine');
    notifyListeners();
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  AchievementSnapshot _buildSnapshot() {
    final summary = _progressService.buildSummary();
    final state = _userStateService?.currentState;

    final missions = state?.missions ?? [];
    final completedCount = missions.where((m) => m.isCompleted).length;
    final totalCount = missions.length;

    // Use static calculate() for all 5 achievement types
    final progressAchievements = calculate(completedCount, totalCount);

    // Build lists from computed achievements
    final badges = <String>[];
    final milestones = <String>[];
    final recent = <AchievementItem>[];

    for (final a in progressAchievements) {
      if (a.completed) {
        if (a.title.contains('First') || a.title.contains('Win')) {
          badges.add(a.title);
        } else {
          milestones.add(a.title);
        }
        recent.add(AchievementItem(
          id: a.id,
          title: a.title,
          type: a.title.contains('Win') ? 'badge' : 'milestone',
          isCompleted: a.completed,
          progress: a.progress,
          date: DateTime.now(),
        ));
      }
    }

    // Add additional level/XP context from ProgressService
    final levelProgress = completedCount > 0 && summary.level > 0
        ? AchievementItem(
            id: 'level-${summary.level}',
            title: 'Level ${summary.level}',
            type: 'milestone',
            isCompleted: true,
            progress: 1.0,
            date: DateTime.now(),
          )
        : null;

    if (levelProgress != null) {
      recent.add(levelProgress);
    }

    return AchievementSnapshot(
      badges: badges,
      milestones: milestones,
      rewards: [],
      certificates: [],
      totalBadges: badges.length,
      totalMilestones: milestones.length,
      totalRewards: 0,
      totalCertificates: 0,
      recentAchievements: recent.take(10).toList(),
      lastUpdated: DateTime.now(),
    );
  }

  // ── AI Ingestion ──────────────────────────────────────────────────

  /// Ingests an AI-generated milestone into the engine.
  void ingest(IngestPackage pkg) {
    if (pkg.type != 'milestone') return;

    if (_aiMilestones.any((e) => e.metadata.contentHash == pkg.contentHash)) {
      _logger.info('AchievementEngine: duplicate milestone ingest skipped',
          category: LogCategory.engine, source: 'AchievementEngine');
      return;
    }

    final data = pkg.content;
    _aiMilestones.add(AIMilestoneEntry(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      metadata: pkg.metadata,
    ));
    _logger.info('AchievementEngine: ingested milestone ${data['title']}',
        category: LogCategory.engine, source: 'AchievementEngine');
  }

  /// Merges AI milestone with an existing entry by content hash.
  void merge(String id, IngestPackage pkg) {
    if (pkg.type != 'milestone') return;
    final idx = _aiMilestones.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final data = pkg.content;
    _aiMilestones[idx] = AIMilestoneEntry(
      id: id,
      title: data['title'] as String? ?? _aiMilestones[idx].title,
      description: data['description'] as String? ?? _aiMilestones[idx].description,
      metadata: pkg.metadata,
    );
  }

  /// Replaces an AI milestone by ID.
  void replace(String id, IngestPackage pkg) {
    merge(id, pkg);
  }

  /// Removes all AI-generated milestones.
  void clearGenerated() {
    _aiMilestones.clear();
    _logger.info('AchievementEngine: cleared all AI-generated milestones',
        category: LogCategory.engine, source: 'AchievementEngine');
  }

  /// Rolls back AI-generated content by content hash.
  void rollback(String contentHash) {
    _aiMilestones.removeWhere((e) => e.metadata.contentHash == contentHash);
    _logger.info('AchievementEngine: rolled back $contentHash',
        category: LogCategory.engine, source: 'AchievementEngine');
  }

  /// Stub for future schema migration support.
  void migration(int fromVersion, int toVersion) {
    _logger.info('AchievementEngine: migration $fromVersion→$toVersion (no-op)',
        category: LogCategory.engine, source: 'AchievementEngine');
  }

  /// Validates an ingest package fits the milestone schema.
  /// Returns null if valid, or an error message if invalid.
  String? validate(IngestPackage pkg) {
    if (pkg.type != 'milestone') return 'Expected type "milestone", got "${pkg.type}"';
    final title = pkg.content['title'] as String?;
    if (title == null || title.isEmpty) return 'Milestone title is required';
    return null;
  }

  // ── Achievement Calculations ─────────────────────────────────────

  /// Calculates achievement progress from mission completion data.
  ///
  /// Static so that [ProgressService] can call it without an engine instance.
  static List<AchievementProgress> calculate(int completedCount, int totalCount) {
    final completionRatio = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return <AchievementProgress>[
      AchievementProgress(
        id: 'first-win',
        title: 'First Win',
        progress: completionRatio.clamp(0.0, 1.0),
        completed: completedCount >= 1,
      ),
      AchievementProgress(
        id: 'consistency',
        title: 'Consistency',
        progress: (completionRatio * 2).clamp(0.0, 1.0),
        completed: completedCount >= 3,
      ),
      AchievementProgress(
        id: 'momentum',
        title: 'Building Momentum',
        progress: (completionRatio * 3).clamp(0.0, 1.0),
        completed: completedCount >= 5,
      ),
      AchievementProgress(
        id: 'dedication',
        title: 'Dedication',
        progress: (completionRatio * 5).clamp(0.0, 1.0),
        completed: completedCount >= 10,
      ),
      AchievementProgress(
        id: 'milestone-25',
        title: 'Quarter Century',
        progress: (completionRatio * 10).clamp(0.0, 1.0),
        completed: completedCount >= 25,
      ),
    ];
  }
}

/// An AI-generated milestone entry in the achievement engine.
class AIMilestoneEntry {
  const AIMilestoneEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.metadata,
  });

  final String id;
  final String title;
  final String description;
  final AIContentMetadata metadata;
}
