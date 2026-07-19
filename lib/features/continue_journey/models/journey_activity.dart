import 'journey_resume_point.dart';

/// A single activity the user has started but not completed.
///
/// Tracks what the user was doing, progress made, and when
/// they last interacted with it.
class JourneyActivity {
  const JourneyActivity({
    required this.id,
    required this.title,
    required this.type,
    this.description = '',
    this.progressPercent = 0.0,
    this.estimatedMinutesRemaining = 0,
    this.lastActive,
    this.created,
    this.xpReward = 0,
    this.growthImpact = 0.0,
    this.relatedMissionId,
    this.route = '',
  });

  /// Unique identifier for this activity.
  final String id;

  /// Display title.
  final String title;

  /// The type of resume point.
  final JourneyResumePoint type;

  /// Short description.
  final String description;

  /// Progress made so far (0.0–1.0).
  final double progressPercent;

  /// Estimated remaining time in minutes.
  final int estimatedMinutesRemaining;

  /// When the user last interacted with this activity.
  final DateTime? lastActive;

  /// When this activity was first started.
  final DateTime? created;

  /// XP reward for completing this activity.
  final int xpReward;

  /// Growth impact on completion (0.0–1.0).
  final double growthImpact;

  /// The mission this activity belongs to, if any.
  final String? relatedMissionId;

  /// The route to navigate to resume this activity.
  final String route;

  /// Create a copy with updated fields.
  JourneyActivity copyWith({
    String? id,
    String? title,
    JourneyResumePoint? type,
    String? description,
    double? progressPercent,
    int? estimatedMinutesRemaining,
    DateTime? lastActive,
    DateTime? created,
    int? xpReward,
    double? growthImpact,
    String? relatedMissionId,
    String? route,
  }) =>
      JourneyActivity(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        description: description ?? this.description,
        progressPercent: progressPercent ?? this.progressPercent,
        estimatedMinutesRemaining:
            estimatedMinutesRemaining ?? this.estimatedMinutesRemaining,
        lastActive: lastActive ?? this.lastActive,
        created: created ?? this.created,
        xpReward: xpReward ?? this.xpReward,
        growthImpact: growthImpact ?? this.growthImpact,
        relatedMissionId: relatedMissionId ?? this.relatedMissionId,
        route: route ?? this.route,
      );

  @override
  String toString() =>
      'JourneyActivity(id: $id, title: $title, type: ${type.name}, '
      'progress: ${(progressPercent * 100).round()}%)';
}
