/// Immutable representation of a skill in the user's portfolio.
///
/// Automatically derived from Knowledge DNA analysis, journey stage
/// requirements, and completed missions. Not manually editable.
class PortfolioSkill {
  const PortfolioSkill({
    required this.id,
    required this.name,
    this.proficiency = 0.0,
    this.category = 'General',
    this.isStrength = false,
  });

  /// Unique identifier for this skill.
  final String id;

  /// Human-readable skill name (e.g. 'Dart', 'System Design').
  final String name;

  /// Proficiency level from 0.0 to 1.0.
  final double proficiency;

  /// Category grouping (e.g. 'Language', 'Framework', 'Soft Skill').
  final String category;

  /// Whether this skill is identified as a strength by Knowledge DNA.
  final bool isStrength;

  /// Creates a copy with the given fields replaced.
  PortfolioSkill copyWith({
    String? id,
    String? name,
    double? proficiency,
    String? category,
    bool? isStrength,
  }) {
    return PortfolioSkill(
      id: id ?? this.id,
      name: name ?? this.name,
      proficiency: proficiency ?? this.proficiency,
      category: category ?? this.category,
      isStrength: isStrength ?? this.isStrength,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioSkill &&
        other.id == id &&
        other.name == name &&
        other.proficiency == proficiency &&
        other.category == category &&
        other.isStrength == isStrength;
  }

  @override
  int get hashCode => Object.hash(id, name, proficiency, category, isStrength);

  @override
  String toString() =>
      'PortfolioSkill(id: $id, name: $name, proficiency: $proficiency)';
}
