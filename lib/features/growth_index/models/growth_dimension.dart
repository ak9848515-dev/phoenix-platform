/// Enum representing each measurable dimension of user growth.
///
/// Each dimension maps to a specific domain within the Phoenix platform.
/// The [GrowthIndexEngine] calculates and tracks [GrowthMetrics] per dimension.
enum GrowthDimension {
  /// Knowledge acquisition and skill-building progress.
  knowledge('Knowledge'),

  /// Practical skills proficiency.
  skills('Skills'),

  /// Project completion and quality.
  projects('Projects'),

  /// Career readiness and job preparation.
  career('Career'),

  /// Habit consistency and streak maintenance.
  habits('Habits'),

  /// Interview preparation readiness.
  interview('Interview'),

  /// Mission completion rate and performance.
  mission('Mission'),

  /// Portfolio development and showcase.
  portfolio('Portfolio'),

  /// Learning consistency over time (streaks, daily activity).
  learningConsistency('Learning Consistency'),

  /// Overall composite growth across all dimensions.
  overall('Overall');

  const GrowthDimension(this.displayName);

  /// Human-readable label for the dimension.
  final String displayName;

  /// Parse from string, returning [overall] for unknown values.
  factory GrowthDimension.fromString(String value) {
    return GrowthDimension.values.firstWhere(
      (d) => d.name == value || d.displayName == value,
      orElse: () => GrowthDimension.overall,
    );
  }
}
