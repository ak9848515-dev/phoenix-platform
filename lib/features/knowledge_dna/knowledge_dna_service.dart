import '../../services/sample_data_service.dart';
import '../mission_engine/mission_service.dart';
import '../persistence/local_progress_repository.dart';
import '../persistence/progress_repository.dart';
import '../progress_engine/progress_service.dart';
import 'knowledge_dna_analyzer.dart';
import 'knowledge_dna_engine.dart';

/// Orchestrates Knowledge DNA analysis from mission and progress data.
class KnowledgeDNAService {
  KnowledgeDNAService({
    SampleDataService? seedSource,
    ProgressRepository? progressRepository,
  })  : seedSource = seedSource ?? const SampleDataService(),
        progressRepository = progressRepository ?? const LocalProgressRepository();

  final SampleDataService seedSource;
  final ProgressRepository progressRepository;

  MissionService get missionService => MissionService(seedSource: seedSource);

  ProgressService get progressService => ProgressService(seedSource: seedSource);

  KnowledgeDNAEngine buildAnalysis() {
    final missionStats = missionService.buildStatistics();
    final progressSummary = progressService.buildSummary();

    return KnowledgeDNAAnalyzer().analyze(
      missionStats: missionStats,
      progressSummary: progressSummary,
      availableMissions: missionService.dailyMissions + missionService.weeklyMissions,
      availableAcademies: seedSource.academySummaries.map((academy) => academy.title).toList(),
    );
  }

  Future<KnowledgeDNAEngine> initialize() async {
    final analysis = buildAnalysis();
    await saveAnalysis(analysis);
    return analysis;
  }

  Future<KnowledgeDNAEngine> restoreAnalysis() async {
    final persistedKnowledgeDNA = await progressRepository.loadKnowledgeDNA();
    final defaultAnalysis = buildAnalysis();

    return KnowledgeDNAEngine(
      knowledgeScore: defaultAnalysis.knowledgeScore,
      confidenceScore: _defaultWhenEmpty(
        persistedKnowledgeDNA.confidence,
        defaultAnalysis.confidenceScore,
      ),
      retentionScore: _defaultWhenEmpty(
        persistedKnowledgeDNA.retention,
        defaultAnalysis.retentionScore,
      ),
      consistencyScore: _defaultWhenEmpty(
        persistedKnowledgeDNA.consistency,
        defaultAnalysis.consistencyScore,
      ),
      learningVelocity: _defaultWhenEmpty(
        persistedKnowledgeDNA.learningVelocity,
        defaultAnalysis.learningVelocity,
      ),
      skillStrengths: persistedKnowledgeDNA.strongAreas.isEmpty
          ? defaultAnalysis.skillStrengths
          : persistedKnowledgeDNA.strongAreas,
      skillWeaknesses: persistedKnowledgeDNA.weakAreas.isEmpty
          ? defaultAnalysis.skillWeaknesses
          : persistedKnowledgeDNA.weakAreas,
      careerDirection: persistedKnowledgeDNA.careerDirection.isEmpty
          ? defaultAnalysis.careerDirection
          : persistedKnowledgeDNA.careerDirection,
      recommendedMissions: defaultAnalysis.recommendedMissions,
      recommendedAcademies: defaultAnalysis.recommendedAcademies,
      summary: defaultAnalysis.summary,
    );
  }

  Future<void> saveAnalysis(KnowledgeDNAEngine analysis) {
    return progressRepository.saveKnowledgeDNA(analysis);
  }

  double _defaultWhenEmpty(double value, double defaultValue) {
    return value == 0.0 ? defaultValue : value;
  }
}
