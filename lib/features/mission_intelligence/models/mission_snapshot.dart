import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_difficulty.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_priority.dart';

import '../models/mission_evaluation.dart';
import '../models/mission_history.dart';
import '../models/mission_recommendation.dart';

/// Read-only snapshot of the current mission intelligence state.
///
/// Consumers (Dashboard, Recommendation Engine, Daily Brief, etc.) read this
/// snapshot instead of querying mission rules directly.
///
/// Immutable. Produced by [MissionIntelligenceEngine.evaluate].
class MissionSnapshot {
  const MissionSnapshot({
    this.currentMission,
    this.alternatives = const [],
    this.topMission,
    this.category,
    this.priority,
    this.difficulty,
    this.estimatedDuration = 0,
    this.rewardXP = 0,
    this.prerequisites = const [],
    this.completionPercent = 0.0,
    this.impactScore = 0.0,
    this.confidence = 0.0,
    this.reason = '',
    this.unlocks = const [],
    this.lastEvaluation,
    this.lastUpdated,
    this.history = const MissionHistory(),
    this.evaluation,
    this.rejectedRules = const [],
  });

  /// The currently active/recommended mission.
  final MissionRecommendation? currentMission;

  /// Alternative recommendations.
  final List<MissionRecommendation> alternatives;

  /// The overall top mission (same as currentMission for now).
  final MissionRecommendation? topMission;

  /// Category of the current mission.
  final MissionCategory? category;

  /// Priority of the current mission.
  final MissionPriority? priority;

  /// Difficulty of the current mission.
  final MissionDifficulty? difficulty;

  /// Estimated duration in minutes.
  final int estimatedDuration;

  /// XP reward.
  final int rewardXP;

  /// Prerequisite mission IDs.
  final List<String> prerequisites;

  /// Completion percentage (0.0–1.0).
  final double completionPercent;

  /// Overall impact score (0.0–1.0).
  final double impactScore;

  /// Confidence in the recommendation (0.0–1.0).
  final double confidence;

  /// Human-readable reason for the recommendation.
  final String reason;

  /// What becomes available after completion.
  final List<String> unlocks;

  /// When the last evaluation was performed.
  final DateTime? lastEvaluation;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  /// Mission recommendation history.
  final MissionHistory history;

  /// The full evaluation result.
  final MissionEvaluation? evaluation;

  /// Rules that were rejected with reasons.
  final List<String> rejectedRules;

  /// Whether there is an active recommendation.
  bool get hasActiveRecommendation => currentMission != null;

  /// Whether there are alternative recommendations.
  bool get hasAlternatives => alternatives.isNotEmpty;

  /// Whether any recommendation exists.
  bool get hasAnyRecommendation =>
      hasActiveRecommendation || hasAlternatives;

  @override
  String toString() =>
      'MissionSnapshot(hasMission: $hasActiveRecommendation, '
      'alternatives: ${alternatives.length}, '
      'confidence: ${(confidence * 100).round()}%)';
}
