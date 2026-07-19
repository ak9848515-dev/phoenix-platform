import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../identity/engine/identity_engine.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../user_state/services/user_state_service.dart';
import '../models/recommendation_history.dart';
import '../models/recommendation_history_entry.dart';
import '../models/recommendation_result.dart';
import '../models/recommendation_snapshot.dart';
import '../repository/recommendation_repository_interface.dart';
import '../rules/recommendation_rules.dart' as rules;

/// The Recommendation Intelligence Engine.
///
/// Transforms mission intelligence into actionable, explainable recommendations.
///
/// - MissionIntelligenceEngine decides WHAT should be done.
/// - RecommendationEngine decides HOW to present it.
///
/// **Responsibilities:**
/// - Evaluate all [RecommendationRule]s against Identity + Growth + Mission state
/// - Rank recommendations by composite score
/// - Generate structured explanations (no AI)
/// - Track recommendation engagement history
/// - Cache the latest snapshot for fast restart
/// - Re-evaluate on relevant platform events
///
/// **Consumer Flow:**
/// ```
/// IdentityEngine ─┐
/// GrowthEngine ───┤
///                  ├──→ RecommendationEngine → RecommendationSnapshot → Dashboard
/// MissionEngine ──┘                                           → Daily Brief
///                                                              → AI Mentor
/// ```
class RecommendationEngine extends ChangeNotifier {
  RecommendationEngine({
    required this.repository,
    required this._identityEngine,
    required this._growthEngine,
    required this._missionEngine,
    required this._userStateService,
    this._cacheService,
    List<rules.RecommendationRule>? customRules,
  })  : _rules = customRules ?? _defaultRules;

  final RecommendationRepositoryInterface repository;
  final IdentityEngine _identityEngine;
  final GrowthIndexEngine _growthEngine;
  final MissionIntelligenceEngine _missionEngine;
  final UserStateService _userStateService;
  final CacheService? _cacheService;
  static const String _cacheKey = 'recommendation:snapshot';
  final List<rules.RecommendationRule> _rules;

  RecommendationSnapshot? _cachedSnapshot;
  final PhoenixLogger _logger = PhoenixLogger.shared;
  RecommendationHistory _history = const RecommendationHistory();
  bool _isInitialized = false;
  bool _isEvaluating = false;

  /// Default set of recommendation rules.
  ///
  /// Rules are evaluated in priority order (highest first).
  /// Each rule produces a [RecommendationResult] if its conditions are met.
  ///
  /// **PHX-087 dynamic rules added:**
  /// - [ProjectMomentumRule] — momentum-based task sizing
  /// - [ResumeHealthRule] — career dimension gap analysis
  /// - [RecentInterestRule] — search/conversation interest signals
  /// - [KnowledgeRelationshipRule] — knowledge-skill-career interconnections
  /// - [AiConversationInsightRule] — AI interaction pattern insights
  static final List<rules.RecommendationRule> _defaultRules = [
    const rules.MissionConfidenceRule(),
    const rules.ProjectMomentumRule(),
    const rules.WeakLearningRule(),
    const rules.LowPortfolioRule(),
    const rules.LowInterviewRule(),
    const rules.ResumeHealthRule(),
    const rules.RecentInterestRule(),
    const rules.KnowledgeRelationshipRule(),
    const rules.AiConversationInsightRule(),
  ];

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current recommendation snapshot (may be cached).
  RecommendationSnapshot? get snapshot => _cachedSnapshot;

  /// Recommendation engagement history.
  RecommendationHistory get history => _history;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes by loading cached data, then running a fresh evaluation.
  /// Subscribes to engine changes for automatic re-evaluation.
  Future<void> init() async {
    _cachedSnapshot = _cacheService?.get<RecommendationSnapshot>(_cacheKey);
    _cachedSnapshot ??= await repository.loadCachedSnapshot();
    _history = await repository.loadHistory();
    final fresh = _evaluate();
    if (_cachedSnapshot == null ||
        fresh.primary?.id != _cachedSnapshot!.primary?.id) {
      _cachedSnapshot = fresh;
      _cacheService?.cache(_cacheKey, fresh, CacheDomain.recommendations);
      await repository.cacheSnapshot(fresh);
    }
    _isInitialized = true;

    _identityEngine.addListener(_onEngineChanged);
    _growthEngine.addListener(_onEngineChanged);
    _missionEngine.addListener(_onEngineChanged);

    _logger.info('RecommendationEngine initialized',
        category: LogCategory.engine, source: 'RecommendationEngine');
    notifyListeners();
  }

  /// Re-evaluates all rules against current state and persists.
  Future<void> evaluate() async {
    _cachedSnapshot = _evaluate();
    _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.recommendations);
    await repository.cacheSnapshot(_cachedSnapshot!);
    _logger.info('RecommendationEngine evaluated',
        category: LogCategory.engine, source: 'RecommendationEngine');
    notifyListeners();
  }

  /// Records acceptance of a recommendation.
  Future<void> acceptRecommendation(String recommendationId) async {
    final entry = RecommendationHistoryEntry(
      recommendationId: recommendationId,
      title: _cachedSnapshot?.primary?.title ?? '',
      categoryName:
          _cachedSnapshot?.primary?.category.displayName ?? '',
      ruleName: _cachedSnapshot?.primary?.ruleName ?? '',
      recommendedAt: _cachedSnapshot?.lastUpdated ?? DateTime.now(),
      acceptedAt: DateTime.now(),
      accepted: true,
    );
    _history = RecommendationHistory(
      entries: [..._history.entries, entry],
    );
    await repository.saveHistory(_history);
    await evaluate();
  }

  /// Records dismissal of a recommendation.
  Future<void> dismissRecommendation(String recommendationId) async {
    final entry = RecommendationHistoryEntry(
      recommendationId: recommendationId,
      title: _cachedSnapshot?.primary?.title ?? '',
      categoryName:
          _cachedSnapshot?.primary?.category.displayName ?? '',
      ruleName: _cachedSnapshot?.primary?.ruleName ?? '',
      recommendedAt: _cachedSnapshot?.lastUpdated ?? DateTime.now(),
      dismissedAt: DateTime.now(),
      dismissed: true,
    );
    _history = RecommendationHistory(
      entries: [..._history.entries, entry],
    );
    await repository.saveHistory(_history);
    await evaluate();
  }

  /// Records completion of a recommendation.
  Future<void> completeRecommendation(
      String recommendationId,
      int completionTimeMinutes) async {
    final entry = RecommendationHistoryEntry(
      recommendationId: recommendationId,
      title: _cachedSnapshot?.primary?.title ?? '',
      categoryName:
          _cachedSnapshot?.primary?.category.displayName ?? '',
      ruleName: _cachedSnapshot?.primary?.ruleName ?? '',
      recommendedAt: _cachedSnapshot?.lastUpdated ?? DateTime.now(),
      completedAt: DateTime.now(),
      completed: true,
      completionTimeMinutes: completionTimeMinutes,
    );
    _history = RecommendationHistory(
      entries: [..._history.entries, entry],
    );
    await repository.saveHistory(_history);
    await evaluate();
  }

  /// Resets all recommendation data.
  Future<void> reset() async {
    _cachedSnapshot = null;
    _history = const RecommendationHistory();
    _isInitialized = false;
    await repository.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _identityEngine.removeListener(_onEngineChanged);
    _growthEngine.removeListener(_onEngineChanged);
    _missionEngine.removeListener(_onEngineChanged);
    super.dispose();
  }

  // ── Engine Change Handler ─────────────────────────────────────────

  /// Triggers automatic re-evaluation when any source engine changes.
  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isEvaluating) return;
    _isEvaluating = true;
    _logger.debug('RecommendationEngine re-evaluating from observer event',
        category: LogCategory.observer, source: 'RecommendationEngine');
    await evaluate();
    _isEvaluating = false;
  }

  // ── Rule Evaluation ───────────────────────────────────────────────

  /// Evaluates all rules and produces a ranked [RecommendationSnapshot].
  RecommendationSnapshot _evaluate() {
    final identitySnapshot = _identityEngine.snapshot;
    final growthSnapshot = _growthEngine.snapshot;
    final missionSnapshot = _missionEngine.snapshot;
    final now = DateTime.now();

    // If engines not ready, return empty snapshot
    if (identitySnapshot == null ||
        growthSnapshot == null ||
        missionSnapshot == null) {
      return RecommendationSnapshot(
        lastUpdated: now,
        history: _history,
      );
    }

    final userState = _userStateService.currentState;

    // Evaluate all rules
    final results = <RecommendationResult>[];
    final rejected = <String>[];

    for (final rule in _rules) {
      try {
        final result = rule.evaluate(
          identitySnapshot: identitySnapshot,
          growthSnapshot: growthSnapshot,
          missionSnapshot: missionSnapshot,
          userState: userState,
        );
        if (result != null) {
          results.add(result);
        } else {
          rejected.add('${rule.name}: Conditions not met');
        }
      } catch (e) {
        rejected.add('${rule.name}: Error — $e');
      }
    }

    // Sort by ranking score descending
    results.sort(
        (a, b) => b.score.rankingScore.compareTo(a.score.rankingScore));

    // Top 1 primary, next 5 alternatives, rest hidden
    final primary = results.isNotEmpty ? results.first : null;
    final alternatives = results.length > 1
        ? results.sublist(1, results.length.clamp(1, 6))
        : <RecommendationResult>[];
    final hidden = results.length > 6
        ? results.sublist(6)
        : <RecommendationResult>[];

    // Compute aggregate scores
    final avgConfidence = results.isNotEmpty
        ? results.take(3).fold<double>(0.0, (a, b) => a + b.score.confidence) /
            results.take(3).length
        : 0.0;
    final totalUrgency = results.isNotEmpty
        ? results.take(3).fold<double>(0.0, (a, b) => a + b.score.urgency.score) /
            results.take(3).length
        : 0.0;
    final totalBenefit = results.isNotEmpty
        ? results.take(3).fold<double>(
            0.0, (a, b) => a + b.score.estimatedBenefit) /
            results.take(3).length
        : 0.0;

    return RecommendationSnapshot(
      primary: primary,
      alternatives: alternatives,
      hidden: hidden,
      allRanked: results,
      reason: primary?.reason,
      priority: primary?.score.priority ?? 0,
      urgencyScore: totalUrgency,
      confidence: avgConfidence,
      estimatedBenefit: totalBenefit,
      estimatedDuration: primary?.estimatedDuration ?? 0,
      category: primary?.category,
      missionLink: primary?.missionId ?? '',
      growthImpact: primary?.growthImpact ?? 0.0,
      careerImpact: primary?.careerImpact ?? 0.0,
      learningImpact: primary?.learningImpact ?? 0.0,
      lastUpdated: now,
      history: _history,
      rejectedRules: rejected,
      totalRules: _rules.length,
    );
  }
}
