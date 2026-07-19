/// AI Opportunity Advisor insight — generated recommendations and analysis.
///
/// Contains the AI advisor's assessment of best opportunities, why they're
/// recommended, missing skills, preparation plan, and improvement areas.
class OpportunityInsight {
  const OpportunityInsight({
    this.bestOpportunityTitle = '',
    this.recommendationReason = '',
    this.missingSkills = const [],
    this.preparationPlan = const [],
    this.resumeImprovements = const [],
    this.portfolioImprovements = const [],
    this.interviewFocusAreas = const [],
    this.confidenceScore = 0.0,
    this.estimatedTimeline = '',
  });

  /// Title of the best-matched opportunity.
  final String bestOpportunityTitle;

  /// Why this opportunity is recommended.
  final String recommendationReason;

  /// Skills the user is missing for top opportunities.
  final List<String> missingSkills;

  /// Step-by-step preparation plan.
  final List<String> preparationPlan;

  /// Recommended resume improvements.
  final List<String> resumeImprovements;

  /// Recommended portfolio improvements.
  final List<String> portfolioImprovements;

  /// Areas to focus on for interview preparation.
  final List<String> interviewFocusAreas;

  /// Confidence in this insight (0.0 – 1.0).
  final double confidenceScore;

  /// Estimated timeline to readiness.
  final String estimatedTimeline;

  @override
  String toString() =>
      'OpportunityInsight(best: $bestOpportunityTitle, confidence: $confidenceScore)';
}
