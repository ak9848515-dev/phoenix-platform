/// A criterion used to evaluate options in a decision.
///
/// Immutable. Each criterion has a weight (0.0–1.0) indicating
/// its relative importance in the overall decision.
class DecisionCriterion {
  const DecisionCriterion({
    required this.id,
    required this.name,
    this.weight = 1.0,
    this.description,
    this.isBeneficial = true,
  });

  /// Unique identifier.
  final String id;

  /// Short name (e.g. "Salary", "Location", "Growth Potential").
  final String name;

  /// Relative importance weight (0.0–1.0).
  ///
  /// Higher values mean this criterion is more important.
  /// Weights are normalised during scoring.
  final double weight;

  /// Optional description of what this criterion measures.
  final String? description;

  /// Whether higher scores are better for this criterion.
  ///
  /// If `false`, lower scores are better (e.g. "Cost").
  final bool isBeneficial;

  DecisionCriterion copyWith({
    String? id,
    String? name,
    double? weight,
    String? description,
    bool? isBeneficial,
  }) {
    return DecisionCriterion(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      isBeneficial: isBeneficial ?? this.isBeneficial,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'description': description,
      'isBeneficial': isBeneficial,
    };
  }

  factory DecisionCriterion.fromMap(Map<String, dynamic> map) {
    return DecisionCriterion(
      id: map['id'] as String,
      name: map['name'] as String,
      weight: (map['weight'] as num?)?.toDouble() ?? 1.0,
      description: map['description'] as String?,
      isBeneficial: map['isBeneficial'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionCriterion && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DecisionCriterion(id: $id, name: $name, weight: $weight)';
}
