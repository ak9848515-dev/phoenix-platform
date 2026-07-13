/// Immutable representation of a skill gap between the user and an opportunity.
class OpportunityGap {
  const OpportunityGap({
    required this.skill,
    this.severity = 0.5,
    this.action = '',
  });

  /// The skill the user is missing.
  final String skill;

  /// How critical this gap is from 0.0 (minor) to 1.0 (critical).
  final double severity;

  /// Recommended action to close this gap.
  final String action;

  /// Creates a copy with the given fields replaced.
  OpportunityGap copyWith({String? skill, double? severity, String? action}) {
    return OpportunityGap(
      skill: skill ?? this.skill,
      severity: severity ?? this.severity,
      action: action ?? this.action,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpportunityGap &&
        other.skill == skill &&
        other.severity == severity &&
        other.action == action;
  }

  @override
  int get hashCode => Object.hash(skill, severity, action);

  @override
  String toString() => 'OpportunityGap(skill: $skill, severity: $severity)';
}
