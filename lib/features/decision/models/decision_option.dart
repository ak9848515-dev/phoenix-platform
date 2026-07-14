import 'decision_criterion.dart' show DecisionCriterion;

/// An option being evaluated as part of a decision.
///
/// Immutable. Each option has scores for each criterion and
/// optionally pros/cons for qualitative assessment.
class DecisionOption {
  const DecisionOption({
    required this.id,
    required this.title,
    this.description,
    this.scores = const {},
    this.pros = const [],
    this.cons = const [],
    this.estimatedCost,
    this.estimatedDuration,
    this.notes,
  });

  /// Unique identifier.
  final String id;

  /// Short title (e.g. "Accept Job Offer A").
  final String title;

  /// Optional detailed description.
  final String? description;

  /// Scores per criterion ID (criterionId → score 0–100).
  final Map<String, double> scores;

  /// Qualitative pros (list of statements).
  final List<String> pros;

  /// Qualitative cons (list of statements).
  final List<String> cons;

  /// Estimated monetary cost (if applicable).
  final double? estimatedCost;

  /// Estimated time commitment (if applicable).
  final int? estimatedDuration;

  /// Free-form notes.
  final String? notes;

  /// Returns the weighted score for this option given criteria.
  double calculateWeightedScore(List<DecisionCriterion> criteria) {
    var totalWeight = 0.0;
    var weightedSum = 0.0;

    for (final criterion in criteria) {
      final score = scores[criterion.id];
      if (score == null) continue;

      final normalisedScore = criterion.isBeneficial ? score : 100.0 - score;
      weightedSum += normalisedScore * criterion.weight;
      totalWeight += criterion.weight;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  DecisionOption copyWith({
    String? id,
    String? title,
    String? description,
    Map<String, double>? scores,
    List<String>? pros,
    List<String>? cons,
    double? estimatedCost,
    int? estimatedDuration,
    String? notes,
  }) {
    return DecisionOption(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scores: scores ?? this.scores,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scores':
          scores.map((key, value) => MapEntry(key, value)),
      'pros': pros,
      'cons': cons,
      'estimatedCost': estimatedCost,
      'estimatedDuration': estimatedDuration,
      'notes': notes,
    };
  }

  factory DecisionOption.fromMap(Map<String, dynamic> map) {
    return DecisionOption(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      scores: (map['scores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      pros: List<String>.from(map['pros'] as List? ?? []),
      cons: List<String>.from(map['cons'] as List? ?? []),
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble(),
      estimatedDuration: map['estimatedDuration'] as int?,
      notes: map['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionOption && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DecisionOption(id: $id, title: $title, scores: ${scores.length})';
}
