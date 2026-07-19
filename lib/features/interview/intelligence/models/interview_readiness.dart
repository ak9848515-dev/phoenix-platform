/// Immutable breakdown of interview readiness across all dimensions.
///
/// Each score is 0.0 to 1.0. The composite readiness score is the
/// weighted combination of all dimensions.
class InterviewReadiness {
  const InterviewReadiness({
    this.overall = 0.0,
    this.knowledgeScore = 0.0,
    this.projectScore = 0.0,
    this.resumeScore = 0.0,
    this.portfolioScore = 0.0,
    this.careerReadinessScore = 0.0,
    this.previousInterviewScore = 0.0,
    this.learningProgressScore = 0.0,
    this.mockInterviewScore = 0.0,
    this.confidenceScore = 0.0,
  });

  /// Composite readiness score (0.0 – 1.0).
  final double overall;

  /// Knowledge assessment score.
  final double knowledgeScore;

  /// Project experience score.
  final double projectScore;

  /// Resume quality score.
  final double resumeScore;

  /// Portfolio strength score.
  final double portfolioScore;

  /// Career readiness score.
  final double careerReadinessScore;

  /// Previous interview performance score.
  final double previousInterviewScore;

  /// Learning progress score.
  final double learningProgressScore;

  /// Average mock interview score.
  final double mockInterviewScore;

  /// Self-assessed confidence level.
  final double confidenceScore;

  /// Number of dimensions that are below 0.5 (needing improvement).
  int get weakDimensionsCount => [
        knowledgeScore,
        projectScore,
        resumeScore,
        portfolioScore,
        careerReadinessScore,
        previousInterviewScore,
        learningProgressScore,
        mockInterviewScore,
        confidenceScore,
      ].where((s) => s < 0.5).length;

  /// Whether the user is interview-ready (overall >= 0.7).
  bool get isReady => overall >= 0.7;

  /// Whether the user needs significant preparation (overall < 0.4).
  bool get needsSignificantPrep => overall < 0.4;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewReadiness &&
          overall == other.overall &&
          knowledgeScore == other.knowledgeScore &&
          projectScore == other.projectScore &&
          resumeScore == other.resumeScore &&
          portfolioScore == other.portfolioScore &&
          careerReadinessScore == other.careerReadinessScore &&
          previousInterviewScore == other.previousInterviewScore &&
          learningProgressScore == other.learningProgressScore &&
          mockInterviewScore == other.mockInterviewScore &&
          confidenceScore == other.confidenceScore;

  @override
  int get hashCode => Object.hash(
        overall,
        knowledgeScore,
        projectScore,
        resumeScore,
        portfolioScore,
        careerReadinessScore,
        previousInterviewScore,
        learningProgressScore,
        mockInterviewScore,
        confidenceScore,
      );

  @override
  String toString() =>
      'InterviewReadiness(overall: $overall, ready: $isReady)';
}
