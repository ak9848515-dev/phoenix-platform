import 'dart:convert';

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../features/academy/engine/learning_path_registry.dart';
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
import '../services/sample_data_service.dart';
import '../theme/theme.dart';
import 'local_repository.dart';
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

    // Seed academy data on first launch if not yet persisted
    await _seedAcademyData(storage);

    // Build the repository (LocalRepository with storage-backed academy data)
    final repository = LocalRepository(storageService: storage);
    final aiMentorService = AIMentorService(repository: repository);

    // Load persisted learning paths
    final persistedPaths = repository.learningPaths;
    final academyService = AcademyService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      initialPaths: persistedPaths.isNotEmpty ? persistedPaths : null,
    );
    _academyService = academyService;

    final decisionService = DecisionIntelligenceService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      storageService: storage,
    );
    await decisionService.initFromStorage();
    // Seed decision data on first launch if not yet persisted
    await _seedDecisionData(storage);
    _decisionService = decisionService;

    // Seed timeline data on first launch if not yet persisted
    await _seedTimelineData(storage);

    final timelineService = TimelineService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      storageService: storage,
    );
    await timelineService.initFromStorage();
    _timelineService = timelineService;

    final habitService = HabitService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      timelineService: timelineService,
      storageService: storage,
    );
    // Load persisted habit data into UserState on first launch
    await habitService.initFromStorage();
    // If UserState has habits but storage doesn't (upgrade from v1),
    // persist them to storage
    await _seedHabitData(storage, userStateService);
    _habitService = habitService;

    // Seed memory graph data on first launch if not yet persisted
    await _seedMemoryGraphData(storage);

    final memoryGraphService = MemoryGraphService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      storageService: storage,
    );
    // Load persisted graph data into UserState on first launch
    await memoryGraphService.initFromStorage();
    _memoryGraphService = memoryGraphService;

    // Build the Knowledge Service
    final knowledgeService = KnowledgeService(
      userStateService: userStateService,
      aiMentorService: aiMentorService,
      storageService: storage,
    );
    await knowledgeService.initFromStorage();
    // Seed knowledge data on first launch if not yet persisted
    await _seedKnowledgeData(storage);
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

  /// Seeds knowledge snapshot data into storage on first launch.
  ///
  /// If storage is empty but UserState already has a knowledge snapshot
  /// (upgrade from v1 where UserState was the sole persistence layer),
  /// writes current snapshot to the new storage key. If both are empty
  /// or the snapshot is empty, writes an empty map so LocalRepository
  /// knows the domain is seeded.
  static Future<void> _seedKnowledgeData(StorageService storage) async {
    final hasData = storage.readKnowledgeSnapshot() != null;
    if (!hasData) {
      await storage.saveKnowledgeSnapshot(json.encode(const <String, dynamic>{}));
    }
  }

  /// Seeds memory graph data into storage on first launch.
  ///
  /// Persists an empty graph map so that LocalRepository knows the data
  /// domain is seeded. On upgrade from v1 where UserState was the sole
  /// persistence layer, [MemoryGraphService.initFromStorage] handles
  /// writing existing UserState data to storage.
  static Future<void> _seedMemoryGraphData(StorageService storage) async {
    final hasData = storage.readMemoryGraph() != null;
    if (!hasData) {
      await storage.saveMemoryGraph(json.encode(const <String, dynamic>{}));
    }
  }

  /// Seeds decision history data into storage on first launch.
  ///
  /// If storage is empty but UserState already has decision history
  /// (upgrade from v1 where UserState was the sole persistence layer),
  /// writes current analyses to the new storage key. If both are
  /// empty, writes empty array so LocalRepository knows the domain
  /// is seeded.
  static Future<void> _seedDecisionData(StorageService storage) async {
    final hasData = storage.readDecisionHistory() != null;
    if (!hasData) {
      await storage.saveDecisionHistory(json.encode([]));
    }
  }

  /// Seeds timeline data into storage on first launch.
  ///
  /// On first launch, persists empty arrays so that LocalRepository
  /// knows the data domain is seeded. On subsequent launches,
  /// existing persisted data is preserved. Timeline events are
  /// computed dynamically from UserState data — the persisted cache
  /// is populated on first event access after init.
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

  /// Seeds habit data into storage on first launch.
  ///
  /// If storage is empty but UserState already has habits (upgrade from
  /// v1 where UserState was the sole persistence layer), writes current
  /// habits and entries to the new storage keys so that LocalRepository
  /// can serve them on subsequent launches. If both are empty, writes
  /// empty arrays so LocalRepository knows the data domain is seeded.
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

  /// Seeds academy data into storage on first launch.
  ///
  /// Reads learning path content from [LearningPathRegistry] and legacy
  /// academy summaries from [SampleDataService], then persists them so
  /// [LocalRepository] can serve them on subsequent launches.
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
