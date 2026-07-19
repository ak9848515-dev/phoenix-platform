/// Analytics for opportunity discovery and application tracking.
///
/// Tracks applications, response rate, interview rate, offer rate,
/// success trends, and opportunity readiness over time.
class OpportunityAnalytics {
  const OpportunityAnalytics({
    this.totalOpportunities = 0,
    this.totalApplications = 0,
    this.activeApplications = 0,
    this.responseRate = 0.0,
    this.interviewRate = 0.0,
    this.offerRate = 0.0,
    this.successTrend = 0.0,
    this.opportunityReadiness = 0.0,
    this.recentActivity = const [],
    this.topSkillGaps = const [],
    this.averageMatchScore = 0.0,
    this.lastUpdated,
  });

  /// Total discovered opportunities.
  final int totalOpportunities;

  /// Total applications submitted.
  final int totalApplications;

  /// Currently active applications (applied/interviewing).
  final int activeApplications;

  /// Rate at which applications receive responses (0.0 – 1.0).
  final double responseRate;

  /// Rate at which applications lead to interviews (0.0 – 1.0).
  final double interviewRate;

  /// Rate at which interviews lead to offers (0.0 – 1.0).
  final double offerRate;

  /// Overall success trend direction (-1.0 declining, 0.0 stable, 1.0 improving).
  final double successTrend;

  /// Overall readiness to pursue opportunities (0.0 – 1.0).
  final double opportunityReadiness;

  /// Recent activity timestamps.
  final List<DateTime> recentActivity;

  /// Top skill gaps across all opportunities.
  final List<String> topSkillGaps;

  /// Average match score across all opportunities.
  final double averageMatchScore;

  /// When this analytics snapshot was last updated.
  final DateTime? lastUpdated;

  /// Whether there is enough data for meaningful analytics.
  bool get hasData => totalApplications > 0 || totalOpportunities > 0;

  /// Whether the user is ready to pursue opportunities.
  bool get isReady => opportunityReadiness >= 0.6;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpportunityAnalytics &&
          totalOpportunities == other.totalOpportunities &&
          totalApplications == other.totalApplications;

  @override
  int get hashCode => Object.hash(totalOpportunities, totalApplications);

  @override
  String toString() =>
      'OpportunityAnalytics(apps: $totalApplications, rate: $responseRate)';
}
