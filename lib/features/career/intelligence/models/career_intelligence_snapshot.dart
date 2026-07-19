import 'career_goal.dart';
import 'career_market_insight.dart';
import 'career_recommendation.dart';
import 'career_roadmap.dart';
import 'career_timeline.dart';
import 'career_analytics.dart';

/// Immutable snapshot produced by [CareerIntelligenceEngine].
///
/// The single source of truth for all career intelligence data.
/// Contains scoring, role info, skill alignment, roadmap, goals,
/// analytics, market insights, recommendations, and timeline.
///
/// **Architecture Rules:**
/// - Produced by CareerIntelligenceEngine only
/// - Consumed by widgets only
/// - No business logic — pure data container
class CareerIntelligenceSnapshot {
  const CareerIntelligenceSnapshot({
    // ── Scoring ──
    this.intelligenceScore = 0.0,
    this.readinessScore = 0.0,
    this.skillMatchScore = 0.0,
    this.resumeMatchScore = 0.0,
    this.portfolioMatchScore = 0.0,
    this.interviewReadinessScore = 0.0,
    this.learningProgressScore = 0.0,
    this.marketAlignmentScore = 0.0,

    // ── Role Info ──
    this.targetRole = '',
    this.currentRole = '',
    this.experience = '',
    this.jobReadiness = 'Starting Out',
    this.estimatedWeeks = 12,

    // ── Analysis ──
    this.strengths = const [],
    this.skillGaps = const [],
    this.prioritizedGaps = const [],
    this.marketInsights = const [],
    this.recommendations = const [],
    this.aiCareerSummary = '',

    // ── Roadmap ──
    this.roadmaps = const [],

    // ── Goals ──
    this.careerGoals = const [],

    // ── Analytics ──
    this.analytics = const CareerAnalytics(),

    // ── Timeline ──
    this.timeline = const [],

    // ── Actions ──
    this.actionItems = const [],
    this.nextBestAction = '',

    // ── Meta ──
    this.hasData = false,
    this.lastUpdated,
  });

  // ── Scoring (0-100) ──────────────────────────────────────────────

  /// Overall career intelligence score (weighted composite).
  final double intelligenceScore;

  /// Career readiness progress (0-100).
  final double readinessScore;

  /// How well current skills match the target career (0-100).
  final double skillMatchScore;

  /// Resume match against target role requirements (0-100).
  final double resumeMatchScore;

  /// Portfolio alignment with career goals (0-100).
  final double portfolioMatchScore;

  /// Interview readiness score (0-100).
  final double interviewReadinessScore;

  /// Learning progress towards career goals (0-100).
  final double learningProgressScore;

  /// Market alignment score (0-100).
  final double marketAlignmentScore;

  // ── Role Info ────────────────────────────────────────────────────

  /// Target career role title (e.g., "Senior Flutter Developer").
  final String targetRole;

  /// Current role title (e.g., "Junior Developer").
  final String currentRole;

  /// Experience level label (e.g., "3 years").
  final String experience;

  /// Job readiness label.
  final String jobReadiness;

  /// Estimated weeks remaining to job readiness.
  final int estimatedWeeks;

  // ── Analysis ─────────────────────────────────────────────────────

  /// Top career strengths.
  final List<String> strengths;

  /// Raw skill gaps.
  final List<String> skillGaps;

  /// Prioritized skill gaps with context.
  final List<PrioritizedGap> prioritizedGaps;

  /// Market insights.
  final List<CareerMarketInsight> marketInsights;

  /// Career recommendations.
  final List<CareerRecommendation> recommendations;

  /// AI-generated career summary.
  final String aiCareerSummary;

  // ── Roadmap ──────────────────────────────────────────────────────

  /// Career roadmaps by time horizon (30d, 90d, 180d, 365d).
  final List<CareerRoadmap> roadmaps;

  // ── Goals ────────────────────────────────────────────────────────

  /// Career goals being tracked.
  final List<CareerGoal> careerGoals;

  // ── Analytics ────────────────────────────────────────────────────

  /// Career analytics data.
  final CareerAnalytics analytics;

  // ── Timeline ─────────────────────────────────────────────────────

  /// Career timeline entries.
  final List<CareerTimelineEntry> timeline;

  // ── Actions ──────────────────────────────────────────────────────

  /// Ranked action items for the action center.
  final List<CareerActionItem> actionItems;

  /// The single next best action string.
  final String nextBestAction;

  // ── Meta ─────────────────────────────────────────────────────────

  /// Whether any career intelligence data has been computed.
  final bool hasData;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  // ── Computed Helpers ─────────────────────────────────────────────

  /// Number of critical skill gaps.
  int get criticalGapCount =>
      prioritizedGaps.where((g) => g.priority == GapActionPriority.critical).length;

  /// Top recommendation.
  CareerRecommendation? get topRecommendation =>
      recommendations.isNotEmpty ? recommendations.first : null;

  /// Primary roadmap (30-day if available, otherwise first).
  CareerRoadmap? get primaryRoadmap =>
      roadmaps.where((r) => r.horizonDays == 30).firstOrNull ?? roadmaps.take(1).firstOrNull;

  /// Primary career goal being tracked.
  CareerGoal? get primaryGoal => careerGoals.isNotEmpty ? careerGoals.first : null;

  /// Whether career needs urgent attention.
  bool get needsAttention => intelligenceScore < 40.0;

  /// Whether career is on a healthy trajectory.
  bool get isHealthy => intelligenceScore >= 70.0;

  /// Whether the user is job-ready.
  bool get isReady => readinessScore >= 80.0;

  @override
  String toString() =>
      'CareerIntelligenceSnapshot(score: $intelligenceScore, '
      'role: $targetRole, readiness: $jobReadiness)';
}

/// A skill gap with priority context.
class PrioritizedGap {
  const PrioritizedGap({
    required this.skillName,
    required this.priority,
    this.description,
    this.suggestion,
    this.impact = 0.0,
  });

  final String skillName;
  final GapActionPriority priority;
  final String? description;
  final String? suggestion;
  final double impact;
}

/// Priority for closing a skill gap.
enum GapActionPriority {
  critical,
  high,
  medium,
  low;

  int get weight {
    switch (this) {
      case GapActionPriority.critical:
        return 100;
      case GapActionPriority.high:
        return 70;
      case GapActionPriority.medium:
        return 40;
      case GapActionPriority.low:
        return 10;
    }
  }

  String get displayName {
    switch (this) {
      case GapActionPriority.critical:
        return 'Critical';
      case GapActionPriority.high:
        return 'High';
      case GapActionPriority.medium:
        return 'Medium';
      case GapActionPriority.low:
        return 'Low';
    }
  }
}

/// An action item for the career action center.
class CareerActionItem {
  const CareerActionItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    this.impact = 0.0,
    this.estimatedWeeks = 0,
    this.route,
    this.completed = false,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final CareerActionPriority priority;
  final double impact;
  final int estimatedWeeks;
  final String? route;
  final bool completed;

  String get typeLabel {
    switch (type) {
      case 'learn_skill':
        return 'Learn Skill';
      case 'build_project':
        return 'Build Project';
      case 'update_resume':
        return 'Update Resume';
      case 'practice_interview':
        return 'Practice Interview';
      case 'apply':
        return 'Apply';
      case 'get_certified':
        return 'Get Certified';
      case 'improve_portfolio':
        return 'Improve Portfolio';
      default:
        return type;
    }
  }

  @override
  String toString() => 'CareerActionItem($type: $title)';
}

/// Priority for career action items.
enum CareerActionPriority {
  critical,
  high,
  medium,
  low;

  int get weight {
    switch (this) {
      case CareerActionPriority.critical:
        return 100;
      case CareerActionPriority.high:
        return 75;
      case CareerActionPriority.medium:
        return 50;
      case CareerActionPriority.low:
        return 25;
    }
  }

  String get displayName {
    switch (this) {
      case CareerActionPriority.critical:
        return 'Critical';
      case CareerActionPriority.high:
        return 'High';
      case CareerActionPriority.medium:
        return 'Medium';
      case CareerActionPriority.low:
        return 'Low';
    }
  }
}
