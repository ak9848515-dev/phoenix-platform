import '../../features/knowledge_dna/knowledge_dna_engine.dart';
import '../../features/knowledge_dna/knowledge_dna_service.dart';
import '../../features/mission_engine/mission_progress.dart';
import '../../features/mission_engine/mission_service.dart';
import '../../features/persistence/local_storage_service.dart';
import '../../features/persistence/mission_repository.dart';
import '../../features/persistence/progress_repository.dart';
import '../../features/persistence/settings_repository.dart';
import '../../features/progress_engine/progress_service.dart';
import '../../features/progress_engine/progress_summary.dart';

class BootstrapResult {
  const BootstrapResult({
    required this.storageService,
    required this.missionRepository,
    required this.progressRepository,
    required this.settingsRepository,
    required this.missionService,
    required this.progressService,
    required this.knowledgeDNAService,
    required this.missionProgress,
    required this.progressSummary,
    required this.knowledgeDNA,
    required this.userPreferences,
  });

  final LocalStorageService storageService;
  final MissionRepository missionRepository;
  final ProgressRepository progressRepository;
  final SettingsRepository settingsRepository;
  final MissionService missionService;
  final ProgressService progressService;
  final KnowledgeDNAService knowledgeDNAService;
  final MissionProgress missionProgress;
  final ProgressSummary progressSummary;
  final KnowledgeDNAEngine knowledgeDNA;
  final UserPreferences userPreferences;
}
