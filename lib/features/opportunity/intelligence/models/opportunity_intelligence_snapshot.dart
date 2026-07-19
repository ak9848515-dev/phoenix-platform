import '../../../opportunity/models/opportunity.dart';
import '../../../opportunity/models/opportunity_match.dart';
import 'opportunity_analytics.dart';
import 'opportunity_application.dart';
import 'opportunity_company_profile.dart';
import 'opportunity_insight.dart';

/// The complete output of the Opportunity Intelligence Engine.
///
/// Contains everything a widget or downstream engine needs:
/// opportunities, matches, applications, companies, analytics,
/// insights, and action items.
///
/// **Architecture:**
/// ```text
/// OpportunityIntelligenceEngine
///   ↓
/// OpportunityIntelligenceSnapshot  ← Widgets read from here
///   ↓
/// OpportunityScreen | Dashboard | NotificationEngine
/// ```
class OpportunityIntelligenceSnapshot {
  const OpportunityIntelligenceSnapshot({
    this.opportunities = const [],
    this.matches = const [],
    this.applications = const [],
    this.companies = const [],
    this.insight = const OpportunityInsight(),
    this.analytics = const OpportunityAnalytics(),
    this.topMatch = const OpportunityMatch(opportunityId: ''),
    this.topOpportunity,
    this.actionItems = const [],
    this.hasData = false,
    this.lastUpdated,
  });

  /// Recommended career opportunities, sorted by match score.
  final List<Opportunity> opportunities;

  /// Detailed match analyses for each opportunity.
  final List<OpportunityMatch> matches;

  /// User's application tracking entries.
  final List<OpportunityApplication> applications;

  /// Company intelligence profiles.
  final List<OpportunityCompanyProfile> companies;

  /// AI Advisor insight.
  final OpportunityInsight insight;

  /// Opportunity analytics.
  final OpportunityAnalytics analytics;

  /// The highest-scoring match.
  final OpportunityMatch topMatch;

  /// The highest-scoring opportunity.
  final Opportunity? topOpportunity;

  /// Actionable items for the user.
  final List<String> actionItems;

  /// Whether the engine has produced meaningful data.
  final bool hasData;

  /// When this snapshot was last updated.
  final DateTime? lastUpdated;

  /// Number of opportunities.
  int get opportunityCount => opportunities.length;

  /// Number of active applications.
  int get activeApplicationCount =>
      applications.where((a) => a.isActive).length;

  /// Number of offers received.
  int get offerCount => applications.where((a) => a.hasOffer).length;

  /// Best match score across all opportunities.
  double get bestMatchScore {
    if (opportunities.isEmpty) return 0.0;
    return opportunities.map((o) => o.matchScore).reduce((a, b) => a > b ? a : b);
  }

  /// Overall opportunity readiness.
  double get overallReadiness => analytics.opportunityReadiness;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpportunityIntelligenceSnapshot &&
          opportunityCount == other.opportunityCount &&
          hasData == other.hasData;

  @override
  int get hashCode => Object.hash(opportunityCount, hasData);

  @override
  String toString() =>
      'OpportunityIntelligenceSnapshot(opportunities: $opportunityCount, '
      'applications: ${applications.length})';
}
