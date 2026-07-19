/// An intelligent career recommendation with estimated impact.
class CareerRecommendation {
  const CareerRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    this.impact = 0.0,
    this.estimatedWeeks = 0,
    this.skillsAddressed = const [],
    this.prerequisites = const [],
    this.route,
  });

  /// Unique identifier.
  final String id;

  /// Recommendation type: 'learn_skill', 'build_project', 'update_resume',
  /// 'practice_interview', 'get_certified', 'network', 'apply',
  /// 'improve_portfolio', 'career_change', 'skill_focus'.
  final String type;

  /// Recommendation title.
  final String title;

  /// Detailed description.
  final String description;

  /// Priority level.
  final CareerRecommendationPriority priority;

  /// Estimated impact on career readiness (0.0-1.0).
  final double impact;

  /// Estimated weeks to complete.
  final int estimatedWeeks;

  /// Skills this recommendation addresses.
  final List<String> skillsAddressed;

  /// Prerequisites for this recommendation.
  final List<String> prerequisites;

  /// Navigation route to execute this recommendation.
  final String? route;

  /// Human-readable type label.
  String get typeLabel {
    switch (type) {
      case 'learn_skill':
        return 'Learn Skill';
      case 'build_project':
        return 'Build Project';
      case 'update_resume':
        return 'Update Resume';
      case 'practice_interview':
        return 'Practice Interviews';
      case 'get_certified':
        return 'Get Certified';
      case 'network':
        return 'Network';
      case 'apply':
        return 'Apply';
      case 'improve_portfolio':
        return 'Improve Portfolio';
      case 'career_change':
        return 'Career Pivot';
      case 'skill_focus':
        return 'Focus Area';
      default:
        return type;
    }
  }

  /// Icon name for display.
  String get iconName {
    switch (type) {
      case 'learn_skill':
        return 'school';
      case 'build_project':
        return 'construction';
      case 'update_resume':
        return 'description';
      case 'practice_interview':
        return 'record_voice_over';
      case 'get_certified':
        return 'verified';
      case 'network':
        return 'groups';
      case 'apply':
        return 'send';
      case 'improve_portfolio':
        return 'folder';
      case 'career_change':
        return 'sync_alt';
      case 'skill_focus':
        return 'psychology';
      default:
        return 'lightbulb';
    }
  }

  @override
  String toString() =>
      'CareerRecommendation($type: $title, priority: ${priority.displayName})';
}

/// Priority for career recommendations.
enum CareerRecommendationPriority {
  critical,
  high,
  medium,
  low;

  int get weight {
    switch (this) {
      case CareerRecommendationPriority.critical:
        return 100;
      case CareerRecommendationPriority.high:
        return 75;
      case CareerRecommendationPriority.medium:
        return 50;
      case CareerRecommendationPriority.low:
        return 25;
    }
  }

  String get displayName {
    switch (this) {
      case CareerRecommendationPriority.critical:
        return 'Critical';
      case CareerRecommendationPriority.high:
        return 'High';
      case CareerRecommendationPriority.medium:
        return 'Medium';
      case CareerRecommendationPriority.low:
        return 'Low';
    }
  }
}
