/// Placeholder model describing the Knowledge DNA profile.
///
/// This is a presentation-only model used to structure sample values for the
/// UI layer without introducing business logic or backend dependencies.
class KnowledgeDNA {
  const KnowledgeDNA({
    required this.knowledge,
    required this.skill,
    required this.confidence,
    required this.retention,
    required this.consistency,
    required this.learningVelocity,
    required this.missionsCompleted,
    required this.projectsCompleted,
    required this.weakAreas,
    required this.strongAreas,
    required this.careerGoal,
  });

  final String knowledge;
  final String skill;
  final double confidence;
  final double retention;
  final double consistency;
  final double learningVelocity;
  final int missionsCompleted;
  final int projectsCompleted;
  final List<String> weakAreas;
  final List<String> strongAreas;
  final String careerGoal;
}
