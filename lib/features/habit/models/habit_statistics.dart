import 'dart:convert';

/// Statistical summary for a habit over a given period.
///
/// Immutable. Produced by [HabitEngine] analytics methods.
class HabitStatistics {
  const HabitStatistics({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completionRate = 0.0,
    this.weeklyConsistency = 0.0,
    this.monthlyConsistency = 0.0,
    this.totalCompletions = 0,
    this.totalDays = 0,
    this.habitScore = 0.0,
    this.skippedDays = 0,
    this.consecutiveDays = 0,
  });

  /// Current active streak in days.
  final int currentStreak;

  /// Longest streak ever achieved.
  final int longestStreak;

  /// Overall completion rate (0.0 - 1.0).
  final double completionRate;

  /// Weekly consistency score (0.0 - 1.0).
  final double weeklyConsistency;

  /// Monthly consistency score (0.0 - 1.0).
  final double monthlyConsistency;

  /// Total number of completions.
  final int totalCompletions;

  /// Total number of tracked days.
  final int totalDays;

  /// Overall habit score (0.0 - 100.0), combining streak, consistency, and rate.
  final double habitScore;

  /// Number of intentionally skipped days.
  final int skippedDays;

  /// Consecutive days with a completion.
  final int consecutiveDays;

  /// Percentage formatted for display (e.g. "85%").
  String get completionPercentage =>
      '${(completionRate * 100).round()}%';

  /// Whether the user is on a streak.
  bool get hasStreak => currentStreak >= 3;

  /// Motivation level based on habit score.
  String get motivationLevel {
    if (habitScore >= 80) return 'Excellent';
    if (habitScore >= 60) return 'Good';
    if (habitScore >= 40) return 'Fair';
    if (habitScore >= 20) return 'Needs Work';
    return 'Just Starting';
  }

  HabitStatistics copyWith({
    int? currentStreak,
    int? longestStreak,
    double? completionRate,
    double? weeklyConsistency,
    double? monthlyConsistency,
    int? totalCompletions,
    int? totalDays,
    double? habitScore,
    int? skippedDays,
    int? consecutiveDays,
  }) {
    return HabitStatistics(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completionRate: completionRate ?? this.completionRate,
      weeklyConsistency: weeklyConsistency ?? this.weeklyConsistency,
      monthlyConsistency: monthlyConsistency ?? this.monthlyConsistency,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      totalDays: totalDays ?? this.totalDays,
      habitScore: habitScore ?? this.habitScore,
      skippedDays: skippedDays ?? this.skippedDays,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completionRate': completionRate,
      'weeklyConsistency': weeklyConsistency,
      'monthlyConsistency': monthlyConsistency,
      'totalCompletions': totalCompletions,
      'totalDays': totalDays,
      'habitScore': habitScore,
      'skippedDays': skippedDays,
      'consecutiveDays': consecutiveDays,
    };
  }

  factory HabitStatistics.fromMap(Map<String, dynamic> map) {
    return HabitStatistics(
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 0.0,
      weeklyConsistency: (map['weeklyConsistency'] as num?)?.toDouble() ?? 0.0,
      monthlyConsistency: (map['monthlyConsistency'] as num?)?.toDouble() ?? 0.0,
      totalCompletions: map['totalCompletions'] as int? ?? 0,
      totalDays: map['totalDays'] as int? ?? 0,
      habitScore: (map['habitScore'] as num?)?.toDouble() ?? 0.0,
      skippedDays: map['skippedDays'] as int? ?? 0,
      consecutiveDays: map['consecutiveDays'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory HabitStatistics.fromJson(String source) =>
      HabitStatistics.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitStatistics &&
          other.currentStreak == currentStreak &&
          other.longestStreak == longestStreak;

  @override
  int get hashCode => Object.hash(currentStreak, longestStreak);

  @override
  String toString() =>
      'HabitStatistics(streak: $currentStreak, score: ${habitScore.round()}, '
      'rate: $completionPercentage)';
}
