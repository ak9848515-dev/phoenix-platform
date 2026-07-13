/// Immutable representation of a skill entry in the resume.
///
/// Automatically derived from Portfolio skills. Includes proficiency
/// level and whether the skill is a strength.
class ResumeSkill {
  const ResumeSkill({
    required this.name,
    this.proficiency = 0.0,
    this.isStrength = false,
    this.category = 'General',
  });

  /// Human-readable skill name (e.g. 'Dart', 'System Design').
  final String name;

  /// Proficiency level from 0.0 to 1.0.
  final double proficiency;

  /// Whether this skill is identified as a strength.
  final bool isStrength;

  /// Category grouping (e.g. 'Language', 'Framework', 'Soft Skill').
  final String category;

  /// Creates a copy with the given fields replaced.
  ResumeSkill copyWith({
    String? name,
    double? proficiency,
    bool? isStrength,
    String? category,
  }) {
    return ResumeSkill(
      name: name ?? this.name,
      proficiency: proficiency ?? this.proficiency,
      isStrength: isStrength ?? this.isStrength,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResumeSkill &&
        other.name == name &&
        other.proficiency == proficiency &&
        other.isStrength == isStrength &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(name, proficiency, isStrength, category);

  @override
  String toString() => 'ResumeSkill(name: $name, proficiency: $proficiency)';
}
