import '../mission_engine.dart' as model;
import '../models/mission_status.dart';
import 'mission_generator.dart';
import 'mission_prioritizer.dart';
import 'mission_scheduler.dart';

/// The Dynamic Mission Engine — single source of truth for all missions.
///
/// The Mission Engine owns:
/// - Mission generation
/// - Mission prioritization
/// - Mission scheduling
/// - Mission completion
/// - Mission recurrence
/// - Mission rewards
/// - Mission difficulty
/// - Mission dependencies
///
/// No other module should implement these rules.
class MissionEngine {
  MissionEngine({
    required this._generator,
    required this._prioritizer,
    required this._scheduler,
  });

  final MissionGenerator _generator;
  final MissionPrioritizer _prioritizer;
  final MissionScheduler _scheduler;

  // ── Generation ────────────────────────────────────────────────────

  /// Generates new missions from all platform services.
  List<model.Mission> generateMissions({
    required List<model.Mission> currentMissions,
    int maxMissions = 12,
  }) {
    return _generator.generateAll(
      currentMissions: currentMissions,
      maxMissions: maxMissions,
    );
  }

  // ── Prioritization ────────────────────────────────────────────────

  /// Returns missions sorted by priority (highest first).
  List<model.Mission> prioritizeMissions(List<model.Mission> missions) {
    return _prioritizer.prioritize(missions);
  }

  /// Returns the single highest-priority actionable mission.
  model.Mission? findTopPriority(List<model.Mission> missions) {
    return _prioritizer.findTopPriority(missions);
  }

  // ── Scheduling ────────────────────────────────────────────────────

  /// Returns missions that should be active today.
  List<model.Mission> getTodaysMissions(List<model.Mission> allMissions) {
    return _scheduler.getTodaysMissions(allMissions);
  }

  /// Returns upcoming missions for the next 7 days.
  List<model.Mission> getUpcomingMissions(List<model.Mission> allMissions) {
    return _scheduler.getUpcomingMissions(allMissions);
  }

  /// Generates a daily batch of missions from templates.
  List<model.Mission> generateDailyBatch({
    required List<model.Mission> existingMissions,
    required List<model.Mission> availableTemplates,
  }) {
    return _scheduler.generateDailyBatch(
      existingMissions: existingMissions,
      availableTemplates: availableTemplates,
    );
  }

  /// Refreshes recurring missions that are due for a new cycle.
  List<model.Mission> refreshRecurring(List<model.Mission> missions) {
    return missions.map((m) => _scheduler.refreshMission(m)).toList();
  }

  /// Checks if a recurring mission should be refreshed.
  bool shouldRefresh(model.Mission mission) {
    return _scheduler.shouldRefresh(mission);
  }

  // ── Completion ────────────────────────────────────────────────────

  /// Completes a mission and returns the updated mission with reward XP.
  ///
  /// The UI simply triggers completion. The engine handles all logic:
  /// - Sets status to completed
  /// - Records completed date
  /// - Sets progress to 1.0
  /// - Handles recurrence for recurring missions
  /// - Unblocks dependent missions
  (model.Mission mission, int xpAwarded) completeMission(
    model.Mission mission, {
    bool completeRecurring = false,
  }) {
    var updated = mission.copyWith(
      status: MissionStatus.completed,
      completedDate: DateTime.now(),
      progress: 1.0,
    );

    // For recurring missions, immediately set up the next cycle
    if (mission.recurring && !completeRecurring) {
      updated = updated.copyWith(
        status: MissionStatus.available,
        progress: 0.0,
        completedDate: DateTime.now(),
      );
    }

    return (updated, mission.rewardXP);
  }

  /// Marks a mission as skipped.
  model.Mission skipMission(model.Mission mission) {
    return mission.copyWith(
      status: MissionStatus.skipped,
      progress: 0.0,
    );
  }

  /// Updates a mission's progress fraction.
  model.Mission updateProgress(model.Mission mission, double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    final newStatus = clamped >= 1.0
        ? MissionStatus.completed
        : clamped > 0.0
            ? MissionStatus.inProgress
            : MissionStatus.pending;

    return mission.copyWith(
      progress: clamped,
      status: newStatus,
      completedDate: clamped >= 1.0 ? DateTime.now() : null,
    );
  }

  /// Unblocks missions whose dependency has been completed.
  List<model.Mission> unblockDependents({
    required String completedMissionId,
    required List<model.Mission> allMissions,
  }) {
    return allMissions.map((mission) {
      if (mission.dependencyMissionId == completedMissionId &&
          mission.isBlocked) {
        return mission.copyWith(status: MissionStatus.pending);
      }
      return mission;
    }).toList();
  }

  // ── Validation ────────────────────────────────────────────────────

  /// Validates a mission has all required fields populated.
  /// Returns null if valid, or an error message if invalid.
  String? validateMission(model.Mission mission) {
    if (mission.id.isEmpty) return 'Mission ID cannot be empty.';
    if (mission.title.isEmpty) return 'Mission title cannot be empty.';
    if (mission.description.isEmpty) {
      return 'Mission description cannot be empty.';
    }
    if (mission.estimatedDuration <= 0) {
      return 'Estimated duration must be positive.';
    }
    if (mission.rewardXP < 0) return 'Reward XP cannot be negative.';
    if (mission.progress < 0.0 || mission.progress > 1.0) {
      return 'Progress must be between 0.0 and 1.0.';
    }
    if (mission.recurring &&
        mission.recurrenceIntervalDays != null &&
        mission.recurrenceIntervalDays! < 1) {
      return 'Recurrence interval must be at least 1 day.';
    }
    return null;
  }
}
