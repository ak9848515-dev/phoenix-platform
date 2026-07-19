/// Priority level of a resume recommendation.
enum RecommendationPriority {
  high('High'),
  medium('Medium'),
  low('Low');

  const RecommendationPriority(this.displayName);
  final String displayName;
}

/// A deterministic recommendation to improve the resume.
///
/// Each recommendation has a category, priority, and estimated
/// score improvement if executed.
class ResumeRecommendation {
  const ResumeRecommendation({
    required this.category,
    required this.description,
    this.priority = RecommendationPriority.medium,
    this.estimatedImprovement = 0.0,
    this.action = '',
  });

  /// Recommendation category (e.g. 'projects', 'skills', 'ats').
  final String category;

  /// Human-readable recommendation description.
  final String description;

  /// Priority level based on gap severity.
  final RecommendationPriority priority;

  /// Estimated score improvement if addressed (0.0–1.0).
  final double estimatedImprovement;

  /// Specific actionable step.
  final String action;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeRecommendation &&
          other.category == category &&
          other.description == description;

  @override
  int get hashCode => Object.hash(category, description);
}
