import '../mission_engine/mission_statistics.dart';
import '../progress_engine/progress_summary.dart';
import '../mission_engine/mission_engine.dart';
import 'knowledge_dna_engine.dart';

/// Computes knowledge intelligence outputs from mission and progress data.
class KnowledgeDNAAnalyzer {
  const KnowledgeDNAAnalyzer();

  KnowledgeDNAEngine analyze({
    required MissionStatistics missionStats,
    required ProgressSummary progressSummary,
    required List<Mission> availableMissions,
    required List<String> availableAcademies,
  }) {
    final knowledgeScore =
        (missionStats.completionPercentage * 0.6) +
        (progressSummary.completionPercentage * 0.4);
    final confidenceScore =
        (knowledgeScore + (progressSummary.level / 10)) / 1.1;
    final retentionScore = (knowledgeScore + (missionStats.streak / 10)) / 1.2;
    final learningVelocity = (confidenceScore + retentionScore) / 2;

    final strengths = <String>[
      if (missionStats.completedCount > 0) 'Systems thinking',
      if (progressSummary.level >= 2) 'Execution clarity',
    ];

    final weaknesses = <String>[
      if (missionStats.pendingCount > 0) 'Consistency gaps',
      if (progressSummary.totalXp < 500) 'Momentum building',
    ];

    final recommendedMissions = availableMissions
        .where((mission) => !mission.completed)
        .take(2)
        .toList();
    final recommendedAcademies = availableAcademies.take(2).toList();

    return KnowledgeDNAEngine(
      knowledgeScore: knowledgeScore.clamp(0.0, 1.0),
      confidenceScore: confidenceScore.clamp(0.0, 1.0),
      retentionScore: retentionScore.clamp(0.0, 1.0),
      learningVelocity: learningVelocity.clamp(0.0, 1.0),
      skillStrengths: strengths.isEmpty
          ? const <String>['Execution clarity']
          : strengths,
      skillWeaknesses: weaknesses.isEmpty
          ? const <String>['Momentum building']
          : weaknesses,
      recommendedMissions: recommendedMissions,
      recommendedAcademies: recommendedAcademies,
      summary: '${(knowledgeScore * 100).toInt()}% knowledge readiness',
    );
  }
}
