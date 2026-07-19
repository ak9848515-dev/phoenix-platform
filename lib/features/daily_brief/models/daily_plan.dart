import 'daily_priority.dart';
import 'daily_schedule.dart';
import 'daily_task.dart';

/// The full daily plan — an ordered collection of tasks.
///
/// Organises tasks into priority tiers and time slots
/// for deterministic presentation.
class DailyPlan {
  const DailyPlan({
    this.tasks = const <DailyTask>[],
  });

  final List<DailyTask> tasks;

  /// High-priority tasks.
  List<DailyTask> get highPriority =>
      tasks.where((t) => t.priority == DailyPriority.high).toList();

  /// Medium-priority tasks.
  List<DailyTask> get mediumPriority =>
      tasks.where((t) => t.priority == DailyPriority.medium).toList();

  /// Low-priority tasks.
  List<DailyTask> get lowPriority =>
      tasks.where((t) => t.priority == DailyPriority.low).toList();

  /// Tasks scheduled for morning.
  List<DailyTask> get morning =>
      tasks.where((t) => t.schedule == DailySchedule.morning).toList();

  /// Tasks scheduled for afternoon.
  List<DailyTask> get afternoon =>
      tasks.where((t) => t.schedule == DailySchedule.afternoon).toList();

  /// Tasks scheduled for evening.
  List<DailyTask> get evening =>
      tasks.where((t) => t.schedule == DailySchedule.evening).toList();

  /// Unscheduled / flexible tasks.
  List<DailyTask> get flexible =>
      tasks.where((t) => t.schedule == DailySchedule.flexible).toList();

  /// Completed tasks.
  List<DailyTask> get completed =>
      tasks.where((t) => t.completed).toList();

  /// Incomplete tasks.
  List<DailyTask> get incomplete =>
      tasks.where((t) => !t.completed).toList();

  /// Total tasks.
  int get total => tasks.length;

  /// Completed count.
  int get completedCount => completed.length;

  /// Completion percentage (0.0–1.0).
  double get completionRatio =>
      total > 0 ? completedCount / total : 0.0;

  /// Total estimated minutes.
  int get totalMinutes =>
      tasks.fold<int>(0, (sum, t) => sum + t.estimatedMinutes);

  /// Total estimated XP.
  int get totalXp =>
      tasks.fold<int>(0, (sum, t) => sum + t.xpReward);
}
