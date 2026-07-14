import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../core/sample_repository.dart';
import '../features/academy/services/academy_service.dart';
import '../features/ai/services/ai_mentor_service.dart';
import '../features/decision/services/decision_intelligence_service.dart';
import '../features/habit/services/habit_service.dart';
import '../features/memory_graph/services/memory_graph_service.dart';
import '../features/personal_knowledge/services/knowledge_service.dart';
import '../features/timeline/services/timeline_service.dart';
import '../features/user_state/engine/user_state_engine.dart';
import '../features/user_state/repository/user_state_repository.dart';
import '../features/user_state/services/user_state_service.dart';
import '../features/voice/providers/mock_speech_provider.dart';
import '../features/voice/services/voice_service.dart';
import '../routes/app_router.dart';
import '../theme/theme.dart';
import 'storage_service.dart';

/// Application bootstrap and startup orchestration.
///
/// Separates startup responsibilities into clearly named methods
/// so the application entry point remains focused and testable.
///
/// Current responsibilities:
///   - Application widget creation
///   - Storage service lifecycle
///
/// Future responsibilities may include:
///   - Service initialization
///   - Persistence setup
///   - Logging configuration
///   - Environment detection
class AppBootstrap {
  AppBootstrap._();

  /// The application-wide [StorageService] instance.
  ///
  /// Initialized once during [init] and accessible throughout the app.
  static StorageService? _storageService;

  /// Returns the initialized [StorageService] instance.
  ///
  /// Throws if [init] has not been called yet.
  static StorageService get storageService {
    assert(
      _storageService != null,
      'StorageService not initialized. Call AppBootstrap.init() first.',
    );
    return _storageService!;
  }

  /// The application-wide [UserStateService] instance.
  ///
  /// Initialized once during [init] and accessible throughout the app.
  /// All feature modules read and write user state through this service.
  static UserStateService? _userStateService;

  /// Returns the initialized [UserStateService] instance.
  ///
  /// Throws if [init] has not been called yet.
  static UserStateService get userStateService {
    assert(
      _userStateService != null,
      'UserStateService not initialized. Call AppBootstrap.init() first.',
    );
    return _userStateService!;
  }

  /// Returns the [UserStateService] instance or `null` if not initialized.
  ///
  /// Safe for use in screens and widgets that may render before
  /// [init] completes.
  static UserStateService? get maybeUserStateService => _userStateService;

  /// The application-wide [VoiceService] instance.
  ///
  /// Initialized once during [init] and accessible throughout the app.
  /// All screens use this service through [VoiceButton] in the Phoenix Shell.
  static VoiceService? _voiceService;

  /// Returns the [VoiceService] instance or `null` if not initialized.
  ///
  /// Safe for use in screens and widgets that may render before
  /// [init] completes.
  static VoiceService? get maybeVoiceService => _voiceService;

  /// The application-wide [AcademyService] instance.
  ///
  /// Initialized once during [init] and accessible throughout the app.
  /// All academy screens use this service.
  static AcademyService? _academyService;

  /// Returns the [AcademyService] instance or `null` if not initialized.
  static AcademyService? get maybeAcademyService => _academyService;

  /// The application-wide [DecisionIntelligenceService] instance.
  static DecisionIntelligenceService? _decisionService;

  /// Returns the [DecisionIntelligenceService] instance or `null`.
  static DecisionIntelligenceService? get maybeDecisionService =>
      _decisionService;

  /// The application-wide [TimelineService] instance.
  static TimelineService? _timelineService;

  /// Returns the [TimelineService] instance or `null` if not initialized.
  static TimelineService? get maybeTimelineService => _timelineService;

  /// The application-wide [HabitService] instance.
  static HabitService? _habitService;

  /// Returns the [HabitService] instance or `null` if not initialized.
  static HabitService? get maybeHabitService => _habitService;

  /// The application-wide [MemoryGraphService] instance.
  static MemoryGraphService? _memoryGraphService;

  /// Returns the [MemoryGraphService] instance or `null` if not initialized.
  static MemoryGraphService? get maybeMemoryGraphService => _memoryGraphService;

  /// The application-wide [KnowledgeService] instance.
  static KnowledgeService? _knowledgeService;

  /// Returns the [KnowledgeService] instance or `null` if not initialized.
  static KnowledgeService? get maybeKnowledgeService => _knowledgeService;

  /// Initializes all app-wide services.
  ///
  /// Must be called once before [createApp]. Currently initializes:
  ///   - [SharedPreferencesStorageService]
  ///   - [UserStateService]
  ///   - [VoiceService]
  static Future<void> init() async {
    final storage = SharedPreferencesStorageService();
    await storage.init();
    _storageService = storage;

    final userStateRepo = UserStateRepository();
    final userStateEngine = UserStateEngine(repository: userStateRepo);
    final userStateService = UserStateService(engine: userStateEngine);
    await userStateService.init();
    _userStateService = userStateService;

    final voiceProvider = MockSpeechProvider();
    final voiceService = VoiceService(provider: voiceProvider);
    await voiceService.initialize();
    _voiceService = voiceService;

    final repository = const SampleRepository();
    final aiMentorService = AIMentorService(repository: repository);
    final academyService = AcademyService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
    );
    _academyService = academyService;

    final decisionService = DecisionIntelligenceService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
    );
    _decisionService = decisionService;

    final timelineService = TimelineService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
    );
    _timelineService = timelineService;

    final habitService = HabitService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      timelineService: timelineService,
    );
    _habitService = habitService;

    final memoryGraphService = MemoryGraphService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
    );
    _memoryGraphService = memoryGraphService;

    // Build the Knowledge Service
    final knowledgeService = KnowledgeService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
    );
    _knowledgeService = knowledgeService;

    // Seed graphs in parallel (non-fatal if either fails)
    await Future.wait([
      memoryGraphService.seedFromPlatform().catchError((_) {
        debugPrint('Memory Graph seeding failed (non-fatal)');
      }),
      knowledgeService.seedFromPlatform().catchError((_) {
        debugPrint('Knowledge seeding failed (non-fatal)');
      }),
    ]);
  }

  /// Creates the root [PhoenixApp] widget with all required configuration.
  ///
  /// This is the single entry point for building the application tree.
  /// All app-wide dependencies must be initialized before this call.
  static Widget createApp() {
    return const PhoenixApp();
  }
}

/// The root widget of the Phoenix Platform application.
///
/// Owns the MaterialApp configuration including theme,
/// routing, and display settings.
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
