import 'interview_enums.dart';

/// An intelligent recommendation for interview preparation.
///
/// Each recommendation includes an action type, priority, impact estimate,
/// and a route for deep linking into the relevant screen.
class InterviewRecommendation {
  const InterviewRecommendation({
    required this.id,
    required this.title,
    required this.description,
    this.actionType = InterviewActionType.practice,
    this.priority = 0.5,
    this.impact = 0.5,
    this.estimatedMinutes = 30,
    this.route,
    this.relatedTopics = const [],
  });

  /// Unique identifier.
  final String id;

  /// Recommendation title.
  final String title;

  /// Detailed description of the recommended action.
  final String description;

  /// Type of action to take.
  final InterviewActionType actionType;

  /// Priority score (0.0 – 1.0). Higher = more urgent.
  final double priority;

  /// Estimated impact on readiness (0.0 – 1.0).
  final double impact;

  /// Estimated time to complete in minutes.
  final int estimatedMinutes;

  /// Deep-link route for navigation.
  final String? route;

  /// Topics this recommendation relates to.
  final List<String> relatedTopics;

  /// Creates a copy with the given fields replaced.
  InterviewRecommendation copyWith({
    String? id,
    String? title,
    String? description,
    InterviewActionType? actionType,
    double? priority,
    double? impact,
    int? estimatedMinutes,
    String? route,
    List<String>? relatedTopics,
  }) {
    return InterviewRecommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      actionType: actionType ?? this.actionType,
      priority: priority ?? this.priority,
      impact: impact ?? this.impact,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      route: route ?? this.route,
      relatedTopics: relatedTopics ?? this.relatedTopics,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InterviewRecommendation && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InterviewRecommendation(id: $id, title: $title, priority: $priority)';
}
