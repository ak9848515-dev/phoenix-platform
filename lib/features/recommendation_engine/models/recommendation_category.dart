/// Category of recommendation produced by the [RecommendationEngine].
///
/// Each category maps to a domain of growth within the Phoenix platform.
enum RecommendationCategory {
  learning('Learning'),
  career('Career'),
  project('Project'),
  interview('Interview'),
  habit('Habit'),
  knowledge('Knowledge'),
  portfolio('Portfolio'),
  assessment('Assessment'),
  review('Review'),
  foundation('Foundation');

  const RecommendationCategory(this.displayName);

  /// Human-readable label for the category.
  final String displayName;

  /// Parse from string, returning [learning] for unknown values.
  factory RecommendationCategory.fromString(String value) {
    return RecommendationCategory.values.firstWhere(
      (c) => c.name == value || c.displayName == value,
      orElse: () => RecommendationCategory.learning,
    );
  }
}
