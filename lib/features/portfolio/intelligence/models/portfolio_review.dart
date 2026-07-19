/// Complete AI portfolio review with strengths, weaknesses, and improvement plan.
class PortfolioReview {
  const PortfolioReview({
    this.strengths = const [],
    this.weaknesses = const [],
    this.missingProjects = const [],
    this.careerAlignment = 0.0,
    this.improvementPlan = const [],
    this.nextBestProject = '',
    this.priorityScore = 0.0,
    this.summary = '',
  });

  /// Identified portfolio strengths.
  final List<String> strengths;

  /// Identified portfolio weaknesses.
  final List<String> weaknesses;

  /// Types of projects missing from the portfolio.
  final List<String> missingProjects;

  /// How well the portfolio aligns with target career (0.0-1.0).
  final double careerAlignment;

  /// Step-by-step improvement plan.
  final List<String> improvementPlan;

  /// Recommended next best project to build.
  final String nextBestProject;

  /// Overall priority score (0-100) — urgency of taking action.
  final double priorityScore;

  /// One-line summary of the review.
  final String summary;

  /// Whether the review has data.
  bool get hasData => strengths.isNotEmpty || weaknesses.isNotEmpty;

  /// Number of actionable items.
  int get actionCount => weaknesses.length + missingProjects.length;

  @override
  String toString() =>
      'PortfolioReview(priorities: $priorityScore, '
      'strengths: ${strengths.length}, weaknesses: ${weaknesses.length})';
}
