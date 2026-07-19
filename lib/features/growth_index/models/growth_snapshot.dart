import 'dart:convert';

import 'growth_dimension.dart';
import 'growth_history.dart';
import 'growth_metrics.dart';
import 'growth_trend.dart';

/// Read-only snapshot of the user's current growth across all dimensions.
///
/// Produced by [GrowthIndexEngine.buildSnapshot]. Consumers read this
/// snapshot instead of calculating growth metrics themselves.
///
/// Immutable. Supports full serialization for caching via [toMap]/[fromMap],
/// including the complete [GrowthHistory] with daily, weekly, and monthly
/// metrics lists.
class GrowthSnapshot {
  const GrowthSnapshot({
    required this.overallScore,
    required this.knowledge,
    required this.skills,
    required this.projects,
    required this.career,
    required this.habits,
    required this.interview,
    required this.mission,
    required this.portfolio,
    this.learningConsistency,
    required this.currentLevel,
    required this.totalXp,
    required this.lastUpdated,
    this.history = const GrowthHistory(),
  });

  // ── Overall ─────────────────────────────────────────────────────────

  /// Composite growth score (0.0–1.0) across all dimensions.
  final double overallScore;

  // ── Dimension Metrics (8 core) ───────────────────────────────────────

  /// Knowledge acquisition score.
  final GrowthMetrics knowledge;
  /// Practical skills proficiency score.
  final GrowthMetrics skills;
  /// Project completion score.
  final GrowthMetrics projects;
  /// Career readiness score.
  final GrowthMetrics career;
  /// Habit consistency score.
  final GrowthMetrics habits;
  /// Interview readiness score.
  final GrowthMetrics interview;
  /// Mission completion score.
  final GrowthMetrics mission;
  /// Portfolio development score.
  final GrowthMetrics portfolio;
  /// Learning consistency over time (optional — may be null if not calculated).
  final GrowthMetrics? learningConsistency;

  // ── Platform Stats ──────────────────────────────────────────────────

  /// Current user level.
  final int currentLevel;
  /// Total XP earned.
  final int totalXp;

  // ── History ─────────────────────────────────────────────────────────

  /// Historical growth snapshots over daily, weekly, and monthly periods.
  final GrowthHistory history;

  /// When this snapshot was generated.
  final DateTime lastUpdated;

  // ── Computed ────────────────────────────────────────────────────────

  /// The overall trend direction (from the knowledge dimension).
  GrowthTrend get overallTrend => knowledge.trend;

  /// All dimension metrics as a list (excluding overall).
  List<GrowthMetrics> get allMetrics {
    final list = <GrowthMetrics>[
      knowledge, skills, projects, career,
      habits, interview, mission, portfolio,
    ];
    if (learningConsistency != null) list.add(learningConsistency!);
    return list;
  }

  /// The strongest dimension (highest score).
  GrowthMetrics get strongestDimension =>
      allMetrics.reduce((a, b) => a.score >= b.score ? a : b);

  /// The weakest dimension (lowest score).
  GrowthMetrics get weakestDimension =>
      allMetrics.reduce((a, b) => a.score <= b.score ? a : b);

  /// Whether this snapshot represents a new user with minimal data.
  bool get isNewUser =>
      totalXp == 0 && allMetrics.every((m) => m.score < 0.1);

  /// Whether the user has made any measurable progress.
  bool get hasAnyProgress =>
      totalXp > 0 || allMetrics.any((m) => m.score >= 0.1);

  // ── Serialization ───────────────────────────────────────────────────

  /// Serializes a single [GrowthMetrics] to a JSON map.
  static Map<String, dynamic> _metricsToMap(GrowthMetrics m) => {
        'dim': m.dimension.name,
        'score': m.score,
        'trend': m.trend.name,
        'prevScore': m.previousScore,
        'label': m.label,
        'detail': m.detail,
      };

  /// Deserializes a [GrowthMetrics] from a JSON map.
  static GrowthMetrics _metricsFromMap(Map<String, dynamic> map) =>
      GrowthMetrics(
        dimension: GrowthDimension.values.firstWhere(
          (d) => d.name == (map['dim'] as String),
          orElse: () => GrowthDimension.overall,
        ),
        score: (map['score'] as num).toDouble(),
        trend: GrowthTrend.values.firstWhere(
          (t) => t.name == (map['trend'] as String? ?? 'stable'),
          orElse: () => GrowthTrend.stable,
        ),
        previousScore: (map['prevScore'] as num?)?.toDouble(),
        label: map['label'] as String? ?? '',
        detail: map['detail'] as String? ?? '',
      );

  /// Serializes to a JSON-compatible map for caching.
  /// Includes full history serialization (daily, weekly, monthly).
  Map<String, dynamic> toMap() => {
        'overallScore': overallScore,
        'knowledge_score': knowledge.score,
        'knowledge_trend': knowledge.trend.name,
        'skills_score': skills.score,
        'skills_trend': skills.trend.name,
        'projects_score': projects.score,
        'projects_trend': projects.trend.name,
        'career_score': career.score,
        'career_trend': career.trend.name,
        'habits_score': habits.score,
        'habits_trend': habits.trend.name,
        'interview_score': interview.score,
        'interview_trend': interview.trend.name,
        'mission_score': mission.score,
        'mission_trend': mission.trend.name,
        'portfolio_score': portfolio.score,
        'portfolio_trend': portfolio.trend.name,
        'learningConsistency_score': learningConsistency?.score,
        'currentLevel': currentLevel,
        'totalXp': totalXp,
        'lastUpdated': lastUpdated.toIso8601String(),
        'history_daily': json.encode(
          history.daily.map(_metricsToMap).toList(),
        ),
        'history_weekly': json.encode(
          history.weekly.map(_metricsToMap).toList(),
        ),
        'history_monthly': json.encode(
          history.monthly.map(_metricsToMap).toList(),
        ),
      };

  /// Creates from a JSON-compatible map.
  factory GrowthSnapshot.fromMap(Map<String, dynamic> map) {
    GrowthMetrics makeMetrics(
      GrowthDimension dim,
      String scoreKey,
      String trendKey,
    ) {
      return GrowthMetrics(
        dimension: dim,
        score: (map[scoreKey] as num?)?.toDouble() ?? 0.0,
        trend: GrowthTrend.values.firstWhere(
          (t) => t.name == (map[trendKey] as String? ?? 'stable'),
          orElse: () => GrowthTrend.stable,
        ),
      );
    }

    // Deserialize history lists
    List<GrowthMetrics> decodeList(String? key) {
      if (key == null) return [];
      final raw = map[key] as String?;
      if (raw == null || raw.isEmpty) return [];
      try {
        final list = json.decode(raw) as List<dynamic>;
        return list
            .map((e) => _metricsFromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        return [];
      }
    }

    return GrowthSnapshot(
      overallScore: (map['overallScore'] as num?)?.toDouble() ?? 0.0,
      knowledge: makeMetrics(
          GrowthDimension.knowledge, 'knowledge_score', 'knowledge_trend'),
      skills: makeMetrics(
          GrowthDimension.skills, 'skills_score', 'skills_trend'),
      projects: makeMetrics(
          GrowthDimension.projects, 'projects_score', 'projects_trend'),
      career: makeMetrics(
          GrowthDimension.career, 'career_score', 'career_trend'),
      habits: makeMetrics(
          GrowthDimension.habits, 'habits_score', 'habits_trend'),
      interview: makeMetrics(
          GrowthDimension.interview, 'interview_score', 'interview_trend'),
      mission: makeMetrics(
          GrowthDimension.mission, 'mission_score', 'mission_trend'),
      portfolio: makeMetrics(
          GrowthDimension.portfolio, 'portfolio_score', 'portfolio_trend'),
      currentLevel: map['currentLevel'] as int? ?? 1,
      totalXp: map['totalXp'] as int? ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : DateTime.now(),
      history: GrowthHistory(
        daily: decodeList('history_daily'),
        weekly: decodeList('history_weekly'),
        monthly: decodeList('history_monthly'),
      ),
    );
  }

  @override
  String toString() =>
      'GrowthSnapshot(overall: ${(overallScore * 100).round()}%, '
      'level: $currentLevel, xp: $totalXp, '
      'daily: ${history.daily.length}, '
      'weekly: ${history.weekly.length}, '
      'monthly: ${history.monthly.length})';
}
