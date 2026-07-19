import 'portfolio_analytics.dart';
import 'portfolio_completeness.dart';
import 'portfolio_enums.dart';
import 'portfolio_insight.dart';
import 'portfolio_review.dart';
import 'portfolio_timeline_entry.dart';
import 'project_recommendation.dart';
import 'skill_gap.dart';

/// Immutable snapshot produced by [PortfolioIntelligenceEngine].
///
/// Contains all intelligence-derived data about the user's portfolio:
/// scoring, gaps, recommendations, insights, analytics, completeness,
/// timeline, and AI review.
///
/// **Architecture Rules:**
/// - Produced by PortfolioIntelligenceEngine only
/// - Consumed by widgets only
/// - No business logic — pure data container
class PortfolioIntelligenceSnapshot {
  const PortfolioIntelligenceSnapshot({
    this.intelligenceScore = 0.0,
    this.score = 0.0,
    this.projectScore = 0.0,
    this.skillScore = 0.0,
    this.resumeAlignmentScore = 0.0,
    this.careerGoalScore = 0.0,
    this.experienceScore = 0.0,
    this.achievementScore = 0.0,
    this.freshnessScore = 0.0,
    this.completenessScore = 0.0,
    this.skillGaps = const [],
    this.projectRecommendations = const [],
    this.insights = const [],
    this.analytics = const PortfolioAnalytics(),
    this.completeness = const PortfolioCompleteness(),
    this.timeline = const [],
    this.review = const PortfolioReview(),
    this.actionItems = const [],
    this.hasData = false,
    this.lastUpdated,
  });

  // ── Scoring ──────────────────────────────────────────────────────

  /// Overall intelligence score (0-100), weighted composite.
  final double intelligenceScore;

  /// Portfolio score component (0-100).
  final double score;

  /// Project quality score (0-100).
  final double projectScore;

  /// Skill coverage score (0-100).
  final double skillScore;

  /// Resume alignment score (0-100).
  final double resumeAlignmentScore;

  /// Career goal alignment score (0-100).
  final double careerGoalScore;

  /// Experience / expertise score (0-100).
  final double experienceScore;

  /// Achievement / certification score (0-100).
  final double achievementScore;

  /// Portfolio freshness score (0-100) — recency of updates.
  final double freshnessScore;

  /// Completeness score (0-100).
  final double completenessScore;

  // ── Analysis ─────────────────────────────────────────────────────

  /// Identified skill gaps between current skills and target career.
  final List<SkillGap> skillGaps;

  /// Recommended projects to build.
  final List<ProjectRecommendation> projectRecommendations;

  /// Generated portfolio insights.
  final List<PortfolioInsight> insights;

  /// Portfolio analytics (charts, distributions).
  final PortfolioAnalytics analytics;

  /// Portfolio completeness tracking.
  final PortfolioCompleteness completeness;

  /// Portfolio timeline (chronological entries).
  final List<PortfolioTimelineEntry> timeline;

  /// AI portfolio review (strengths, weaknesses, plan).
  final PortfolioReview review;

  // ── Actions ──────────────────────────────────────────────────────

  /// Ranked list of intelligent action items.
  final List<PortfolioActionItem> actionItems;

  // ── Meta ─────────────────────────────────────────────────────────

  /// Whether any intelligence data has been computed.
  final bool hasData;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  // ── Computed Helpers ─────────────────────────────────────────────

  /// Number of critical skill gaps.
  int get criticalGapCount =>
      skillGaps.where((g) => g.severity == GapSeverity.critical).length;

  /// Number of high-priority project recommendations.
  int get highPriorityProjectCount =>
      projectRecommendations.where((r) => r.priority == RecommendationPriority.high).length;

  /// Top skill gap (by severity, then impact).
  SkillGap? get topSkillGap =>
      skillGaps.isNotEmpty ? skillGaps.first : null;

  /// Top project recommendation (by priority, then impact).
  ProjectRecommendation? get topProjectRecommendation =>
      projectRecommendations.isNotEmpty ? projectRecommendations.first : null;

  /// Top insight (by importance).
  PortfolioInsight? get topInsight => insights.isNotEmpty ? insights.first : null;

  /// Whether the portfolio needs urgent attention.
  bool get needsAttention => intelligenceScore < 40.0 || completenessScore < 50.0;

  /// Whether the portfolio is in good shape.
  bool get isHealthy => intelligenceScore >= 70.0 && completenessScore >= 80.0;

  /// Whether there are critical skill gaps.
  bool get hasCriticalGaps => criticalGapCount > 0;

  @override
  String toString() =>
      'PortfolioIntelligenceSnapshot(score: $intelligenceScore, '
      'gaps: ${skillGaps.length}, recs: ${projectRecommendations.length})';
}

/// Ranked action item for the portfolio action center.
class PortfolioActionItem {
  const PortfolioActionItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    this.impact,
    this.estimatedMinutes,
    this.estimatedXp,
    this.route,
    this.completed = false,
  });

  /// Unique identifier.
  final String id;

  /// Action type: 'build_project', 'improve_resume', 'add_certificate',
  /// 'update_github', 'add_achievement', 'learn_skill', 'start_mission'.
  final String type;

  /// Human-readable title.
  final String title;

  /// Short description.
  final String description;

  /// Priority level.
  final ActionPriority priority;

  /// Estimated impact on portfolio score (0.0-1.0).
  final double? impact;

  /// Estimated time to complete in minutes.
  final int? estimatedMinutes;

  /// Estimated XP reward.
  final int? estimatedXp;

  /// Navigation route to execute this action.
  final String? route;

  /// Whether this action has been completed.
  final bool completed;

  PortfolioActionItem copyWith({bool? completed}) =>
      PortfolioActionItem(
        id: id,
        type: type,
        title: title,
        description: description,
        priority: priority,
        impact: impact,
        estimatedMinutes: estimatedMinutes,
        estimatedXp: estimatedXp,
        route: route,
        completed: completed ?? this.completed,
      );

  @override
  String toString() => 'PortfolioActionItem($type: $title, priority: $priority)';
}

