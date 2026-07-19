import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../academy/services/academy_service.dart';
import '../../habit/services/habit_service.dart';
import '../../journey/models/journey.dart';
import '../../personal_knowledge/services/knowledge_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../models/identity_events.dart' show IdentityEvent, IdentityEventData;
import '../models/identity_profile.dart';
import '../models/identity_snapshot.dart';
import '../models/identity_state.dart';
import '../repository/identity_repository_interface.dart';

/// Single source of truth for identity state across the Phoenix Platform.
///
/// [IdentityEngine] owns all identity data and produces a unified
/// [IdentitySnapshot] that every consumer reads. No other module should
/// maintain duplicate identity state.
///
/// **Responsibilities:**
/// - Aggregate identity data from [UserStateService] and other services
/// - Produce a single [IdentitySnapshot] for all consumers
/// - Cache the snapshot for fast restart and offline startup
/// - React to platform events and refresh the snapshot
/// - Notify listeners when identity state changes
///
/// **Architecture Rules:**
/// - No AI logic
/// - No recommendation logic
/// - No mission logic
/// - No growth calculations
/// - Consumes services only — never duplicates data
/// - Dashboard reads [IdentitySnapshot] only — no direct service access
///
/// **Consumer Flow:**
/// ```
/// User → IdentityEngine → IdentitySnapshot → Dashboard
///                                            → Mission Engine
///                                            → Recommendation Engine
///                                            → AI Router
/// ```
class IdentityEngine extends ChangeNotifier {
  IdentityEngine({
    required this.repository,
    required this._userStateService,
    this._academyService,
    this._habitService,
    this._knowledgeService,
  });

  final IdentityRepositoryInterface repository;
  final UserStateService _userStateService;
  final AcademyService? _academyService;
  final HabitService? _habitService;
  final KnowledgeService? _knowledgeService;

  final PhoenixLogger _logger = PhoenixLogger.shared;
  IdentitySnapshot? _cachedSnapshot;
  IdentityState _identityState = IdentityState.uninitialized;

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current identity snapshot (may be cached).
  IdentitySnapshot? get snapshot => _cachedSnapshot;

  /// The current lifecycle state of this engine.
  IdentityState get identityState => _identityState;

  /// Whether the engine has been initialized to [IdentityState.ready].
  bool get isInitialized => _identityState == IdentityState.ready;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine by loading cached data, then building a fresh
  /// snapshot. If no cached data exists (first launch), builds from defaults.
  Future<void> init() async {
    _identityState = IdentityState.loading;
    notifyListeners();

    try {
      // 1. Try loading cached snapshot
      _cachedSnapshot = await repository.loadCachedSnapshot();

      // 2. Build a fresh snapshot from current service data
      final fresh = await _buildSnapshot();

      // 3. If we had a cache but services disagree (e.g. XP changed), update
      if (_cachedSnapshot == null ||
          _cachedSnapshot!.totalXp != fresh.totalXp ||
          _cachedSnapshot!.completionPercent != fresh.completionPercent) {
        _cachedSnapshot = fresh;
        await repository.cacheSnapshot(fresh);
      }

      _identityState = IdentityState.ready;
      _logger.info('IdentityEngine initialized',
          category: LogCategory.engine, source: 'IdentityEngine');
    } catch (e) {
      _identityState = IdentityState.error;
      _logger.error('IdentityEngine init failed',
          category: LogCategory.engine,
          source: 'IdentityEngine',
          errorDetail: e.toString());
    }

    notifyListeners();
  }

  /// Refreshes the snapshot from current service data and persists the cache.
  Future<void> refresh() async {
    _cachedSnapshot = await _buildSnapshot();
    await repository.cacheSnapshot(_cachedSnapshot!);
    _logger.info('IdentityEngine refreshed',
        category: LogCategory.engine, source: 'IdentityEngine');
    notifyListeners();
  }

  /// Handles a platform event and refreshes if identity-relevant.
  Future<void> handleEvent(IdentityEventData eventData) async {
    _logger.debug('IdentityEngine handling event: ${eventData.event.name}',
        category: LogCategory.observer, source: 'IdentityEngine');
    // All current events trigger a refresh
    switch (eventData.event) {
      case IdentityEvent.missionCompleted:
      case IdentityEvent.lessonCompleted:
      case IdentityEvent.projectCompleted:
      case IdentityEvent.assessmentCompleted:
      case IdentityEvent.careerUpdated:
      case IdentityEvent.goalUpdated:
      case IdentityEvent.profileUpdated:
      case IdentityEvent.learningPreferenceChanged:
      case IdentityEvent.habitCompleted:
      case IdentityEvent.xpGained:
      case IdentityEvent.stageProgressed:
        await refresh();
    }
  }

  /// Updates the identity profile and refreshes.
  Future<void> updateProfile(IdentityProfile profile) async {
    await repository.saveProfile(profile);
    await refresh();
  }

  /// Resets all identity data.
  Future<void> reset() async {
    _cachedSnapshot = null;
    _identityState = IdentityState.reset;
    await repository.clear();
    notifyListeners();
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  /// Builds a fresh [IdentitySnapshot] from all service data.
  Future<IdentitySnapshot> _buildSnapshot() async {
    final profile = await _buildProfile();
    final now = DateTime.now();

    // Read from UserStateService
    final userState = _userStateService.currentState;
    final identity = userState.identity;
    final journey = userState.journey;
    final stage = userState.currentJourneyStage;
    final missions = userState.missions;
    final totalXp = userState.totalXp;
    final level = userState.level;

    // Compute mission stats
    final completedMissions = missions.where((m) => m.isCompleted).length;
    final hasActiveMission = missions.any((m) => m.isActionable);
    final activeMission = missions.where((m) => m.isActionable).toList();
    final currentMissionTitle = activeMission.isNotEmpty
        ? activeMission.first.title
        : '';

    // Compute journey progress
    final journeyPercent = journey != null
        ? (journey.completion * 100).round()
        : 0;
    final stageTitle = stage?.title ?? '';

    // Compute experience label
    final experience = _experienceLabel(level);

    // Compute progress label
    final progress = profile.targetLevel > 0
        ? 'Level ${profile.currentLevel} of ${profile.targetLevel}'
        : 'Level $level';

    // Current goal
    final currentGoal = _buildGoal(journey, stageTitle, journeyPercent);

    // Learning
    final activePath = _academyService?.activePathProgress;
    final currentLesson = _academyService?.currentLesson;
    final hasActiveLearning = currentLesson != null || activePath != null;
    final currentLearningPathTitle = activePath?.pathId ?? '';

    // Career
    final careerProfile = userState.careerProfile;
    final currentCareerPathTitle = careerProfile?.nextGoal ?? '';

    // Habits
    final activeHabits = _habitService?.activeHabits ?? [];
    final activeHabitCount = activeHabits.length;

    // Knowledge
    final analytics = _knowledgeService?.analytics ?? {};
    final knowledgeNodeCount = (analytics['nodeCount'] as int?) ?? 0;

    // Lesson stats
    final learningProgress = userState.learningProgress;
    final lessonCount = learningProgress.fold<int>(
      0,
      (sum, lp) => sum + lp.moduleProgresses.fold<int>(
        0,
        (s, mp) => s + mp.lessonProgress.length,
      ),
    );
    final completedLessons = learningProgress.fold<int>(
      0,
      (sum, lp) => sum + lp.moduleProgresses.fold<int>(
        0,
        (s, mp) => s + mp.lessonProgress.where((l) => l.state.isFinished).length,
      ),
    );

    // Growth index (placeholder — always 0.5 for now)
    const growthIndex = 0.5;

    return IdentitySnapshot(
      profile: profile,
      currentIdentityTitle: identity?.title ?? profile.title,
      targetIdentityTitle: identity?.title ?? profile.title,
      currentGoal: currentGoal,
      experience: experience,
      progress: progress,
      currentMissionTitle: currentMissionTitle,
      currentLearningPathTitle: currentLearningPathTitle,
      currentCareerPathTitle: currentCareerPathTitle,
      growthIndex: growthIndex,
      completionPercent: journeyPercent,
      lastUpdated: now,
      missionCount: missions.length,
      completedMissions: completedMissions,
      lessonCount: lessonCount,
      completedLessons: completedLessons,
      totalXp: totalXp,
      level: level,
      activeHabitCount: activeHabitCount,
      knowledgeNodeCount: knowledgeNodeCount,
      hasActiveMission: hasActiveMission,
      hasActiveLearning: hasActiveLearning,
    );
  }

  /// Builds the identity profile from persisted data or service defaults.
  Future<IdentityProfile> _buildProfile() async {
    // 1. Try reading persisted profile from repository first.
    // This allows updateProfile() to persist and retrieve custom profiles.
    final persisted = await repository.loadProfile();
    if (persisted != null) return persisted;

    // 2. Fall back to UserState identity if no profile is persisted yet.
    final userState = _userStateService.currentState;
    final identity = userState.identity;

    if (identity != null) {
      return IdentityProfile(
        id: identity.id,
        title: identity.title,
        description: identity.description,
        iconName: identity.iconName,
        category: identity.category,
        currentLevel: identity.currentLevel,
        targetLevel: identity.targetLevel,
        careerGoal: userState.careerProfile?.nextGoal ?? '',
        experienceLevel: _experienceLabel(userState.level),
      );
    }

    // Default profile for new users
    return const IdentityProfile(
      id: 'default',
      title: 'Explorer',
      description: 'Begin your growth journey with Phoenix',
      iconName: 'person_outlined',
      category: 'General',
      currentLevel: 1,
      targetLevel: 5,
      careerGoal: 'Define your career goal',
      experienceLevel: 'beginner',
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /// Maps a numeric level to an experience label.
  String _experienceLabel(int level) {
    if (level <= 2) return 'Beginner';
    if (level <= 5) return 'Intermediate';
    if (level <= 8) return 'Advanced';
    return 'Expert';
  }

  /// Builds a human-readable goal string.
  String _buildGoal(
    Journey? journey,
    String stageTitle,
    int journeyPercent,
  ) {
    if (journey == null) return 'Begin your journey';
    if (journeyPercent >= 100) return 'Journey complete — maintain momentum';
    if (stageTitle.isNotEmpty) {
      return 'Complete $stageTitle stage — $journeyPercent% done';
    }
    return 'Progress through your journey — $journeyPercent% complete';
  }
}
