/// Difficulty levels for missions in the Dynamic Mission Engine.
///
/// Difficulty affects XP rewards and estimated duration multipliers.
enum MissionDifficulty {
  /// For absolute beginners — no prerequisites.
  beginner('Beginner', 1.0),

  /// Easy — basic skills required.
  easy('Easy', 1.5),

  /// Medium — moderate proficiency required.
  medium('Medium', 2.0),

  /// Hard — advanced skills required.
  hard('Hard', 3.0),

  /// Expert — mastery-level challenge.
  expert('Expert', 4.0);

  const MissionDifficulty(this.displayName, this.xpMultiplier);

  /// Human-readable label.
  final String displayName;

  /// Multiplier applied to base XP rewards.
  final double xpMultiplier;

  /// Parse from string.
  factory MissionDifficulty.fromString(String value) {
    return MissionDifficulty.values.firstWhere(
      (d) => d.name == value.toLowerCase() || d.displayName == value,
      orElse: () => MissionDifficulty.medium,
    );
  }
}
