/// The severity level of a risk.
enum RiskSeverity {
  /// Catastrophic — would completely derail the decision outcome.
  critical,

  /// Severe — significant negative impact.
  high,

  /// Moderate — noticeable but manageable impact.
  medium,

  /// Minor — small impact, easily mitigated.
  low,

  /// Negligible — minimal to no impact.
  negligible,
}

/// The probability level of a risk occurring.
enum RiskProbability {
  /// Almost certain to occur (>90%).
  almostCertain,

  /// Likely to occur (>50%).
  likely,

  /// Possible (20–50%).
  possible,

  /// Unlikely (<20%).
  unlikely,

  /// Rare (<5%).
  rare,
}

/// A risk associated with a decision option.
///
/// Immutable. Combines probability and severity to calculate
/// a risk score for prioritisation.
class DecisionRisk {
  const DecisionRisk({
    required this.id,
    required this.description,
    this.probability = RiskProbability.possible,
    this.severity = RiskSeverity.medium,
    this.mitigation,
    this.optionId,
  });

  /// Unique identifier.
  final String id;

  /// Description of the risk.
  final String description;

  /// Probability of this risk occurring.
  final RiskProbability probability;

  /// Severity if the risk occurs.
  final RiskSeverity severity;

  /// Optional mitigation strategy.
  final String? mitigation;

  /// Optional ID of the option this risk applies to.
  /// If null, the risk applies to the decision as a whole.
  final String? optionId;

  /// Numeric risk score (0–100) combining probability and severity.
  ///
  /// Higher scores = higher risk.
  double get riskScore {
    final probValue = _probabilityValue(probability);
    final sevValue = _severityValue(severity);
    return (probValue * sevValue) / 25.0 * 100.0;
  }

  /// Human-readable risk level label.
  String get level {
    final score = riskScore;
    if (score >= 75) return 'Critical';
    if (score >= 50) return 'High';
    if (score >= 25) return 'Medium';
    if (score >= 10) return 'Low';
    return 'Negligible';
  }

  DecisionRisk copyWith({
    String? id,
    String? description,
    RiskProbability? probability,
    RiskSeverity? severity,
    String? mitigation,
    String? optionId,
  }) {
    return DecisionRisk(
      id: id ?? this.id,
      description: description ?? this.description,
      probability: probability ?? this.probability,
      severity: severity ?? this.severity,
      mitigation: mitigation ?? this.mitigation,
      optionId: optionId ?? this.optionId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'probability': probability.name,
      'severity': severity.name,
      'mitigation': mitigation,
      'optionId': optionId,
    };
  }

  factory DecisionRisk.fromMap(Map<String, dynamic> map) {
    return DecisionRisk(
      id: map['id'] as String,
      description: map['description'] as String,
      probability: RiskProbability.values.firstWhere(
        (p) => p.name == (map['probability'] as String),
        orElse: () => RiskProbability.possible,
      ),
      severity: RiskSeverity.values.firstWhere(
        (s) => s.name == (map['severity'] as String),
        orElse: () => RiskSeverity.medium,
      ),
      mitigation: map['mitigation'] as String?,
      optionId: map['optionId'] as String?,
    );
  }

  static double _probabilityValue(RiskProbability p) {
    switch (p) {
      case RiskProbability.almostCertain:
        return 5.0;
      case RiskProbability.likely:
        return 4.0;
      case RiskProbability.possible:
        return 3.0;
      case RiskProbability.unlikely:
        return 2.0;
      case RiskProbability.rare:
        return 1.0;
    }
  }

  static double _severityValue(RiskSeverity s) {
    switch (s) {
      case RiskSeverity.critical:
        return 5.0;
      case RiskSeverity.high:
        return 4.0;
      case RiskSeverity.medium:
        return 3.0;
      case RiskSeverity.low:
        return 2.0;
      case RiskSeverity.negligible:
        return 1.0;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionRisk && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DecisionRisk(id: $id, level: $level, score: ${riskScore.toStringAsFixed(0)})';
}
