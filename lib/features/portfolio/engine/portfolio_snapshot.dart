/// Immutable snapshot of the user's portfolio state.
///
/// Single source of truth for portfolio data consumed by PortfolioScreen,
/// Dashboard, Progress, and AI recommendations.
///
/// Produced by [PortfolioEngine]. Widgets read this snapshot only.
class PortfolioSnapshot {
  const PortfolioSnapshot({
    this.portfolioScore = 0.0,
    this.projectCount = 0,
    this.skillCount = 0,
    this.technologyCount = 0,
    this.achievementCount = 0,
    this.careerReadiness = '',
    this.strengthAreas = const [],
    this.improvementAreas = const [],
    this.technologies = const [],
    this.lastUpdated,
  });

  /// Overall portfolio score from 0.0 to 1.0.
  final double portfolioScore;

  /// Number of completed projects.
  final int projectCount;

  /// Number of tracked skills.
  final int skillCount;

  /// Number of distinct technologies.
  final int technologyCount;

  /// Number of achievements and badges.
  final int achievementCount;

  /// Career readiness label.
  final String careerReadiness;

  /// Areas identified as strengths.
  final List<String> strengthAreas;

  /// Areas identified for improvement.
  final List<String> improvementAreas;

  /// Technology stack list.
  final List<String> technologies;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  /// Whether portfolio data has been populated.
  bool get hasData => portfolioScore > 0.0;

  /// Whether the portfolio is strong (score >= 0.7).
  bool get isStrong => portfolioScore >= 0.7;

  /// Whether the portfolio needs attention (score < 0.4).
  bool get needsAttention => portfolioScore < 0.4;

  @override
  String toString() =>
      'PortfolioSnapshot(score: $portfolioScore, '
      'projects: $projectCount, skills: $skillCount)';
}
