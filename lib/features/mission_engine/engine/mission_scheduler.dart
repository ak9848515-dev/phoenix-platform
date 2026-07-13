import '../models/mission_category.dart';
import '../models/mission_status.dart';
import '../mission_engine.dart';

/// Handles mission scheduling — daily, weekly, one-time, and recurring.
///
/// The scheduler determines which missions should be active today,
/// which need to be refreshed, and which recurrence cycles apply.
class MissionScheduler {
  /// Returns missions that should be active today.
  List<Mission> getTodaysMissions(List<Mission> allMissions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allMissions.where((mission) {
      // Always include pending/in-progress missions
      if (mission.isActionable) return true;

      // Include recurring missions whose next cycle is today
      if (mission.recurring &&
          mission.recurrenceIntervalDays != null &&
          mission.completedDate != null) {
        final nextDue = mission.completedDate!
            .add(Duration(days: mission.recurrenceIntervalDays!));
        final nextDueDate = DateTime(nextDue.year, nextDue.month, nextDue.day);
        if (!nextDueDate.isAfter(today)) return true;
      }

      // Include missions due today
      if (mission.dueDate != null) {
        final dueDate =
            DateTime(mission.dueDate!.year, mission.dueDate!.month, mission.dueDate!.day);
        if (dueDate == today) return true;
      }

      return false;
    }).toList();
  }

  /// Returns missions scheduled for the upcoming week.
  List<Mission> getUpcomingMissions(List<Mission> allMissions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    return allMissions.where((mission) {
      if (mission.dueDate == null) return false;
      final dueDate = DateTime(
        mission.dueDate!.year,
        mission.dueDate!.month,
        mission.dueDate!.day,
      );
      return dueDate.isAfter(today) && !dueDate.isAfter(weekEnd);
    }).toList();
  }

  /// Generates a fresh set of daily missions based on the schedule.
  List<Mission> generateDailyBatch({
    required List<Mission> existingMissions,
    required List<Mission> availableTemplates,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Collect existing daily missions for today
    final existingDaily = existingMissions
        .where((m) =>
            m.category == MissionCategory.daily &&
            m.createdDate != null)
        .where((m) {
      final created =
          DateTime(m.createdDate!.year, m.createdDate!.month, m.createdDate!.day);
      return created == today;
    }).toList();

    if (existingDaily.isNotEmpty) return existingDaily;

    // Create new daily missions from templates
    final dailyTemplates = availableTemplates
        .where((m) => m.category == MissionCategory.daily)
        .toList();

    return dailyTemplates.map((template) {
      return template.copyWith(
        id: 'daily-${today.toIso8601String()}-${template.id}',
        status: _resolveStatus(template),
        createdDate: now,
        dueDate: today.add(const Duration(days: 1)),
        progress: 0.0,
        completedDate: null,
      );
    }).toList();
  }

  /// Checks if a recurring mission should be refreshed.
  bool shouldRefresh(Mission mission) {
    if (!mission.recurring || mission.recurrenceIntervalDays == null) {
      return false;
    }
    if (mission.completedDate == null) {
      // Not yet completed — don't refresh until completed
      return false;
    }

    final nextDue =
        mission.completedDate!
            .add(Duration(days: mission.recurrenceIntervalDays!));
    return !nextDue.isAfter(DateTime.now());
  }

  /// Refreshes a recurring mission for a new cycle.
  Mission refreshMission(Mission mission) {
    if (!shouldRefresh(mission)) return mission;

    return mission.copyWith(
      status: MissionStatus.available,
      progress: 0.0,
      completedDate: null,
    );
  }

  MissionStatus _resolveStatus(Mission template) {
    if (template.dependencyMissionId != null) {
      return MissionStatus.blocked;
    }
    return MissionStatus.pending;
  }
}
