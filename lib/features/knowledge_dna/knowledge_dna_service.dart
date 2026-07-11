import '../../services/sample_data_service.dart';
import '../mission_engine/mission_service.dart';
import '../progress_engine/progress_service.dart';
import 'knowledge_dna_analyzer.dart';
import 'knowledge_dna_engine.dart';

/// Orchestrates Knowledge DNA analysis from mission and progress data.
class KnowledgeDNAService {
  KnowledgeDNAService({SampleDataService? seedSource})
    : seedSource = seedSource ?? const SampleDataService();

  final SampleDataService seedSource;

  MissionService get missionService => MissionService(seedSource: seedSource);

  ProgressService get progressService =>
      ProgressService(seedSource: seedSource);

  KnowledgeDNAEngine buildAnalysis() {
    final missionStats = missionService.buildStatistics();
    final progressSummary = progressService.buildSummary();

    return KnowledgeDNAAnalyzer().analyze(
      missionStats: missionStats,
      progressSummary: progressSummary,
      availableMissions:
          missionService.dailyMissions + missionService.weeklyMissions,
      availableAcademies: seedSource.academySummaries
          .map((academy) => academy.title)
          .toList(),
    );
  }
}
