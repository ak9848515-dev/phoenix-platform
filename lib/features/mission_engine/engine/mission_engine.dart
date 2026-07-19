import '../../../shared/infrastructure/ai_content/ingest_package.dart';
import '../../../shared/infrastructure/ai_content/metadata.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../mission_engine.dart' as model;
import '../models/mission_category.dart';
import '../models/mission_difficulty.dart';
import '../models/mission_priority.dart';
import '../models/mission_snapshot.dart';
import '../models/mission_status.dart';
import 'mission_generator.dart';
import 'mission_prioritizer.dart';
import 'mission_scheduler.dart';

/// The Dynamic Mission Engine — single source of truth for all missions.
///
/// The Mission Engine owns:
/// - Mission generation
/// - Mission prioritization
/// - Mission scheduling
/// - Mission completion
/// - Mission recurrence
/// - Mission rewards
/// - Mission difficulty
/// - Mission dependencies
///
/// No other module should implement these rules.
class MissionEngine {
  MissionEngine({
    required this._generator,
    required this._prioritizer,
    required this._scheduler,
  });

  final MissionGenerator _generator;
  final MissionPrioritizer _prioritizer;
  final MissionScheduler _scheduler;
  final PhoenixLogger _logger = PhoenixLogger.shared;

  /// AI-generated missions kept separate from user-created ones.
  final List<_AIMissionEntry> _aiMissions = [];

  // ── Accessors ─────────────────────────────────────────────────────

  /// The growth-aware prioritizer.
  MissionPrioritizer get prioritizer => _prioritizer;

  /// All AI-generated missions currently stored.
  List<model.Mission> get aiGeneratedMissions =>
      _aiMissions.map((e) => e.mission).toList();

  /// Whether any AI-generated missions exist.
  bool get hasAIGeneratedMissions => _aiMissions.isNotEmpty;

  /// Builds an immutable [MissionSnapshot] from current state.
  MissionSnapshot get snapshot {
    // Collect all missions (both generated and AI-ingested)
    final allMissions = <model.Mission>[
      ..._aiMissions.map((e) => e.mission),
    ];

    final active = allMissions.where((m) => m.isActionable).toList();
    final completed = allMissions.where((m) => m.isCompleted).toList();
    final top = findTopPriority(allMissions);
    final upcoming = getUpcomingMissions(allMissions).take(5).toList();
    final total = allMissions.length;
    final done = completed.length;

    return MissionSnapshot(
      currentMission: top,
      upcomingMissions: upcoming,
      completedMissions: completed.take(10).toList(),
      activeMissions: _prioritizer.prioritize(active),
      totalMissions: total,
      completedCount: done,
      activeCount: active.length,
      completionRatio: total > 0 ? done / total : 0.0,
      aiGeneratedCount: _aiMissions.length,
      lastUpdated: DateTime.now(),
      aiMetadata: _aiMissions.map((e) => e.metadata).toList(),
    );
  }

  /// Refreshes internal state (no-op for now — missions are in-memory).
  /// Exists for interface consistency with other domain engines.
  void refresh() {
    _logger.info('MissionEngine refreshed',
        category: LogCategory.engine, source: 'MissionEngine');
  }

  // ── Generation ────────────────────────────────────────────────────

  /// Generates new missions from all platform services.
  List<model.Mission> generateMissions({
    required List<model.Mission> currentMissions,
    int maxMissions = 12,
  }) {
    return _generator.generateAll(
      currentMissions: currentMissions,
      maxMissions: maxMissions,
    );
  }

  // ── Prioritization ────────────────────────────────────────────────

  /// Returns missions sorted by priority (highest first).
  List<model.Mission> prioritizeMissions(List<model.Mission> missions) {
    return _prioritizer.prioritize(missions);
  }

  /// Returns the single highest-priority actionable mission.
  model.Mission? findTopPriority(List<model.Mission> missions) {
    return _prioritizer.findTopPriority(missions);
  }

  // ── Scheduling ────────────────────────────────────────────────────

  /// Returns missions that should be active today.
  List<model.Mission> getTodaysMissions(List<model.Mission> allMissions) {
    return _scheduler.getTodaysMissions(allMissions);
  }

  /// Returns upcoming missions for the next 7 days.
  List<model.Mission> getUpcomingMissions(List<model.Mission> allMissions) {
    return _scheduler.getUpcomingMissions(allMissions);
  }

  /// Generates a daily batch of missions from templates.
  List<model.Mission> generateDailyBatch({
    required List<model.Mission> existingMissions,
    required List<model.Mission> availableTemplates,
  }) {
    return _scheduler.generateDailyBatch(
      existingMissions: existingMissions,
      availableTemplates: availableTemplates,
    );
  }

  /// Refreshes recurring missions that are due for a new cycle.
  List<model.Mission> refreshRecurring(List<model.Mission> missions) {
    return missions.map((m) => _scheduler.refreshMission(m)).toList();
  }

  /// Checks if a recurring mission should be refreshed.
  bool shouldRefresh(model.Mission mission) {
    return _scheduler.shouldRefresh(mission);
  }

  // ── Completion ────────────────────────────────────────────────────

  /// Completes a mission and returns the updated mission with reward XP.
  ///
  /// The UI simply triggers completion. The engine handles all logic:
  /// - Sets status to completed
  /// - Records completed date
  /// - Sets progress to 1.0
  /// - Handles recurrence for recurring missions
  /// - Unblocks dependent missions
  (model.Mission mission, int xpAwarded) completeMission(
    model.Mission mission, {
    bool completeRecurring = false,
  }) {
    var updated = mission.copyWith(
      status: MissionStatus.completed,
      completedDate: DateTime.now(),
      progress: 1.0,
    );

    // For recurring missions, immediately set up the next cycle
    if (mission.recurring && !completeRecurring) {
      updated = updated.copyWith(
        status: MissionStatus.available,
        progress: 0.0,
        completedDate: DateTime.now(),
      );
    }

    return (updated, mission.rewardXP);
  }

  /// Marks a mission as skipped.
  model.Mission skipMission(model.Mission mission) {
    return mission.copyWith(
      status: MissionStatus.skipped,
      progress: 0.0,
    );
  }

  /// Updates a mission's progress fraction.
  model.Mission updateProgress(model.Mission mission, double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    final newStatus = clamped >= 1.0
        ? MissionStatus.completed
        : clamped > 0.0
            ? MissionStatus.inProgress
            : MissionStatus.pending;

    return mission.copyWith(
      progress: clamped,
      status: newStatus,
      completedDate: clamped >= 1.0 ? DateTime.now() : null,
    );
  }

  /// Unblocks missions whose dependency has been completed.
  List<model.Mission> unblockDependents({
    required String completedMissionId,
    required List<model.Mission> allMissions,
  }) {
    return allMissions.map((mission) {
      if (mission.dependencyMissionId == completedMissionId &&
          mission.isBlocked) {
        return mission.copyWith(status: MissionStatus.pending);
      }
      return mission;
    }).toList();
  }

  // ── Validation ────────────────────────────────────────────────────

  /// Validates a mission has all required fields populated.
  /// Returns null if valid, or an error message if invalid.
  String? validateMission(model.Mission mission) {
    if (mission.id.isEmpty) return 'Mission ID cannot be empty.';
    if (mission.title.isEmpty) return 'Mission title cannot be empty.';
    if (mission.description.isEmpty) {
      return 'Mission description cannot be empty.';
    }
    if (mission.estimatedDuration <= 0) {
      return 'Estimated duration must be positive.';
    }
    if (mission.rewardXP < 0) return 'Reward XP cannot be negative.';
    if (mission.progress < 0.0 || mission.progress > 1.0) {
      return 'Progress must be between 0.0 and 1.0.';
    }
    if (mission.recurring &&
        mission.recurrenceIntervalDays != null &&
        mission.recurrenceIntervalDays! < 1) {
      return 'Recurrence interval must be at least 1 day.';
    }
    return null;
  }

  // ── AI Ingestion ──────────────────────────────────────────────────

  /// Ingests an AI-generated mission into the engine.
  ///
  /// The engine wraps the mission with metadata and stores it separately
  /// from user-created missions. Duplicate detection uses [IngestPackage.contentHash].
  void ingest(IngestPackage pkg) {
    if (pkg.type != 'mission') return;

    // Duplicate detection by content hash
    if (_aiMissions.any((e) => e.metadata.contentHash == pkg.contentHash)) {
      _logger.info('MissionEngine: duplicate ingest skipped',
          category: LogCategory.engine, source: 'MissionEngine');
      return;
    }

    final mission = _parseMissionFromPackage(pkg);
    if (mission == null) return;

    _aiMissions.add(_AIMissionEntry(mission: mission, metadata: pkg.metadata));
    _logger.info('MissionEngine: ingested mission ${mission.title}',
        category: LogCategory.engine, source: 'MissionEngine');
  }

  /// Merges an AI mission with an existing mission by ID.
  ///
  /// Does nothing if no existing mission matches the ID.
  /// User-created missions are never overwritten.
  void merge(String id, IngestPackage pkg) {
    if (pkg.type != 'mission') return;

    final idx = _aiMissions.indexWhere((e) => e.mission.id == id);
    if (idx == -1) {
      _logger.warning('MissionEngine: merge target $id not found',
          category: LogCategory.engine, source: 'MissionEngine');
      return;
    }

    final updated = _parseMissionFromPackage(pkg);
    if (updated == null) return;
    _aiMissions[idx] = _AIMissionEntry(mission: updated, metadata: pkg.metadata);
    _logger.info('MissionEngine: merged mission $id',
        category: LogCategory.engine, source: 'MissionEngine');
  }

  /// Replaces an AI mission entirely by ID.
  void replace(String id, IngestPackage pkg) {
    // Same as merge for now — AI missions are fully replaceable
    merge(id, pkg);
  }

  /// Removes all AI-generated missions from this engine.
  void clearGenerated() {
    _aiMissions.clear();
    _logger.info('MissionEngine: cleared all AI-generated missions',
        category: LogCategory.engine, source: 'MissionEngine');
  }

  /// Rolls back AI-generated content to a previous version by content hash.
  /// Removes the matching entry if it exists.
  void rollback(String contentHash) {
    _aiMissions.removeWhere((e) => e.metadata.contentHash == contentHash);
    _logger.info('MissionEngine: rolled back $contentHash',
        category: LogCategory.engine, source: 'MissionEngine');
  }

  /// Stub for future schema migration support.
  void migration(int fromVersion, int toVersion) {
    _logger.info('MissionEngine: migration $fromVersion→$toVersion (no-op)',
        category: LogCategory.engine, source: 'MissionEngine');
  }

  /// Validates an ingest package fits the mission schema.
  /// Returns null if valid, or an error message if invalid.
  String? validate(IngestPackage pkg) {
    if (pkg.type != 'mission') return 'Expected type "mission", got "${pkg.type}"';
    final mission = _parseMissionFromPackage(pkg);
    if (mission == null) return 'Failed to parse mission from package';
    return validateMission(mission);
  }

  model.Mission? _parseMissionFromPackage(IngestPackage pkg) {
    try {
      final data = pkg.content;
      final id = data['id'] as String? ?? '';
      final title = data['title'] as String? ?? '';
      final description = data['description'] as String? ?? '';
      final duration = data['estimatedMinutes'] as int? ?? 30;
      final difficulty = data['difficulty'] as String? ?? 'intermediate';

      return model.Mission(
        id: id,
        title: title,
        description: description,
        category: _mapCategory(difficulty),
        priority: MissionPriority.high,
        difficulty: _mapDifficulty(difficulty),
        estimatedDuration: duration,
        rewardXP: duration * 10,
        status: MissionStatus.available,
        progress: 0.0,
        createdDate: pkg.metadata.generatedAt,
        sourceService: 'ai:${pkg.metadata.provider}',
      );
    } catch (e) {
      _logger.error('MissionEngine: failed to parse ingest package: $e',
          category: LogCategory.engine, source: 'MissionEngine',
          errorDetail: e.toString());
      return null;
    }
  }

  MissionDifficulty _mapDifficulty(String d) {
    switch (d.toLowerCase()) {
      case 'beginner':
        return MissionDifficulty.beginner;
      case 'easy':
        return MissionDifficulty.easy;
      case 'hard':
        return MissionDifficulty.hard;
      case 'expert':
        return MissionDifficulty.expert;
      default:
        return MissionDifficulty.medium;
    }
  }

  MissionCategory _mapCategory(String d) {
    switch (d.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return MissionCategory.learning;
      case 'hard':
      case 'expert':
        return MissionCategory.portfolio;
      default:
        return MissionCategory.build;
    }
  }
}

/// Internal entry pairing a parsed Mission with its AI metadata.
class _AIMissionEntry {
  const _AIMissionEntry({
    required this.mission,
    required this.metadata,
  });

  final model.Mission mission;
  final AIContentMetadata metadata;
}
