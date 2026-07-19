

/// Immutable, read-only unified AI context snapshot.
///
/// This is the SINGLE SOURCE OF TRUTH for all AI interactions.
/// Every AI feature reads this snapshot instead of querying individual engines.
///
/// Produced by [AIContextEngine.buildSnapshot]. Immutable.
///
/// **Architecture Rule:**
/// No feature may build prompts independently. All AI requests must first
/// pass through the AI Context Engine and consume this snapshot.
class AIContextSnapshot {
  const AIContextSnapshot({
    required this.identity,
    required this.growth,
    required this.career,
    required this.knowledge,
    required this.portfolio,
    required this.journey,
    required this.mission,
    required this.memory,
    required this.recommendation,
    required this.settings,
    required this.metadata,
  });

  // ── 10 Sections ─────────────────────────────────────────────────

  /// The user's identity context.
  final IdentityContext identity;

  /// The user's growth context.
  final GrowthContext growth;

  /// The user's career context.
  final CareerContext career;

  /// The user's knowledge context.
  final KnowledgeContext knowledge;

  /// The user's portfolio context.
  final PortfolioContext portfolio;

  /// The user's journey context.
  final JourneyContext journey;

  /// The user's mission context.
  final MissionContext mission;

  /// The user's memory context.
  final MemoryContext memory;

  /// The user's recommendation context.
  final RecommendationContext recommendation;

  /// The user's settings context.
  final SettingsContext settings;

  /// Metadata about this context snapshot.
  final ContextMetadata metadata;

  // ── Computed ────────────────────────────────────────────────────

  /// Whether the context has enough data for meaningful AI generation.
  bool get isReady =>
      identity.name.isNotEmpty &&
      growth.level > 0 &&
      metadata.generatedAt.isAfter(
        DateTime.now().subtract(const Duration(hours: 24)),
      );

  /// Whether this is a new user with minimal data.
  bool get isNewUser =>
      growth.totalXp == 0 &&
      identity.name == 'Explorer' &&
      mission.activeCount == 0;

  @override
  String toString() =>
      'AIContextSnapshot(identity: ${identity.name}, '
      'level: ${growth.level}, xp: ${growth.totalXp}, '
      'missions: ${mission.activeCount}, '
      'freshness: ${metadata.freshnessLabel})';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 1: Identity
// ═════════════════════════════════════════════════════════════════════

/// Identity section of the AI context.
class IdentityContext {
  const IdentityContext({
    this.name = '',
    this.currentGoal = '',
    this.careerGoal = '',
    this.learningStyle = '',
    this.experienceLevel = 'beginner',
    this.identityTitle = '',
    this.targetIdentity = '',
    this.missionCount = 0,
    this.completedMissions = 0,
    this.lessonCount = 0,
    this.completedLessons = 0,
    this.completionPercent = 0,
  });

  /// The user's name or identity title.
  final String name;

  /// The user's current primary goal.
  final String currentGoal;

  /// The user's long-term career goal.
  final String careerGoal;

  /// Preferred learning style (e.g. 'Visual', 'Reading', 'Hands-on').
  final String learningStyle;

  /// Experience level (e.g. 'beginner', 'intermediate', 'advanced', 'expert').
  final String experienceLevel;

  /// Current identity title (e.g. 'Software Engineer').
  final String identityTitle;

  /// Target identity the user is working toward.
  final String targetIdentity;

  /// Total number of missions.
  final int missionCount;

  /// Number of completed missions.
  final int completedMissions;

  /// Total number of lessons.
  final int lessonCount;

  /// Number of completed lessons.
  final int completedLessons;

  /// Overall journey completion percentage (0–100).
  final int completionPercent;

  /// Mission completion rate (0.0–1.0).
  double get missionCompletionRate =>
      missionCount > 0 ? completedMissions / missionCount : 0.0;

  /// Lesson completion rate (0.0–1.0).
  double get lessonCompletionRate =>
      lessonCount > 0 ? completedLessons / lessonCount : 0.0;

  @override
  String toString() => 'Identity(name: $name, goal: $currentGoal, level: $experienceLevel)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 2: Growth
// ═════════════════════════════════════════════════════════════════════

/// Growth section of the AI context.
class GrowthContext {
  const GrowthContext({
    this.totalXp = 0,
    this.level = 1,
    this.growthIndex = 0.0,
    this.streak = 0,
    this.strengths = const [],
    this.weaknesses = const [],
    this.overallScore = 0.0,
    this.knowledgeScore = 0.0,
    this.skillsScore = 0.0,
    this.careerScore = 0.0,
    this.habitsScore = 0.0,
  });

  /// Total XP earned.
  final int totalXp;

  /// Current level.
  final int level;

  /// Overall growth index (0.0–1.0).
  final double growthIndex;

  /// Current streak (days).
  final int streak;

  /// Top strengths as labels.
  final List<String> strengths;

  /// Areas needing improvement.
  final List<String> weaknesses;

  /// Overall composite growth score (0.0–1.0).
  final double overallScore;

  /// Knowledge dimension score.
  final double knowledgeScore;

  /// Skills dimension score.
  final double skillsScore;

  /// Career dimension score.
  final double careerScore;

  /// Habits dimension score.
  final double habitsScore;

  @override
  String toString() =>
      'Growth(level: $level, xp: $totalXp, index: ${(growthIndex * 100).round()}%)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 3: Career
// ═════════════════════════════════════════════════════════════════════

/// Career section of the AI context.
class CareerContext {
  const CareerContext({
    this.careerScore = 0.0,
    this.resumeScore = 0.0,
    this.careerReadiness = '',
    this.interviewReadiness = 0.0,
    this.targetRole = '',
    this.skillGaps = const [],
    this.strengths = const [],
    this.applicationCount = 0,
    this.estimatedWeeks = 12,
  });

  /// Overall career readiness score (0.0–1.0).
  final double careerScore;

  /// Resume quality score (0.0–1.0).
  final double resumeScore;

  /// Career readiness label (e.g. 'Exploring', 'Building', 'Ready').
  final String careerReadiness;

  /// Interview readiness score (0.0–1.0).
  final double interviewReadiness;

  /// Target job role.
  final String targetRole;

  /// Skills that need improvement.
  final List<String> skillGaps;

  /// Top career strengths.
  final List<String> strengths;

  /// Number of applications tracked.
  final int applicationCount;

  /// Estimated weeks remaining.
  final int estimatedWeeks;

  @override
  String toString() =>
      'Career(score: ${(careerScore * 100).round()}%, role: $targetRole)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 4: Knowledge
// ═════════════════════════════════════════════════════════════════════

/// Knowledge section of the AI context.
class KnowledgeContext {
  const KnowledgeContext({
    this.knowledgeScore = 0.0,
    this.masteredSkills = const [],
    this.weakSkills = const [],
    this.learningProgress = 0.0,
    this.nodeCount = 0,
    this.domainCoverage = 0,
    this.totalDomains = 5,
    this.learningVelocity = 0.0,
    this.insights = const [],
  });

  /// Knowledge acquisition score (0.0–1.0).
  final double knowledgeScore;

  /// Skills the user has mastered.
  final List<String> masteredSkills;

  /// Skills that need improvement.
  final List<String> weakSkills;

  /// Overall learning progress (0.0–1.0).
  final double learningProgress;

  /// Number of knowledge graph nodes.
  final int nodeCount;

  /// Number of domains covered.
  final int domainCoverage;

  /// Total number of available domains.
  final int totalDomains;

  /// Learning velocity (0.0–1.0).
  final double learningVelocity;

  /// Insight descriptions from the knowledge engine.
  final List<String> insights;

  @override
  String toString() =>
      'Knowledge(score: ${(knowledgeScore * 100).round()}%, '
      'nodes: $nodeCount, mastery: ${masteredSkills.length} skills)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 5: Portfolio
// ═════════════════════════════════════════════════════════════════════

/// Portfolio section of the AI context.
class PortfolioContext {
  const PortfolioContext({
    this.portfolioScore = 0.0,
    this.projectCount = 0,
    this.skillCount = 0,
    this.technologyCount = 0,
    this.achievementCount = 0,
    this.technologies = const [],
    this.strengthAreas = const [],
  });

  /// Overall portfolio score (0.0–1.0).
  final double portfolioScore;

  /// Number of completed projects.
  final int projectCount;

  /// Number of tracked skills.
  final int skillCount;

  /// Number of distinct technologies.
  final int technologyCount;

  /// Number of achievements and badges.
  final int achievementCount;

  /// Technology stack used.
  final List<String> technologies;

  /// Identified strength areas.
  final List<String> strengthAreas;

  @override
  String toString() =>
      'Portfolio(score: ${(portfolioScore * 100).round()}%, '
      'projects: $projectCount, techs: $technologyCount)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 6: Journey
// ═════════════════════════════════════════════════════════════════════

/// Journey section of the AI context.
class JourneyContext {
  const JourneyContext({
    this.currentJourney = '',
    this.currentStage = '',
    this.completionPercent = 0.0,
    this.resumeTitle = '',
    this.resumeType = '',
    this.resumeReason = '',
  });

  /// Current journey label.
  final String currentJourney;

  /// Current stage label.
  final String currentStage;

  /// Overall completion percentage (0.0–1.0).
  final double completionPercent;

  /// Title of the activity to resume.
  final String resumeTitle;

  /// Type of the resume point (e.g. 'lesson', 'mission', 'project').
  final String resumeType;

  /// Reason for the resume recommendation.
  final String resumeReason;

  @override
  String toString() =>
      'Journey(stage: $currentStage, completion: ${(completionPercent * 100).round()}%)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 7: Mission
// ═════════════════════════════════════════════════════════════════════

/// Mission section of the AI context.
class MissionContext {
  const MissionContext({
    this.activeCount = 0,
    this.completedCount = 0,
    this.pendingCount = 0,
    this.currentMission = '',
    this.currentPriority = '',
    this.confidence = 0.0,
    this.reason = '',
  });

  /// Number of active missions.
  final int activeCount;

  /// Number of completed missions.
  final int completedCount;

  /// Number of pending missions.
  final int pendingCount;

  /// Current mission title.
  final String currentMission;

  /// Current mission priority label.
  final String currentPriority;

  /// Confidence in the recommendation (0.0–1.0).
  final double confidence;

  /// Reason for the current mission recommendation.
  final String reason;

  @override
  String toString() =>
      'Mission(active: $activeCount, completed: $completedCount, '
      'current: $currentMission)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 8: Memory
// ═════════════════════════════════════════════════════════════════════

/// Memory section of the AI context.
class MemoryContext {
  const MemoryContext({
    this.recentTimeline = const [],
    this.recentDecisions = const [],
    this.recentLearning = const [],
    this.totalMemories = 0,
    this.totalRelationships = 0,
    this.topMemory = '',
  });

  /// Recent timeline event descriptions.
  final List<String> recentTimeline;

  /// Recent decision descriptions.
  final List<String> recentDecisions;

  /// Recent learning activity descriptions.
  final List<String> recentLearning;

  /// Total number of stored memories.
  final int totalMemories;

  /// Total number of memory relationships.
  final int totalRelationships;

  /// The single most important memory.
  final String topMemory;

  @override
  String toString() =>
      'Memory(memories: $totalMemories, recent: ${recentTimeline.length})';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 9: Recommendation
// ═════════════════════════════════════════════════════════════════════

/// Recommendation section of the AI context.
class RecommendationContext {
  const RecommendationContext({
    this.topRecommendation = '',
    this.topPriority = 0,
    this.nextPriorities = const [],
    this.confidence = 0.0,
    this.urgencyScore = 0.0,
    this.estimatedBenefit = 0.0,
  });

  /// Title of the top recommendation.
  final String topRecommendation;

  /// Priority level (1–10).
  final int topPriority;

  /// Next priority recommendations.
  final List<String> nextPriorities;

  /// Recommendation confidence (0.0–1.0).
  final double confidence;

  /// Urgency score (0.0–1.0).
  final double urgencyScore;

  /// Estimated benefit (0.0–1.0).
  final double estimatedBenefit;

  @override
  String toString() =>
      'Recommendation(top: $topRecommendation, confidence: ${(confidence * 100).round()}%)';
}

// ═════════════════════════════════════════════════════════════════════
// SECTION 10: Settings
// ═════════════════════════════════════════════════════════════════════

/// Settings section of the AI context.
class SettingsContext {
  const SettingsContext({
    this.preferredAIProvider = '',
    this.preferredModel = '',
    this.language = 'en',
    this.timezone = 'UTC',
    this.dailyAvailableMinutes = 30,
    this.themeMode = 'light',
  });

  /// Preferred AI provider ID.
  final String preferredAIProvider;

  /// Preferred AI model name.
  final String preferredModel;

  /// User's language code.
  final String language;

  /// User's timezone.
  final String timezone;

  /// Daily available learning time in minutes.
  final int dailyAvailableMinutes;

  /// Current theme mode.
  final String themeMode;

  @override
  String toString() =>
      'Settings(provider: $preferredAIProvider, model: $preferredModel, '
      'daily: ${dailyAvailableMinutes}min)';
}

// ═════════════════════════════════════════════════════════════════════
// METADATA
// ═════════════════════════════════════════════════════════════════════

/// Metadata about the AI context snapshot.
class ContextMetadata {
  const ContextMetadata({
    required this.generatedAt,
    required this.contextVersion,
    this.lastUpdated,
    this.isComplete = false,
    this.missingSections = const [],
  });

  /// The context schema version.
  static const int currentVersion = 1;

  /// When this context was generated.
  final DateTime generatedAt;

  /// Version of the context schema.
  final int contextVersion;

  /// When the underlying data was last updated.
  final DateTime? lastUpdated;

  /// Whether all sections have data.
  final bool isComplete;

  /// Sections that are missing data.
  final List<String> missingSections;

  /// Human-readable freshness label.
  String get freshnessLabel {
    final minutesAgo = DateTime.now().difference(generatedAt).inMinutes;
    if (minutesAgo < 1) return 'just now';
    if (minutesAgo < 60) return '${minutesAgo}m ago';
    final hoursAgo = (minutesAgo / 60).floor();
    if (hoursAgo < 24) return '${hoursAgo}h ago';
    return '${(hoursAgo / 24).floor()}d ago';
  }

  @override
  String toString() =>
      'Metadata(version: $contextVersion, generated: $freshnessLabel, '
      'complete: $isComplete)';
}

// ═════════════════════════════════════════════════════════════════════
// DEFAULT VALUES
// ═════════════════════════════════════════════════════════════════════

/// Default values for a newly initialized context (before any data is loaded).
class AIContextDefaults {
  AIContextDefaults._();

  static AIContextSnapshot createUninitialized() => AIContextSnapshot(
        identity: const IdentityContext(),
        growth: const GrowthContext(),
        career: const CareerContext(),
        knowledge: const KnowledgeContext(),
        portfolio: const PortfolioContext(),
        journey: const JourneyContext(),
        mission: const MissionContext(),
        memory: const MemoryContext(),
        recommendation: const RecommendationContext(),
        settings: const SettingsContext(),
        metadata: ContextMetadata(
          generatedAt: DateTime.fromMillisecondsSinceEpoch(0),
          contextVersion: 1,
          isComplete: false,
        ),
      );
}
