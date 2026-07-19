import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../personal_knowledge/engine/knowledge_engine.dart';
import '../../progress_engine/achievement_engine.dart';
import '../models/adaptation_priority.dart';
import '../models/adaptation_reason.dart';
import '../models/adaptation_type.dart';
import '../models/adaptive_learning_snapshot.dart';
import '../models/learning_adaptation.dart';
import '../models/learning_profile.dart';

/// Adaptive Learning Engine — determines HOW learning should evolve.
///
/// **Responsibilities:**
/// - Evaluate 10+ deterministic adaptation rules against current context
/// - Maintain a [LearningProfile] (pace, difficulty, revision, etc.)
/// - Produce an immutable [AdaptiveLearningSnapshot] for all consumers
/// - Support what-if simulation
///
/// **Architecture Rules:**
/// - NEVER calls AI providers
/// - NEVER uses random weights (fully deterministic)
/// - NEVER modifies other engines
/// - NEVER generates learning content (that's the LLM's responsibility)
///
/// **Consumers:**
/// - Dashboard (today's learning strategy)
/// - Academy/Learn screen (difficulty/revision adjustments)
/// - Phoenix Assistant (reuse snapshot)
/// - PromptBuilderService (influence difficulty/tone/pace)
///
/// **Flow:**
/// ```
/// All Engines → AdaptiveLearningEngine.evaluate() → AdaptiveLearningSnapshot
///   → UI + PromptBuilderService
/// ```
class AdaptiveLearningEngine extends ChangeNotifier {
  AdaptiveLearningEngine({
    required this.growthEngine,
    required this.missionEngine,
    required this.knowledgeEngine,
    required this.achievementEngine,
  });

  final GrowthIndexEngine growthEngine;
  final MissionIntelligenceEngine missionEngine;
  final KnowledgeEngine knowledgeEngine;
  final AchievementEngine achievementEngine;

  final PhoenixLogger _logger = PhoenixLogger.shared;
  AdaptiveLearningSnapshot? _cachedSnapshot;
  final List<AdaptiveLearningSnapshot> _history = [];
  bool _isInitialized = false;
  bool _isEvaluating = false;

  // ── Accessors ─────────────────────────────────────────────────────

  AdaptiveLearningSnapshot? get snapshot => _cachedSnapshot;
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  Future<void> init() async {
    _cachedSnapshot = _evaluate();
    _isInitialized = true;

    growthEngine.addListener(_onEngineChanged);
    missionEngine.addListener(_onEngineChanged);
    knowledgeEngine.addListener(_onEngineChanged);
    achievementEngine.addListener(_onEngineChanged);

    _logger.info('AdaptiveLearningEngine initialized',
        category: LogCategory.engine, source: 'AdaptiveLearningEngine',
        metadata: {
          'adaptations': _cachedSnapshot?.adaptations.length ?? 0,
          'top': _cachedSnapshot?.topAdaptation?.type.displayName ?? 'none',
        });
    notifyListeners();
  }

  Future<void> evaluate() async {
    if (_cachedSnapshot != null) {
      _history.insert(0, _cachedSnapshot!);
      if (_history.length > 10) _history.removeLast();
    }
    _cachedSnapshot = _evaluate();
    _logger.debug('AdaptiveLearningEngine re-evaluated',
        category: LogCategory.engine, source: 'AdaptiveLearningEngine');
    notifyListeners();
  }

  @override
  void dispose() {
    growthEngine.removeListener(_onEngineChanged);
    missionEngine.removeListener(_onEngineChanged);
    knowledgeEngine.removeListener(_onEngineChanged);
    achievementEngine.removeListener(_onEngineChanged);
    super.dispose();
  }

  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isEvaluating) return;
    _isEvaluating = true;
    await evaluate();
    _isEvaluating = false;
  }

  // ── What-If Simulation ────────────────────────────────────────────

  /// Simulates adaptations under a modified scenario.
  AdaptiveLearningSnapshot simulate({
    double retentionBoost = 0.0,
    int additionalMinutes = 0,
    double consistencyBoost = 0.0,
  }) {
    final growthSnap = growthEngine.snapshot;
    if (growthSnap == null) {
      return AdaptiveLearningSnapshot(
        profile: const LearningProfile(),
        adaptations: const [],
        generatedAt: DateTime.now(),
      );
    }

    // Apply simulation modifiers to scores
    final simulatedRetention = (growthSnap.knowledge.score + retentionBoost)
        .clamp(0.0, 1.0);
    final simulatedConsistency = (growthSnap.habits.score + consistencyBoost)
        .clamp(0.0, 1.0);
    final simulatedMinutes = 30 + additionalMinutes;

    // Build profile with simulated values
    final profile = LearningProfile(
      preferredDifficulty: simulatedRetention >= 0.7 ? 'advanced' : 'intermediate',
      preferredPace: simulatedConsistency >= 0.6 ? 'fast' : 'moderate',
      revisionIntervalDays: simulatedRetention >= 0.6 ? 5 : 2,
      assessmentIntervalDays: simulatedRetention >= 0.5 ? 5 : 3,
      retentionScore: simulatedRetention,
      consistencyScore: simulatedConsistency,
      dailyStudyMinutes: simulatedMinutes,
      focusScore: growthSnap.overallScore,
    );

    return AdaptiveLearningSnapshot(
      profile: profile,
      adaptations: _buildAdaptations(growthSnap, profile),
      generatedAt: DateTime.now(),
    );
  }

  // ── Core Evaluation ───────────────────────────────────────────────

  AdaptiveLearningSnapshot _evaluate() {
    final now = DateTime.now();
    final growthSnap = growthEngine.snapshot;

    if (growthSnap == null || growthSnap.totalXp == 0) {
      return AdaptiveLearningSnapshot(
        profile: const LearningProfile(),
        adaptations: const [],
        generatedAt: now,
      );
    }

    final profile = _buildProfile(growthSnap);
    final adaptations = _buildAdaptations(growthSnap, profile);

    // Sort by priority (critical first) then confidence
    final sorted = List<LearningAdaptation>.from(adaptations)
      ..sort((a, b) {
        final prio = a.priority.index.compareTo(b.priority.index);
        if (prio != 0) return prio;
        return b.confidence.compareTo(a.confidence);
      });

    return AdaptiveLearningSnapshot(
      profile: profile,
      adaptations: sorted,
      topAdaptation: sorted.isNotEmpty ? sorted.first : null,
      generatedAt: now,
      history: List.from(_history),
    );
  }

  // ── Profile Builder ───────────────────────────────────────────────

  LearningProfile _buildProfile(dynamic snap) {
    final knowledgeScore = snap.knowledge.score;
    final habitScore = snap.habits.score;
    final consistency = snap.learningConsistency?.score ?? habitScore;

    // Determine difficulty from knowledge score
    final difficulty = knowledgeScore >= 0.7
        ? 'advanced'
        : knowledgeScore >= 0.4
            ? 'intermediate'
            : 'beginner';

    // Determine pace from consistency
    final pace = consistency >= 0.6
        ? 'fast'
        : consistency >= 0.3
            ? 'moderate'
            : 'slow';

    return LearningProfile(
      preferredDifficulty: difficulty,
      preferredPace: pace,
      preferredLessonSize: consistency >= 0.5 ? 'medium' : 'small',
      preferredProjectSize: snap.projects.score >= 0.5 ? 'large' : 'small',
      revisionIntervalDays: knowledgeScore >= 0.6 ? 5 : 2,
      assessmentIntervalDays: knowledgeScore >= 0.5 ? 5 : 3,
      retentionScore: knowledgeScore,
      focusScore: snap.overallScore,
      consistencyScore: consistency,
      dailyStudyMinutes: (30 * (1 + consistency)).round(),
      strengths: _topAreas(snap, 3),
      weaknesses: _weakAreas(snap, 3),
    );
  }

  // ── Adaptation Rules ──────────────────────────────────────────────

  List<LearningAdaptation> _buildAdaptations(dynamic snap, LearningProfile profile) {
    final adaptations = <LearningAdaptation>[];
    final knowScore = snap.knowledge.score;
    const minData = 0.1;

    // 1. Retention low → increase revision
    if (knowScore < 0.4 && knowScore >= minData) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.increaseRevision,
        priority: AdaptationPriority.high,
        reason: const AdaptationReason(
          why: 'Knowledge retention is low',
          evidence: 'Knowledge score is below 40%',
          expectedImpact: 'Improved long-term retention',
          alternativeAction: 'Focus on core concepts first',
        ),
        confidence: 75,
        affectedArea: 'knowledge',
        suggestedValue: 'every 2 days',
        fromValue: 'every ${profile.revisionIntervalDays} days',
      ));
    }

    // 2. Retention high → decrease revision
    if (knowScore >= 0.75) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.decreaseRevision,
        priority: AdaptationPriority.low,
        reason: const AdaptationReason(
          why: 'Knowledge retention is strong',
          evidence: 'Knowledge score is above 75%',
          expectedImpact: 'More time for new material',
        ),
        confidence: 70,
        affectedArea: 'knowledge',
        suggestedValue: 'every 5 days',
        fromValue: 'every ${profile.revisionIntervalDays} days',
      ));
    }

    // 3. Strong knowledge + low challenge → increase difficulty
    if (knowScore >= 0.65 && profile.preferredDifficulty == 'intermediate') {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.increaseDifficulty,
        priority: AdaptationPriority.medium,
        reason: const AdaptationReason(
          why: 'Ready for more challenging content',
          evidence: 'Knowledge score consistently above 65%',
          expectedImpact: 'Faster skill development',
          alternativeAction: 'Take an assessment first',
        ),
        confidence: 70,
        affectedArea: 'knowledge',
        suggestedValue: 'advanced',
        fromValue: profile.preferredDifficulty,
      ));
    }

    // 4. Low scores + high difficulty → reduce difficulty
    if (knowScore < 0.3 && profile.preferredDifficulty == 'advanced') {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.reduceDifficulty,
        priority: AdaptationPriority.high,
        reason: const AdaptationReason(
          why: 'Current difficulty may be too high',
          evidence: 'Knowledge score is below 30% with advanced content',
          expectedImpact: 'Better comprehension and confidence',
        ),
        confidence: 80,
        affectedArea: 'knowledge',
        suggestedValue: 'intermediate',
        fromValue: profile.preferredDifficulty,
      ));
    }

    // 5. Low project count → more projects
    if (snap.projects.score < 0.3 && snap.projects.score >= minData) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.moreProjects,
        priority: AdaptationPriority.medium,
        reason: const AdaptationReason(
          why: 'Project completion rate is low',
          evidence: 'Project score is below 30%',
          expectedImpact: 'Stronger portfolio and practical skills',
          alternativeAction: 'Complete smaller practice projects',
        ),
        confidence: 65,
        affectedArea: 'projects',
        suggestedValue: 'add 1-2 small projects',
        fromValue: 'current: ${snap.projects.score}',
      ));
    }

    // 6. High project load → fewer projects
    if (snap.projects.score >= 0.8) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.fewerProjects,
        priority: AdaptationPriority.low,
        reason: const AdaptationReason(
          why: 'Project portfolio is already strong',
          evidence: 'Project score is above 80%',
          expectedImpact: 'Focus on depth over breadth',
        ),
        confidence: 60,
        affectedArea: 'projects',
        suggestedValue: 'focus on existing projects',
        fromValue: 'current: ${snap.projects.score}',
      ));
    }

    // 7. Low interview readiness → increase interview practice
    if (snap.interview.score < 0.3 && snap.interview.score >= minData) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.increaseInterviewPractice,
        priority: AdaptationPriority.high,
        reason: const AdaptationReason(
          why: 'Interview readiness needs attention',
          evidence: 'Interview score is below 30%',
          expectedImpact: 'Better job readiness and confidence',
        ),
        confidence: 75,
        affectedArea: 'career',
        suggestedValue: '2-3 practice sessions per week',
        fromValue: 'current: ${snap.interview.score}',
      ));
    }

    // 8. Strong knowledge → more assessments
    if (knowScore >= 0.6) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.increaseAssessments,
        priority: AdaptationPriority.medium,
        reason: const AdaptationReason(
          why: 'Knowledge is strong — validate with assessments',
          evidence: 'Knowledge score is above 60%',
          expectedImpact: 'Certification and confidence boost',
          alternativeAction: 'Try practice tests first',
        ),
        confidence: 65,
        affectedArea: 'knowledge',
        suggestedValue: 'weekly assessments',
        fromValue: 'every ${profile.assessmentIntervalDays} days',
      ));
    }

    // 9. Weak area ordering → reorder lessons
    if (snap.knowledge.score < 0.4 && snap.knowledge.trend.name == 'declining') {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.reorderLessons,
        priority: AdaptationPriority.high,
        reason: const AdaptationReason(
          why: 'Knowledge is declining — restructure learning',
          evidence: 'Knowledge score below 40% and declining',
          expectedImpact: 'Improved learning trajectory',
          alternativeAction: 'Focus on fundamentals',
        ),
        confidence: 70,
        affectedArea: 'knowledge',
        suggestedValue: 'reorder to focus on weak areas',
        fromValue: 'current ordering',
      ));
    }

    // 10. Mission progress flagging → adjust priority
    if (snap.mission.score < 0.4 && snap.mission.trend.name == 'declining') {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.adjustMissionPriority,
        priority: AdaptationPriority.medium,
        reason: const AdaptationReason(
          why: 'Mission progress is declining',
          evidence: 'Mission score below 40% and declining',
          expectedImpact: 'Renewed focus on important missions',
        ),
        confidence: 65,
        affectedArea: 'missions',
        suggestedValue: 're-prioritize active missions',
        fromValue: 'current: ${snap.mission.score}',
      ));
    }

    final activityCount = snap.history.daily.length;

    // 11. Low consistency + many activities → reduce workload
    if (consistencyScore < 0.3 && activityCount > 5) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.reduceWorkload,
        priority: AdaptationPriority.high,
        reason: const AdaptationReason(
          why: 'Too many activities with low consistency',
          evidence: 'Consistency below 30% with high activity count',
          expectedImpact: 'Better focus and completion rates',
        ),
        confidence: 75,
        affectedArea: 'all',
        suggestedValue: 'focus on 1-2 key activities',
        fromValue: 'multiple activities',
      ));
    }

    // 12. High consistency + low activity → increase workload
    if (consistencyScore >= 0.6 && activityCount < 3) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.increaseWorkload,
        priority: AdaptationPriority.medium,
        reason: AdaptationReason(
          why: 'Room for more learning activities',
          evidence: 'High consistency with few activities',
          expectedImpact: 'Faster progress without overwhelming',
        ),
        confidence: 65,
        affectedArea: 'all',
        suggestedValue: 'add 1-2 more activities',
        fromValue: 'current: $activityCount',
      ));
    }

    // 13. Recent learning with low retention → recommend review
    if (knowScore < 0.5 && consistencyScore >= 0.4) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.recommendReview,
        priority: AdaptationPriority.medium,
        reason: const AdaptationReason(
          why: 'Review would strengthen retention',
          evidence: 'Knowledge score below 50% despite consistent activity',
          expectedImpact: 'Improved long-term knowledge retention',
        ),
        confidence: 70,
        affectedArea: 'knowledge',
        suggestedValue: '15-min review session',
        fromValue: 'current: ${(knowScore * 100).round()}% retention',
      ));
    }

    // 14. Extended streak → recommend recovery day
    if (consistencyScore >= 0.7) {
      adaptations.add(LearningAdaptation(
        type: AdaptationType.recommendRecoveryDay,
        priority: AdaptationPriority.low,
        reason: const AdaptationReason(
          why: 'Long streak — rest consolidates learning',
          evidence: 'High consistency maintained for extended period',
          expectedImpact: 'Better long-term retention and renewed energy',
        ),
        confidence: 60,
        affectedArea: 'all',
        suggestedValue: 'take one day off',
        fromValue: 'continuously active',
      ));
    }

    return adaptations;
  }

  // ── Helpers ───────────────────────────────────────────────────────

  double get consistencyScore {
    final snap = growthEngine.snapshot;
    if (snap == null) return 0.0;
    final habitScore = snap.habits.score;
    final learningConsistency = snap.learningConsistency?.score ?? habitScore;
    return (habitScore + learningConsistency) / 2.0;
  }

  List<String> _topAreas(dynamic snap, int count) {
    final areas = <_AreaScore>[];
    _addArea(areas, 'Knowledge', snap.knowledge?.score ?? 0);
    _addArea(areas, 'Skills', snap.skills?.score ?? 0);
    _addArea(areas, 'Career', snap.career?.score ?? 0);
    _addArea(areas, 'Portfolio', snap.portfolio?.score ?? 0);
    _addArea(areas, 'Habits', snap.habits?.score ?? 0);
    areas.sort((a, b) => b.score.compareTo(a.score));
    return areas.take(count).map((a) => a.name).toList();
  }

  List<String> _weakAreas(dynamic snap, int count) {
    final areas = <_AreaScore>[];
    _addArea(areas, 'Knowledge', snap.knowledge?.score ?? 0);
    _addArea(areas, 'Skills', snap.skills?.score ?? 0);
    _addArea(areas, 'Career', snap.career?.score ?? 0);
    _addArea(areas, 'Portfolio', snap.portfolio?.score ?? 0);
    _addArea(areas, 'Habits', snap.habits?.score ?? 0);
    areas.sort((a, b) => a.score.compareTo(b.score));
    return areas.take(count).map((a) => a.name).toList();
  }

  void _addArea(List<_AreaScore> areas, String name, double score) {
    if (score > 0) areas.add(_AreaScore(name, score));
  }
}

class _AreaScore {
  _AreaScore(this.name, this.score);
  final String name;
  final double score;
}
