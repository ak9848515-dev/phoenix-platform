import 'daily_priority.dart';
import 'daily_schedule.dart';

/// A single task within the daily brief.
///
/// Contains all metadata for display: what, why, how long, impact.
class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    this.schedule = DailySchedule.flexible,
    this.estimatedMinutes = 0,
    this.xpReward = 0,
    this.impact = 0.0,
    this.reason = '',
    this.relatedMissionId,
    this.completed = false,
  });

  final String id;
  final String title;
  final String description;
  final DailyPriority priority;
  final String category;
  final DailySchedule schedule;
  final int estimatedMinutes;
  final int xpReward;
  final double impact;
  final String reason;
  final String? relatedMissionId;
  final bool completed;

  DailyTask copyWith({bool? completed}) => DailyTask(
        id: id,
        title: title,
        description: description,
        priority: priority,
        category: category,
        schedule: schedule,
        estimatedMinutes: estimatedMinutes,
        xpReward: xpReward,
        impact: impact,
        reason: reason,
        relatedMissionId: relatedMissionId,
        completed: completed ?? this.completed,
      );

  @override
  String toString() =>
      'DailyTask(id: $id, title: $title, priority: ${priority.name})';
}
