import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../shared/infrastructure/performance/debounce_notifier.dart';
import '../../decision_intelligence/engine/decision_engine.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../growth_index/models/growth_snapshot.dart';
import '../../growth_index/models/growth_trend.dart';
import '../../identity/engine/identity_engine.dart';
import '../../identity/models/identity_snapshot.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../mission_intelligence/models/mission_snapshot.dart';
import '../../recommendation_engine/engine/recommendation_engine.dart';
import '../../recommendation_engine/models/recommendation_snapshot.dart';
import '../models/daily_brief_snapshot.dart';
import '../models/daily_history.dart';
import '../models/daily_history_entry.dart';
import '../models/daily_insight.dart';
import '../models/daily_plan.dart';
import '../models/daily_priority.dart';
import '../models/daily_progress.dart';
import '../models/daily_schedule.dart';
import '../models/daily_task.dart';
import '../repository/daily_brief_repository_interface.dart';

/// The Phoenix Daily Brief Engine.
///
/// Creates the user's daily action plan by orchestrating inputs from all
/// four intelligence engines:
/// - IdentityEngine — who the user is
/// - GrowthIndexEngine — current growth state
/// - MissionIntelligenceEngine — what to do
/// - RecommendationEngine — how to present
///
/// **Responsibilities:**
/// - Build a daily plan (tasks organised by priority and time slot)
/// - Generate deterministic insights (no AI)
/// - Schedule tasks into morning/afternoon/evening/flexible
/// - Track daily progress and history
/// - Cache the latest snapshot for fast restart
///
/// **Architecture Rules:**
/// - No AI, no LLM, no prompt generation
/// - No mission generation — consumes from MissionEngine
/// - No recommendation generation — consumes from RecommendationEngine
/// - Daily orchestration only
class DailyBriefEngine extends ChangeNotifier
    with DebounceChangeNotifier {
  DailyBriefEngine({
    required this.repository,
    required this._identityEngine,
    required this._growthEngine,
    required this._missionEngine,
    required this._recommendationEngine,
    this._decisionEngine,
    this._cacheService,
  });

  final DailyBriefRepositoryInterface repository;
  final IdentityEngine _identityEngine;
  final GrowthIndexEngine _growthEngine;
  final MissionIntelligenceEngine _missionEngine;
  final RecommendationEngine _recommendationEngine;
  DecisionEngine? _decisionEngine;
  final CacheService? _cacheService;

  /// Cache key for the daily brief snapshot in [CacheService].
  static const String _cacheKey = 'daily_brief:snapshot';

  /// Attaches a [DecisionEngine] after construction.
  ///
  /// Called during bootstrap after the Decision Intelligence Engine is
  /// initialized. The engine will be used in the next snapshot rebuild.
  Future<void> attachDecisionEngine(DecisionEngine engine) async {
    _decisionEngine = engine;
    _logger.info('DecisionEngine attached to DailyBriefEngine',
        category: LogCategory.engine, source: 'DailyBriefEngine');
    // Rebuild immediately so the snapshot includes Decision Intelligence data
    await rebuild();
  }

  DailyBriefSnapshot? _cachedSnapshot;
  final PhoenixLogger _logger = PhoenixLogger.shared;
  DailyHistory _history = const DailyHistory();
  bool _isInitialized = false;
  bool _isBuilding = false;

  // ── Accessors ─────────────────────────────────────────────────────

  DailyBriefSnapshot? get snapshot => _cachedSnapshot;
  DailyHistory get history => _history;
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  Future<void> init() async {
    // Check in-memory cache first for fast restart
    _cachedSnapshot = _cacheService?.get<DailyBriefSnapshot>(_cacheKey);

    // Fall back to persistent repository
    _cachedSnapshot ??= await repository.loadCachedSnapshot();
    _history = await repository.loadHistory();

    // Only build fresh if cache is from a different day
    final today = _todayDate();
    if (_cachedSnapshot == null || _cachedSnapshot!.date != today) {
      _cachedSnapshot = _buildBrief();
      if (_cachedSnapshot != null) {
        await _cacheWithService(_cachedSnapshot!);
      }
    }
    _isInitialized = true;

    _identityEngine.addListener(_onEngineChanged);
    _growthEngine.addListener(_onEngineChanged);
    _missionEngine.addListener(_onEngineChanged);
    _recommendationEngine.addListener(_onEngineChanged);

    setDebounceMs(60); // 60ms debounce for 4-engine cascade
    _logger.info('DailyBriefEngine initialized',
        category: LogCategory.engine, source: 'DailyBriefEngine');
    notifyImmediately();
  }

  /// Rebuilds the daily brief from current engine state.
  Future<void> rebuild() async {
    _cachedSnapshot = _buildBrief();
    if (_cachedSnapshot != null) {
      await _cacheWithService(_cachedSnapshot!);
    }
    _logger.info('DailyBriefEngine rebuilt',
        category: LogCategory.engine, source: 'DailyBriefEngine');
    // Use debounced notifyListeners for engine cascade events
    notifyListeners();
  }

  /// Marks a task as completed and persists the change.
  Future<void> completeTask(String taskId) async {
    final snap = _cachedSnapshot;
    if (snap == null) {
      _logger.warning(
          'DailyBriefEngine: no snapshot when completing task $taskId',
          category: LogCategory.engine, source: 'DailyBriefEngine');
      return;
    }
    final updatedTasks = snap.plan.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(completed: true);
      return t;
    }).toList();
    _cachedSnapshot = DailyBriefSnapshot(
      date: snap.date,
      todaysFocus: snap.todaysFocus,
      todaysMission: snap.todaysMission,
      todaysGoal: snap.todaysGoal,
      plan: DailyPlan(tasks: updatedTasks),
      insights: snap.insights,
      totalMinutes: snap.totalMinutes,
      totalXp: snap.totalXp,
      expectedGrowth: snap.expectedGrowth,
      completionPercent: _computeCompletion(updatedTasks),
      lastUpdated: DateTime.now(),
      history: snap.history,
    );
    await _cacheWithService(_cachedSnapshot!);
    notifyImmediately();
  }

  /// Finalizes the day and records history.
  Future<DailyProgress> finalizeDay(int xpEarned, double growthDelta) async {
    final snap = _cachedSnapshot;
    if (snap == null) {
      return DailyProgress(
        totalTasks: 0, completedTasks: 0, skippedTasks: 0,
        completionPercentage: 0.0, xpEarned: 0, growthDelta: 0.0,
      );
    }
    final completed = snap.plan.completedCount;
    final total = snap.plan.total;
    final skipped = total - completed;
    final ratio = total > 0 ? completed / total : 0.0;

    final entry = DailyHistoryEntry(
      date: snap.date,
      todaysFocus: snap.todaysFocus,
      totalTasks: total,
      completedTasks: completed,
      xpEarned: xpEarned,
      growthDelta: growthDelta,
      completionRatio: ratio,
    );
    _logger.info('DailyBriefEngine finalized day',
        category: LogCategory.engine, source: 'DailyBriefEngine',
        metadata: {'completed': completed, 'total': total, 'xp': xpEarned});
    _history = DailyHistory(entries: [..._history.entries, entry]);
    await repository.saveHistory(_history);

    final progress = DailyProgress(
      totalTasks: total, completedTasks: completed, skippedTasks: skipped,
      completionPercentage: ratio, xpEarned: xpEarned, growthDelta: growthDelta,
    );
    _cachedSnapshot = DailyBriefSnapshot(
      date: snap.date,
      todaysFocus: snap.todaysFocus,
      todaysMission: snap.todaysMission,
      todaysGoal: snap.todaysGoal,
      plan: snap.plan,
      insights: snap.insights,
      totalMinutes: snap.totalMinutes,
      totalXp: snap.totalXp,
      expectedGrowth: snap.expectedGrowth,
      completionPercent: ratio,
      progress: progress,
      lastUpdated: DateTime.now(),
      history: _history,
    );
    await _cacheWithService(_cachedSnapshot!);
    notifyImmediately();
    return progress;
  }

  Future<void> reset() async {
    _cachedSnapshot = null;
    _history = const DailyHistory();
    _isInitialized = false;
    _cacheService?.invalidate(CacheDomain.journey);
    await repository.clear();
    _logger.info('DailyBriefEngine reset',
        category: LogCategory.engine, source: 'DailyBriefEngine');
    notifyImmediately();
  }

  @override
  void dispose() {
    _identityEngine.removeListener(_onEngineChanged);
    _growthEngine.removeListener(_onEngineChanged);
    _missionEngine.removeListener(_onEngineChanged);
    _recommendationEngine.removeListener(_onEngineChanged);
    super.dispose(); // DebounceChangeNotifier.dispose() handles timer cleanup
  }

  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isBuilding) return;
    _isBuilding = true;
    _cacheService?.invalidate(CacheDomain.journey);
    _logger.debug('DailyBriefEngine rebuilding from observer event',
        category: LogCategory.observer, source: 'DailyBriefEngine');
    await rebuild();
    _isBuilding = false;
  }

  /// Caches the snapshot both in-memory (via [CacheService]) and persistently
  /// (via [repository]).
  Future<void> _cacheWithService(DailyBriefSnapshot snapshot) async {
    _cacheService?.cache(_cacheKey, snapshot, CacheDomain.journey);
    await repository.cacheSnapshot(snapshot);
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  /// Builds a complete daily brief from all engine states.
  DailyBriefSnapshot _buildBrief() {
    final identitySnap = _identityEngine.snapshot;
    final growthSnap = _growthEngine.snapshot;
    final missionSnap = _missionEngine.snapshot;
    final recSnap = _recommendationEngine.snapshot;
    final now = DateTime.now();

    final date = _todayDate();
    final todaysFocus = _buildFocus(
      missionSnap, recSnap, identitySnap,
    );
    final tasks = _buildTasks(
      missionSnap, recSnap, growthSnap, identitySnap,
    );
    final plan = DailyPlan(tasks: tasks);
    final insights = _buildInsights(growthSnap, identitySnap, missionSnap);

    return DailyBriefSnapshot(
      date: date,
      todaysFocus: todaysFocus,
      todaysMission: missionSnap?.currentMission?.title ?? '',
      todaysGoal: identitySnap?.currentGoal ?? '',
      plan: plan,
      insights: insights,
      totalMinutes: plan.totalMinutes,
      totalXp: plan.totalXp,
      expectedGrowth: recSnap?.growthImpact ?? 0.0,
      completionPercent: plan.completionRatio,
      lastUpdated: now,
      history: _history,
    );
  }

  // ── Focus Builder ─────────────────────────────────────────────────

  /// Determines today's single focus statement.
  String _buildFocus(
    MissionSnapshot? missionSnap,
    RecommendationSnapshot? recSnap,
    IdentitySnapshot? identitySnap,
  ) {
    // 1. Decision Intelligence top recommendation (highest authority)
    final decisionTop = _decisionEngine?.snapshot?.top;
    if (decisionTop != null && decisionTop.score.overall >= 70) {
      return decisionTop.title;
    }

    // 2. Recommendation Engine primary
    if (recSnap?.primary != null) {
      return recSnap!.primary!.title;
    }

    // 3. Active mission
    if (missionSnap?.currentMission != null) {
      return missionSnap!.currentMission!.title;
    }

    // 4. Identity goal
    if (identitySnap?.currentGoal != null &&
        identitySnap!.currentGoal.isNotEmpty) {
      return identitySnap.currentGoal;
    }

    return 'Begin your journey';
  }

  // ── Task Builder ──────────────────────────────────────────────────

  /// Builds the day's task list from all engine states.
  List<DailyTask> _buildTasks(
    MissionSnapshot? missionSnap,
    RecommendationSnapshot? recSnap,
    GrowthSnapshot? growthSnap,
    IdentitySnapshot? identitySnap,
  ) {
    final tasks = <DailyTask>[];

    // 1. Primary recommendation -> morning, high priority
    if (recSnap?.primary != null) {
      final r = recSnap!.primary!;
      tasks.add(DailyTask(
        id: 'rec-${r.id}',
        title: r.title,
        description: r.description,
        priority: r.score.priority >= 8
            ? DailyPriority.high
            : r.score.priority >= 5
                ? DailyPriority.medium
                : DailyPriority.low,
        category: r.category.displayName,
        schedule: r.score.urgency.isTimeSensitive
            ? DailySchedule.morning
            : DailySchedule.flexible,
        estimatedMinutes: r.estimatedDuration,
        xpReward: 0,
        impact: r.growthImpact,
        reason: r.reason.why,
        relatedMissionId: r.missionId,
      ));
    }

    // 2. Secondary recommendations -> afternoon/evening
    final alternatives = recSnap?.alternatives;
    if (alternatives != null && alternatives.isNotEmpty) {
      for (final alt in alternatives.take(3)) {
        tasks.add(DailyTask(
          id: 'rec-alt-${alt.id}',
          title: alt.title,
          description: alt.description,
          priority: DailyPriority.medium,
          category: alt.category.displayName,
          schedule: DailySchedule.afternoon,
          estimatedMinutes: alt.estimatedDuration,
          xpReward: 0,
          impact: alt.growthImpact,
          reason: alt.reason.why,
          relatedMissionId: alt.missionId,
        ));
      }
    }

    // 3. Active mission -> morning if no primary rec
    // 3. Decision Intelligence top recommendation (if not already covered)
    final decisionTop = _decisionEngine?.snapshot?.top;
    if (decisionTop != null && recSnap?.primary == null) {
      tasks.add(DailyTask(
        id: 'decision-${decisionTop.id}',
        title: decisionTop.title,
        description: decisionTop.description,
        priority: decisionTop.score.overall >= 70
            ? DailyPriority.high
            : DailyPriority.medium,
        category: decisionTop.type.displayName,
        schedule: DailySchedule.morning,
        estimatedMinutes: decisionTop.score.estimatedMinutes,
        xpReward: decisionTop.score.estimatedXp,
        impact: decisionTop.score.overall / 100.0,
        reason: decisionTop.reason.why,
        relatedMissionId: decisionTop.relatedMissionId,
      ));
    }

    // 4. Active mission (if not already covered)
    final currentMission = missionSnap?.currentMission;
    if (currentMission != null &&
        recSnap?.primary == null &&
        decisionTop == null) {
      tasks.add(DailyTask(
        id: 'mission-${currentMission.id}',
        title: currentMission.title,
        description: currentMission.description,
        priority: DailyPriority.high,
        category: currentMission.category.displayName,
        schedule: DailySchedule.morning,
        estimatedMinutes: currentMission.estimatedDuration,
        xpReward: currentMission.rewardXP,
        impact: currentMission.impact.overallImpact,
        reason: currentMission.reason,
        relatedMissionId: currentMission.id,
      ));
    }

    // 5. Weakening growth dimensions -> habit reminders
    if (growthSnap != null) {
      final allMetrics = growthSnap.allMetrics;
      final declining = allMetrics
          .where((m) => m.trend == GrowthTrend.declining && m.score > 0.1)
          .toList();
      for (final dim in declining.take(2)) {
        tasks.add(DailyTask(
          id: 'growth-${dim.dimension.name}',
          title: 'Review ${dim.dimension.displayName}',
          description:
              'Your ${dim.dimension.displayName} score is declining. '
              'Take action to reverse the trend.',
          priority: DailyPriority.medium,
          category: dim.dimension.displayName,
          schedule: DailySchedule.afternoon,
          estimatedMinutes: 10,
          xpReward: 15,
          impact: 0.2,
          reason: 'Declining trend needs attention.',
        ));
      }
    }

    // 6. Identity goal -> flexible, low priority background
    if (identitySnap != null &&
        identitySnap.currentGoal.isNotEmpty &&
        tasks.every((t) =>
            t.title != identitySnap.currentGoal)) {
      tasks.add(DailyTask(
        id: 'goal-today',
        title: identitySnap.currentGoal,
        description: 'Keep your current goal in mind today.',
        priority: DailyPriority.low,
        category: 'Goal',
        schedule: DailySchedule.flexible,
        estimatedMinutes: 5,
        xpReward: 10,
        impact: 0.1,
        reason: 'Your chosen focus for this journey.',
      ));
    }

    // 7. Habits checklist
    final habitCount = identitySnap?.activeHabitCount ?? 0;
    if (habitCount > 0) {
      tasks.add(DailyTask(
        id: 'habits-today',
        title: 'Complete $habitCount habit${habitCount == 1 ? '' : 's'}',
        description:
            'Stay consistent with your daily habits.',
        priority: DailyPriority.high,
        category: 'Habit',
        schedule: DailySchedule.morning,
        estimatedMinutes: 10 * habitCount,
        xpReward: 10 * habitCount,
        impact: 0.3,
        reason: 'Habits build long-term growth.',
      ));
    }

    return tasks;
  }

  // ── Insights Builder ──────────────────────────────────────────────

  /// Generates deterministic insights from current state.
  List<DailyInsight> _buildInsights(
    GrowthSnapshot? growthSnap,
    IdentitySnapshot? identitySnap,
    MissionSnapshot? missionSnap,
  ) {
    final insights = <DailyInsight>[];

    // Mission unlock insight
    final currentMission = missionSnap?.currentMission;
    if (currentMission != null &&
        currentMission.unlocks.isNotEmpty) {
      insights.add(DailyInsight(
        message:
            'Completing "${currentMission.title}" '
            'unlocks ${currentMission.unlocks.join(", ")}.',
        category: 'mission',
        relevance: 0.9,
      ));
    }

    // Learning consistency insight
    if (growthSnap != null) {
      final learningConsistency = growthSnap.learningConsistency;
      if (learningConsistency != null) {
        if (learningConsistency.trend == GrowthTrend.improving) {
          insights.add(DailyInsight(
            message:
                'Your learning consistency has improved this week. '
                'Keep the momentum!',
            category: 'growth',
            relevance: 0.8,
          ));
        } else if (learningConsistency.trend == GrowthTrend.declining) {
          insights.add(DailyInsight(
            message:
                'Your learning consistency is declining. '
                'A short session today will rebuild your streak.',
            category: 'growth',
            relevance: 0.7,
          ));
        }
      }
    }

    // Strongest dimension insight
    if (growthSnap != null) {
      final strongest = growthSnap.strongestDimension;
      if (strongest.score > 0.7) {
        insights.add(DailyInsight(
          message:
              'Your ${strongest.dimension.displayName} is your strongest '
              'area at ${(strongest.score * 100).round()}%. '
              'Leverage it to improve weaker areas.',
          category: 'growth',
          relevance: 0.6,
        ));
      }
    }

    // XP milestone insight
    if (growthSnap != null && growthSnap.totalXp > 0) {
      final nextMilestone = ((growthSnap.currentLevel + 1) * 1000);
      final xpToNext = nextMilestone - growthSnap.totalXp;
      if (xpToNext > 0 && xpToNext < 500) {
        insights.add(DailyInsight(
          message:
              'You are $xpToNext XP away from Level '
              '${growthSnap.currentLevel + 1}. '
              'Today\'s tasks could get you there!',
          category: 'progress',
          relevance: 0.5,
        ));
      }
    }

    return insights;
  }

  // ── Helpers ───────────────────────────────────────────────────────

  double _computeCompletion(List<DailyTask> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.completed).length;
    return completed / tasks.length;
  }

  String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
