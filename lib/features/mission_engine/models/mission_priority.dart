/// Priority levels for missions in the Dynamic Mission Engine.
///
/// Priority must be calculated inside the Mission Engine only.
/// Never inside widgets.
enum MissionPriority {
  /// Critical priority — highest impact, time-sensitive.
  critical('Critical', 4),

  /// High priority — significant impact on progress.
  high('High', 3),

  /// Medium priority — moderate impact.
  medium('Medium', 2),

  /// Low priority — supplementary, optional action.
  low('Low', 1);

  const MissionPriority(this.displayName, this.weight);

  /// Human-readable label.
  final String displayName;

  /// Numeric weight for sorting (higher = more important).
  final int weight;

  /// Parse from string or display name.
  factory MissionPriority.fromString(String value) {
    return MissionPriority.values.firstWhere(
      (p) => p.name == value.toLowerCase() || p.displayName == value,
      orElse: () => MissionPriority.medium,
    );
  }

  /// Returns the priority for a given weight score (1-4).
  factory MissionPriority.fromWeight(int weight) {
    return MissionPriority.values.firstWhere(
      (p) => p.weight == weight,
      orElse: () => MissionPriority.medium,
    );
  }
}
