import '../../core/repository.dart';
import '../../core/sample_repository.dart';
import '../mission_engine/mission_service.dart';
import '../progress_engine/progress_service.dart';
import 'knowledge_dna_analyzer.dart';
import 'knowledge_dna_engine.dart';

/// Orchestrates Knowledge DNA analysis from mission and progress data.
class KnowledgeDNAService {
  KnowledgeDNAService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  MissionService get missionService => MissionService(repository: repository);

  ProgressService get progressService =>
      ProgressService(repository: repository);

  KnowledgeDNAEngine buildAnalysis() {
    final missionStats = missionService.buildStatistics();
    final progressSummary = progressService.buildSummary();

    return KnowledgeDNAAnalyzer().analyze(
      missionStats: missionStats,
      progressSummary: progressSummary,
      availableMissions:
          missionService.dailyMissions + missionService.weeklyMissions,
      availableAcademies: repository.academySummaries
          .map((academy) => academy.title)
          .toList(),
    );
  }
}
