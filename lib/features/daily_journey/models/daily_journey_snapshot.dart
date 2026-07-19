import '../../daily_brief/models/daily_brief_snapshot.dart';
import '../../daily_brief/models/daily_plan.dart';
import '../../continue_journey/models/journey_snapshot.dart';
import '../../continue_journey/models/journey_activity.dart';
import '../../growth_index/models/growth_snapshot.dart';
import '../../interview/intelligence/models/interview_intelligence_snapshot.dart';
import '../../opportunity/intelligence/models/opportunity_intelligence_snapshot.dart';
import '../../resume_intelligence/models/resume_intelligence_snapshot.dart';
import '../../portfolio/engine/portfolio_snapshot.dart';

/// The complete Daily Journey orchestration snapshot.
///
/// NOT an engine — this is a read-only orchestration layer that
/// aggregates data from all existing intelligence engines into one
/// unified daily experience.
///
/// **Architecture:**
/// ```text
/// DailyBriefEngine + ContinueJourneyEngine + InterviewEngine + ...
///   ↓
/// DailyJourneyOrchestrator  (screen reads engine snapshots)
///   ↓
/// DailyJourneySnapshot  ← data for all daily widgets
/// ```
class DailyJourneySnapshot {
  const DailyJourneySnapshot({
    required this.dailyBrief,
    required this.journey,
    this.growthSnapshot,
    this.interviewSnapshot,
    this.opportunitySnapshot,
    this.resumeSnapshot,
    this.portfolioSnapshot,
    this.hasData = false,
    this.lastUpdated,
  });

  /// Daily Brief snapshot with today's plan.
  final DailyBriefSnapshot dailyBrief;

  /// Continue Journey snapshot with resume points.
  final JourneySnapshot journey;

  /// Current growth metrics.
  final GrowthSnapshot? growthSnapshot;

  /// Interview readiness and practice data.
  final InterviewIntelligenceSnapshot? interviewSnapshot;

  /// Opportunity recommendations.
  final OpportunityIntelligenceSnapshot? opportunitySnapshot;

  /// Resume health and intelligence.
  final ResumeIntelligenceSnapshot? resumeSnapshot;

  /// Portfolio status.
  final PortfolioSnapshot? portfolioSnapshot;

  /// Whether the journey has meaningful data.
  final bool hasData;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  // ── Computed Properties ────────────────────────────────────────

  /// Today's single focus item.
  String get todaysFocus => dailyBrief.todaysFocus;

  /// Today's mission title.
  String get todaysMission => dailyBrief.todaysMission;

  /// Today's primary goal.
  String get todaysGoal => dailyBrief.todaysGoal;

  /// Today's task plan.
  DailyPlan get plan => dailyBrief.plan;

  /// Top resume candidate to continue.
  JourneyActivity? get resumePoint => journey.resumePoint;

  /// Overall journey completion percent.
  double get journeyCompletion => journey.completionPercent;

  /// Interview readiness score.
  double get interviewReadiness =>
      interviewSnapshot?.readiness.overall ?? 0.0;

  /// Opportunity match score.
  double get opportunityMatchScore =>
      opportunitySnapshot?.bestMatchScore ?? 0.0;

  /// Resume health score.
  double get resumeHealthScore =>
      resumeSnapshot?.overallScore ?? 0.0;

  /// Portfolio score.
  double get portfolioScore =>
      portfolioSnapshot?.portfolioScore ?? 0.0;

  /// Daily completion percent.
  double get dailyCompletionPercent => dailyBrief.completionPercent;

  /// Whether interview practice is ready.
  bool get hasInterviewData => interviewSnapshot?.hasData ?? false;

  /// Whether opportunities are available.
  bool get hasOpportunityData => opportunitySnapshot?.hasData ?? false;

  /// Whether resume data is available.
  bool get hasResumeData => resumeSnapshot?.hasData ?? false;

  @override
  String toString() =>
      'DailyJourneySnapshot(focus: $todaysFocus, '
      'completion: ${(dailyCompletionPercent * 100).round()}%)';
}
