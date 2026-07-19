import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../shared/infrastructure/performance/debounce_notifier.dart';
import '../../career/engine/career_engine.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../identity/engine/identity_engine.dart';
import '../../memory_engine/engine/memory_engine.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../personal_knowledge/engine/knowledge_engine.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../../progress_engine/achievement_engine.dart';
import '../models/decision_recommendation.dart';
import '../models/decision_snapshot.dart';
import '../rules/decision_rules.dart';

/// Decision Intelligence Engine — the reasoning layer of Phoenix OS.
///
/// **Responsibilities:**
/// - Evaluate all 12 deterministic decision rules against current context
/// - Produce a ranked, scored, immutable [DecisionSnapshot]
/// - Own all recommendations — no widget or service computes its own
///
/// **Architecture Rules:**
/// - NEVER calls AI providers
/// - NEVER uses random weights (fully deterministic)
/// - NEVER modifies other engines
/// - Always consumes engine snapshots (never queries repositories)
///
/// **Consumers:**
/// - Dashboard
/// - Phoenix Assistant
/// - Daily Brief
///
/// **Flow:**
/// ```
/// All Engines → DecisionEngine.evaluate() → DecisionSnapshot → UI
/// ```
class DecisionEngine extends ChangeNotifier
    with DebounceChangeNotifier {
  DecisionEngine({
    required this.identityEngine,
    required this.growthEngine,
    required this.missionEngine,
    required this.careerEngine,
    required this.portfolioEngine,
    required this.knowledgeEngine,
    required this.achievementEngine,
    required this.memoryEngine,
    List<DecisionRule>? customRules,
    this._cacheService,
  })  : _rules = customRules ?? _defaultRules;

  final IdentityEngine identityEngine;
  final GrowthIndexEngine growthEngine;
  final MissionIntelligenceEngine missionEngine;
  final CareerEngine careerEngine;
  final PortfolioEngine portfolioEngine;
  final KnowledgeEngine knowledgeEngine;
  final AchievementEngine achievementEngine;
  final MemoryEngine memoryEngine;
  final List<DecisionRule> _rules;
  final CacheService? _cacheService;
  static const String _cacheKey = 'decision:snapshot';

  final PhoenixLogger _logger = PhoenixLogger.shared;
  DecisionSnapshot? _cachedSnapshot;
  bool _isInitialized = false;
  bool _isEvaluating = false;

  static const int _contextVersion = 1;

  /// Default set of 12 deterministic decision rules.
  static final List<DecisionRule> _defaultRules = [
    const ContinueMissionRule(),
    const ReviewLessonRule(),
    const StartProjectRule(),
    const TakeAssessmentRule(),
    const PracticeInterviewRule(),
    const ReviseTopicRule(),
    const UpdateResumeRule(),
    const ImprovePortfolioRule(),
    const TakeBreakRule(),
    const RestDayRule(),
    const ExploreTechnologyRule(),
    const CareerActionRule(),
  ];

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current decision snapshot (may be null before first evaluation).
  DecisionSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine by subscribing to all source engines
  /// and running the first evaluation.
  Future<void> init() async {
    _cachedSnapshot = _cacheService?.get<DecisionSnapshot>(_cacheKey);
    if (_cachedSnapshot == null) {
      _cachedSnapshot = _evaluate();
      _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.journey);
    }
    _isInitialized = true;

    // Subscribe to engine changes for automatic re-evaluation
    identityEngine.addListener(_onEngineChanged);
    growthEngine.addListener(_onEngineChanged);
    missionEngine.addListener(_onEngineChanged);
    careerEngine.addListener(_onEngineChanged);
    portfolioEngine.addListener(_onEngineChanged);
    knowledgeEngine.addListener(_onEngineChanged);
    achievementEngine.addListener(_onEngineChanged);
    memoryEngine.addListener(_onEngineChanged);
    setDebounceMs(60); // 60ms debounce for 8-engine cascade

    _logger.info('DecisionEngine initialized with ${_rules.length} rules',
        category: LogCategory.engine, source: 'DecisionEngine',
        metadata: {'rules': _rules.length, 'active': _cachedSnapshot?.activeRules ?? 0});
    notifyImmediately();
  }

  /// Forces a fresh evaluation of all rules.
  Future<void> evaluate() async {
    _cachedSnapshot = _evaluate();
    _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.journey);
    _logger.debug('DecisionEngine re-evaluated',
        category: LogCategory.engine, source: 'DecisionEngine');
    notifyListeners();
  }

  @override
  void dispose() {
    identityEngine.removeListener(_onEngineChanged);
    growthEngine.removeListener(_onEngineChanged);
    missionEngine.removeListener(_onEngineChanged);
    careerEngine.removeListener(_onEngineChanged);
    portfolioEngine.removeListener(_onEngineChanged);
    knowledgeEngine.removeListener(_onEngineChanged);
    achievementEngine.removeListener(_onEngineChanged);
    memoryEngine.removeListener(_onEngineChanged);
    super.dispose();
  }

  // ── Engine Change Handler ─────────────────────────────────────────

  /// Triggers automatic re-evaluation when any source engine changes.
  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isEvaluating) return;
    _isEvaluating = true;
    await evaluate();
    _isEvaluating = false;
  }

  // ── Rule Evaluation ───────────────────────────────────────────────

  /// Evaluates all rules against current engine state and produces a
  /// ranked, scored [DecisionSnapshot].
  DecisionSnapshot _evaluate() {
    final now = DateTime.now();

    // Build context from all engine snapshots
    final identitySnap = identityEngine.snapshot;
    final growthSnap = growthEngine.snapshot;
    final missionSnap = missionEngine.snapshot;
    final careerSnap = careerEngine.snapshot;
    final portfolioSnap = portfolioEngine.snapshot;
    final achievementSnap = achievementEngine.snapshot;
    final memorySnap = memoryEngine.snapshot;

    // Extract knowledge analytics
    final knowledgeAnalytics = knowledgeEngine.analytics;

    // Build unified DecisionContext
    final context = DecisionContext(
      identitySnapshot: identitySnap,
      growthSnapshot: growthSnap,
      missionSnapshot: missionSnap,
      careerSnapshot: careerSnap,
      portfolioSnapshot: portfolioSnap,
      achievementSnapshot: achievementSnap,
      memorySnapshot: memorySnap,
      activeMissionTitle: missionSnap?.currentMission?.title ?? '',
      activeMissionProgress: missionSnap?.completionPercent ?? 0.0,
      hasOverdueMissions: false,
      portfolioProjectCount: portfolioSnap?.projectCount ?? 0,
      portfolioScore: growthSnap?.portfolio.score ?? 0.0,
      interviewReadiness: careerSnap?.interviewReadiness ?? 0.0,
      careerScore: growthSnap?.career.score ?? 0.0,
      knowledgeScore: growthSnap?.knowledge.score ?? 0.0,
      weakSkills: _extractWeakSkills(knowledgeAnalytics),
      strongSkills: _extractStrongSkills(knowledgeAnalytics),
      recentActivityCount: memorySnap?.totalMemories ?? 0,
      streak: 0,
      totalXp: growthSnap?.totalXp ?? 0,
      level: growthSnap?.currentLevel ?? 1,
    );

    // Evaluate all rules
    final results = <DecisionRecommendation>[];
    var activeRules = 0;

    for (final rule in _rules) {
      try {
        final result = rule.evaluate(context);
        if (result != null) {
          results.add(result);
          activeRules++;
        }
      } catch (e) {
        _logger.warning('Decision rule "${rule.name}" failed: $e',
            category: LogCategory.engine, source: 'DecisionEngine');
      }
    }

    // Sort by score descending
    results.sort((a, b) => b.score.overall.compareTo(a.score.overall));

    // Compute overall confidence from top result
    final confidence = results.isNotEmpty ? results.first.score.confidence : 0;

    return DecisionSnapshot(
      top: results.isNotEmpty ? results.first : null,
      recommendations: results,
      confidence: confidence,
      totalRules: _rules.length,
      activeRules: activeRules,
      generatedAt: now,
      contextVersion: _contextVersion,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  List<String> _extractWeakSkills(Map<String, dynamic>? analytics) {
    if (analytics == null) return [];
    final weak = analytics['weakSkills'];
    if (weak is List) return weak.whereType<String>().toList();
    return [];
  }

  List<String> _extractStrongSkills(Map<String, dynamic>? analytics) {
    if (analytics == null) return [];
    final strong = analytics['topSkills'];
    if (strong is List) return strong.whereType<String>().toList();
    return [];
  }
}
