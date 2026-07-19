import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../shared/infrastructure/performance/debounce_notifier.dart';
import '../../career/engine/career_engine.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../identity/engine/identity_engine.dart';
import '../../interview/intelligence/engine/interview_intelligence_engine.dart';
import '../../memory_engine/engine/memory_engine.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../../opportunity/intelligence/engine/opportunity_intelligence_engine.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../../recommendation_engine/engine/recommendation_engine.dart';
import '../../resume_intelligence/engine/resume_intelligence_engine.dart';
import '../models/decision_intelligence_snapshot.dart';
import '../models/scored_action.dart';

/// Decision Intelligence Orchestrator — the final decision layer of Phoenix.
///
/// **This engine does NOT generate recommendations.** It evaluates
/// recommendations from every intelligence engine and selects the
/// highest-value action for the user.
///
/// **Inputs:** All 11 intelligence engines (Career, Portfolio, Resume,
/// Interview, Opportunity, Mission, Growth, Knowledge, Recommendation,
/// Review/Memory, Identity)
///
/// **Scoring:** 9 dimensions → composite weight → rank → Next Best Action
///
/// **Outputs:** DecisionIntelligenceSnapshot with:
/// - Top Priority (Next Best Action)
/// - Second Priority (fallback)
/// - Quick Wins (up to 3 high-ROI, low-difficulty)
/// - Long-Term Goal (high career impact, sustained effort)
/// - Structured reasoning
/// - Aggregate confidence
///
/// **Architecture:**
/// ```text
/// All Engines
///   ↓ (snapshots)
/// DecisionIntelligenceOrchestrator.evaluate()
///   ↓ (scoring + ranking)
/// DecisionIntelligenceSnapshot
///   ↓
/// Dashboard | Daily Journey | Notifications
/// ```
class DecisionIntelligenceOrchestrator extends ChangeNotifier
    with DebounceChangeNotifier {
  DecisionIntelligenceOrchestrator({
    required this._careerEngine,
    required this._portfolioEngine,
    required this._resumeEngine,
    required this._interviewEngine,
    required this._opportunityEngine,
    required this._missionEngine,
    required this._growthEngine,
    required this._identityEngine,
    required this._recommendationEngine,
    required this._memoryEngine,
  });

  final CareerEngine _careerEngine;
  final PortfolioEngine _portfolioEngine;
  final ResumeIntelligenceEngine _resumeEngine;
  final InterviewIntelligenceEngine _interviewEngine;
  final OpportunityIntelligenceEngine _opportunityEngine;
  final MissionIntelligenceEngine _missionEngine;
  final GrowthIndexEngine _growthEngine;
  final IdentityEngine _identityEngine;
  final RecommendationEngine _recommendationEngine;
  final MemoryEngine _memoryEngine;

  final PhoenixLogger _logger = PhoenixLogger.shared;
  DecisionIntelligenceSnapshot? _snapshot;
  bool _isInitialized = false;
  bool _isEvaluating = false;

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current decision intelligence snapshot.
  DecisionIntelligenceSnapshot? get snapshot => _snapshot;

  /// Whether the orchestrator has been initialized.
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes by running the first evaluation and subscribing to
  /// all source engine changes.
  Future<void> init() async {
    _snapshot = _evaluate();
    _isInitialized = true;

    _careerEngine.addListener(_onEngineChanged);
    _portfolioEngine.addListener(_onEngineChanged);
    _resumeEngine.addListener(_onEngineChanged);
    _interviewEngine.addListener(_onEngineChanged);
    _opportunityEngine.addListener(_onEngineChanged);
    _missionEngine.addListener(_onEngineChanged);
    _growthEngine.addListener(_onEngineChanged);
    _identityEngine.addListener(_onEngineChanged);
    _recommendationEngine.addListener(_onEngineChanged);
    _memoryEngine.addListener(_onEngineChanged);
    setDebounceMs(80); // 80ms debounce for 10-engine cascade

    _logger.info(
        'DecisionIntelligenceOrchestrator initialized with ${_snapshot!.allScored.length} actions',
        category: LogCategory.engine,
        source: 'DecisionIntelligenceOrchestrator');
    notifyImmediately();
  }

  /// Forces a fresh evaluation of all engine snapshots.
  Future<void> evaluate() async {
    _snapshot = _evaluate();
    _logger.debug('DecisionIntelligenceOrchestrator re-evaluated',
        category: LogCategory.engine, source: 'DecisionIntelligenceOrchestrator');
    notifyListeners();
  }

  @override
  void dispose() {
    _careerEngine.removeListener(_onEngineChanged);
    _portfolioEngine.removeListener(_onEngineChanged);
    _resumeEngine.removeListener(_onEngineChanged);
    _interviewEngine.removeListener(_onEngineChanged);
    _opportunityEngine.removeListener(_onEngineChanged);
    _missionEngine.removeListener(_onEngineChanged);
    _growthEngine.removeListener(_onEngineChanged);
    _identityEngine.removeListener(_onEngineChanged);
    _recommendationEngine.removeListener(_onEngineChanged);
    _memoryEngine.removeListener(_onEngineChanged);
    super.dispose(); // DebounceChangeNotifier.dispose() handles timer cleanup
  }

  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isEvaluating) return;
    _isEvaluating = true;
    try {
      await evaluate();
    } finally {
      _isEvaluating = false;
    }
  }

  // ── Core Evaluation ──────────────────────────────────────────────

  /// Evaluates all engine snapshots and produces a ranked snapshot.
  DecisionIntelligenceSnapshot _evaluate() {
    final now = DateTime.now();

    // Collect candidates from all engines
    final allActions = <ScoredAction>[
      ..._fromCareerEngine(),
      ..._fromPortfolioEngine(),
      ..._fromResumeEngine(),
      ..._fromInterviewEngine(),
      ..._fromOpportunityEngine(),
      ..._fromMissionEngine(),
      ..._fromGrowthEngine(),
      ..._fromIdentityEngine(),
      ..._fromRecommendationEngine(),
      ..._fromMemoryEngine(),
    ];

    // If no actions generated, return empty snapshot
    if (allActions.isEmpty) {
      return DecisionIntelligenceSnapshot(
        topPriority: ScoredAction(
          id: 'default',
          title: 'Begin your journey',
          description: 'Complete your profile to get personalized recommendations.',
          source: ActionSource.identity,
          score: const ActionScore(),
          reasoning: 'Set up your profile to unlock personalized action recommendations.',
        ),
        allScored: [],
        confidence: 0.0,
        generatedAt: now,
        isInitialized: true,
      );
    }

    // Sort by composite score descending
    allActions.sort((a, b) => b.score.composite.compareTo(a.score.composite));

    // Classify actions
    final quickWins = allActions.where((a) => a.isQuickWin).take(3).toList();
    final longTermGoal = allActions.where((a) => a.isLongTermGoal).firstOrNull;

    // Top priority (NBA) = highest composite score
    final topPriority = allActions.first;

    // Second priority = next best that differs in type
    final secondPriority = allActions.length > 1 ? allActions[1] : null;

    // Build reasoning
    final reasoning = _buildReasoning(topPriority, allActions);

    // Aggregate confidence and career impact
    final avgConfidence = allActions.fold(0.0, (a, b) => a + b.score.confidence) /
        allActions.length;
    final avgCareerImpact = allActions.fold(0.0, (a, b) => a + b.score.careerImpact) /
        allActions.length;

    return DecisionIntelligenceSnapshot(
      topPriority: topPriority,
      secondPriority: secondPriority,
      quickWins: quickWins,
      longTermGoal: longTermGoal,
      reasoning: reasoning,
      allScored: allActions,
      confidence: avgConfidence,
      careerImpact: avgCareerImpact,
      generatedAt: now,
      isInitialized: true,
    );
  }

  // ── Engine-Specific Candidate Builders ────────────────────────────

  /// Scores a candidate using the 9 scoring dimensions.
  ActionScore _score({
    required double careerImpact,
    required double learningDependency,
    required double deadline,
    required double difficulty,
    required double roi,
    required double skillGap,
    required double momentum,
    required double recentActivity,
    required double userGoals,
  }) {
    return ActionScore(
      careerImpact: careerImpact.clamp(0.0, 1.0),
      learningDependency: learningDependency.clamp(0.0, 1.0),
      deadline: deadline.clamp(0.0, 1.0),
      difficulty: difficulty.clamp(0.0, 1.0),
      roi: roi.clamp(0.0, 1.0),
      skillGap: skillGap.clamp(0.0, 1.0),
      momentum: momentum.clamp(0.0, 1.0),
      recentActivity: recentActivity.clamp(0.0, 1.0),
      userGoals: userGoals.clamp(0.0, 1.0),
    );
  }

  List<ScoredAction> _fromCareerEngine() {
    final snap = _careerEngine.snapshot;
    if (snap == null || !snap.hasData) return [];

    return [
      ScoredAction(
        id: 'career-improve',
        title: 'Improve career readiness',
        description: 'Your career score is ${(snap.careerScore * 100).round()}%. '
            'Close skill gaps to advance your career.',
        source: ActionSource.career,
        score: _score(
          careerImpact: 0.9,
          learningDependency: snap.skillGaps.isNotEmpty ? 0.6 : 0.2,
          deadline: snap.needsAttention ? 0.8 : 0.3,
          difficulty: snap.skillGaps.length > 5 ? 0.7 : 0.4,
          roi: 0.8,
          skillGap: (snap.skillGaps.length / 10).clamp(0.0, 1.0),
          momentum: 0.5,
          recentActivity: 0.5,
          userGoals: 0.7,
        ),
        reasoning: snap.careerScore < 0.5
            ? 'Career readiness needs significant improvement. '
                'Focus on closing skill gaps first.'
            : 'Continue building on your career momentum.',
        route: '/career',
        category: 'Career',
        goalType: 'longTerm',
      ),
    ];
  }

  List<ScoredAction> _fromPortfolioEngine() {
    final snap = _portfolioEngine.snapshot;
    if (snap == null || !snap.hasData) return [];

    return [
      ScoredAction(
        id: 'portfolio-improve',
        title: 'Strengthen your portfolio',
        description: 'Portfolio score is ${(snap.portfolioScore * 100).round()}%. '
            'Add projects to showcase your skills.',
        source: ActionSource.portfolio,
        score: _score(
          careerImpact: 0.8,
          learningDependency: 0.3,
          deadline: 0.3,
          difficulty: 0.4,
          roi: 0.9,
          skillGap: 0.5,
          momentum: 0.4,
          recentActivity: 0.4,
          userGoals: 0.6,
        ),
        reasoning: 'A strong portfolio is essential for career growth. '
            'Each project demonstrates real-world capability.',
        route: '/portfolio',
        category: 'Portfolio',
        goalType: 'longTerm',
      ),
    ];
  }

  List<ScoredAction> _fromResumeEngine() {
    final snap = _resumeEngine.snapshot;
    if (snap == null || !snap.hasData) return [];

    return [
      ScoredAction(
        id: 'resume-improve',
        title: snap.isHealthy
            ? 'Review and optimize resume'
            : 'Improve your resume urgently',
        description: snap.isHealthy
            ? 'Your resume is in good shape. Optimize for your next application.'
            : 'Resume needs attention. Score: ${snap.overallScore.round()}%.',
        source: ActionSource.resume,
        score: _score(
          careerImpact: snap.isHealthy ? 0.5 : 0.9,
          learningDependency: 0.2,
          deadline: snap.needsUrgentAttention ? 0.9 : 0.3,
          difficulty: 0.3,
          roi: snap.isHealthy ? 0.5 : 0.9,
          skillGap: 0.3,
          momentum: 0.4,
          recentActivity: 0.3,
          userGoals: 0.6,
        ),
        reasoning: snap.topRecommendation?.description ??
            (snap.isHealthy
                ? 'Your resume is competitive. Keep it updated.'
                : 'A strong resume is critical for job applications.'),
        route: '/resume',
        category: 'Resume',
        goalType: snap.needsUrgentAttention ? 'shortTerm' : 'quickWin',
      ),
    ];
  }

  List<ScoredAction> _fromInterviewEngine() {
    final snap = _interviewEngine.snapshot;
    if (snap == null || !snap.hasData) return [];

    return [
      ScoredAction(
        id: 'interview-practice',
        title: snap.isReadyForInterviews
            ? 'Practice mock interview'
            : 'Improve interview readiness',
        description: 'Readiness: ${(snap.readiness.overall * 100).round()}%. '
            '${snap.hasWeakTopics ? "Focus on weak topics: ${snap.weakTopics.take(2).map((t) => t.subject).join(", ")}" : "Practice to stay sharp."}',
        source: ActionSource.interview,
        score: _score(
          careerImpact: 0.9,
          learningDependency: snap.readiness.needsSignificantPrep ? 0.5 : 0.2,
          deadline: snap.isReadyForInterviews ? 0.6 : 0.4,
          difficulty: snap.readiness.needsSignificantPrep ? 0.6 : 0.3,
          roi: 0.8,
          skillGap: snap.hasWeakTopics ? 0.7 : 0.3,
          momentum: snap.progress.isImproving ? 0.7 : 0.3,
          recentActivity: snap.progress.lastPracticedAt != null ? 0.6 : 0.1,
          userGoals: 0.8,
        ),
        reasoning: snap.aiCoachSummary.isNotEmpty
            ? snap.aiCoachSummary
            : 'Interview preparation directly impacts career opportunities.',
        route: '/interview',
        category: 'Interview',
        goalType: snap.isReadyForInterviews ? 'quickWin' : 'shortTerm',
      ),
    ];
  }

  List<ScoredAction> _fromOpportunityEngine() {
    final snap = _opportunityEngine.snapshot;
    if (snap == null || !snap.hasData) return [];

    final actions = <ScoredAction>[];
    if (snap.topOpportunity != null && snap.bestMatchScore >= 0.6) {
      actions.add(ScoredAction(
        id: 'opportunity-apply',
        title: 'Apply to ${snap.topOpportunity!.title}',
        description: 'Match score: ${(snap.bestMatchScore * 100).round()}%. '
            'You are well-positioned for this opportunity.',
        source: ActionSource.opportunity,
        score: _score(
          careerImpact: 1.0,
          learningDependency: 0.3,
          deadline: 0.8,
          difficulty: 0.5,
          roi: 1.0,
          skillGap: 0.4,
          momentum: 0.5,
          recentActivity: 0.2,
          userGoals: 1.0,
        ),
        reasoning: 'This role matches your profile well. Apply while the opportunity is available.',
        route: '/opportunity',
        category: 'Opportunity',
        goalType: 'shortTerm',
      ));
    }
    return actions;
  }

  List<ScoredAction> _fromMissionEngine() {
    final snap = _missionEngine.snapshot;
    if (snap == null || !snap.hasActiveRecommendation) return [];

    if (snap.currentMission != null) {
      final mission = snap.currentMission!;
      return [
        ScoredAction(
          id: 'mission-continue',
          title: 'Continue: ${mission.title}',
          description: mission.description.isNotEmpty
              ? mission.description
              : 'Progress on your active mission to advance your growth.',
          source: ActionSource.mission,
          score: _score(
            careerImpact: mission.impact.careerGain,
            learningDependency: 0.3,
            deadline: 0.5,
            difficulty: 0.4,
            roi: 0.7,
            skillGap: 0.5,
            momentum: 0.8,
            recentActivity: 0.7,
            userGoals: 0.7,
          ),
          reasoning: 'You have momentum on this mission. Continuing builds consistency.',
          route: '/mission-center',
          category: 'Mission',
          goalType: 'shortTerm',
        ),
      ];
    }
    return [];
  }

  List<ScoredAction> _fromGrowthEngine() {
    final snap = _growthEngine.snapshot;
    if (snap == null) return [];

    final lowestDimension = [
      ('Knowledge', snap.knowledge.score),
      ('Career', snap.career.score),
      ('Portfolio', snap.portfolio.score),
      ('Interview', snap.interview.score),
      ('Habits', snap.habits.score),
    ].reduce((a, b) => a.$2 < b.$2 ? a : b);

    if (lowestDimension.$2 < 0.4) {
      return [
        ScoredAction(
          id: 'growth-focus-${lowestDimension.$1.toLowerCase()}',
          title: 'Focus on ${lowestDimension.$1} growth',
          description: 'Your ${lowestDimension.$1.toLowerCase()} score is '
              '${(lowestDimension.$2 * 100).round()}%. '
              'This is your biggest growth opportunity.',
          source: ActionSource.growth,
          score: _score(
            careerImpact: 0.6,
            learningDependency: 0.3,
            deadline: 0.4,
            difficulty: 0.3,
            roi: 0.9,
            skillGap: 0.8,
            momentum: 0.3,
            recentActivity: 0.3,
            userGoals: 0.5,
          ),
          reasoning: 'Improving your weakest area creates the most balanced growth.',
          route: '/progress',
          category: 'Growth',
          goalType: 'shortTerm',
        ),
      ];
    }
    return [];
  }

  List<ScoredAction> _fromIdentityEngine() {
    final snap = _identityEngine.snapshot;
    if (snap == null) return [];

    if (snap.currentGoal.isEmpty) {
      return [
        ScoredAction(
          id: 'identity-set-goal',
          title: 'Set your career goal',
          description: 'Having a clear goal helps Phoenix personalize everything for you.',
          source: ActionSource.identity,
          score: _score(
            careerImpact: 0.7,
            learningDependency: 0.1,
            deadline: 0.2,
            difficulty: 0.2,
            roi: 0.9,
            skillGap: 0.2,
            momentum: 0.3,
            recentActivity: 0.5,
            userGoals: 1.0,
          ),
          reasoning: 'A clear goal enables Phoenix to provide tailored recommendations.',
          route: '/identity',
          category: 'Identity',
          goalType: 'quickWin',
        ),
      ];
    }
    return [];
  }

  List<ScoredAction> _fromRecommendationEngine() {
    final snap = _recommendationEngine.snapshot;
    if (snap == null || !snap.hasRecommendation) return [];

    return [
      ScoredAction(
        id: 'recommendation-primary',
        title: snap.primary!.title,
        description: snap.primary!.description,
        source: ActionSource.recommendation,
        score: _score(
          careerImpact: snap.careerImpact,
          learningDependency: 0.3,
          deadline: snap.priority > 5 ? 0.7 : 0.3,
          difficulty: snap.estimatedDuration > 60 ? 0.6 : 0.3,
          roi: snap.estimatedBenefit,
          skillGap: 0.4,
          momentum: 0.5,
          recentActivity: 0.5,
          userGoals: 0.6,
        ),
        reasoning: snap.reason?.why ?? 'Recommended based on your growth profile.',
        route: '/recommendation',
        category: snap.category?.displayName ?? 'Recommended',
        goalType: snap.priority > 7 ? 'shortTerm' : 'quickWin',
      ),
    ];
  }

  List<ScoredAction> _fromMemoryEngine() {
    final snap = _memoryEngine.snapshot;
    if (snap == null || !snap.hasMemories) return [];

    if (snap.totalMemories >= 3) {
      return [
        ScoredAction(
          id: 'memory-review',
          title: 'Review your knowledge',
          description: 'You have ${snap.totalMemories} saved items. '
              'Review to reinforce what you\'ve learned.',
          source: ActionSource.memory,
          score: _score(
            careerImpact: 0.4,
            learningDependency: 0.2,
            deadline: 0.2,
            difficulty: 0.2,
            roi: 0.5,
            skillGap: 0.3,
            momentum: 0.6,
            recentActivity: 0.7,
            userGoals: 0.4,
          ),
          reasoning: 'Regular review of saved knowledge strengthens retention.',
          route: '/memory',
          category: 'Review',
          goalType: 'quickWin',
        ),
      ];
    }
    return [];
  }

  // ── Reasoning Builder ──────────────────────────────────────────────

  String _buildReasoning(ScoredAction top, List<ScoredAction> all) {
    final buffer = StringBuffer();
    buffer.write('Based on your ${all.length} scored actions, ');

    if (top.score.careerImpact > 0.7) {
      buffer.write('${top.title} has the highest career impact. ');
    } else if (top.isQuickWin) {
      buffer.write('${top.title} is your best quick win today. ');
    } else if (top.isSuitableForToday) {
      buffer.write('${top.title} fits well with your current momentum. ');
    } else {
      buffer.write('${top.title} is the highest-value action right now. ');
    }

    if (top.score.confidence > 0.7) {
      buffer.write('High confidence recommendation.');
    } else if (top.score.confidence > 0.4) {
      buffer.write('Moderate confidence — consider alternatives below.');
    } else {
      buffer.write('Exploratory recommendation — try it and see what fits.');
    }

    return buffer.toString();
  }
}
