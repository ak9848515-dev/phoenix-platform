import 'package:flutter/widgets.dart';

import '../../features/knowledge_dna/knowledge_dna_engine.dart';
import '../../features/knowledge_dna/knowledge_dna_service.dart';
import '../../features/mission_engine/mission_progress.dart';
import '../../features/mission_engine/mission_service.dart';
import '../../features/persistence/local_mission_repository.dart';
import '../../features/persistence/local_progress_repository.dart';
import '../../features/persistence/local_settings_repository.dart';
import '../../features/persistence/local_storage_service.dart';
import '../../features/persistence/settings_repository.dart';
import '../../features/progress_engine/progress_service.dart';
import '../../features/progress_engine/progress_summary.dart';
import '../../services/sample_data_service.dart';
import 'bootstrap_result.dart';

class PhoenixBootstrap {
  const PhoenixBootstrap._();

  static Future<BootstrapResult> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    const storageService = LocalStorageService();
    await _warmUpStorage(storageService);

    const seedSource = SampleDataService();
    final missionRepository = LocalMissionRepository(storageService: storageService);
    final progressRepository = LocalProgressRepository(storageService: storageService);
    final settingsRepository = LocalSettingsRepository(storageService: storageService);

    final missionService = MissionService(
      seedSource: seedSource,
      missionRepository: missionRepository,
    );
    final progressService = ProgressService(
      seedSource: seedSource,
      progressRepository: progressRepository,
    );
    final knowledgeDNAService = KnowledgeDNAService(
      seedSource: seedSource,
      progressRepository: progressRepository,
    );

    final missionProgress = await _initializeMissionService(missionService);
    final progressSummary = await _initializeProgressService(progressService);
    final knowledgeDNA = await _initializeKnowledgeDNAService(knowledgeDNAService);
    final userPreferences = await _loadUserPreferences(settingsRepository);

    return BootstrapResult(
      storageService: storageService,
      missionRepository: missionRepository,
      progressRepository: progressRepository,
      settingsRepository: settingsRepository,
      missionService: missionService,
      progressService: progressService,
      knowledgeDNAService: knowledgeDNAService,
      missionProgress: missionProgress,
      progressSummary: progressSummary,
      knowledgeDNA: knowledgeDNA,
      userPreferences: userPreferences,
    );
  }

  static Future<void> _warmUpStorage(LocalStorageService storageService) async {
    try {
      await storageService.getKeys();
    } catch (_) {
      return;
    }
  }

  static Future<MissionProgress> _initializeMissionService(MissionService service) async {
    try {
      return await service.initialize();
    } catch (_) {
      return service.buildProgress();
    }
  }

  static Future<ProgressSummary> _initializeProgressService(ProgressService service) async {
    try {
      return await service.initialize();
    } catch (_) {
      return service.buildSummary();
    }
  }

  static Future<KnowledgeDNAEngine> _initializeKnowledgeDNAService(KnowledgeDNAService service) async {
    try {
      return await service.initialize();
    } catch (_) {
      return service.buildAnalysis();
    }
  }

  static Future<UserPreferences> _loadUserPreferences(LocalSettingsRepository repository) async {
    try {
      return await repository.loadUserPreferences();
    } catch (_) {
      return const UserPreferences(values: <String, Object>{});
    }
  }
}
