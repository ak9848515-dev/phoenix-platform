import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../shared/infrastructure/performance/debounce_notifier.dart';
import '../../daily_brief/engine/daily_brief_engine.dart';
import '../../daily_brief/models/daily_brief_snapshot.dart';
import '../../daily_brief/models/daily_task.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../growth_index/models/growth_snapshot.dart';
import '../../identity/engine/identity_engine.dart';
import '../../identity/models/identity_snapshot.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../mission_intelligence/models/mission_snapshot.dart';
import '../../recommendation_engine/engine/recommendation_engine.dart';
import '../../recommendation_engine/models/recommendation_snapshot.dart';
import '../models/journey_activity.dart';
import '../models/journey_history.dart';
import '../models/journey_history_entry.dart';
import '../models/journey_resume_point.dart';
import '../models/journey_snapshot.dart';
import '../repository/journey_repository_interface.dart';

/// The Phoenix Continue Journey Engine.
///
/// Determines what the user was doing and what they should continue.
///
/// **Responsibilities:**
/// - Identify the user's current journey and stage
/// - Detect interrupted/pending activities across all domains
/// - Rank resume candidates by priority, progress, and impact
/// - Track journey history (started, paused, completed, cancelled)
/// - Cache the latest snapshot for fast restart
///
/// **Architecture Rules:**
/// - No AI, no LLM, no prompt generation
/// - No mission generation — consumes from MissionEngine
/// - No recommendation generation — consumes from RecommendationEngine
/// - Continue Journey orchestration only
class ContinueJourneyEngine extends ChangeNotifier
    with DebounceChangeNotifier {
  ContinueJourneyEngine({
    required this.repository,
    required this._identityEngine,
    required this._growthEngine,
    required this._missionEngine,
    required this._recommendationEngine,
    required this._dailyBriefEngine,
    this._cacheService,
  });

  final JourneyRepositoryInterface repository;
  final IdentityEngine _identityEngine;
  final GrowthIndexEngine _growthEngine;
  final MissionIntelligenceEngine _missionEngine;
  final RecommendationEngine _recommendationEngine;
  final DailyBriefEngine _dailyBriefEngine;
  final CacheService? _cacheService;
  static const String _cacheKey = 'journey:snapshot';

  JourneySnapshot? _cachedSnapshot;
  final PhoenixLogger _logger = PhoenixLogger.shared;
  JourneyHistory _history = const JourneyHistory();
  bool _isInitialized = false;
  bool _isBuilding = false;

  // ── Accessors ─────────────────────────────────────────────────────

  JourneySnapshot? get snapshot => _cachedSnapshot;
  JourneyHistory get history => _history;
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  Future<void> init() async {
    _cachedSnapshot = _cacheService?.get<JourneySnapshot>(_cacheKey);
    _cachedSnapshot ??= await repository.loadCachedSnapshot();
    _history = await repository.loadHistory();

    if (_cachedSnapshot == null) {
      _cachedSnapshot = _buildJourney();
      if (_cachedSnapshot != null) {
        _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.journey);
        await repository.cacheSnapshot(_cachedSnapshot!);
      }
    }
    _isInitialized = true;

    _identityEngine.addListener(_onEngineChanged);
    _growthEngine.addListener(_onEngineChanged);
    _missionEngine.addListener(_onEngineChanged);
    _recommendationEngine.addListener(_onEngineChanged);
    _dailyBriefEngine.addListener(_onEngineChanged);

    setDebounceMs(60); // 60ms debounce for 5-engine cascade
    _logger.info('ContinueJourneyEngine initialized',
        category: LogCategory.engine, source: 'ContinueJourneyEngine');
    notifyImmediately();
  }

  /// Rebuilds the journey state from current engine states.
  Future<void> rebuild() async {
    _cachedSnapshot = _buildJourney();
    if (_cachedSnapshot != null) {
      _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.journey);
      await repository.cacheSnapshot(_cachedSnapshot!);
    }
    _logger.info('ContinueJourneyEngine rebuilt',
        category: LogCategory.engine, source: 'ContinueJourneyEngine');
    // Use debounced notifyListeners for engine cascade events
    notifyListeners();
  }

  /// Marks an activity as started and records it in history.
  Future<void> startActivity(
    String activityId,
    String title,
    JourneyResumePoint type,
  ) async {
    final entry = JourneyHistoryEntry(
      activityId: activityId,
      activityTitle: title,
      activityType: type,
      status: 'started',
      startedAt: DateTime.now(),
    );
    _logger.info('Journey activity started: $title',
        category: LogCategory.observer, source: 'ContinueJourneyEngine',
        metadata: {'activityId': activityId, 'type': type.name});
    _history = JourneyHistory(entries: [..._history.entries, entry]);
    await repository.saveHistory(_history);
    notifyImmediately();
  }

  /// Marks an activity as resumed and increments the resume count.
  Future<void> resumeActivity(String activityId) async {
    final existing = _history.entries.where((e) => e.activityId == activityId);
    final activityTitle =
        existing.isNotEmpty ? existing.first.activityTitle : activityId;

    _history = JourneyHistory(
      entries: _history.entries.map((e) {
        if (e.activityId == activityId) {
          return JourneyHistoryEntry(
            activityId: e.activityId,
            activityTitle: e.activityTitle,
            activityType: e.activityType,
            status: 'resumed',
            startedAt: e.startedAt,
            completedAt: e.completedAt,
            resumeCount: e.resumeCount + 1,
            totalMinutesSpent: e.totalMinutesSpent,
            xpEarned: e.xpEarned,
          );
        }
        return e;
      }).toList(),
    );
    _logger.debug('Journey activity resumed: $activityTitle',
        category: LogCategory.observer, source: 'ContinueJourneyEngine');
    await repository.saveHistory(_history);
    notifyImmediately();
  }

  /// Marks an activity as completed.
  Future<void> completeActivity(
    String activityId, {
    int minutesSpent = 0,
    int xpEarned = 0,
  }) async {
    _history = JourneyHistory(
      entries: _history.entries.map((e) {
        if (e.activityId == activityId) {
          return JourneyHistoryEntry(
            activityId: e.activityId,
            activityTitle: e.activityTitle,
            activityType: e.activityType,
            status: 'completed',
            startedAt: e.startedAt,
            completedAt: DateTime.now(),
            resumeCount: e.resumeCount,
            totalMinutesSpent: e.totalMinutesSpent + minutesSpent,
            xpEarned: e.xpEarned + xpEarned,
          );
        }
        return e;
      }).toList(),
    );
    await repository.saveHistory(_history);
    notifyImmediately();
  }

  /// Marks an activity as cancelled.
  Future<void> cancelActivity(String activityId) async {
    _history = JourneyHistory(
      entries: _history.entries.map((e) {
        if (e.activityId == activityId) {
          return JourneyHistoryEntry(
            activityId: e.activityId,
            activityTitle: e.activityTitle,
            activityType: e.activityType,
            status: 'cancelled',
            startedAt: e.startedAt,
            completedAt: DateTime.now(),
            resumeCount: e.resumeCount,
            totalMinutesSpent: e.totalMinutesSpent,
            xpEarned: e.xpEarned,
          );
        }
        return e;
      }).toList(),
    );
    await repository.saveHistory(_history);
    notifyImmediately();
  }

  Future<void> reset() async {
    _cachedSnapshot = null;
    _history = const JourneyHistory();
    _isInitialized = false;
    _cacheService?.invalidate(CacheDomain.journey);
    await repository.clear();
    _logger.info('ContinueJourneyEngine reset',
        category: LogCategory.engine, source: 'ContinueJourneyEngine');
    notifyImmediately();
  }

  @override
  void dispose() {
    _identityEngine.removeListener(_onEngineChanged);
    _growthEngine.removeListener(_onEngineChanged);
    _missionEngine.removeListener(_onEngineChanged);
    _recommendationEngine.removeListener(_onEngineChanged);
    _dailyBriefEngine.removeListener(_onEngineChanged);
    super.dispose(); // DebounceChangeNotifier.dispose() handles timer cleanup
  }

  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isBuilding) return;
    _isBuilding = true;
    _logger.debug('ContinueJourneyEngine rebuilding from observer event',
        category: LogCategory.observer, source: 'ContinueJourneyEngine');
    await rebuild();
    _isBuilding = false;
  }

  // ── Journey Builder ───────────────────────────────────────────────

  /// Builds a complete journey snapshot from all engine states.
  JourneySnapshot _buildJourney() {
    final identitySnap = _identityEngine.snapshot;
    final growthSnap = _growthEngine.snapshot;
    final missionSnap = _missionEngine.snapshot;
    final recSnap = _recommendationEngine.snapshot;
    final briefSnap = _dailyBriefEngine.snapshot;

    final currentJourney = _buildCurrentJourney(identitySnap, missionSnap);
    final currentStage = _buildCurrentStage(identitySnap, missionSnap);
    final candidates = _buildResumeCandidates(
      identitySnap, missionSnap, recSnap, briefSnap, growthSnap,
    );
    final ranked = _rankCandidates(candidates);

    return JourneySnapshot(
      currentJourney: currentJourney,
      currentStage: currentStage,
      resumePoint: ranked.isNotEmpty ? ranked.first : null,
      lastActivity: _findLastActivity(ranked),
      nextActivity: ranked.length > 1 ? ranked[1] : null,
      completionPercent: _computeCompletion(ranked, growthSnap),
      estimatedRemainingMinutes: ranked.isNotEmpty
          ? ranked.first.estimatedMinutesRemaining
          : 0,
      priority: ranked.isNotEmpty ? _computeScore(ranked.first) : 0,
      reason: _buildReason(ranked, identitySnap),
      resumeCandidates: ranked,
      lastUpdated: DateTime.now(),
      history: _history,
    );
  }

  // ── Resume Candidate Builder ──────────────────────────────────────

  /// Collects all possible resume candidates from all engine inputs.
  List<JourneyActivity> _buildResumeCandidates(
    IdentitySnapshot? identitySnap,
    MissionSnapshot? missionSnap,
    RecommendationSnapshot? recSnap,
    DailyBriefSnapshot? briefSnap,
    GrowthSnapshot? growthSnap,
  ) {
    final candidates = <JourneyActivity>[];

    // 1. Active mission
    final currentMission = missionSnap?.currentMission;
    if (currentMission != null) {
      candidates.add(JourneyActivity(
        id: 'mission-${currentMission.id}',
        title: currentMission.title,
        description: currentMission.description,
        type: JourneyResumePoint.mission,
        progressPercent: missionSnap?.completionPercent ?? 0.0,
        estimatedMinutesRemaining: currentMission.estimatedDuration,
        xpReward: currentMission.rewardXP,
        growthImpact: currentMission.impact.overallImpact,
        relatedMissionId: currentMission.id,
        route: '/mission/${currentMission.id}',
      ));
    }

    // 2. Incomplete tasks from daily brief
    if (briefSnap != null) {
      for (final task in briefSnap.plan.incomplete.take(3)) {
        final type = _mapTaskType(task);
        candidates.add(JourneyActivity(
          id: 'continued-${task.id}',
          title: task.title,
          description: task.description,
          type: type,
          progressPercent: 0.0,
          estimatedMinutesRemaining: task.estimatedMinutes,
          xpReward: task.xpReward,
          growthImpact: task.impact,
          relatedMissionId: task.relatedMissionId,
          route: _routeForType(type, task.id),
        ));
      }
    }

    // 3. Primary recommendation if not already covered
    if (recSnap?.primary != null &&
        candidates.every((c) => c.id != 'rec-${recSnap!.primary!.id}')) {
      final r = recSnap!.primary!;
      candidates.add(JourneyActivity(
        id: 'rec-${r.id}',
        title: r.title,
        description: r.description,
        type: _mapRecCategory(r.category.displayName),
        progressPercent: 0.0,
        estimatedMinutesRemaining: r.estimatedDuration,
        xpReward: 0,
        growthImpact: r.growthImpact,
        route: '/recommendation/${r.id}',
      ));
    }

    // 4. Identity goal as background
    if (identitySnap != null &&
        identitySnap.currentGoal.isNotEmpty &&
        candidates.every(
            (c) => c.title != identitySnap.currentGoal)) {
      candidates.add(JourneyActivity(
        id: 'goal-continue',
        title: identitySnap.currentGoal,
        description: 'Keep your goal in focus today.',
        type: JourneyResumePoint.unknown,
        progressPercent: identitySnap.completionPercent / 100.0,
        estimatedMinutesRemaining: 10,
        xpReward: 10,
        growthImpact: 0.1,
        route: '/journey',
      ));
    }

    return candidates;
  }

  // ── Ranking ───────────────────────────────────────────────────────

  /// Ranks resume candidates by priority score.
  List<JourneyActivity> _rankCandidates(List<JourneyActivity> candidates) {
    if (candidates.length <= 1) return candidates;

    final sorted = List<JourneyActivity>.from(candidates);
    sorted.sort((a, b) => _computeScore(b).compareTo(_computeScore(a)));
    return sorted;
  }

  /// Computes a priority score for a resume candidate.
  ///
  /// Factors: progress, growth impact, remaining time, XP reward.
  int _computeScore(JourneyActivity activity) {
    int score = 0;

    // Higher progress = higher continuation priority
    score += (activity.progressPercent * 50).round();

    // Higher growth impact = higher priority
    score += (activity.growthImpact * 30).round();

    // Shorter remaining time = higher priority (quick wins)
    score +=
        activity.estimatedMinutesRemaining > 0
            ? (30 - activity.estimatedMinutesRemaining).clamp(0, 30)
            : 0;

    // Higher XP reward = higher priority
    score += (activity.xpReward / 10).round();

    // Mission and project types get bonus
    if (activity.type == JourneyResumePoint.mission) score += 20;
    if (activity.type == JourneyResumePoint.project) score += 15;

    return score;
  }

  /// Builds the current journey label.
  String _buildCurrentJourney(
    IdentitySnapshot? identitySnap,
    MissionSnapshot? missionSnap,
  ) {
    if (identitySnap?.targetIdentityTitle != null &&
        identitySnap!.targetIdentityTitle.isNotEmpty) {
      return 'Becoming ${identitySnap.targetIdentityTitle}';
    }
    if (identitySnap?.currentIdentityTitle != null &&
        identitySnap!.currentIdentityTitle.isNotEmpty) {
      return '${identitySnap.currentIdentityTitle} Path';
    }
    if (missionSnap?.currentMission != null) {
      return missionSnap!.currentMission!.title;
    }
    return 'Getting Started';
  }

  /// Builds the current stage label.
  String _buildCurrentStage(
    IdentitySnapshot? identitySnap,
    MissionSnapshot? missionSnap,
  ) {
    if (identitySnap?.currentMissionTitle != null &&
        identitySnap!.currentMissionTitle.isNotEmpty) {
      return identitySnap.currentMissionTitle;
    }
    if (missionSnap?.currentMission != null) {
      return missionSnap!.currentMission!.category.displayName;
    }
    if (identitySnap?.currentLearningPathTitle != null &&
        identitySnap!.currentLearningPathTitle.isNotEmpty) {
      return identitySnap.currentLearningPathTitle;
    }
    return 'Foundation';
  }

  /// Finds the user's most recent activity from history.
  JourneyActivity? _findLastActivity(List<JourneyActivity> candidates) {
    final inProgress = _history.inProgress;
    if (inProgress.isNotEmpty) {
      final last = inProgress.last;
      return candidates.where((c) => c.id.contains(last.activityId)).firstOrNull;
    }
    return candidates.isNotEmpty ? candidates.first : null;
  }

  /// Computes overall journey completion percentage.
  double _computeCompletion(
    List<JourneyActivity> candidates,
    GrowthSnapshot? growthSnap,
  ) {
    if (candidates.isEmpty) return growthSnap?.overallScore ?? 0.0;
    final avgProgress =
        candidates.fold<double>(0.0, (s, c) => s + c.progressPercent) /
            candidates.length;
    return (avgProgress + (growthSnap?.overallScore ?? 0.0)) / 2.0;
  }

  /// Builds a human-readable reason for the top resume recommendation.
  String _buildReason(
    List<JourneyActivity> ranked,
    IdentitySnapshot? identitySnap,
  ) {
    if (ranked.isEmpty) {
      return 'Start your journey to begin tracking progress.';
    }
    final top = ranked.first;
    if (top.progressPercent > 0.5) {
      return 'You are ${(top.progressPercent * 100).round()}% '
          'through "${top.title}". Continue where you left off.';
    }
    if (top.type == JourneyResumePoint.mission) {
      return 'Your active mission "${top.title}" needs your attention.';
    }
    if (identitySnap?.currentGoal != null &&
        identitySnap!.currentGoal.isNotEmpty) {
      return 'Keep progressing toward your goal: '
          '${identitySnap.currentGoal}';
    }
    return '"${top.title}" is ready to continue.';
  }

  // ── Helpers ───────────────────────────────────────────────────────

  JourneyResumePoint _mapTaskType(DailyTask task) {
    switch (task.priority.name) {
      case 'high':
        return JourneyResumePoint.mission;
      case 'medium':
        return JourneyResumePoint.lesson;
      default:
        return JourneyResumePoint.habit;
    }
  }

  JourneyResumePoint _mapRecCategory(String category) {
    switch (category.toLowerCase()) {
      case 'learning':
        return JourneyResumePoint.lesson;
      case 'career':
        return JourneyResumePoint.project;
      case 'interview':
        return JourneyResumePoint.interview;
      case 'habit':
        return JourneyResumePoint.habit;
      case 'assessment':
        return JourneyResumePoint.assessment;
      default:
        return JourneyResumePoint.unknown;
    }
  }

  String _routeForType(JourneyResumePoint type, String id) {
    switch (type) {
      case JourneyResumePoint.lesson:
        return '/lesson/$id';
      case JourneyResumePoint.mission:
        return '/mission/$id';
      case JourneyResumePoint.project:
        return '/project/$id';
      case JourneyResumePoint.interview:
        return '/interview/$id';
      case JourneyResumePoint.habit:
        return '/habits';
      case JourneyResumePoint.assessment:
        return '/assessment/$id';
      case JourneyResumePoint.learningPath:
        return '/academy';
      case JourneyResumePoint.unknown:
        return '/journey';
    }
  }
}
