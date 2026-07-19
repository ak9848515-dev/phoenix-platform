import 'portfolio_enums.dart';

/// An intelligent project recommendation with estimated impact.
class ProjectRecommendation {
  const ProjectRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.difficulty,
    required this.estimatedTime,
    this.careerImpact = 0.0,
    this.resumeImpact = 0.0,
    this.portfolioImpact = 0.0,
    this.overallImpact = 0.0,
    this.technologies = const [],
    this.skillsTargeted = const [],
    this.learningPrerequisites = const [],
    this.gapsAddressed = const [],
    this.reason,
    this.actionRoute,
  });

  /// Unique identifier.
  final String id;

  /// Project title (e.g., 'Build a RAP Inventory System').
  final String title;

  /// Short description of what to build.
  final String description;

  /// Priority level.
  final RecommendationPriority priority;

  /// Difficulty level: 'beginner', 'intermediate', 'advanced'.
  final String difficulty;

  /// Estimated time to complete (hours).
  final int estimatedTime;

  /// Impact on career readiness (0.0-1.0).
  final double careerImpact;

  /// Impact on resume quality (0.0-1.0).
  final double resumeImpact;

  /// Impact on portfolio score (0.0-1.0).
  final double portfolioImpact;

  /// Overall weighted impact.
  final double overallImpact;

  /// Technologies used in this project.
  final List<String> technologies;

  /// Skills this project demonstrates.
  final List<String> skillsTargeted;

  /// Prerequisites for this project.
  final List<String> learningPrerequisites;

  /// Skill gaps this project helps close.
  final List<String> gapsAddressed;

  /// Why this project is recommended.
  final String? reason;

  /// Navigation route to start this project.
  final String? actionRoute;

  /// Display-friendly difficulty label.
  String get difficultyLabel {
    switch (difficulty) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return difficulty;
    }
  }

  @override
  String toString() =>
      'ProjectRecommendation($title, $difficulty, '
      'impact: $overallImpact)';
}
