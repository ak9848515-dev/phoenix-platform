import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/diagnostics/diagnostics_service.dart';
import '../../../core/bootstrap.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../identity/engine/identity_engine.dart';
import '../../mission_engine/models/mission_category.dart';
import '../../mission_engine/models/mission_difficulty.dart';
import '../../mission_engine/models/mission_priority.dart';
import '../../user_state/services/user_state_service.dart';
import '../models/mission_evaluation.dart';
import '../models/mission_history.dart';
import '../models/mission_history_entry.dart';
import '../models/mission_impact.dart';
import '../models/mission_recommendation.dart';
import '../models/mission_score.dart';
import '../models/mission_snapshot.dart';
import '../repository/mission_intelligence_repository_interface.dart';
import '../rules/mission_rules.dart' as rules;

/// The intelligence layer that decides "What should this user do next?"
///
/// [MissionIntelligenceEngine] is the single source of truth for mission
/// recommendations across the Phoenix Platform. It evaluates all registered
/// [MissionRule]s against the user's current state and produces a ranked
/// [MissionSnapshot] with the top recommendation and alternatives.
///
/// **Responsibilities:**
/// - Evaluate all [MissionRule]s against [IdentitySnapshot] + [GrowthSnapshot]
/// - Rank recommendations by weighted score, priority, and confidence
/// - Return top mission + up to 3 alternatives + rejected rule reasons
/// - Maintain history of accepted/rejected/completed missions
/// - Cache the latest snapshot for fast restart and offline startup
/// - Re-evaluate on relevant platform events
///
/// **Architecture Rules:**
/// - No AI logic — purely deterministic rule evaluation
/// - No UI access — produces read-only snapshots
/// - No repository duplication — consumes IdentityEngine and GrowthIndexEngine
///
/// **Consumer Flow:**
/// ```
/// IdentityEngine ─┐
///                  ├──→ MissionIntelligenceEngine → MissionSnapshot → Dashboard
/// GrowthIndexEngine┘                                           → Daily Brief
///                                                              → Recommendation Engine
///                                                              → AI Mentor
/// ```
class MissionIntelligenceEngine extends ChangeNotifier {
  MissionIntelligenceEngine({
    required this.repository,
    required this._identityEngine,
    required this._growthEngine,
    required this._userStateService,
    List<rules.MissionRule>? customRules,
  }) : _rules = customRules ?? _defaultRules;

  final MissionIntelligenceRepositoryInterface repository;
  final IdentityEngine _identityEngine;
  final GrowthIndexEngine _growthEngine;
  final UserStateService _userStateService;
  final List<rules.MissionRule> _rules;

  MissionSnapshot? _cachedSnapshot;
  final PhoenixLogger _logger = PhoenixLogger.shared;
  MissionHistory _history = const MissionHistory();
  bool _isInitialized = false;
  bool _isEvaluating = false;

  /// Default set of mission rules used when no custom rules are provided.
  static final List<rules.MissionRule> _defaultRules = [
    const rules.LowKnowledgeRule(),
    const rules.EmptyPortfolioRule(),
    const rules.CareerUndefinedRule(),
    const rules.WeakLearningConsistencyRule(),
    const rules.LowInterviewReadinessRule(),
  ];

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current mission intelligence snapshot (may be cached).
  MissionSnapshot? get snapshot => _cachedSnapshot;

  /// Mission recommendation history.
  MissionHistory get history => _history;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine by loading cached data and history, then
  /// running a fresh evaluation.
  ///
  /// Subscribes to [IdentityEngine] and [GrowthIndexEngine] change
  /// notifications so that any identity or growth update triggers
  /// automatic re-evaluation of all mission rules.
  Future<void> init() async {
    final start = DateTime.now();
    _cachedSnapshot = await repository.loadCachedSnapshot();
    _history = await repository.loadHistory();

    final elapsed = DateTime.now().difference(start).inMilliseconds;
    final diagnostics = _getDiagnostics();
    diagnostics?.recordEngineExecution('MissionIntelligenceEngine.init', elapsed);
    final fresh = _evaluate();
    if (_cachedSnapshot == null ||
        fresh.topMission?.id != _cachedSnapshot!.topMission?.id) {
      _cachedSnapshot = fresh;
      await repository.cacheSnapshot(fresh);
    }
    _isInitialized = true;

    // Subscribe to engine changes for automatic re-evaluation
    _identityEngine.addListener(_onEngineChanged);
    _growthEngine.addListener(_onEngineChanged);

    _logger.info('MissionIntelligenceEngine initialized',
        category: LogCategory.engine, source: 'MissionIntelligenceEngine');
    notifyListeners();
  }

  /// Re-evaluates all rules against current state and persists the result.
  Future<void> evaluate() async {
    final start = DateTime.now();
    _cachedSnapshot = _evaluate();
    await repository.cacheSnapshot(_cachedSnapshot!);

    final elapsed = DateTime.now().difference(start).inMilliseconds;
    final diagnostics = _getDiagnostics();
    diagnostics?.recordEngineExecution('MissionIntelligenceEngine.evaluate', elapsed);
    _logger.info('MissionIntelligenceEngine evaluated',
        category: LogCategory.engine, source: 'MissionIntelligenceEngine');
    notifyListeners();
  }

  /// Records that a mission was accepted and re-evaluates.
  Future<void> acceptMission(String recommendationId, String missionId,
      String missionTitle) async {
    final entry = MissionHistoryEntry(
      missionId: missionId,
      missionTitle: missionTitle,
      recommendationId: recommendationId,
      ruleName: _cachedSnapshot?.currentMission?.ruleName ?? '',
      recommendedAt: _cachedSnapshot?.lastEvaluation ?? DateTime.now(),
      acceptedAt: DateTime.now(),
      accepted: true,
    );
    _history = MissionHistory(
      entries: [..._history.entries, entry],
    );
    await repository.saveHistory(_history);
    await evaluate();
  }

  /// Records that a mission was skipped/declined and re-evaluates.
  Future<void> rejectMission(String recommendationId) async {
    final existing = _history.entries.where(
      (e) => e.recommendationId == recommendationId && !e.rejected,
    );
    if (existing.isNotEmpty) {
      final entry = existing.first;
      _history = MissionHistory(
        entries: [
          ..._history.entries
              .where((e) => e.recommendationId != recommendationId),
          MissionHistoryEntry(
            missionId: entry.missionId,
            missionTitle: entry.missionTitle,
            recommendationId: entry.recommendationId,
            ruleName: entry.ruleName,
            recommendedAt: entry.recommendedAt,
            rejectedAt: DateTime.now(),
            rejected: true,
          ),
        ],
      );
      await repository.saveHistory(_history);
    }
    await evaluate();
  }

  /// Records that a mission was completed and re-evaluates.
  Future<void> completeMission(String recommendationId, int xpEarned,
      int completionTimeMinutes) async {
    final existing = _history.entries.where(
      (e) => e.recommendationId == recommendationId && !e.completed,
    );
    if (existing.isNotEmpty) {
      final entry = existing.first;
      _history = MissionHistory(
        entries: [
          ..._history.entries
              .where((e) => e.recommendationId != recommendationId),
          MissionHistoryEntry(
            missionId: entry.missionId,
            missionTitle: entry.missionTitle,
            recommendationId: entry.recommendationId,
            ruleName: entry.ruleName,
            recommendedAt: entry.recommendedAt,
            acceptedAt: entry.acceptedAt,
            completedAt: DateTime.now(),
            accepted: true,
            completed: true,
            xpEarned: xpEarned,
            completionTimeMinutes: completionTimeMinutes,
          ),
        ],
      );
      await repository.saveHistory(_history);
    }
    await evaluate();
  }

  /// Called when IdentityEngine or GrowthIndexEngine fires a change.
  /// Triggers automatic re-evaluation so mission recommendations stay current.
  ///
  /// Uses [_isEvaluating] guard to prevent concurrent re-evaluations when
  /// both engines fire near-simultaneously.
  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isEvaluating) return;
    _isEvaluating = true;
    _logger.debug('MissionIntelligenceEngine re-evaluating from observer event',
        category: LogCategory.observer, source: 'MissionIntelligenceEngine');
    await evaluate();
    _isEvaluating = false;
  }

  @override
  void dispose() {
    _identityEngine.removeListener(_onEngineChanged);
    _growthEngine.removeListener(_onEngineChanged);
    super.dispose();
  }

  /// Resets all mission intelligence data.
  Future<void> reset() async {
    _cachedSnapshot = null;
    _history = const MissionHistory();
    _isInitialized = false;
    await repository.clear();
    notifyListeners();
  }

  // ── Rule Evaluation ───────────────────────────────────────────────

  /// Evaluates all rules against the current identity and growth state.
  ///
  /// Returns a [MissionSnapshot] containing:
  /// - The top-ranked mission recommendation
  /// - Up to 3 alternative recommendations
  /// - Rejected rules with reasons
  /// - All individual scores
  /// Helper to access the global diagnostics service.
  DiagnosticsService? _getDiagnostics() =>
      AppBootstrap.maybeDiagnosticsService;

  MissionSnapshot _evaluate() {
    final identitySnapshot = _identityEngine.snapshot;
    final growthSnapshot = _growthEngine.snapshot;
    final now = DateTime.now();

    // If engines haven't initialized yet, return empty snapshot
    // Do NOT access _userStateService before this check — it may not be ready.
    if (identitySnapshot == null || growthSnapshot == null) {
      return MissionSnapshot(
        lastEvaluation: now,
        lastUpdated: now,
        history: _history,
        reason:
            'Engines not yet initialized — waiting for identity and growth data.',
      );
    }

    final userState = _userStateService.currentState;

    // Evaluate all rules
    final recommendations = <MissionRecommendation>[];
    final rejectedReasons = <String>[];

    for (final rule in _rules) {
      try {
        final result = rule.evaluate(
          identitySnapshot: identitySnapshot,
          growthSnapshot: growthSnapshot,
          userState: userState,
        );
        if (result != null) {
          recommendations.add(result);
        } else {
          rejectedReasons.add('${rule.name}: Conditions not met');
        }
      } catch (e) {
        rejectedReasons.add('${rule.name}: Error during evaluation — $e');
      }
    }

    // Sort by weighted score descending, then priority, then confidence
    recommendations.sort((a, b) {
      final scoreCompare =
          b.score.weightedScore.compareTo(a.score.weightedScore);
      if (scoreCompare != 0) return scoreCompare;
      final priorityCompare =
          b.priority.weight.compareTo(a.priority.weight);
      if (priorityCompare != 0) return priorityCompare;
      return b.confidence.compareTo(a.confidence);
    });

    // Top mission + up to 3 alternatives
    final topMission =
        recommendations.isNotEmpty ? recommendations.first : null;
    final alternatives = recommendations.length > 1
        ? recommendations.sublist(1, recommendations.length.clamp(1, 4))
        : <MissionRecommendation>[];

    // All scores
    final allScores =
        recommendations.map((r) => r.score).toList();

    // Compute confidence: average of top recommendation scores
    final avgConfidence = recommendations.isNotEmpty
        ? recommendations.take(3).fold<double>(
              0.0,
              (a, b) => a + b.confidence,
            ) /
            recommendations.take(3).length
        : 0.0;

    final evaluation = MissionEvaluation(
      topMission: topMission ??
          MissionRecommendation(
            id: 'none',
            title: 'No recommendation',
            description:
                'All conditions are well balanced — continue your current path.',
            category: MissionCategory.custom,
            priority: MissionPriority.low,
            difficulty: MissionDifficulty.beginner,
            estimatedDuration: 0,
            rewardXP: 0,
            reason: 'No action needed — all areas are progressing well.',
            score: MissionScore(score: 0.0, weight: 0, confidence: 0.0),
            impact: const MissionImpact(),
            confidence: 1.0,
            ruleName: 'none',
          ),
      alternatives: alternatives,
      rejectedRules: rejectedReasons,
      allScores: allScores,
      evaluationTime: now,
      ruleCount: recommendations.length,
      totalRules: _rules.length,
    );

    return MissionSnapshot(
      currentMission: topMission,
      alternatives: alternatives,
      topMission: topMission,
      category: topMission?.category,
      priority: topMission?.priority,
      difficulty: topMission?.difficulty,
      estimatedDuration: topMission?.estimatedDuration ?? 0,
      rewardXP: topMission?.rewardXP ?? 0,
      completionPercent: topMission != null ? 0.0 : 1.0,
      impactScore: topMission?.impact.overallImpact ?? 0.0,
      confidence: avgConfidence,
      reason: topMission?.reason ?? 'No recommendation needed.',
      unlocks: topMission?.unlocks ?? [],
      lastEvaluation: now,
      lastUpdated: now,
      history: _history,
      evaluation: evaluation,
      rejectedRules: rejectedReasons,
    );
  }
}
