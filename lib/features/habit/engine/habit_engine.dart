import '../models/habit.dart';
import '../models/habit_entry.dart';
import '../models/habit_insight.dart';
import '../models/habit_statistics.dart';
import '../models/habit_trend.dart';

/// The core Habit Intelligence Engine.
///
/// Owns:
/// - Habit creation and validation
/// - Habit completion tracking
/// - Streak calculation (current + longest)
/// - Consistency analysis (weekly, monthly)
/// - Habit scoring (streak × consistency × completion rate)
/// - Weekly/monthly trend analysis
/// - Behaviour insight generation
/// - Reminder scheduling recommendations
///
/// **Never** owns business logic from Mission, Timeline, Decision,
/// Knowledge DNA, or AI engines.
///
/// This engine is pure Dart — no Flutter or service dependencies.
/// Integration happens in [HabitService].
class HabitEngine {
  const HabitEngine();

  // ── Streak Calculation ───────────────────────────────────────────

  /// Calculates the current streak for a habit.
  ///
  /// A streak is the number of consecutive days with at least one
  /// completion, ending today or yesterday (allowing for today's
  /// incomplete status).
  int calculateCurrentStreak(
    Habit habit,
    List<HabitEntry> entries, {
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _dateKey(today);

    // Build a set of completed date keys
    final completedDates = <String>{};
    for (final entry in entries) {
      if (entry.completed && entry.habitId == habit.id) {
        completedDates.add(entry.dateKey);
      }
    }

    // Check if today or yesterday is completed
    final hasToday = completedDates.contains(todayStr);
    final hasYesterday = completedDates.contains(_dateKey(
        today.subtract(const Duration(days: 1))));

    // If neither today nor yesterday is completed, streak is 0
    if (!hasToday && !hasYesterday) return 0;

    // Start from the last completed day
    DateTime cursor;
    if (hasToday) {
      cursor = today;
    } else {
      cursor = today.subtract(const Duration(days: 1));
    }

    int streak = 0;
    while (completedDates.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculates the longest streak ever achieved for a habit.
  int calculateLongestStreak(
    Habit habit,
    List<HabitEntry> entries,
  ) {
    final relevant = entries
        .where((e) => e.habitId == habit.id)
        .toList();

    if (relevant.isEmpty) return 0;

    // Sort by date ascending
    final sorted = List<HabitEntry>.from(relevant)
      ..sort((a, b) => a.date.compareTo(b.date));

    int longest = 0;
    int current = 0;
    String? lastKey;

    for (final entry in sorted) {
      final key = entry.dateKey;

      if (!entry.completed) {
        current = 0;
        lastKey = null;
        continue;
      }

      if (lastKey == null) {
        current = 1;
      } else {
        // Check if consecutive
        final lastDate = _parseDateKey(lastKey);
        final thisDate = _parseDateKey(key);
        final diff = thisDate.difference(lastDate).inDays;

        if (diff == 1) {
          current++;
        } else if (diff == 0) {
          // Same day, multiple completions — same streak
        } else {
          // Gap detected
          current = 1;
        }
      }

      if (current > longest) longest = current;
      lastKey = key;
    }

    return longest;
  }

  // ── Consistency Analysis ─────────────────────────────────────────

  /// Calculates weekly consistency for a habit.
  ///
  /// Returns the fraction of days in the past 7 days that were
  /// completed (0.0 - 1.0).
  double calculateWeeklyConsistency(
    Habit habit,
    List<HabitEntry> entries, {
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 6));

    return _calculateConsistencyInRange(
      habit, entries, start: weekAgo, end: today);
  }

  /// Calculates monthly consistency for a habit.
  ///
  /// Returns the fraction of days in the past 30 days that were
  /// completed (0.0 - 1.0).
  double calculateMonthlyConsistency(
    Habit habit,
    List<HabitEntry> entries, {
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthAgo = today.subtract(const Duration(days: 29));

    return _calculateConsistencyInRange(
      habit, entries, start: monthAgo, end: today);
  }

  /// Calculates consistency for a date range.
  double _calculateConsistencyInRange(
    Habit habit,
    List<HabitEntry> entries, {
    required DateTime start,
    required DateTime end,
  }) {
    final relevant = entries
        .where((e) =>
            e.habitId == habit.id &&
            !e.date.isBefore(start) &&
            !e.date.isAfter(end))
        .toList();

    if (relevant.isEmpty) return 0.0;

    final completed = relevant.where((e) => e.completed).length;
    return completed / relevant.length;
  }

  // ── Completion Rate ──────────────────────────────────────────────

  /// Calculates the overall completion rate for a habit.
  double calculateCompletionRate(
    Habit habit,
    List<HabitEntry> entries,
  ) {
    final relevant = entries.where((e) => e.habitId == habit.id).toList();
    if (relevant.isEmpty) return 0.0;

    final total = relevant.length;
    final completed = relevant.where((e) => e.completed).length;
    return completed / total;
  }

  // ── Habit Scoring ────────────────────────────────────────────────

  /// Calculates the overall habit score (0.0 - 100.0).
  ///
  /// Score combines:
  /// - Current streak (max 30 points)
  /// - Weekly consistency (max 30 points)
  /// - Monthly consistency (max 20 points)
  /// - Completion rate (max 20 points)
  double calculateHabitScore(
    Habit habit,
    List<HabitEntry> entries, {
    DateTime? asOf,
  }) {
    final streak = calculateCurrentStreak(habit, entries, asOf: asOf);
    final weekly = calculateWeeklyConsistency(habit, entries, asOf: asOf);
    final monthly = calculateMonthlyConsistency(habit, entries, asOf: asOf);
    final rate = calculateCompletionRate(habit, entries);

    // Streak: 30 points max (cap at 30 days)
    final streakScore = (streak / 30.0 * 30.0).clamp(0.0, 30.0);

    // Weekly consistency: 30 points
    final weeklyScore = weekly * 30.0;

    // Monthly consistency: 20 points
    final monthlyScore = monthly * 20.0;

    // Completion rate: 20 points
    final rateScore = rate * 20.0;

    return (streakScore + weeklyScore + monthlyScore + rateScore)
        .clamp(0.0, 100.0);
  }

  // ── Statistics ───────────────────────────────────────────────────

  /// Computes full statistics for a habit.
  HabitStatistics computeStatistics(
    Habit habit,
    List<HabitEntry> entries, {
    DateTime? asOf,
  }) {
    final relevant = entries.where((e) => e.habitId == habit.id).toList();
    final completed = relevant.where((e) => e.completed).toList();
    final skipped = relevant.where((e) => e.skipped).toList();

    return HabitStatistics(
      currentStreak: calculateCurrentStreak(habit, entries, asOf: asOf),
      longestStreak: calculateLongestStreak(habit, entries),
      completionRate: calculateCompletionRate(habit, entries),
      weeklyConsistency: calculateWeeklyConsistency(habit, entries, asOf: asOf),
      monthlyConsistency:
          calculateMonthlyConsistency(habit, entries, asOf: asOf),
      totalCompletions: completed.length,
      totalDays: relevant.length,
      habitScore: calculateHabitScore(habit, entries, asOf: asOf),
      skippedDays: skipped.length,
      consecutiveDays: calculateCurrentStreak(habit, entries, asOf: asOf),
    );
  }

  // ── Trend Analysis ───────────────────────────────────────────────

  /// Analyzes weekly trend for a habit.
  HabitTrend analyzeWeeklyTrend(
    Habit habit,
    List<HabitEntry> entries, {
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Last 8 weeks of data
    final dataPoints = <TrendDataPoint>[];
    for (int w = 7; w >= 0; w--) {
      final weekEnd = today.subtract(Duration(days: today.weekday - 1 + w * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));

      final weekEntries = entries.where((e) {
        return e.habitId == habit.id &&
            !e.date.isBefore(weekStart) &&
            !e.date.isAfter(weekEnd);
      }).toList();

      final total = weekEntries.length;
      final completed = weekEntries.where((e) => e.completed).length;
      final rate = total > 0 ? completed / total : 0.0;

      dataPoints.add(TrendDataPoint(
        label: 'W${8 - w}',
        rate: rate,
        count: completed,
      ));
    }

    // Current week vs previous week
    final current = dataPoints.last.rate;
    final previous = dataPoints.length >= 2
        ? dataPoints[dataPoints.length - 2].rate
        : current;
    final avg = dataPoints.fold(0.0, (sum, dp) => sum + dp.rate) /
        dataPoints.length;

    final direction = _determineDirection(current, previous);
    final percentage = previous > 0
        ? ((current - previous) / previous * 100)
        : (current > 0 ? 100.0 : 0.0);

    return HabitTrend(
      habitId: habit.id,
      period: TrendPeriod.weekly,
      direction: direction,
      percentage: percentage,
      completionRate: current,
      averageRate: avg,
      dataPoints: dataPoints,
      comparison: TrendComparison(
        previousRate: previous,
        currentRate: current,
        change: current - previous,
      ),
    );
  }

  /// Analyzes monthly trend for a habit.
  HabitTrend analyzeMonthlyTrend(
    Habit habit,
    List<HabitEntry> entries, {
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Last 6 months of data
    final dataPoints = <TrendDataPoint>[];
    for (int m = 5; m >= 0; m--) {
      final monthStart = DateTime(today.year, today.month - m, 1);
      final monthEnd = DateTime(today.year, today.month - m + 1, 0);

      final monthEntries = entries.where((e) {
        return e.habitId == habit.id &&
            !e.date.isBefore(monthStart) &&
            !e.date.isAfter(monthEnd);
      }).toList();

      final total = monthEntries.length;
      final completed = monthEntries.where((e) => e.completed).length;
      final rate = total > 0 ? completed / total : 0.0;

      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      dataPoints.add(TrendDataPoint(
        label: months[monthStart.month - 1],
        rate: rate,
        count: completed,
      ));
    }

    final current = dataPoints.last.rate;
    final previous = dataPoints.length >= 2
        ? dataPoints[dataPoints.length - 2].rate
        : current;
    final avg = dataPoints.fold(0.0, (sum, dp) => sum + dp.rate) /
        dataPoints.length;

    final direction = _determineDirection(current, previous);
    final percentage = previous > 0
        ? ((current - previous) / previous * 100)
        : (current > 0 ? 100.0 : 0.0);

    return HabitTrend(
      habitId: habit.id,
      period: TrendPeriod.monthly,
      direction: direction,
      percentage: percentage,
      completionRate: current,
      averageRate: avg,
      dataPoints: dataPoints,
      comparison: TrendComparison(
        previousRate: previous,
        currentRate: current,
        change: current - previous,
      ),
    );
  }

  // ── Insight Generation ───────────────────────────────────────────

  /// Generates insights for a habit based on its statistics and trends.
  List<HabitInsight> generateInsights(
    Habit habit,
    HabitStatistics stats,
    HabitTrend weeklyTrend,
    HabitTrend monthlyTrend,
  ) {
    final insights = <HabitInsight>[];

    // Streak insights
    if (stats.currentStreak >= 7) {
      insights.add(HabitInsight(
        id: '${habit.id}-streak-${stats.currentStreak}',
        habitId: habit.id,
        title: '${stats.currentStreak}-Day Streak!',
        description:
            'You are on an impressive ${stats.currentStreak}-day streak '
            'for "${habit.title}". Keep it going!',
        type: InsightType.streak,
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
      ));
    } else if (stats.currentStreak >= 3) {
      insights.add(HabitInsight(
        id: '${habit.id}-streak-${stats.currentStreak}',
        habitId: habit.id,
        title: 'Building Momentum',
        description:
            'You have a ${stats.currentStreak}-day streak for '
            '"${habit.title}". Add 3 more days for a full week!',
        type: InsightType.encouragement,
        priority: InsightPriority.normal,
        createdAt: DateTime.now(),
      ));
    } else if (stats.currentStreak == 0 && stats.totalDays > 0) {
      insights.add(HabitInsight(
        id: '${habit.id}-streak-broken',
        habitId: habit.id,
        title: 'Streak at Risk',
        description:
            'Your streak for "${habit.title}" has ended. '
            'Complete it today to start a new streak!',
        type: InsightType.warning,
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
        actionable: true,
        actionLabel: 'Complete Now',
      ));
    }

    // Consistency insights
    if (stats.weeklyConsistency >= 0.85) {
      insights.add(HabitInsight(
        id: '${habit.id}-consistent-high',
        habitId: habit.id,
        title: 'Excellent Consistency',
        description:
            'You completed "${habit.title}" ${(stats.weeklyConsistency * 100).round()}% '
            'of days this week — outstanding consistency!',
        type: InsightType.consistency,
        priority: InsightPriority.normal,
        createdAt: DateTime.now(),
      ));
    } else if (stats.weeklyConsistency < 0.5 && stats.totalDays > 5) {
      insights.add(HabitInsight(
        id: '${habit.id}-consistent-low',
        habitId: habit.id,
        title: 'Consistency Needs Attention',
        description:
            '"${habit.title}" was only completed '
            '${(stats.weeklyConsistency * 100).round()}% of days this week. '
            'Consider adjusting your schedule to make it easier.',
        type: InsightType.recommendation,
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
        actionable: true,
        actionLabel: 'Adjust Schedule',
      ));
    }

    // Trend insights
    if (weeklyTrend.direction == TrendDirection.improving &&
        weeklyTrend.percentage > 20) {
      insights.add(HabitInsight(
        id: '${habit.id}-trend-up',
        habitId: habit.id,
        title: 'Trending Up!',
        description:
            '"${habit.title}" is improving — '
            '${weeklyTrend.percentage.round()}% increase this week. Great progress!',
        type: InsightType.trend,
        priority: InsightPriority.normal,
        createdAt: DateTime.now(),
      ));
    } else if (weeklyTrend.direction == TrendDirection.declining &&
        weeklyTrend.percentage.abs() > 20) {
      insights.add(HabitInsight(
        id: '${habit.id}-trend-down',
        habitId: habit.id,
        title: 'Declining Trend',
        description:
            '"${habit.title}" has declined '
            '${weeklyTrend.percentage.abs().round()}% this week. '
            'Try to refocus on this habit.',
        type: InsightType.warning,
        priority: InsightPriority.normal,
        createdAt: DateTime.now(),
      ));
    }

    // Overall score insight
    if (stats.habitScore >= 80) {
      insights.add(HabitInsight(
        id: '${habit.id}-score-high',
        habitId: habit.id,
        title: 'Mastering "${habit.title}"',
        description:
            'Your habit score of ${stats.habitScore.round()} shows you\'ve '
            'mastered this habit. Consider increasing the difficulty or target.',
        type: InsightType.observation,
        priority: InsightPriority.low,
        createdAt: DateTime.now(),
        actionable: true,
        actionLabel: 'Increase Target',
      ));
    } else if (stats.habitScore < 30 && stats.totalDays > 10) {
      insights.add(HabitInsight(
        id: '${habit.id}-score-low',
        habitId: habit.id,
        title: 'Struggling with "${habit.title}"',
        description:
            'Your habit score of ${stats.habitScore.round()} suggests '
            'this habit needs a different approach. Try reducing the target '
            'or changing the schedule.',
        type: InsightType.recommendation,
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
        actionable: true,
        actionLabel: 'Simplify Habit',
      ));
    }

    return insights;
  }

  /// Generates overall insights across all habits.
  List<HabitInsight> generateOverallInsights(
    List<Habit> habits,
    Map<String, HabitStatistics> statsMap,
    Map<String, HabitTrend> weeklyTrends,
  ) {
    final insights = <HabitInsight>[];

    if (habits.isEmpty) return insights;

    // Total active habits
    final active = habits.where((h) => h.isActive).length;
    if (active > 0) {
      insights.add(HabitInsight(
        id: 'overview-active',
        habitId: 'overall',
        title: '$active Active Habits',
        description:
            'You are tracking $active habits. '
            'Consistency across all habits builds powerful routines.',
        type: InsightType.observation,
        priority: InsightPriority.normal,
        createdAt: DateTime.now(),
      ));
    }

    // Best performing habit
    Habit? bestHabit;
    double bestScore = 0;
    for (final habit in habits) {
      final stats = statsMap[habit.id];
      if (stats != null && stats.habitScore > bestScore) {
        bestScore = stats.habitScore;
        bestHabit = habit;
      }
    }
    if (bestHabit != null && bestScore >= 60) {
      insights.add(HabitInsight(
        id: 'overall-best',
        habitId: 'overall',
        title: 'Strongest Habit: ${bestHabit.title}',
        description:
            'Your strongest habit has a score of ${bestScore.round()}. '
            'Use this momentum to improve other habits.',
        type: InsightType.encouragement,
        priority: InsightPriority.normal,
        createdAt: DateTime.now(),
      ));
    }

    // Habits needing attention
    final struggling = habits.where((h) {
      final stats = statsMap[h.id];
      return stats != null && stats.habitScore < 30 && stats.totalDays > 5;
    }).toList();
    if (struggling.length == 1) {
      insights.add(HabitInsight(
        id: 'overall-attention',
        habitId: 'overall',
        title: '1 Habit Needs Attention',
        description:
            '"${struggling.first.title}" needs a different approach. '
            'Consider reducing frequency or target.',
        type: InsightType.recommendation,
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
      ));
    } else if (struggling.length > 1) {
      insights.add(HabitInsight(
        id: 'overall-attention',
        habitId: 'overall',
        title: '${struggling.length} Habits Need Attention',
        description:
            '${struggling.map((h) => '"${h.title}"').join(', ')} need '
            'a different approach. Focus on 1-2 at a time.',
        type: InsightType.recommendation,
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }

  // ── Reminder Planning ────────────────────────────────────────────

  /// Suggests an optimal reminder time based on habit completion patterns.
  ///
  /// Returns the most common completion hour (0-23), or null if no data.
  int? suggestReminderTime(
    Habit habit,
    List<HabitEntry> entries,
  ) {
    final relevant = entries
        .where((e) => e.habitId == habit.id && e.completed)
        .toList();
    if (relevant.isEmpty) return null;

    // Get the hour from the createdAt timestamp (best approximation)
    final hourCounts = <int, int>{};
    for (final entry in relevant) {
      if (entry.createdAt != null) {
        final hour = entry.createdAt!.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }
    if (hourCounts.isEmpty) return null;

    return hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // ── Habit Validation ─────────────────────────────────────────────

  /// Validates a habit and returns any issues.
  List<String> validateHabit(Habit habit) {
    final issues = <String>[];
    if (habit.title.trim().isEmpty) {
      issues.add('Habit title cannot be empty');
    }
    if (habit.targetPerDay < 1) {
      issues.add('Target must be at least 1');
    }
    return issues;
  }

  // ── Helpers ──────────────────────────────────────────────────────

  TrendDirection _determineDirection(double current, double previous) {
    const threshold = 0.05; // 5% change threshold
    if (current > previous + threshold) return TrendDirection.improving;
    if (current < previous - threshold) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  DateTime _parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
