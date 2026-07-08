import '../mission_engine/mission_engine.dart';

/// Immutable knowledge analysis model used by the Knowledge DNA engine.
class KnowledgeDNAEngine {
  const KnowledgeDNAEngine({
    required this.knowledgeScore,
    required this.confidenceScore,
    required this.retentionScore,
    required this.learningVelocity,
    required this.skillStrengths,
    required this.skillWeaknesses,
    required this.recommendedMissions,
    required this.recommendedAcademies,
    required this.summary,
  });

  final double knowledgeScore;
  final double confidenceScore;
  final double retentionScore;
  final double learningVelocity;
  final List<String> skillStrengths;
  final List<String> skillWeaknesses;
  final List<Mission> recommendedMissions;
  final List<String> recommendedAcademies;
  final String summary;
}
