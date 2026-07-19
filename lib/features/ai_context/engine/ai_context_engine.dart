import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../career/engine/career_engine.dart';
import '../../continue_journey/engine/continue_journey_engine.dart';
import '../../daily_brief/engine/daily_brief_engine.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../growth_index/models/growth_snapshot.dart';
import '../../identity/engine/identity_engine.dart';
import '../../memory_engine/engine/memory_engine.dart';
import '../../memory_engine/models/memory_snapshot.dart';
import '../../mission_intelligence/engine/mission_intelligence_engine.dart';

import '../../personal_knowledge/engine/knowledge_engine.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../../progress_engine/achievement_engine.dart';
import '../../recommendation_engine/engine/recommendation_engine.dart';
import '../../settings/engine/settings_engine.dart';
import '../models/ai_context_snapshot.dart';

/// AI Context Engine — single source of truth for all AI interactions.
class AIContextEngine extends ChangeNotifier {
  AIContextEngine({
    required this.identityEngine,
    required this.growthEngine,
    required this.careerEngine,
    required this.portfolioEngine,
    required this.knowledgeEngine,
    required this.missionEngine,
    required this.journeyEngine,
    required this.memoryEngine,
    required this.recommendationEngine,
    required this.achievementEngine,
    required this.dailyBriefEngine,
    required this.settingsEngine,
  });

  // ── Dependencies ─────────────────────────────────────────────────

  final IdentityEngine identityEngine;
  final GrowthIndexEngine growthEngine;
  final CareerEngine careerEngine;
  final PortfolioEngine portfolioEngine;
  final KnowledgeEngine knowledgeEngine;
  final MissionIntelligenceEngine missionEngine;
  final ContinueJourneyEngine journeyEngine;
  final MemoryEngine memoryEngine;
  final RecommendationEngine recommendationEngine;
  final AchievementEngine achievementEngine;
  final DailyBriefEngine dailyBriefEngine;
  final SettingsEngine settingsEngine;

  final PhoenixLogger _logger = PhoenixLogger.shared;

  AIContextSnapshot _cachedSnapshot = AIContextDefaults.createUninitialized();
  bool _isInitialized = false;

  // ── Accessors ───────────────────────────────────────────────────

  AIContextSnapshot get snapshot => _cachedSnapshot;
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ───────────────────────────────────────────────────

  Future<void> init() async {
    _refreshSnapshot();
    _isInitialized = true;

    _logger.info('AIContextEngine initialized',
        category: LogCategory.engine, source: 'AIContextEngine');

    notifyListeners();
  }

  Future<void> refresh() async {
    _refreshSnapshot();
    _logger.debug('AIContextEngine refreshed',
        category: LogCategory.engine, source: 'AIContextEngine');
    notifyListeners();
  }

  // ── Snapshot Builder ────────────────────────────────────────────

  void _refreshSnapshot() {
    final now = DateTime.now();

    // ── Identity ──────────────────────────────────────────────────
    final identitySnap = identityEngine.snapshot;
    final identityProfile = identitySnap?.profile;
    final identity = IdentityContext(
      name: identitySnap?.currentIdentityTitle ?? 'Explorer',
      currentGoal: identitySnap?.currentGoal ?? 'Begin your journey',
      careerGoal: identityProfile?.careerGoal ?? '',
      learningStyle: identityProfile?.learningStyle.isNotEmpty == true
          ? identityProfile!.learningStyle.first
          : '',
      experienceLevel: identityProfile?.experienceLevel ?? 'beginner',
      identityTitle: identitySnap?.currentIdentityTitle ?? '',
      targetIdentity: identitySnap?.targetIdentityTitle ?? '',
      missionCount: identitySnap?.missionCount ?? 0,
      completedMissions: identitySnap?.completedMissions ?? 0,
      lessonCount: identitySnap?.lessonCount ?? 0,
      completedLessons: identitySnap?.completedLessons ?? 0,
      completionPercent: identitySnap?.completionPercent ?? 0,
    );

    // ── Growth ────────────────────────────────────────────────────
    final growthSnap = growthEngine.snapshot;
    final growth = GrowthContext(
      totalXp: growthSnap?.totalXp ?? identitySnap?.totalXp ?? 0,
      level: growthSnap?.currentLevel ?? identitySnap?.level ?? 1,
      growthIndex: growthSnap?.overallScore ?? 0.0,
      streak: 0,
      strengths: _deriveStrengths(growthSnap),
      weaknesses: _deriveWeaknesses(growthSnap),
      overallScore: growthSnap?.overallScore ?? 0.0,
      knowledgeScore: growthSnap?.knowledge.score ?? 0.0,
      skillsScore: growthSnap?.skills.score ?? 0.0,
      careerScore: growthSnap?.career.score ?? 0.0,
      habitsScore: growthSnap?.habits.score ?? 0.0,
    );

    // ── Career ────────────────────────────────────────────────────
    final careerSnap = careerEngine.snapshot;
    final career = CareerContext(
      careerScore: careerSnap?.careerScore ?? 0.0,
      resumeScore: careerSnap?.resumeProgress ?? 0.0,
      careerReadiness: careerSnap?.jobReadiness ?? '',
      interviewReadiness: careerSnap?.interviewReadiness ?? 0.0,
      targetRole: careerSnap?.nextGoal ?? '',
      skillGaps: careerSnap?.skillGaps ?? [],
      strengths: careerSnap?.strengths ?? [],
      applicationCount: careerSnap?.applicationCount ?? 0,
      estimatedWeeks: careerSnap?.estimatedWeeks ?? 12,
    );

    // ── Knowledge ─────────────────────────────────────────────────
    final knowledgeAnalytics = knowledgeEngine.analytics;
    final knowledgeRawInsights = knowledgeEngine.insights;
    final knowledge = KnowledgeContext(
      knowledgeScore: growthSnap?.knowledge.score ?? 0.0,
      masteredSkills: _castStringList(knowledgeAnalytics['topSkills']),
      weakSkills: _castStringList(knowledgeAnalytics['weakSkills']),
      learningProgress: (knowledgeAnalytics['learningProgress'] as num?)?.toDouble() ?? 0.0,
      nodeCount: knowledgeAnalytics['nodeCount'] as int? ?? 0,
      domainCoverage: knowledgeAnalytics['domainCoverage'] as int? ?? 0,
      totalDomains: knowledgeAnalytics['totalDomains'] as int? ?? 5,
      learningVelocity: _deriveLearningVelocity(knowledgeAnalytics),
      insights: knowledgeRawInsights.map((e) => e.toString()).toList(),
    );

    // ── Portfolio ─────────────────────────────────────────────────
    final portfolioSnap = portfolioEngine.snapshot;
    final portfolio = PortfolioContext(
      portfolioScore: portfolioSnap?.portfolioScore ?? 0.0,
      projectCount: portfolioSnap?.projectCount ?? 0,
      skillCount: portfolioSnap?.skillCount ?? 0,
      technologyCount: portfolioSnap?.technologyCount ?? 0,
      achievementCount: portfolioSnap?.achievementCount ?? 0,
      technologies: portfolioSnap?.technologies ?? [],
      strengthAreas: portfolioSnap?.strengthAreas ?? [],
    );

    // ── Journey ───────────────────────────────────────────────────
    final journeySnap = journeyEngine.snapshot;
    final journey = JourneyContext(
      currentJourney: journeySnap?.currentJourney ?? '',
      currentStage: journeySnap?.currentStage ?? '',
      completionPercent: journeySnap?.completionPercent ?? 0.0,
      resumeTitle: journeySnap?.resumePoint?.title ?? '',
      resumeType: journeySnap?.resumePoint?.type.name ?? '',
      resumeReason: journeySnap?.reason ?? '',
    );

    // ── Mission ───────────────────────────────────────────────────
    final missionSnap = missionEngine.snapshot;
    final mission = MissionContext(
      activeCount: missionSnap?.currentMission != null ? 1 : 0,
      completedCount: missionSnap?.evaluation?.totalRules ?? 0,
      pendingCount: missionSnap?.alternatives.length ?? 0,
      currentMission: missionSnap?.currentMission?.title ?? '',
      currentPriority: missionSnap?.priority?.name ?? '',
      confidence: missionSnap?.confidence ?? 0.0,
      reason: missionSnap?.reason ?? '',
    );

    // ── Memory ────────────────────────────────────────────────────
    final memorySnap = memoryEngine.snapshot;
    final memory = MemoryContext(
      recentTimeline: _deriveMemoryTimeline(memorySnap),
      recentDecisions: <String>[],
      recentLearning: _deriveMemoryLearning(memorySnap),
      totalMemories: memorySnap?.totalMemories ?? 0,
      totalRelationships: memorySnap?.totalRelationships ?? 0,
      topMemory: memorySnap?.topMemory?.title ?? '',
    );

    // ── Recommendation ────────────────────────────────────────────
    final recSnap = recommendationEngine.snapshot;
    final recommendation = RecommendationContext(
      topRecommendation: recSnap?.primary?.title ?? '',
      topPriority: recSnap?.priority ?? 0,
      nextPriorities:
          recSnap?.alternatives.map((a) => a.title).toList() ?? [],
      confidence: recSnap?.confidence ?? 0.0,
      urgencyScore: recSnap?.urgencyScore ?? 0.0,
      estimatedBenefit: recSnap?.estimatedBenefit ?? 0.0,
    );

    // ── Settings ──────────────────────────────────────────────────
    final settingsSnap = settingsEngine.snapshot;
    final aiProviderPref = settingsSnap.aiProvider;
    final language = settingsSnap.language;
    final isDarkMode = settingsSnap.isDarkMode;
    final dailyGoalMinutes = settingsSnap.learning.dailyGoalMinutes;
    final settings = SettingsContext(
      preferredAIProvider: aiProviderPref.defaultProvider ?? '',
      preferredModel: '',
      language: language,
      timezone: 'UTC',
      dailyAvailableMinutes: dailyGoalMinutes,
      themeMode: isDarkMode ? 'dark' : 'light',
    );

    // ── Metadata ──────────────────────────────────────────────────
    final sections = <String>[
      if (identity.name.isEmpty) 'identity',
      if (growth.totalXp == 0) 'growth',
      if (career.careerScore == 0.0) 'career',
      if (knowledge.nodeCount == 0) 'knowledge',
      if (portfolio.portfolioScore == 0.0) 'portfolio',
      if (journey.currentJourney.isEmpty) 'journey',
      if (mission.activeCount == 0 && mission.completedCount == 0) 'mission',
      if (memory.totalMemories == 0) 'memory',
      if (recommendation.topRecommendation.isEmpty) 'recommendation',
    ];

    _cachedSnapshot = AIContextSnapshot(
      identity: identity,
      growth: growth,
      career: career,
      knowledge: knowledge,
      portfolio: portfolio,
      journey: journey,
      mission: mission,
      memory: memory,
      recommendation: recommendation,
      settings: settings,
      metadata: ContextMetadata(
        generatedAt: now,
        contextVersion: ContextMetadata.currentVersion,
        lastUpdated: now,
        isComplete: sections.isEmpty,
        missingSections: sections,
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  List<String> _deriveStrengths(GrowthSnapshot? snap) {
    if (snap == null) return [];
    final top = snap.strongestDimension;
    if (top.score > 0.5) return [top.dimension.displayName];
    return [];
  }

  List<String> _deriveWeaknesses(GrowthSnapshot? snap) {
    if (snap == null) return [];
    final bottom = snap.weakestDimension;
    if (bottom.score < 0.5) return [bottom.dimension.displayName];
    return [];
  }

  List<String> _deriveMemoryTimeline(MemorySnapshot? snap) {
    if (snap == null) return [];
    return snap.recentMemories.take(5).map((e) => e.title).toList();
  }

  List<String> _deriveMemoryLearning(MemorySnapshot? snap) {
    if (snap == null) return [];
    return snap.recentAchievements.take(3).map((e) => e.title).toList();
  }

  double _deriveLearningVelocity(Map<String, dynamic> analytics) {
    final recentCount = analytics['recentActivityCount'];
    if (recentCount is int && recentCount > 0) {
      return (recentCount / 30.0).clamp(0.0, 1.0);
    }
    final topSkills = analytics['topSkills'];
    if (topSkills is List && topSkills.isNotEmpty) {
      return 0.5;
    }
    return 0.3;
  }

  List<String> _castStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  Future<void> reset() async {
    _cachedSnapshot = AIContextDefaults.createUninitialized();
    _isInitialized = false;
    _logger.info('AIContextEngine reset',
        category: LogCategory.engine, source: 'AIContextEngine');
    notifyListeners();
  }
}
