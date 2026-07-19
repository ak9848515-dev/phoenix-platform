/// Immutable analytics data for portfolio charts and distributions.
///
/// Produced by [PortfolioIntelligenceEngine] and consumed by
/// the Portfolio Analytics visualization widgets.
class PortfolioAnalytics {
  const PortfolioAnalytics({
    this.skillDistribution = const [],
    this.technologyUsage = const [],
    this.projectCategories = const [],
    this.careerAlignment = 0.0,
    this.growthTrend = const [],
    this.skillDistributionLabels = const [],
    this.technologyUsageLabels = const [],
    this.projectCategoryLabels = const [],
    this.growthTrendLabels = const [],
  });

  // ── Skill Distribution ──────────────────────────────────────────

  /// Distribution of skills across categories (percentages 0-100).
  final List<double> skillDistribution;

  /// Labels for skill distribution.
  final List<String> skillDistributionLabels;

  /// Returns a map of category → percentage for charting.
  Map<String, double> get skillDistributionMap {
    final map = <String, double>{};
    for (var i = 0; i < skillDistribution.length && i < skillDistributionLabels.length; i++) {
      map[skillDistributionLabels[i]] = skillDistribution[i];
    }
    return map;
  }

  // ── Technology Usage ───────────────────────────────────────────

  /// Usage frequency of each technology (0-100).
  final List<double> technologyUsage;

  /// Labels for technology usage.
  final List<String> technologyUsageLabels;

  /// Returns a map of technology → usage for charting.
  Map<String, double> get technologyUsageMap {
    final map = <String, double>{};
    for (var i = 0; i < technologyUsage.length && i < technologyUsageLabels.length; i++) {
      map[technologyUsageLabels[i]] = technologyUsage[i];
    }
    return map;
  }

  // ── Project Categories ─────────────────────────────────────────

  /// Distribution of projects by category.
  final List<double> projectCategories;

  /// Labels for project categories.
  final List<String> projectCategoryLabels;

  /// Returns a map of category → count for charting.
  Map<String, double> get projectCategoryMap {
    final map = <String, double>{};
    for (var i = 0; i < projectCategories.length && i < projectCategoryLabels.length; i++) {
      map[projectCategoryLabels[i]] = projectCategories[i];
    }
    return map;
  }

  // ── Career Alignment ───────────────────────────────────────────

  /// Overall career alignment score (0.0-1.0).
  final double careerAlignment;

  // ── Growth Trend ───────────────────────────────────────────────

  /// Portfolio growth over time (monthly scores).
  final List<double> growthTrend;

  /// Labels for growth trend (month/year).
  final List<String> growthTrendLabels;

  /// Returns a map of month → score for charting.
  Map<String, double> get growthTrendMap {
    final map = <String, double>{};
    for (var i = 0; i < growthTrend.length && i < growthTrendLabels.length; i++) {
      map[growthTrendLabels[i]] = growthTrend[i];
    }
    return map;
  }

  /// Whether analytics data has been populated.
  bool get hasData => skillDistribution.isNotEmpty;

  @override
  String toString() =>
      'PortfolioAnalytics(skills: ${skillDistribution.length}, '
      'technologies: ${technologyUsage.length}, '
      'projects: ${projectCategories.length})';
}
