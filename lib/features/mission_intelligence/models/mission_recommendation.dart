import 'package:phoenix_platform/features/mission_engine/mission_engine.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_difficulty.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_priority.dart';
import '../models/mission_impact.dart';
import '../models/mission_score.dart';

/// A mission recommendation produced by a [MissionRule].
///
/// Contains the full recommendation metadata including why it was chosen,
/// what impact it will have, and what becomes available after completion.
class MissionRecommendation {
  const MissionRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.difficulty,
    required this.estimatedDuration,
    required this.rewardXP,
    required this.reason,
    required this.score,
    required this.impact,
    this.confidence = 0.5,
    this.unlocks = const [],
    this.ruleName = '',
    this.prerequisites = const [],
  });

  /// Unique identifier for this recommendation.
  final String id;

  /// Short, actionable title.
  final String title;

  /// Detailed description of what the mission entails.
  final String description;

  /// The mission category.
  final MissionCategory category;

  /// Priority level.
  final MissionPriority priority;

  /// Difficulty level.
  final MissionDifficulty difficulty;

  /// Estimated time to complete in minutes.
  final int estimatedDuration;

  /// XP awarded on completion.
  final int rewardXP;

  /// Human-readable explanation: "Why this mission?"
  final String reason;

  /// Scoring details for ranking.
  final MissionScore score;

  /// Impact assessment.
  final MissionImpact impact;

  /// Confidence in this recommendation (0.0–1.0).
  final double confidence;

  /// What becomes available after completing this mission.
  final List<String> unlocks;

  /// Which rule generated this recommendation.
  final String ruleName;

  /// IDs of missions that must be completed first.
  final List<String> prerequisites;

  /// Whether this recommendation has all required prerequisites met.
  bool get isAvailable => prerequisites.isEmpty;

  /// Converts this recommendation to a [Mission] entity.
  Mission toMission() => Mission(
        id: id,
        title: title,
        description: description,
        category: category,
        priority: priority,
        difficulty: difficulty,
        estimatedDuration: estimatedDuration,
        rewardXP: rewardXP,
        recommendationReason: reason,
        sourceService: 'mission_intelligence',
      );

  @override
  String toString() =>
      'MissionRecommendation(id: $id, title: $title, '
      'priority: $priority, confidence: $confidence)';
}
