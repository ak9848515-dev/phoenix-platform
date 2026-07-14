/// Tracks the outcome of a decision after it was made.
///
/// Immutable. Used to build a decision history and improve
/// future recommendations.
class DecisionOutcome {
  const DecisionOutcome({
    required this.decisionId,
    required this.selectedOptionId,
    this.actualScore,
    this.satisfaction,
    this.lessonsLearned,
    this.outcomeDate,
    this.metExpectations = true,
  });

  /// The ID of the decision this outcome is for.
  final String decisionId;

  /// The ID of the option that was chosen.
  final String selectedOptionId;

  /// Actual outcome score (0–100) after the fact.
  final int? actualScore;

  /// Satisfaction level (0 = very dissatisfied, 10 = very satisfied).
  final int? satisfaction;

  /// Lessons learned from this decision.
  final String? lessonsLearned;

  /// When the outcome was recorded.
  final DateTime? outcomeDate;

  /// Whether the outcome met expectations.
  final bool metExpectations;

  DecisionOutcome copyWith({
    String? decisionId,
    String? selectedOptionId,
    int? actualScore,
    int? satisfaction,
    String? lessonsLearned,
    DateTime? outcomeDate,
    bool? metExpectations,
  }) {
    return DecisionOutcome(
      decisionId: decisionId ?? this.decisionId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      actualScore: actualScore ?? this.actualScore,
      satisfaction: satisfaction ?? this.satisfaction,
      lessonsLearned: lessonsLearned ?? this.lessonsLearned,
      outcomeDate: outcomeDate ?? this.outcomeDate,
      metExpectations: metExpectations ?? this.metExpectations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'decisionId': decisionId,
      'selectedOptionId': selectedOptionId,
      'actualScore': actualScore,
      'satisfaction': satisfaction,
      'lessonsLearned': lessonsLearned,
      'outcomeDate': outcomeDate?.toIso8601String(),
      'metExpectations': metExpectations,
    };
  }

  factory DecisionOutcome.fromMap(Map<String, dynamic> map) {
    return DecisionOutcome(
      decisionId: map['decisionId'] as String,
      selectedOptionId: map['selectedOptionId'] as String,
      actualScore: map['actualScore'] as int?,
      satisfaction: map['satisfaction'] as int?,
      lessonsLearned: map['lessonsLearned'] as String?,
      outcomeDate: map['outcomeDate'] != null
          ? DateTime.parse(map['outcomeDate'] as String)
          : null,
      metExpectations: map['metExpectations'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionOutcome && other.decisionId == decisionId;

  @override
  int get hashCode => decisionId.hashCode;

  @override
  String toString() =>
      'DecisionOutcome(decisionId: $decisionId, satisfaction: $satisfaction)';
}
