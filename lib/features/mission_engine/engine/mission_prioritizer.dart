import '../models/mission_priority.dart';
import '../mission_engine.dart';
import '../models/mission_category.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../growth_index/models/growth_dimension.dart';

/// Calculates mission priority based on mission properties and context.
///
/// Priority is NEVER calculated inside UI or widgets.
/// Only the Mission Engine computes priority.
///
/// The prioritizer scores missions for sorting. The raw score is used for
/// ordering; the priority enum reflects the mission's inherent priority
/// level (critical > high > medium > low), which is set during generation.
class MissionPrioritizer {
  MissionPrioritizer({
    this._growthEngine,
  });

  final GrowthIndexEngine? _growthEngine;

  // ── Public API ────────────────────────────────────────────────────

  /// Returns the mission's inherent priority level.
  /// The priority was set during generation and reflects the mission's
  /// base importance. The prioritizer does NOT recalculate this.
  MissionPriority calculatePriority(Mission mission) {
    return mission.priority;
  }

  /// Sorts missions by score (highest priority first).
  /// Score combines priority weight, due-date urgency, difficulty,
  /// and growth-aware boost for missions addressing weak areas.
  List<Mission> prioritize(List<Mission> missions) {
    final scored = missions.map((m) => _ScoredMission(m, _calculateScore(m)));
    final sorted = scored.toList();
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted.map((s) => s.mission).toList();
  }

  /// Returns the highest-priority actionable mission.
  Mission? findTopPriority(List<Mission> missions) {
    final actionable = missions.where((m) => m.isActionable).toList();
    if (actionable.isEmpty) return null;
    return prioritize(actionable).first;
  }

  // ── Scoring (for sorting) ─────────────────────────────────────────

  int _calculateScore(Mission mission) {
    var score = 0;

    // 1. Base priority weight (1-4)
    score += mission.priority.weight * 100;

    // 2. Due date urgency
    if (mission.dueDate != null) {
      final daysUntilDue = mission.dueDate!.difference(DateTime.now()).inDays;
      if (daysUntilDue < 0) {
        score += 40; // overdue
      } else if (daysUntilDue == 0) {
        score += 30; // due today
      } else if (daysUntilDue <= 2) {
        score += 20; // due soon
      } else {
        score += 10; // due later
      }
    }

    // 3. Difficulty boost — harder missions score higher
    score += mission.difficulty.xpMultiplier.round();

    // 4. Recurring missions that are due get a small boost
    if (mission.recurring && mission.completedDate != null) {
      score += 5;
    }

    // 5. Growth-aware boost — missions addressing weak areas score higher
    final growthBoost = _growthBoost(mission);
    score += growthBoost;

    return score;
  }

  /// Computes a growth-aware score boost for this mission.
  ///
  /// Missions whose category matches the weakest growth dimension get a
  /// +30 boost. Missions related to the second-weakest get +15.
  int _growthBoost(Mission mission) {
    final engine = _growthEngine;
    if (engine == null || engine.snapshot == null) return 0;

    final snapshot = engine.snapshot!;
    final weakest = snapshot.weakestDimension;

    // Find second weakest
    final sorted = snapshot.allMetrics
        .toList()
      ..sort((a, b) => a.score.compareTo(b.score));
    final secondWeakest = sorted.length > 1 ? sorted[1] : null;

    final missionDim = _categoryToGrowthDimension(mission.category);

    if (missionDim == weakest.dimension) return 30;
    if (secondWeakest != null && missionDim == secondWeakest.dimension) {
      return 15;
    }
    return 0;
  }

  /// Maps a [MissionCategory] to the closest [GrowthDimension].
  GrowthDimension _categoryToGrowthDimension(MissionCategory category) {
    switch (category) {
      case MissionCategory.learning:
        return GrowthDimension.knowledge;
      case MissionCategory.practice:
        return GrowthDimension.skills;
      case MissionCategory.build:
        return GrowthDimension.projects;
      case MissionCategory.portfolio:
        return GrowthDimension.portfolio;
      case MissionCategory.resume:
        return GrowthDimension.career;
      case MissionCategory.interview:
        return GrowthDimension.interview;
      case MissionCategory.career:
        return GrowthDimension.career;
      case MissionCategory.habit:
        return GrowthDimension.habits;
      case MissionCategory.reflection:
        return GrowthDimension.knowledge;
      case MissionCategory.daily:
        return GrowthDimension.habits;
      case MissionCategory.weekly:
        return GrowthDimension.mission;
      case MissionCategory.custom:
        return GrowthDimension.overall;
    }
  }
}

/// Internal helper to pair a mission with its computed score.
class _ScoredMission {
  _ScoredMission(this.mission, this.score);
  final Mission mission;
  final int score;
}
