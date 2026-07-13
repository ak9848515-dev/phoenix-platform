/// Extensible categories for missions in the Dynamic Mission Engine.
///
/// Each category represents a domain of action the user can take
/// within the Phoenix platform.
enum MissionCategory {
  /// Knowledge acquisition and skill-building.
  learning('Learning'),

  /// Hands-on application and exercises.
  practice('Practice'),

  /// Creating tangible outputs and projects.
  build('Build'),

  /// Portfolio development and showcase.
  portfolio('Portfolio'),

  /// Resume building and optimisation.
  resume('Resume'),

  /// Interview preparation and mock sessions.
  interview('Interview'),

  /// Career development and job readiness.
  career('Career'),

  /// Daily habits and routines.
  habit('Habit'),

  /// Reflection and journaling.
  reflection('Reflection'),

  /// Daily check-in missions.
  daily('Daily'),

  /// Weekly review and planning missions.
  weekly('Weekly'),

  /// User-created custom missions.
  custom('Custom');

  const MissionCategory(this.displayName);

  /// Human-readable label for the category.
  final String displayName;

  /// Parse from string, returning [custom] for unknown values.
  factory MissionCategory.fromString(String value) {
    return MissionCategory.values.firstWhere(
      (c) => c.name == value || c.displayName == value,
      orElse: () => MissionCategory.custom,
    );
  }
}
