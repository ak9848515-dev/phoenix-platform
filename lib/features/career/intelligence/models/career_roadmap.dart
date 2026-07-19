/// A career roadmap covering a specific time horizon.
///
/// Each roadmap contains milestones for learning, projects,
/// certifications, interview preparation, and portfolio improvements.
class CareerRoadmap {
  const CareerRoadmap({
    required this.id,
    required this.horizonDays,
    required this.title,
    required this.description,
    this.milestones = const [],
    this.completion = 0.0,
    this.createdAt,
  });

  /// Unique identifier.
  final String id;

  /// Time horizon in days: 30, 90, 180, or 365.
  final int horizonDays;

  /// Human-readable title.
  final String title;

  /// Description of this phase.
  final String description;

  /// Milestones to complete in this horizon.
  final List<RoadmapMilestone> milestones;

  /// Overall completion percentage (0.0-1.0).
  final double completion;

  /// When this roadmap was created.
  final DateTime? createdAt;

  /// Count of completed milestones.
  int get completedCount => milestones.where((m) => m.isCompleted).length;

  /// Count of total milestones.
  int get totalCount => milestones.length;

  /// Whether all milestones are completed.
  bool get isComplete => completedCount == totalCount && totalCount > 0;

  /// Human-readable horizon label.
  String get horizonLabel {
    switch (horizonDays) {
      case 30:
        return '30-Day Plan';
      case 90:
        return '90-Day Plan';
      case 180:
        return '6-Month Plan';
      case 365:
        return '12-Month Plan';
      default:
        return '$horizonDays-Day Plan';
    }
  }

  @override
  String toString() =>
      'CareerRoadmap($horizonLabel: ${milestones.length} milestones, '
      'completion: ${(completion * 100).round()}%)';
}

/// A single milestone in a career roadmap.
class RoadmapMilestone {
  const RoadmapMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.estimatedDays = 0,
    this.isCompleted = false,
    this.dependsOn = const [],
    this.route,
  });

  /// Unique identifier.
  final String id;

  /// Human-readable title.
  final String title;

  /// Detailed description.
  final String description;

  /// Category: 'learning', 'project', 'certification', 'interview',
  /// 'portfolio', 'networking', 'assessment', 'resume', 'application'.
  final String category;

  /// Estimated days to complete this milestone.
  final int estimatedDays;

  /// Whether this milestone has been completed.
  final bool isCompleted;

  /// IDs of milestones that must be completed first.
  final List<String> dependsOn;

  /// Navigation route for this milestone.
  final String? route;

  /// Human-readable category label.
  String get categoryLabel {
    switch (category) {
      case 'learning':
        return 'Learning';
      case 'project':
        return 'Project';
      case 'certification':
        return 'Certification';
      case 'interview':
        return 'Interview Prep';
      case 'portfolio':
        return 'Portfolio';
      case 'networking':
        return 'Networking';
      case 'assessment':
        return 'Assessment';
      case 'resume':
        return 'Resume';
      case 'application':
        return 'Application';
      default:
        return category;
    }
  }

  @override
  String toString() =>
      'RoadmapMilestone($title, $category, ${isCompleted ? "done" : "pending"})';
}
