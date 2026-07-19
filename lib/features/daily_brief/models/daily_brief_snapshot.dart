import 'daily_plan.dart';
import 'daily_progress.dart';
import 'daily_insight.dart';
import 'daily_history.dart';

/// Read-only snapshot of the daily brief for consumers.
///
/// Dashboard, Notifications, AI Mentor, etc. read this snapshot
/// instead of querying engines directly.
///
/// Immutable. Produced by [DailyBriefEngine.buildBrief].
class DailyBriefSnapshot {
  const DailyBriefSnapshot({
    this.todaysFocus = '',
    this.todaysMission = '',
    this.todaysGoal = '',
    this.plan = const DailyPlan(),
    this.insights = const <DailyInsight>[],
    this.totalMinutes = 0,
    this.totalXp = 0,
    this.expectedGrowth = 0.0,
    this.completionPercent = 0.0,
    this.progress,
    this.lastUpdated,
    this.history = const DailyHistory(),
    this.date = '',
  });

  /// Today's single focus statement.
  final String todaysFocus;

  /// Today's primary mission title.
  final String todaysMission;

  /// Today's goal description.
  final String todaysGoal;

  /// The full daily plan.
  final DailyPlan plan;

  /// Generated insights.
  final List<DailyInsight> insights;

  /// Total estimated minutes.
  final int totalMinutes;

  /// Total expected XP.
  final int totalXp;

  /// Expected growth impact (0.0–1.0).
  final double expectedGrowth;

  /// Current completion percentage.
  final double completionPercent;

  /// End-of-day progress (set after day completes).
  final DailyProgress? progress;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  /// Daily brief history.
  final DailyHistory history;

  /// Date string (YYYY-MM-DD).
  final String date;

  /// Whether there are tasks for today.
  bool get hasTasks => plan.total > 0;

  /// Whether today's brief has been created.
  bool get hasBrief => todaysFocus.isNotEmpty;

  @override
  String toString() =>
      'DailyBriefSnapshot(date: $date, focus: $todaysFocus, '
      'tasks: ${plan.total}, xp: $totalXp)';
}
