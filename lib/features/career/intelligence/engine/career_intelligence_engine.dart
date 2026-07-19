import 'package:flutter/foundation.dart';

import '../../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../career/engine/career_engine.dart';
import '../../../career/engine/career_snapshot.dart';
import '../../../growth_index/engine/growth_index_engine.dart';
import '../../../growth_index/models/growth_snapshot.dart';
import '../../../identity/engine/identity_engine.dart';
import '../../../identity/models/identity_snapshot.dart';
import '../../../portfolio/engine/portfolio_engine.dart';
import '../../../portfolio/engine/portfolio_snapshot.dart';
import '../../../resume_intelligence/engine/resume_intelligence_engine.dart';
import '../../../resume_intelligence/models/resume_intelligence_snapshot.dart';
import '../models/career_analytics.dart';
import '../models/career_goal.dart';
import '../models/career_intelligence_snapshot.dart';
import '../models/career_market_insight.dart';
import '../models/career_recommendation.dart';
import '../models/career_roadmap.dart';
import '../models/career_timeline.dart';
import '../models/roadmap_plan.dart';

/// Career Intelligence Engine — PHX-074.
///
/// Continuously evaluates career readiness, identifies gaps,
/// recommends actions, generates roadmaps, and produces an
/// immutable [CareerIntelligenceSnapshot] for all consumers.
///
/// **Architecture:**
/// ```text
/// CareerEngine + GrowthIndexEngine + IdentityEngine
///   + ResumeIntelligenceEngine + PortfolioEngine
///   ↓
/// CareerIntelligenceEngine
///   ↓
/// CareerIntelligenceSnapshot
///   ↓
/// CareerScreen | Dashboard | Profile | PhoenixAssistant
/// ```
///
/// **Rules:**
/// - Fully deterministic — no AI, no randomness
/// - All scores are reproducible given the same inputs
/// - Widgets read [snapshot] only
/// - Extends (does not replace) the existing CareerEngine
class CareerIntelligenceEngine extends ChangeNotifier {
  CareerIntelligenceEngine({
    required this._careerEngine,
    required this._growthEngine,
    required this._identityEngine,
    required this._resumeEngine,
    required this._portfolioEngine,
  });

  final CareerEngine _careerEngine;
  final GrowthIndexEngine _growthEngine;
  final IdentityEngine _identityEngine;
  final ResumeIntelligenceEngine _resumeEngine;
  final PortfolioEngine _portfolioEngine;
  final PhoenixLogger _logger = PhoenixLogger.shared;

  bool _isInitialized = false;
  CareerIntelligenceSnapshot? _cachedSnapshot;
  bool _isBuilding = false;

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current career intelligence snapshot.
  CareerIntelligenceSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine and builds the first snapshot.
  Future<void> init() async {
    _buildSnapshot();
    _isInitialized = true;

    _careerEngine.addListener(_onEngineChanged);
    _growthEngine.addListener(_onEngineChanged);
    _identityEngine.addListener(_onEngineChanged);
    _resumeEngine.addListener(_onEngineChanged);
    _portfolioEngine.addListener(_onEngineChanged);

    _logger.info('CareerIntelligenceEngine initialized',
        category: LogCategory.engine, source: 'CareerIntelligenceEngine');
    notifyListeners();
  }

  /// Refreshes the snapshot from current engine states.
  Future<void> refresh() async {
    _buildSnapshot();
    _logger.debug('CareerIntelligenceEngine refreshed',
        category: LogCategory.engine, source: 'CareerIntelligenceEngine');
    notifyListeners();
  }

  @override
  void dispose() {
    _careerEngine.removeListener(_onEngineChanged);
    _growthEngine.removeListener(_onEngineChanged);
    _identityEngine.removeListener(_onEngineChanged);
    _resumeEngine.removeListener(_onEngineChanged);
    _portfolioEngine.removeListener(_onEngineChanged);
    super.dispose();
  }

  Future<void> _onEngineChanged() async {
    if (!_isInitialized || _isBuilding) return;
    _isBuilding = true;
    await refresh();
    _isBuilding = false;
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  void _buildSnapshot() {
    final career = _careerEngine.snapshot ?? const CareerSnapshot();
    final growth = _growthEngine.snapshot;
    final identity = _identityEngine.snapshot;
    final resume = _resumeEngine.snapshot;
    final portfolio = _portfolioEngine.snapshot ?? const PortfolioSnapshot();

    // ── 1. Scores ──
    final readinessScore = _computeReadinessScore(career, growth);
    final skillMatch = _computeSkillMatch(career, growth);
    final resumeMatch = _computeResumeMatch(career, resume);
    final portfolioMatch = _computePortfolioMatch(career, portfolio);
    final interviewReadiness = career.interviewReadiness * 100;
    final learningProgress = (growth?.knowledge.score ?? 0) * 100;
    final marketAlignment = _computeMarketAlignment(career, growth);
    final overallScore = _computeOverallScore(
      readinessScore, skillMatch, resumeMatch, portfolioMatch,
      interviewReadiness, learningProgress, marketAlignment,
    );

    // ── 2. Role Info ──
    final targetRole = identity?.targetIdentityTitle ?? career.jobReadiness;
    final currentRole = identity?.currentIdentityTitle ?? 'Getting Started';
    final experience = identity?.experience ?? 'Beginner';

    // ── 3. Analysis ──
    final strengths = career.strengths;
    final skillGaps = career.skillGaps;
    final prioritizedGaps = _prioritizeGaps(career, resume);
    final marketInsights = _generateMarketInsights(career, growth);
    final recommendations = _generateRecommendations(
      career, growth, identity, resume, prioritizedGaps,
    );
    final aiSummary = _generateSummary(
      overallScore, readinessScore, targetRole, strengths, skillGaps,
    );

    // ── 4. Roadmaps ──
    final roadmaps = _generateRoadmaps(career, prioritizedGaps);

    // ── 5. Goals ──
    final goals = _buildGoals(career, identity);

    // ── 6. Analytics ──
    final analytics = _buildAnalytics(career, growth, portfolio);

    // ── 7. Timeline ──
    final timeline = _buildTimeline(career, growth);

    // ── 8. Actions ──
    final actions = _buildActions(recommendations, prioritizedGaps, career);
    final nextAction = actions.isNotEmpty ? actions.first.title : 'Define your career goal';

    _cachedSnapshot = CareerIntelligenceSnapshot(
      intelligenceScore: overallScore,
      readinessScore: readinessScore,
      skillMatchScore: skillMatch,
      resumeMatchScore: resumeMatch,
      portfolioMatchScore: portfolioMatch,
      interviewReadinessScore: interviewReadiness,
      learningProgressScore: learningProgress,
      marketAlignmentScore: marketAlignment,
      targetRole: targetRole,
      currentRole: currentRole,
      experience: experience,
      jobReadiness: career.jobReadiness,
      estimatedWeeks: career.estimatedWeeks,
      strengths: strengths,
      skillGaps: skillGaps,
      prioritizedGaps: prioritizedGaps,
      marketInsights: marketInsights,
      recommendations: recommendations,
      aiCareerSummary: aiSummary,
      roadmaps: roadmaps,
      careerGoals: goals,
      analytics: analytics,
      timeline: timeline,
      actionItems: actions,
      nextBestAction: nextAction,
      hasData: career.hasData,
      lastUpdated: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. SCORING
  // ═══════════════════════════════════════════════════════════════════

  /// Career readiness score (0-100).
  double _computeReadinessScore(CareerSnapshot career, GrowthSnapshot? growth) {
    return (career.careerScore * 30 +
        (growth?.portfolio.score ?? 0) * 25 +
        career.interviewReadiness * 25 +
        career.resumeProgress * 20)
        .clamp(0.0, 100.0);
  }

  /// Skill match score (0-100).
  double _computeSkillMatch(CareerSnapshot career, GrowthSnapshot? growth) {
    final hasCareerGoal = career.careerScore > 0.3 ? 20.0 : 0.0;
    return ((growth?.knowledge.score ?? 0) * 40 +
        (growth?.skills.score ?? 0) * 40 +
        hasCareerGoal)
        .clamp(0.0, 100.0);
  }

  /// Resume match score (0-100).
  double _computeResumeMatch(CareerSnapshot career, ResumeIntelligenceSnapshot? resume) {
    final resumeScore = (resume?.overallScore ?? career.resumeProgress * 100);
    return (resumeScore * 0.6 + career.resumeProgress * 100 * 0.4).clamp(0.0, 100.0);
  }

  /// Portfolio match score (0-100).
  double _computePortfolioMatch(CareerSnapshot career, PortfolioSnapshot portfolio) {
    return (portfolio.portfolioScore * 100 * 0.5 +
        career.portfolioProgress * 100 * 0.5)
        .clamp(0.0, 100.0);
  }

  /// Market alignment score (0-100).
  double _computeMarketAlignment(CareerSnapshot career, GrowthSnapshot? growth) {
    return ((growth?.skills.score ?? 0) * 30 +
        50.0 + // baseline market alignment
        (growth?.knowledge.score ?? 0) * 20)
        .clamp(0.0, 100.0);
  }

  /// Overall intelligence score (0-100).
  double _computeOverallScore(
    double readiness, double skillMatch, double resumeMatch,
    double portfolioMatch, double interview, double learning, double market,
  ) {
    return (readiness * 0.25 +
        skillMatch * 0.20 +
        resumeMatch * 0.10 +
        portfolioMatch * 0.10 +
        interview * 0.15 +
        learning * 0.10 +
        market * 0.10)
        .clamp(0.0, 100.0);
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. MARKET INSIGHTS
  // ═══════════════════════════════════════════════════════════════════

  List<CareerMarketInsight> _generateMarketInsights(
    CareerSnapshot career, GrowthSnapshot? growth) {
    final insights = <CareerMarketInsight>[];

    if ((growth?.knowledge.score ?? 0) < 0.3) {
      insights.add(const CareerMarketInsight(
        id: 'market_tech_demand',
        type: 'demand',
        title: 'Technology Skills in Demand',
        description: 'Employers seek candidates with modern technology skills.',
        impact: 0.8, confidence: 0.7,
      ));
    }
    if (career.interviewReadiness < 0.4) {
      insights.add(const CareerMarketInsight(
        id: 'market_interview',
        type: 'requirement',
        title: 'Interview Readiness Gap',
        description: 'Mock interviews could give you a competitive edge.',
        impact: 0.7, confidence: 0.8,
      ));
    }
    if (career.skillGaps.length >= 3) {
      insights.add(CareerMarketInsight(
        id: 'market_gaps',
        type: 'competition',
        title: 'Competitive Position',
        description: '${career.skillGaps.length} skill gaps affect your position.',
        impact: 0.6, confidence: 0.7,
        relatedSkills: career.skillGaps.take(3).toList(),
      ));
    }
    if (career.resumeProgress < 0.5) {
      insights.add(const CareerMarketInsight(
        id: 'market_resume',
        type: 'requirement',
        title: 'Resume Optimization',
        description: 'A polished resume boosts interview call-back rates.',
        impact: 0.7, confidence: 0.9,
      ));
    }
    return insights;
  }

  // ═══════════════════════════════════════════════════════════════════
  // GAP PRIORITIZATION
  // ═══════════════════════════════════════════════════════════════════

  List<PrioritizedGap> _prioritizeGaps(CareerSnapshot career, ResumeIntelligenceSnapshot? resume) {
    final prioritized = <PrioritizedGap>[];
    for (var i = 0; i < career.skillGaps.length; i++) {
      final gap = career.skillGaps[i];
      prioritized.add(PrioritizedGap(
        skillName: gap,
        priority: i == 0 ? GapActionPriority.critical
            : i == 1 ? GapActionPriority.high
            : i <= 3 ? GapActionPriority.medium
            : GapActionPriority.low,
        description: '$gap skills need development.',
        suggestion: 'Build $gap through projects and learning.',
        impact: (1.0 - i * 0.15).clamp(0.1, 1.0),
      ));
    }
    if (resume != null && resume.gaps.isNotEmpty) {
      for (final gap in resume.gaps.take(2)) {
        if (!prioritized.any((p) => p.skillName == gap.category)) {
          prioritized.add(PrioritizedGap(
            skillName: gap.category,
            priority: GapActionPriority.high,
            description: gap.description,
            suggestion: gap.suggestion,
            impact: gap.impact,
          ));
        }
      }
    }
    prioritized.sort((a, b) => b.priority.weight.compareTo(a.priority.weight));
    return prioritized;
  }

  // ═══════════════════════════════════════════════════════════════════
  // RECOMMENDATIONS
  // ═══════════════════════════════════════════════════════════════════

  List<CareerRecommendation> _generateRecommendations(
    CareerSnapshot career, GrowthSnapshot? growth,
    IdentitySnapshot? identity, ResumeIntelligenceSnapshot? resume,
    List<PrioritizedGap> gaps,
  ) {
    final recs = <CareerRecommendation>[];
    for (final gap in gaps.take(3)) {
      recs.add(CareerRecommendation(
        id: 'rec_${gap.skillName.toLowerCase().replaceAll(' ', '_')}',
        type: 'learn_skill',
        title: 'Learn ${gap.skillName}',
        description: gap.suggestion ?? 'Build ${gap.skillName} skills.',
        priority: gap.priority == GapActionPriority.critical
            ? CareerRecommendationPriority.critical
            : gap.priority == GapActionPriority.high
                ? CareerRecommendationPriority.high
                : CareerRecommendationPriority.medium,
        impact: gap.impact, estimatedWeeks: gap.priority == GapActionPriority.critical ? 4 : 8,
        skillsAddressed: [gap.skillName],
      ));
    }
    if (career.resumeProgress < 0.6) {
      recs.add(const CareerRecommendation(
        id: 'rec_update_resume', type: 'update_resume',
        title: 'Update Your Resume', description: 'Polish resume with current projects.',
        priority: CareerRecommendationPriority.high, impact: 0.6, estimatedWeeks: 1,
      ));
    }
    if (career.interviewReadiness < 0.5) {
      recs.add(const CareerRecommendation(
        id: 'rec_practice_interviews', type: 'practice_interview',
        title: 'Practice Mock Interviews', description: 'Build interview confidence.',
        priority: CareerRecommendationPriority.high, impact: 0.5, estimatedWeeks: 2,
      ));
    }
    if (career.portfolioProgress < 0.5) {
      recs.add(const CareerRecommendation(
        id: 'rec_improve_portfolio', type: 'improve_portfolio',
        title: 'Strengthen Portfolio', description: 'Add more projects to your portfolio.',
        priority: CareerRecommendationPriority.medium, impact: 0.4, estimatedWeeks: 4,
      ));
    }
    if (career.careerScore < 0.3 && (identity == null || identity.isNewUser)) {
      recs.add(const CareerRecommendation(
        id: 'rec_define_career', type: 'career_change',
        title: 'Define Career Goal', description: 'Set a clear career direction.',
        priority: CareerRecommendationPriority.critical, impact: 0.8, estimatedWeeks: 1,
      ));
    }
    recs.sort((a, b) => b.priority.weight.compareTo(a.priority.weight));
    return recs;
  }

  // ═══════════════════════════════════════════════════════════════════
  // AI SUMMARY
  // ═══════════════════════════════════════════════════════════════════

  String _generateSummary(
    double overall, double readiness, String role,
    List<String> strengths, List<String> gaps,
  ) {
    final sb = StringBuffer();
    if (role.isNotEmpty) {
      sb.write('You are targeting a $role role. ');
    }
    if (overall >= 70) {
      sb.write('Your career readiness is strong. ');
    } else if (overall >= 40) {
      sb.write('You are making progress toward your career goals. ');
    } else {
      sb.write('Your career journey is just beginning. ');
    }
    if (strengths.isNotEmpty) {
      sb.write('Key strengths: ${strengths.take(3).join(", ")}. ');
    }
    if (gaps.isNotEmpty) {
      sb.write('Focus areas: ${gaps.take(3).join(", ")}. ');
    }
    if (readiness >= 80) {
      sb.write('You are ready to start applying for jobs!');
    }
    return sb.toString().trim();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 4. ROADMAP GENERATION
  // ═══════════════════════════════════════════════════════════════════

  List<CareerRoadmap> _generateRoadmaps(
    CareerSnapshot career, List<PrioritizedGap> gaps,
  ) {
    final gapNames = gaps.map((g) => g.skillName).toList();
    final horizons = [30, 90, 180, 365];
    final undefined = career.careerScore < 0.3;

    return horizons.map((days) => RoadmapPlan.generate(
      id: 'roadmap_${days}d',
      horizonDays: days,
      skillGaps: gapNames,
      interviewReadiness: career.interviewReadiness,
      resumeProgress: career.resumeProgress,
      portfolioProgress: career.portfolioProgress,
      isReady: career.isReady,
      careerUndefined: undefined,
    )).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 5. GOALS
  // ═══════════════════════════════════════════════════════════════════

  List<CareerGoal> _buildGoals(CareerSnapshot career, IdentitySnapshot? identity) {
    final goals = <CareerGoal>[];
    if (identity != null && !identity.isNewUser) {
      goals.add(CareerGoal(
        id: 'goal_primary',
        targetRole: identity.targetIdentityTitle,
        progress: career.careerScore,
        isPrimary: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUpdated: DateTime.now(),
      ));
    }
    return goals;
  }

  // ═══════════════════════════════════════════════════════════════════
  // 6. ANALYTICS
  // ═══════════════════════════════════════════════════════════════════

  CareerAnalytics _buildAnalytics(
    CareerSnapshot career, GrowthSnapshot? growth, PortfolioSnapshot portfolio,
  ) {
    return CareerAnalytics(
      readinessTrend: [career.careerScore * 100],
      readinessLabels: ['Current'],
      skillGrowth: [(growth?.skills.score ?? 0) * 100],
      skillGrowthLabels: ['Current'],
      learningVelocity: (growth?.knowledge.score ?? 0) * 5,
      goalCompletionTrend: [career.careerScore * 100],
      goalCompletionLabels: ['Current'],
      marketAlignment: _computeMarketAlignment(career, growth),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 7. TIMELINE
  // ═══════════════════════════════════════════════════════════════════

  List<CareerTimelineEntry> _buildTimeline(CareerSnapshot career, GrowthSnapshot? growth) {
    return [
      CareerTimelineEntry(
        id: 'tl_start',
        type: 'milestone',
        title: 'Career Journey Started',
        date: career.lastUpdated ?? DateTime.now(),
        description: 'Readiness: ${career.jobReadiness} (${(career.careerScore * 100).round()}%)',
        status: 'completed',
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════
  // 8. ACTION ITEMS
  // ═══════════════════════════════════════════════════════════════════

  List<CareerActionItem> _buildActions(
    List<CareerRecommendation> recs,
    List<PrioritizedGap> gaps,
    CareerSnapshot career,
  ) {
    final actions = <CareerActionItem>[];
    for (final rec in recs.take(5)) {
      actions.add(CareerActionItem(
        id: 'action_${rec.id}',
        type: rec.type,
        title: rec.title,
        description: rec.description,
        priority: rec.priority == CareerRecommendationPriority.critical
            ? CareerActionPriority.critical
            : rec.priority == CareerRecommendationPriority.high
                ? CareerActionPriority.high
                : CareerActionPriority.medium,
        impact: rec.impact,
        estimatedWeeks: rec.estimatedWeeks,
        route: rec.route,
      ));
    }
    if (career.isReady && !actions.any((a) => a.type == 'apply')) {
      actions.add(const CareerActionItem(
        id: 'action_apply', type: 'apply',
        title: 'Start Applying', description: 'Begin job applications.',
        priority: CareerActionPriority.critical, impact: 0.9,
      ));
    }
    return actions;
  }
}
