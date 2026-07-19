import '../../../shared/infrastructure/ai_content/metadata.dart';
import '../mission_engine.dart' as model;

/// Immutable snapshot of the mission engine state.
///
/// Consumed by widgets, the AI Context Engine, and reports.
/// Never contains mutable state.
///
/// **Architecture:**
/// ```
/// MissionEngine → MissionSnapshot → Widgets
/// ```
class MissionSnapshot {
  const MissionSnapshot({
    required this.currentMission,
    required this.upcomingMissions,
    required this.completedMissions,
    required this.activeMissions,
    required this.totalMissions,
    required this.completedCount,
    required this.activeCount,
    required this.completionRatio,
    required this.aiGeneratedCount,
    required this.lastUpdated,
    this.aiMetadata = const [],
  });

  /// The single highest-priority actionable mission.
  final model.Mission? currentMission;

  /// Missions scheduled for the next 7 days.
  final List<model.Mission> upcomingMissions;

  /// Missions that have been completed.
  final List<model.Mission> completedMissions;

  /// Missions currently in-progress or pending.
  final List<model.Mission> activeMissions;

  /// Total number of missions.
  final int totalMissions;

  /// Number of completed missions.
  final int completedCount;

  /// Number of active missions.
  final int activeCount;

  /// Completion ratio (0.0–1.0).
  final double completionRatio;

  /// Number of AI-generated missions currently stored.
  final int aiGeneratedCount;

  /// When this snapshot was built.
  final DateTime lastUpdated;

  /// AI metadata for AI-generated missions.
  final List<AIContentMetadata> aiMetadata;

  /// Whether there are any missions.
  bool get hasMissions => totalMissions > 0;

  /// Whether there is a current mission to work on.
  bool get hasCurrentMission => currentMission != null;

  /// Human-readable summary of mission progress.
  String get summary =>
      '$completedCount of $totalMissions missions complete';

  @override
  String toString() =>
      'MissionSnapshot(current: ${currentMission?.title ?? "none"}, '
      'active: $activeCount, completed: $completedCount/$totalMissions, '
      'ai: $aiGeneratedCount)';
}
