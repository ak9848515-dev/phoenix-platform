import 'dart:convert';

import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../features/academy/engine/learning_path_registry.dart';
import '../features/academy/services/academy_service.dart';
import '../features/ai/services/ai_mentor_service.dart';
import '../features/auth/services/authentication_service.dart';
import '../features/decision/services/decision_intelligence_service.dart';
import '../features/habit/services/habit_service.dart';
import '../features/growth_index/calculators/habits_calculator.dart';
import '../features/growth_index/calculators/mission_calculator.dart';
import '../features/growth_index/engine/growth_index_engine.dart';
import '../features/growth_index/repository/local_growth_repository.dart';
import '../features/identity/engine/identity_engine.dart';
import '../features/identity/repository/local_identity_repository.dart';
import '../features/mission_intelligence/engine/mission_intelligence_engine.dart';
import '../features/mission_intelligence/repository/mission_intelligence_repository.dart';
import '../features/recommendation_engine/engine/recommendation_engine.dart';
import '../features/recommendation_engine/repository/local_recommendation_repository.dart';
import '../features/daily_brief/engine/daily_brief_engine.dart';
import '../features/daily_brief/repository/local_daily_brief_repository.dart';
import '../features/continue_journey/engine/continue_journey_engine.dart';
import '../features/continue_journey/repository/local_journey_repository.dart';
import '../features/ai_capability_router/adapters/mock_claude_adapter.dart';
import '../features/ai_capability_router/adapters/mock_deepseek_adapter.dart';
import '../features/ai_capability_router/adapters/gemini_adapter.dart';
import '../features/ai_capability_router/adapters/mock_gemini_adapter.dart';
import '../features/ai_capability_router/adapters/mock_ollama_adapter.dart';
import '../features/ai_capability_router/adapters/mock_openai_adapter.dart';
import '../features/ai_capability_router/adapters/mock_openrouter_adapter.dart';
import '../features/ai_capability_router/models/ai_router_config.dart';
import '../features/ai_capability_router/registry/ai_provider_registry.dart';
import '../features/ai_capability_router/router/ai_capability_router.dart';
import '../features/ai/provider_config/services/connection_test_service.dart';
import '../features/ai/provider_config/services/health_monitor.dart';
import '../features/settings/engine/settings_engine.dart';
import '../features/settings/repository/settings_repository.dart';
import '../features/settings/services/settings_service.dart';
import '../features/ai/provider_config/services/provider_config_repository.dart';
import '../features/ai/provider_config/services/provider_config_service.dart';
import '../features/ai/provider_config/services/secure_storage_service.dart';
import '../features/memory_graph/services/memory_graph_service.dart';
import '../features/personal_knowledge/services/knowledge_service.dart';
import '../features/timeline/services/timeline_service.dart';
import '../features/user_state/engine/user_state_engine.dart';
import '../features/user_state/repository/user_state_repository.dart';
import '../features/user_state/services/user_state_service.dart';
import '../features/voice/providers/mock_speech_provider.dart';
import '../features/voice/services/voice_service.dart';
import '../routes/app_router.dart';
import '../services/sample_data_service.dart';
import '../shared/infrastructure/diagnostics/diagnostics_service.dart';
import '../shared/infrastructure/logging/phoenix_logger.dart';
import '../theme/theme.dart';
import 'cloud/firestore_sync_adapter.dart';
import 'local_repository.dart';
import 'storage_service.dart';
import '../shared/infrastructure/cache/cache_service.dart';

// ── Content Generation Platform ────────────────────────────────────
import '../features/content_generation/services/content_generator_coordinator.dart';
import '../features/content_generation/services/content_repository.dart';

// ── Domain Engine Imports ───────────────────────────────────────────
import '../features/career/engine/career_engine.dart';
import '../features/career/repository/local_career_repository.dart';
import '../features/career/services/career_service.dart';
import '../features/portfolio/engine/portfolio_engine.dart';
import '../features/portfolio/repository/local_portfolio_repository.dart';
import '../features/portfolio/services/portfolio_service.dart';
import '../features/personal_knowledge/engine/knowledge_engine.dart';
import '../features/memory_engine/engine/memory_engine.dart';
import '../features/memory_engine/repository/local_memory_repository.dart';
import '../features/progress_engine/achievement_engine.dart';
import '../features/progress_engine/progress_service.dart';
import '../features/progress_engine/repository/local_achievement_repository.dart';

// ── Mission Engine Imports ────────────────────────────────────────────
import '../features/mission_engine/engine/mission_engine.dart' as dynamic_mission_engine;
import '../features/mission_engine/engine/mission_generator.dart';
import '../features/mission_engine/engine/mission_prioritizer.dart';
import '../features/mission_engine/engine/mission_scheduler.dart';
import '../features/knowledge_dna/knowledge_dna_service.dart';
import '../features/resume/services/resume_service.dart';
import '../features/opportunity/services/opportunity_service.dart';
import '../features/interview/intelligence/engine/interview_intelligence_engine.dart';
import '../features/interview/intelligence/repository/local_interview_intelligence_repository.dart';
import '../features/interview/services/interview_service.dart';
import '../features/opportunity/intelligence/engine/opportunity_intelligence_engine.dart';
import '../features/opportunity/intelligence/repository/local_opportunity_intelligence_repository.dart';
import '../features/recommendation/services/recommendation_service.dart';

// ── AI Context Engine ────────────────────────────────────────────────
import '../features/ai_context/engine/ai_context_engine.dart';

// ── Prompt Builder ───────────────────────────────────────────────────
import '../features/ai_prompt/services/prompt_builder_service.dart';
import '../features/ai_prompt/services/prompt_template_registry.dart';

// ── AI Response Gateway ──────────────────────────────────────────────
import '../features/ai_gateway/services/ai_response_gateway.dart';
import '../features/ai_gateway/services/schema_registry.dart';

// ── Learning Experience Generator ─────────────────────────────────────
import '../features/learning_experience/services/learning_experience_generator.dart';

// ── Decision Intelligence Engine ───────────────────────────────────────
import '../features/decision_intelligence/engine/decision_engine.dart';

// ── Growth Intelligence Engine ────────────────────────────────────────
import '../features/growth_intelligence/engine/growth_intelligence_engine.dart';

// ── Adaptive Learning Engine ────────────────────────────────────────
import '../features/adaptive_learning/engine/adaptive_learning_engine.dart';

// ── Resume Intelligence Engine ─────────────────────────────────────
import '../features/resume_intelligence/engine/resume_intelligence_engine.dart';

// ── Review Engine ───────────────────────────────────────────────────
import '../features/review_engine/engine/review_engine.dart';
import '../features/review_engine/repository/review_repository.dart';

// ── Notification Engine ─────────────────────────────────────────────
import '../features/notification_center/engine/notification_engine.dart';

// ── Learning Experience ──────────────────────────────────────────────
import '../features/learning_experience/services/learning_experience_orchestrator.dart';
import '../features/learning_experience/services/learning_experience_registry.dart';

// ── Phoenix Assistant ──────────────────────────────────────────────────
import '../features/ai_assistant/services/phoenix_assistant_service.dart';

// ── Knowledge Relationship Intelligence ──────────────────────────────
import '../features/knowledge_relationship/services/knowledge_relationship_service.dart';

// ── Decision Intelligence Orchestrator ─────────────────────────────────
import '../features/decision_intelligence/orchestrator/decision_intelligence_orchestrator.dart';

/// Application bootstrap and startup orchestration.
///
/// Separates startup responsibilities into clearly named methods
/// so the application entry point remains focused and testable.
class AppBootstrap {
  AppBootstrap._();

  /// The application-wide [StorageService] instance.
  static StorageService? _storageService;

  /// Returns the initialized [StorageService] instance.
  static StorageService get storageService {
    assert(
      _storageService != null,
      'StorageService not initialized. Call AppBootstrap.init() first.',
    );
    return _storageService!;
  }

  /// Returns the [StorageService] instance or `null` if not initialized.
  static StorageService? get maybeStorageService => _storageService;

  /// The application-wide [UserStateService] instance.
  static UserStateService? _userStateService;

  /// Returns the initialized [UserStateService] instance.
  static UserStateService get userStateService {
    assert(
      _userStateService != null,
      'UserStateService not initialized. Call AppBootstrap.init() first.',
    );
    return _userStateService!;
  }

  static UserStateService? get maybeUserStateService => _userStateService;

  static VoiceService? _voiceService;
  static VoiceService? get maybeVoiceService => _voiceService;

  static AcademyService? _academyService;
  static AcademyService? get maybeAcademyService => _academyService;

  static DecisionIntelligenceService? _decisionService;
  static DecisionIntelligenceService? get maybeDecisionService =>
      _decisionService;

  static TimelineService? _timelineService;
  static TimelineService? get maybeTimelineService => _timelineService;

  static HabitService? _habitService;
  static HabitService? get maybeHabitService => _habitService;

  static MemoryGraphService? _memoryGraphService;
  static MemoryGraphService? get maybeMemoryGraphService => _memoryGraphService;

  static KnowledgeService? _knowledgeService;
  static KnowledgeService? get maybeKnowledgeService => _knowledgeService;

  /// The application-wide [AuthenticationService] instance (Firebase-backed).
  static AuthenticationService? _authenticationService;

  /// Returns the [AuthenticationService] instance or `null` if not initialized.
  static AuthenticationService? get maybeAuthenticationService =>
      _authenticationService;

  static IdentityEngine? _identityEngine;
  static IdentityEngine? get maybeIdentityEngine => _identityEngine;

  static GrowthIndexEngine? _growthEngine;
  static GrowthIndexEngine? get maybeGrowthEngine => _growthEngine;

  static MissionIntelligenceEngine? _missionIntelligenceEngine;
  static MissionIntelligenceEngine? get maybeMissionIntelligenceEngine =>
      _missionIntelligenceEngine;

  static RecommendationEngine? _recommendationEngine;
  static RecommendationEngine? get maybeRecommendationEngine =>
      _recommendationEngine;

  static DailyBriefEngine? _dailyBriefEngine;
  static DailyBriefEngine? get maybeDailyBriefEngine => _dailyBriefEngine;

  static ContinueJourneyEngine? _continueJourneyEngine;
  static ContinueJourneyEngine? get maybeContinueJourneyEngine =>
      _continueJourneyEngine;

  static AICapabilityRouter? _aiCapabilityRouter;
  static AICapabilityRouter? get maybeAICapabilityRouter =>
      _aiCapabilityRouter;

  static ProviderConfigurationService? _providerConfigService;
  static ProviderConfigurationService? get maybeProviderConfigService =>
      _providerConfigService;

  static ConnectionTestService? _connectionTestService;
  static ConnectionTestService? get maybeConnectionTestService =>
      _connectionTestService;

  static HealthMonitor? _healthMonitor;
  static HealthMonitor? get maybeHealthMonitor => _healthMonitor;

  static SettingsService? _settingsService;
  static SettingsService? get maybeSettingsService => _settingsService;

  static SettingsEngine? _settingsEngine;
  static SettingsEngine? get maybeSettingsEngine => _settingsEngine;

  // ── Domain Engine Getters ──────────────────────────────────────────

  static CareerEngine? _careerEngine;
  static CareerEngine? get maybeCareerEngine => _careerEngine;

  static dynamic_mission_engine.MissionEngine? _missionEngine;
  static dynamic_mission_engine.MissionEngine? get maybeMissionEngine =>
      _missionEngine;

  static PortfolioEngine? _portfolioEngine;
  static PortfolioEngine? get maybePortfolioEngine => _portfolioEngine;

  static KnowledgeEngine? _knowledgeEngine;
  static KnowledgeEngine? get maybeKnowledgeEngine => _knowledgeEngine;

  static MemoryEngine? _memoryEngine;
  static MemoryEngine? get maybeMemoryEngine => _memoryEngine;

  static AchievementEngine? _achievementEngine;
  static AchievementEngine? get maybeAchievementEngine => _achievementEngine;

  // ── AI Context Engine ──────────────────────────────────────────────

  static AIContextEngine? _aiContextEngine;
  static AIContextEngine? get maybeAIContextEngine => _aiContextEngine;

  // ── Prompt Builder ─────────────────────────────────────────────────

  static PromptTemplateRegistry? _promptTemplateRegistry;
  static PromptTemplateRegistry? get maybePromptTemplateRegistry =>
      _promptTemplateRegistry;

  static PromptBuilderService? _promptBuilderService;
  static PromptBuilderService? get maybePromptBuilderService =>
      _promptBuilderService;

  // ── AI Response Gateway ─────────────────────────────────────────────

  static SchemaRegistry? _schemaRegistry;
  static SchemaRegistry? get maybeSchemaRegistry => _schemaRegistry;

  static AIResponseGateway? _aiResponseGateway;
  static AIResponseGateway? get maybeAIResponseGateway =>
      _aiResponseGateway;

  // ── Learning Experience ──────────────────────────────────────────────

  static LearningExperienceRegistry? _learningExperienceRegistry;
  static LearningExperienceRegistry? get maybeLearningExperienceRegistry =>
      _learningExperienceRegistry;

  static LearningExperienceOrchestrator? _learningExperienceOrchestrator;
  static LearningExperienceOrchestrator? get maybeLearningExperienceOrchestrator =>
      _learningExperienceOrchestrator;

  static LearningExperienceGenerator? _learningExperienceGenerator;
  static LearningExperienceGenerator? get maybeLearningExperienceGenerator =>
      _learningExperienceGenerator;

  // ── Phoenix Assistant ────────────────────────────────────────────────

  static PhoenixAssistantService? _phoenixAssistantService;
  static PhoenixAssistantService? get maybePhoenixAssistantService =>
      _phoenixAssistantService;

    // ── Decision Intelligence Engine ───────────────────────────────────

  static DecisionEngine? _decisionIntelligenceEngine;
  static DecisionEngine? get maybeDecisionIntelligenceEngine =>
      _decisionIntelligenceEngine;

  // ── Growth Intelligence Engine ───────────────────────────────────

  static GrowthIntelligenceEngine? _growthIntelligenceEngine;
  static GrowthIntelligenceEngine? get maybeGrowthIntelligenceEngine =>
      _growthIntelligenceEngine;

  // ── Adaptive Learning Engine ───────────────────────────────────

  static AdaptiveLearningEngine? _adaptiveLearningEngine;
  static AdaptiveLearningEngine? get maybeAdaptiveLearningEngine =>
      _adaptiveLearningEngine;

  // ── Resume Intelligence Engine ─────────────────────────────────────

  static ResumeIntelligenceEngine? _resumeIntelligenceEngine;
  static ResumeIntelligenceEngine? get maybeResumeIntelligenceEngine =>
      _resumeIntelligenceEngine;

  // ── Review Engine ────────────────────────────────────────────────

  static ReviewEngine? _reviewEngine;
  static ReviewEngine? get maybeReviewEngine => _reviewEngine;

  // ── Notification Engine ───────────────────────────────────────────

  static NotificationEngine? _notificationEngine;
  static NotificationEngine? get maybeNotificationEngine =>
      _notificationEngine;

  // ── Interview Intelligence Engine ─────────────────────────────────

  static InterviewIntelligenceEngine? _interviewIntelligenceEngine;
  static InterviewIntelligenceEngine? get maybeInterviewIntelligenceEngine =>
      _interviewIntelligenceEngine;

  // ── Opportunity Intelligence Engine ───────────────────────────────

  static OpportunityIntelligenceEngine? _opportunityIntelligenceEngine;
  static OpportunityIntelligenceEngine? get maybeOpportunityIntelligenceEngine =>
      _opportunityIntelligenceEngine;

  // ── Decision Intelligence Orchestrator ─────────────────────────────

  static DecisionIntelligenceOrchestrator? _decisionIntelligenceOrchestrator;
  static DecisionIntelligenceOrchestrator? get maybeDecisionIntelligenceOrchestrator =>
      _decisionIntelligenceOrchestrator;

  // ── Firestore Sync Adapter ─────────────────────────────────────────

  static FirestoreSyncAdapter? _firestoreSyncAdapter;
  static FirestoreSyncAdapter? get maybeFirestoreSyncAdapter =>
      _firestoreSyncAdapter;

  // ── Cache Service ──────────────────────────────────────────────────

  static CacheService? _cacheService;
  static CacheService? get maybeCacheService => _cacheService;

  // ── Startup Performance Metrics ────────────────────────────────────

  /// Total startup time in milliseconds (set by main.dart after init).
  static int? startupMs;

  /// Bootstrap initialization time in milliseconds.
  static int? bootstrapMs;

  /// Firebase initialization time in milliseconds.
  static int? firebaseMs;

  // ── Content Generation Platform ──────────────────────────────────

  static ContentGeneratorCoordinator? _contentGeneratorCoordinator;
  static ContentGeneratorCoordinator? get maybeContentGeneratorCoordinator =>
      _contentGeneratorCoordinator;

  // ── Diagnostics ────────────────────────────────────────────────────

  static DiagnosticsService? _diagnosticsService;
  static DiagnosticsService? get maybeDiagnosticsService => _diagnosticsService;

  /// Initializes all app-wide services.
  ///
  /// Must be called once before [createApp].
  ///
  /// **Performance:** Independent initialization groups are parallelized
  /// with [Future.wait] to reduce total startup time.
  static Future<void> init() async {
    final storage = SharedPreferencesStorageService();
    await storage.init();
    _storageService = storage;

    // ── Phase 1: Core infrastructure (parallel) ───────────────────
    final authenticationService = AuthenticationService();
    await Future.wait([
      authenticationService.init(),
      _seedAcademyData(storage),
      _seedDecisionData(storage),
      _seedTimelineData(storage),
      _seedMemoryGraphData(storage),
      _seedKnowledgeData(storage),
    ]);
    _authenticationService = authenticationService;

    // ── Phase 2: User state + voice (parallel) ────────────────────
    final userStateRepo = UserStateRepository();
    final userStateEngine = UserStateEngine(repository: userStateRepo);
    final userStateService = UserStateService(engine: userStateEngine);

    final voiceProvider = MockSpeechProvider();
    final voiceService = VoiceService(provider: voiceProvider);

    await Future.wait([
      userStateService.init(),
      voiceService.initialize(),
    ]);
    _userStateService = userStateService;
    _voiceService = voiceService;

    // ── Phase 3: Services with UserState (parallel where possible) ─
    final repository = LocalRepository(storageService: storage);
    final aiMentorService = AIMentorService(repository: repository);

    final persistedPaths = repository.learningPaths;
    final academyService = AcademyService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      initialPaths: persistedPaths.isNotEmpty ? persistedPaths : null,
    );
    _academyService = academyService;

    // Decision, Timeline, Habit, Knowledge, MemoryGraph can init in parallel
    final decisionService = DecisionIntelligenceService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      storageService: storage,
    );
    final timelineService = TimelineService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      storageService: storage,
    );
    final memoryGraphService = MemoryGraphService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      storageService: storage,
    );
    final knowledgeService = KnowledgeService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      storageService: storage,
    );

    // Initialize services in parallel (they don't depend on each other)
    await Future.wait([
      decisionService.initFromStorage(),
      timelineService.initFromStorage(),
      memoryGraphService.initFromStorage(),
      knowledgeService.initFromStorage(),
    ]);

    // HabitService depends on timelineService, init after parallel block
    final habitService = HabitService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      timelineService: timelineService,
      storageService: storage,
    );
    await habitService.initFromStorage();
    await _seedHabitData(storage, userStateService);

    _decisionService = decisionService;
    _timelineService = timelineService;
    _habitService = habitService;
    _memoryGraphService = memoryGraphService;
    _knowledgeService = knowledgeService;

    // ── Phase 4: Intelligence Engines (parallel where possible) ────

    // Cache Service (in-memory, no dependencies)
    final cacheService = CacheService(maxEntries: 500, purgeIntervalSeconds: 300);
    cacheService.startPeriodicPurge();
    _cacheService = cacheService;

    final identityRepo = const LocalIdentityRepository();
    final identityEngine = IdentityEngine(
      repository: identityRepo,
      userStateService: userStateService,
      academyService: academyService,
      habitService: habitService,
      knowledgeService: knowledgeService,
    );

    final growthRepo = const LocalGrowthRepository();
    final growthEngine = GrowthIndexEngine(
      repository: growthRepo,
      userStateService: userStateService,
      academyService: academyService,
      missionCalculator: MissionCalculator(userStateService: userStateService),
      habitsCalculator: HabitsCalculator(habitService: habitService),
      cacheService: cacheService,
    );

    // Identity and Growth are independent → parallel init
    await Future.wait([
      identityEngine.init(),
      growthEngine.init(),
    ]);
    _identityEngine = identityEngine;
    _growthEngine = growthEngine;

    // Mission Intelligence depends on Identity + Growth
    final missionIntelligenceRepo = const LocalMissionIntelligenceRepository();
    final missionIntelligenceEngine = MissionIntelligenceEngine(
      repository: missionIntelligenceRepo,
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      userStateService: userStateService,
    );
    await missionIntelligenceEngine.init();
    _missionIntelligenceEngine = missionIntelligenceEngine;

    // Recommendation depends on Identity + Growth + Mission
    final recommendationRepo = const LocalRecommendationRepository();
    final recommendationEngine = RecommendationEngine(
      repository: recommendationRepo,
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      missionEngine: missionIntelligenceEngine,
      userStateService: userStateService,
      cacheService: cacheService,
    );
    await recommendationEngine.init();
    _recommendationEngine = recommendationEngine;

    // Daily Brief and Continue Journey can init after recommendation
    DailyBriefEngine dailyBriefEngine;
    dailyBriefEngine = DailyBriefEngine(
      repository: const LocalDailyBriefRepository(),
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      missionEngine: missionIntelligenceEngine,
      recommendationEngine: recommendationEngine,
      cacheService: cacheService,
    );
    await dailyBriefEngine.init();
    _dailyBriefEngine = dailyBriefEngine;

    // Continue Journey Engine
    final journeyRepo = const LocalJourneyRepository();
    final continueJourneyEngine = ContinueJourneyEngine(
      repository: journeyRepo,
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      missionEngine: missionIntelligenceEngine,
      recommendationEngine: recommendationEngine,
      dailyBriefEngine: dailyBriefEngine,
      cacheService: cacheService,
    );
    await continueJourneyEngine.init();
    _continueJourneyEngine = continueJourneyEngine;

    // ── Domain Engine Initialization ─────────────────────────────────

    // Career Engine
    final careerService = CareerService(repository: repository);
    final careerEngine = CareerEngine(
      repository: const LocalCareerRepository(),
      careerService: careerService,
      cacheService: cacheService,
    );
    await careerEngine.init();
    _careerEngine = careerEngine;

    // Portfolio Engine
    final portfolioService = PortfolioService(repository: repository);
    final portfolioEngine = PortfolioEngine(
      repository: const LocalPortfolioRepository(),
      portfolioService: portfolioService,
      cacheService: cacheService,
    );
    await portfolioEngine.init();
    _portfolioEngine = portfolioEngine;

    // Knowledge Engine
    final knowledgeEngine = KnowledgeEngine(
      knowledgeService: knowledgeService,
      cacheService: cacheService,
    );
    await knowledgeEngine.init();
    _knowledgeEngine = knowledgeEngine;

    // Memory Engine
    final memoryRepo = const LocalMemoryRepository();
    final memoryEngine = MemoryEngine(
      repository: memoryRepo,
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      missionEngine: missionIntelligenceEngine,
      cacheService: cacheService,
    );
    await memoryEngine.init();
    _memoryEngine = memoryEngine;

    // Achievement Engine
    final progressService = ProgressService(
      repository: repository,
      userStateService: userStateService,
    );
    final achievementEngine = AchievementEngine(
      repository: const LocalAchievementRepository(),
      progressService: progressService,
      userStateService: userStateService,
      cacheService: cacheService,
    );
    await achievementEngine.init();
    _achievementEngine = achievementEngine;

    // ── Mission Engine ────────────────────────────────────────────────
    // MissionGenerator needs several services that use the LocalRepository
    // Note: portfolioService is reused from the Portfolio Engine block above
    final knowledgeDnaService = KnowledgeDNAService(repository: repository);
    final resumeService = ResumeService(repository: repository);
    final interviewService = InterviewService(repository: repository);
    final opportunityService = OpportunityService(repository: repository);
    final recommendationService = RecommendationService(repository: repository);

    final missionScheduler = MissionScheduler();
    final missionPrioritizer = MissionPrioritizer(
      growthEngine: growthEngine,
    );
    final missionGenerator = MissionGenerator(
      knowledgeDnaService: knowledgeDnaService,
      portfolioService: portfolioService,
      resumeService: resumeService,
      interviewService: interviewService,
      opportunityService: opportunityService,
      recommendationService: recommendationService,
      growthEngine: growthEngine,
    );
    final dynamicMissionEngine = dynamic_mission_engine.MissionEngine(
      generator: missionGenerator,
      prioritizer: missionPrioritizer,
      scheduler: missionScheduler,
    );
    _missionEngine = dynamicMissionEngine;

    // ── AI & Settings Infrastructure ─────────────────────────────────

    final providerRegistry = AIProviderRegistry();
    providerRegistry.registerAll([
      const MockGeminiAdapter(),
      const MockDeepSeekAdapter(),
      const MockOpenAIAdapter(),
      const MockClaudeAdapter(),
      const MockOllamaAdapter(),
      const MockOpenRouterAdapter(),
    ]);
    final aiCapabilityRouter = AICapabilityRouter(
      registry: providerRegistry,
      config: const AIRouterConfig(),
    );
    _aiCapabilityRouter = aiCapabilityRouter;

    final providerConfigRepo = ProviderConfigurationRepository();
    final secureStorage = FlutterSecureStorageService();
    // One-time migration of existing API keys from SharedPreferences
    await FlutterSecureStorageService.migrateFromSharedPreferences();
    final providerConfigService = ProviderConfigurationService(
      repository: providerConfigRepo,
      secureStorage: secureStorage,
    );
    await providerConfigService.initializeDefaults([
      const ProviderConfigDefaults(
        providerId: 'gemini',
        providerName: 'Gemini',
        defaultModel: 'gemini-pro',
        supportsOffline: true,
        fallbackPriority: 2,
      ),
      const ProviderConfigDefaults(
        providerId: 'deepseek',
        providerName: 'DeepSeek',
        defaultModel: 'deepseek-coder',
        supportsOffline: true,
        fallbackPriority: 3,
      ),
      const ProviderConfigDefaults(
        providerId: 'openAI',
        providerName: 'OpenAI',
        isDefault: true,
        defaultModel: 'gpt-4o',
        supportsOffline: false,
        fallbackPriority: 0,
      ),
      const ProviderConfigDefaults(
        providerId: 'claude',
        providerName: 'Claude',
        defaultModel: 'claude-3-opus',
        supportsOffline: false,
        fallbackPriority: 1,
      ),
      const ProviderConfigDefaults(
        providerId: 'ollama',
        providerName: 'Ollama',
        defaultModel: 'llama3.2',
        supportsOffline: true,
        fallbackPriority: 4,
      ),
      const ProviderConfigDefaults(
        providerId: 'openRouter',
        providerName: 'OpenRouter',
        defaultModel: null,
        supportsOffline: true,
        fallbackPriority: 5,
      ),
    ]);
    _providerConfigService = providerConfigService;

    // Register real Gemini adapter (production — requires API key)
    // Mock adapter remains registered as fallback for testing
    final geminiApiKey = await providerConfigService.readApiKey('gemini');
    final geminiAdapter = GeminiAdapter(
      apiKey: geminiApiKey,
    );
    providerRegistry.register(geminiAdapter);

    final connectionTestService = ConnectionTestService();
    _connectionTestService = connectionTestService;

    final healthMonitor = HealthMonitor();
    healthMonitor.initialize([
      'gemini', 'deepseek', 'openAI', 'claude', 'ollama', 'openRouter',
    ]);
    _healthMonitor = healthMonitor;

    // Settings Platform
    final settingsRepo = SettingsRepository();
    final settingsService = SettingsService(repository: settingsRepo);
    _settingsService = settingsService;

    final settingsEngine = SettingsEngine(settingsService: settingsService);
    await settingsEngine.init();
    _settingsEngine = settingsEngine;

    // ── Initialize AI Context Engine ────────────────────────────────
    // Must be initialized after all other engines are ready
    final aiContextEngine = AIContextEngine(
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      careerEngine: careerEngine,
      portfolioEngine: portfolioEngine,
      knowledgeEngine: knowledgeEngine,
      missionEngine: missionIntelligenceEngine,
      journeyEngine: continueJourneyEngine,
      memoryEngine: memoryEngine,
      recommendationEngine: recommendationEngine,
      achievementEngine: achievementEngine,
      dailyBriefEngine: dailyBriefEngine,
      settingsEngine: settingsEngine,
    );
    await aiContextEngine.init();
    _aiContextEngine = aiContextEngine;

    // ── Initialize Prompt Builder ────────────────────────────────────
    // Must be initialized after AI Context Engine is ready
    final promptTemplateRegistry = PromptTemplateRegistry();
    promptTemplateRegistry.registerDefaults();
    _promptTemplateRegistry = promptTemplateRegistry;

    final promptBuilderService = PromptBuilderService(
      templateRegistry: promptTemplateRegistry,
    );
    _promptBuilderService = promptBuilderService;

    // ── Initialize AI Response Gateway ───────────────────────────────
    final schemaRegistry = SchemaRegistry();
    schemaRegistry.registerDefaults();
    _schemaRegistry = schemaRegistry;

    final aiResponseGateway = AIResponseGateway(
      schemaRegistry: schemaRegistry,
    );
    _aiResponseGateway = aiResponseGateway;

    // ── Initialize Learning Experience Orchestrator ────────────────────
    final learningExperienceRegistry = LearningExperienceRegistry();
    _learningExperienceRegistry = learningExperienceRegistry;

    final learningExperienceOrchestrator = LearningExperienceOrchestrator(
      missionEngine: dynamicMissionEngine,
      portfolioEngine: portfolioEngine,
      knowledgeEngine: knowledgeEngine,
      careerEngine: careerEngine,
      memoryEngine: memoryEngine,
      dailyBriefEngine: dailyBriefEngine,
      achievementEngine: achievementEngine,
    );
    _learningExperienceOrchestrator = learningExperienceOrchestrator;

    // ── Initialize Learning Experience Generator ─────────────────────
    // Connects the full AI pipeline: Context → Prompt → Router → Gateway → Orchestrator
    final learningExperienceGenerator = LearningExperienceGenerator(
      aiContextEngine: aiContextEngine,
      promptBuilderService: promptBuilderService,
      aiCapabilityRouter: aiCapabilityRouter,
      aiResponseGateway: aiResponseGateway,
      orchestrator: learningExperienceOrchestrator,
      registry: learningExperienceRegistry,
    );
    _learningExperienceGenerator = learningExperienceGenerator;

    // ── Initialize Decision Intelligence Engine ────────────────────────
    // Must be initialized after all domain engines are ready.
    // This is the reasoning layer — it evaluates all context and produces
    // the unified DecisionSnapshot consumed by Dashboard, Assistant, and Daily Brief.
    final decisionIntelligenceEngine = DecisionEngine(
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      missionEngine: missionIntelligenceEngine,
      careerEngine: careerEngine,
      portfolioEngine: portfolioEngine,
      knowledgeEngine: knowledgeEngine,
      achievementEngine: achievementEngine,
      memoryEngine: memoryEngine,
      cacheService: cacheService,
    );
    await decisionIntelligenceEngine.init();
    _decisionIntelligenceEngine = decisionIntelligenceEngine;

    // Attach DecisionEngine to Daily Brief Engine for enriched planning
    await dailyBriefEngine.attachDecisionEngine(decisionIntelligenceEngine);

    // ── Initialize Adaptive Learning Engine ────────────────────────────
    // Must be initialized after all domain engines are ready.
    final adaptiveLearningEngine = AdaptiveLearningEngine(
      growthEngine: growthEngine,
      missionEngine: missionIntelligenceEngine,
      knowledgeEngine: knowledgeEngine,
      achievementEngine: achievementEngine,
    );
    await adaptiveLearningEngine.init();
    _adaptiveLearningEngine = adaptiveLearningEngine;

    // ── Initialize Growth Intelligence Engine ──────────────────────────
    // Must be initialized after all domain engines + DecisionEngine are ready.
    final growthIntelligenceEngine = GrowthIntelligenceEngine(
      growthEngine: growthEngine,
      missionEngine: missionIntelligenceEngine,
      careerEngine: careerEngine,
      portfolioEngine: portfolioEngine,
      decisionEngine: decisionIntelligenceEngine,
    );
    await growthIntelligenceEngine.init();
    _growthIntelligenceEngine = growthIntelligenceEngine;

    // ── Initialize Resume Intelligence Engine ─────────────────────────
    final resumeIntelligenceEngine = ResumeIntelligenceEngine(
      knowledgeEngine: knowledgeEngine,
      portfolioEngine: portfolioEngine,
      careerEngine: careerEngine,
      achievementEngine: achievementEngine,
      cacheService: cacheService,
    );
    await resumeIntelligenceEngine.init();
    _resumeIntelligenceEngine = resumeIntelligenceEngine;

    // ── Initialize Interview Intelligence Engine ─────────────────────
    // Must be initialized after Career, Portfolio, Resume, Growth, Identity.
    // Uses existing InterviewService plus engine dependencies.
    final interviewIntelligenceEngine = InterviewIntelligenceEngine(
      interviewService: interviewService,
      careerEngine: careerEngine,
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      portfolioEngine: portfolioEngine,
      resumeEngine: resumeIntelligenceEngine,
      repository: LocalInterviewIntelligenceRepository(),
      cacheService: cacheService,
    );
    await interviewIntelligenceEngine.init();
    _interviewIntelligenceEngine = interviewIntelligenceEngine;

    // ── Initialize Opportunity Intelligence Engine ──────────────────
    // Must be initialized after Career, Portfolio, Resume, Interview,
    // Identity, Growth. Uses existing OpportunityService plus engine deps.
    final opportunityIntelligenceEngine = OpportunityIntelligenceEngine(
      opportunityService: opportunityService,
      careerEngine: careerEngine,
      portfolioEngine: portfolioEngine,
      resumeEngine: resumeIntelligenceEngine,
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      repository: LocalOpportunityIntelligenceRepository(),
      cacheService: cacheService,
    );
    await opportunityIntelligenceEngine.init();
    _opportunityIntelligenceEngine = opportunityIntelligenceEngine;

    // ── Initialize Knowledge Relationship Service ────────────────────
    // Analyzes knowledge graphs to enrich AI answers with relationship data.
    final knowledgeRelationshipService = KnowledgeRelationshipService(
      growthIndexEngine: growthEngine,
      identityEngine: identityEngine,
      portfolioEngine: portfolioEngine,
    );

    // ── Initialize Phoenix Assistant Service ──────────────────────────
    // Must be initialized after AI Context Engine, Prompt Builder,
    // AI Capability Router, AI Response Gateway, DecisionEngine,
    // GrowthIntelligenceEngine, ResumeIntelligenceEngine, and
    // KnowledgeRelationshipService are ready.
    final phoenixAssistantService = PhoenixAssistantService(
      aiContextEngine: aiContextEngine,
      promptBuilderService: promptBuilderService,
      aiCapabilityRouter: aiCapabilityRouter,
      aiResponseGateway: aiResponseGateway,
      knowledgeRelationshipService: knowledgeRelationshipService,
      decisionEngine: decisionIntelligenceEngine,
      growthIntelligenceEngine: growthIntelligenceEngine,
      adaptiveLearningEngine: adaptiveLearningEngine,
      resumeIntelligenceEngine: resumeIntelligenceEngine,
    );
    _phoenixAssistantService = phoenixAssistantService;

    // ── Initialize Review Engine ────────────────────────────────────
    final reviewEngine = ReviewEngine(
      repository: LocalReviewRepository(),
      growthEngine: growthEngine,
      careerEngine: careerEngine,
      portfolioEngine: portfolioEngine,
      resumeEngine: resumeIntelligenceEngine,
      interviewEngine: interviewIntelligenceEngine,
      opportunityEngine: opportunityIntelligenceEngine,
      cacheService: cacheService,
    );
    await reviewEngine.init();
    _reviewEngine = reviewEngine;

    // ── Initialize Notification Engine ───────────────────────────────
    final notificationEngine = NotificationEngine(
      identityEngine: identityEngine,
      careerEngine: careerEngine,
      missionEngine: missionIntelligenceEngine,
      achievementEngine: achievementEngine,
      portfolioEngine: portfolioEngine,
      decisionEngine: decisionIntelligenceEngine,
      recommendationEngine: recommendationEngine,
      dailyBriefEngine: dailyBriefEngine,
      memoryEngine: memoryEngine,
      growthEngine: growthIntelligenceEngine,
      interviewEngine: interviewIntelligenceEngine,
      opportunityEngine: opportunityIntelligenceEngine,
    );
    await notificationEngine.init();
    _notificationEngine = notificationEngine;

    // ── Initialize Decision Intelligence Orchestrator ────────────────
    // Must be initialized after ALL intelligence engines are ready.
    // This is the final decision layer that evaluates all engine snapshots
    // and selects the Next Best Action for the user.
    final decisionIntelligenceOrchestrator = DecisionIntelligenceOrchestrator(
      careerEngine: careerEngine,
      portfolioEngine: portfolioEngine,
      resumeEngine: resumeIntelligenceEngine,
      interviewEngine: interviewIntelligenceEngine,
      opportunityEngine: opportunityIntelligenceEngine,
      missionEngine: missionIntelligenceEngine,
      growthEngine: growthEngine,
      identityEngine: identityEngine,
      recommendationEngine: recommendationEngine,
      memoryEngine: memoryEngine,
    );
    await decisionIntelligenceOrchestrator.init();
    _decisionIntelligenceOrchestrator = decisionIntelligenceOrchestrator;

    // ── Initialize Firestore Sync Adapter ────────────────────────────
    // Pass all engine references so the adapter can serialize actual snapshot
    // data to Firestore (instead of just metadata markers).
    final firestoreSyncAdapter = FirestoreSyncAdapter(
      identityEngine: identityEngine,
      careerEngine: careerEngine,
      portfolioEngine: portfolioEngine,
      resumeEngine: resumeIntelligenceEngine,
      interviewEngine: interviewIntelligenceEngine,
      opportunityEngine: opportunityIntelligenceEngine,
      growthEngine: growthEngine,
      knowledgeEngine: knowledgeEngine,
      memoryEngine: memoryEngine,
      achievementEngine: achievementEngine,
      journeyEngine: continueJourneyEngine,
      reviewEngine: reviewEngine,
    );
    firestoreSyncAdapter.startBackgroundSync();
    _firestoreSyncAdapter = firestoreSyncAdapter;

    // ── Initialize Diagnostics Service ────────────────────────────────
    // Register all engines for health monitoring and diagnostics export.
    // Startup timing data is set later by main.dart via static fields.
    final diagnosticsService = DiagnosticsService();
    diagnosticsService.registerEngines(
      identityEngine: identityEngine,
      growthEngine: growthEngine,
      missionEngine: missionIntelligenceEngine,
      recommendationEngine: recommendationEngine,
      dailyBriefEngine: dailyBriefEngine,
      continueJourneyEngine: continueJourneyEngine,
      memoryEngine: memoryEngine,
      aiRouter: aiCapabilityRouter,
      careerEngine: careerEngine,
      portfolioEngine: portfolioEngine,
      knowledgeEngine: knowledgeEngine,
      achievementEngine: achievementEngine,
      settingsEngine: settingsEngine,
      providerConfigService: providerConfigService,
      healthMonitor: healthMonitor,
      interviewEngine: interviewIntelligenceEngine,
      opportunityEngine: opportunityIntelligenceEngine,
      reviewEngine: reviewEngine,
      syncAdapter: firestoreSyncAdapter,
      notificationEngine: notificationEngine,
      decisionEngine: decisionIntelligenceEngine,
      decisionOrchestrator: decisionIntelligenceOrchestrator,
      growthIntelligenceEngine: growthIntelligenceEngine,
      adaptiveLearningEngine: adaptiveLearningEngine,
      resumeEngine: resumeIntelligenceEngine,
      aiContextEngine: aiContextEngine,
      promptBuilderService: promptBuilderService,
      aiResponseGateway: aiResponseGateway,
      cacheService: cacheService,
    );

    // ── Initialize Content Generation Coordinator ────────────────
    // Must be initialized after all AI pipeline components are ready.
    final contentRepository = ContentRepository();
    final contentGeneratorCoordinator = ContentGeneratorCoordinator(
      aiContextEngine: aiContextEngine,
      promptBuilderService: promptBuilderService,
      aiCapabilityRouter: aiCapabilityRouter,
      aiResponseGateway: aiResponseGateway,
      repository: contentRepository,
    );
    _contentGeneratorCoordinator = contentGeneratorCoordinator;

    PhoenixLogger.shared.info(
      'Content Generator Coordinator initialized',
      category: LogCategory.engine,
      source: 'AppBootstrap',
    );

    // Seed graphs in parallel
    await Future.wait([
      memoryGraphService.seedFromPlatform().catchError((_) {
        PhoenixLogger.shared.warning(
          'Memory Graph seeding failed (non-fatal)',
          category: LogCategory.engine,
          source: 'AppBootstrap',
        );
      }),
      knowledgeService.seedFromPlatform().catchError((_) {
        PhoenixLogger.shared.warning(
          'Knowledge seeding failed (non-fatal)',
          category: LogCategory.engine,
          source: 'AppBootstrap',
        );
      }),
    ]);
  }

  static Future<void> _seedKnowledgeData(StorageService storage) async {
    final hasData = storage.readKnowledgeSnapshot() != null;
    if (!hasData) {
      await storage.saveKnowledgeSnapshot(json.encode(const <String, dynamic>{}));
    }
  }

  static Future<void> _seedMemoryGraphData(StorageService storage) async {
    final hasData = storage.readMemoryGraph() != null;
    if (!hasData) {
      await storage.saveMemoryGraph(json.encode(const <String, dynamic>{}));
    }
  }

  static Future<void> _seedDecisionData(StorageService storage) async {
    final hasData = storage.readDecisionHistory() != null;
    if (!hasData) {
      await storage.saveDecisionHistory(json.encode([]));
    }
  }

  static Future<void> _seedTimelineData(StorageService storage) async {
    final hasEvents = storage.readTimelineEvents() != null;
    final hasMilestones = storage.readMilestones() != null;

    if (!hasEvents) {
      await storage.saveTimelineEvents(json.encode([]));
    }
    if (!hasMilestones) {
      await storage.saveMilestones(json.encode([]));
    }
  }

  static Future<void> _seedHabitData(
    StorageService storage,
    UserStateService userStateService,
  ) async {
    final hasHabits = storage.readHabits() != null;
    final hasEntries = storage.readHabitEntries() != null;

    if (!hasHabits) {
      final state = userStateService.currentState;
      await storage.saveHabits(
        json.encode(state.habits.map((h) => h.toMap()).toList()),
      );
    }
    if (!hasEntries) {
      final state = userStateService.currentState;
      await storage.saveHabitEntries(
        json.encode(state.habitEntries.map((e) => e.toMap()).toList()),
      );
    }
  }

  static Future<void> _seedAcademyData(StorageService storage) async {
    final hasPaths = storage.readLearningPaths() != null;
    final hasSummaries = storage.readAcademySummaries() != null;
    final hasFeatured = storage.readFeaturedAcademy() != null;

    if (!hasPaths) {
      final registry = LearningPathRegistry();
      final pathsJson = json.encode(
        registry.allPaths.map((p) => p.toMap()).toList(),
      );
      await storage.saveLearningPaths(pathsJson);
    }

    if (!hasSummaries) {
      final sampleData = SampleDataService();
      final summariesJson = json.encode(
        sampleData.academySummaries.map((a) => a.toMap()).toList(),
      );
      await storage.saveAcademySummaries(summariesJson);
    }

    if (!hasFeatured) {
      final sampleData = SampleDataService();
      await storage.saveFeaturedAcademy(sampleData.featuredAcademy.toJson());
    }
  }

  /// Creates the root [PhoenixApp] widget with all required configuration.
  static Widget createApp() {
    return const PhoenixApp();
  }
}

/// The root widget of the Phoenix Platform application.
class PhoenixApp extends StatelessWidget {
  const PhoenixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppConfig.initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
