/// Immutable career analytics data for charts and visualizations.
///
/// Tracks readiness trend over time, skill growth rates,
/// learning velocity, goal completion progress, and market alignment.
class CareerAnalytics {
  const CareerAnalytics({
    this.readinessTrend = const [],
    this.readinessLabels = const [],
    this.skillGrowth = const [],
    this.skillGrowthLabels = const [],
    this.learningVelocity = 0.0,
    this.goalCompletionTrend = const [],
    this.goalCompletionLabels = const [],
    this.marketAlignment = 0.0,
    this.careerTimeline = const [],
    this.careerTimelineLabels = const [],
  });

  // ── Readiness Trend ─────────────────────────────────────────────

  /// Readiness scores over time (monthly, 0-100 each).
  final List<double> readinessTrend;

  /// Labels for readiness trend (month/year).
  final List<String> readinessLabels;

  /// Returns a map of month → readiness score for charting.
  Map<String, double> get readinessTrendMap {
    final map = <String, double>{};
    for (var i = 0; i < readinessTrend.length && i < readinessLabels.length; i++) {
      map[readinessLabels[i]] = readinessTrend[i];
    }
    return map;
  }

  /// Latest readiness score.
  double get latestReadiness =>
      readinessTrend.isNotEmpty ? readinessTrend.last : 0.0;

  /// Readiness trend direction: 1 = improving, -1 = declining, 0 = stable.
  int get trendDirection {
    if (readinessTrend.length < 2) return 0;
    final recent = readinessTrend.sublist(readinessTrend.length - 2);
    final diff = recent.last - recent.first;
    if (diff > 2) return 1;
    if (diff < -2) return -1;
    return 0;
  }

  // ── Skill Growth ────────────────────────────────────────────────

  /// Skill scores over time (monthly, 0-100 each).
  final List<double> skillGrowth;

  /// Labels for skill growth.
  final List<String> skillGrowthLabels;

  /// Returns a map for charting.
  Map<String, double> get skillGrowthMap {
    final map = <String, double>{};
    for (var i = 0; i < skillGrowth.length && i < skillGrowthLabels.length; i++) {
      map[skillGrowthLabels[i]] = skillGrowth[i];
    }
    return map;
  }

  // ── Learning Velocity ───────────────────────────────────────────

  /// Current learning velocity (skill points gained per month).
  final double learningVelocity;

  // ── Goal Completion ─────────────────────────────────────────────

  /// Goal completion rates over time.
  final List<double> goalCompletionTrend;

  /// Labels for goal completion.
  final List<String> goalCompletionLabels;

  /// Returns a map for charting.
  Map<String, double> get goalCompletionMap {
    final map = <String, double>{};
    for (var i = 0; i < goalCompletionTrend.length && i < goalCompletionLabels.length; i++) {
      map[goalCompletionLabels[i]] = goalCompletionTrend[i];
    }
    return map;
  }

  // ── Market Alignment ────────────────────────────────────────────

  /// Overall market alignment score (0-100).
  final double marketAlignment;

  // ── Career Timeline ─────────────────────────────────────────────

  /// Milestone completion timeline.
  final List<double> careerTimeline;

  /// Labels for career timeline.
  final List<String> careerTimelineLabels;

  /// Returns a map for charting.
  Map<String, double> get careerTimelineMap {
    final map = <String, double>{};
    for (var i = 0; i < careerTimeline.length && i < careerTimelineLabels.length; i++) {
      map[careerTimelineLabels[i]] = careerTimeline[i];
    }
    return map;
  }

  /// Whether analytics data has been populated.
  bool get hasData => readinessTrend.isNotEmpty || skillGrowth.isNotEmpty;

  @override
  String toString() =>
      'CareerAnalytics(trend: ${readinessTrend.length} points, '
      'velocity: $learningVelocity, alignment: $marketAlignment)';
}
