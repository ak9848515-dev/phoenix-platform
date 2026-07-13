import '../../../features/career/services/career_service.dart';
import '../../../features/decision/services/decision_service.dart';
import '../../../features/knowledge_dna/knowledge_dna_service.dart';
import '../../../features/memory/services/memory_service.dart';
import '../../../features/mission_engine/mission_service.dart';
import '../../../features/progress_engine/progress_service.dart';
import '../../../models/user_settings.dart';
import '../../repository.dart';
import '../../sample_repository.dart';
import '../models/phoenix_context.dart';

/// Assembles a [PhoenixContext] from the [Repository] and all Phoenix
/// feature services.
///
/// The builder instantiates each required service with the shared
/// [Repository], ensuring all data derives from the same source.
/// This guarantees coherence across Identity → Journey → Mission →
/// Progress → Memory → Career → Decision.
///
/// No AI, no persistence, no networking.
class PhoenixContextBuilder {
  PhoenixContextBuilder({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  // ─────────────────────────────────────────────────────────────────────
  // Service accessors (lazy, stateless)
  // ─────────────────────────────────────────────────────────────────────

  MissionService get _missionService => MissionService(repository: repository);

  ProgressService get _progressService =>
      ProgressService(repository: repository);

  KnowledgeDNAService get _knowledgeDnaService =>
      KnowledgeDNAService(repository: repository);

  MemoryService get _memoryService => MemoryService(repository: repository);

  CareerService get _careerService => CareerService(repository: repository);

  DecisionService get _decisionService =>
      DecisionService(repository: repository);

  UserSettings get _userSettings => const UserSettings();

  // ─────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────

  /// Builds a complete [PhoenixContext] snapshot from the current state
  /// of all Phoenix modules.
  PhoenixContext build() {
    final selectedIdentity = repository.selectedIdentity;
    final journey = repository.journey;
    final currentStage = repository.currentJourneyStage;
    final missionProgress = _missionService.buildProgress();
    final knowledgeDNA = _knowledgeDnaService.buildAnalysis();
    final progress = _progressService.buildSummary();
    final memories = _memoryService.getSampleMemories();
    final career = _careerService.buildProfile();
    final decision = _decisionService.getDecision();
    final userSettings = _userSettings;

    return PhoenixContext(
      selectedIdentity: selectedIdentity,
      journey: journey,
      currentStage: currentStage,
      missionProgress: missionProgress,
      knowledgeDNA: knowledgeDNA,
      progress: progress,
      memories: memories,
      career: career,
      decision: decision,
      userSettings: userSettings,
      generatedAt: DateTime.now(),
    );
  }
}
