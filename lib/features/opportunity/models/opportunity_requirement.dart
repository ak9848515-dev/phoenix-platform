/// Immutable representation of a skill requirement for an opportunity.
class OpportunityRequirement {
  const OpportunityRequirement({
    required this.skill,
    this.isRequired = true,
    this.isMatched = false,
  });

  /// The required skill or qualification.
  final String skill;

  /// Whether this is a required (vs preferred) skill.
  final bool isRequired;

  /// Whether the user currently matches this requirement.
  final bool isMatched;

  /// Creates a copy with the given fields replaced.
  OpportunityRequirement copyWith({
    String? skill,
    bool? isRequired,
    bool? isMatched,
  }) {
    return OpportunityRequirement(
      skill: skill ?? this.skill,
      isRequired: isRequired ?? this.isRequired,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpportunityRequirement &&
        other.skill == skill &&
        other.isRequired == isRequired &&
        other.isMatched == isMatched;
  }

  @override
  int get hashCode => Object.hash(skill, isRequired, isMatched);

  @override
  String toString() =>
      'OpportunityRequirement(skill: $skill, matched: $isMatched)';
}
