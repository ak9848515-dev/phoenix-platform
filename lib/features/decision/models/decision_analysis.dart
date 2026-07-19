import 'decision_criterion.dart' show DecisionCriterion;
import 'decision_option.dart' show DecisionOption;
import 'decision_outcome.dart' show DecisionOutcome;
import 'decision_risk.dart' show DecisionRisk;
import 'decision_type.dart' show DecisionType;

/// The result of a full decision analysis.
///
/// Immutable. Produced by [DecisionAnalyzer] and consumed by UI screens.
/// Contains weighted scores, trade-off insights, risks, and a
/// top recommendation.
class DecisionAnalysis {
  const DecisionAnalysis({
    required this.id,
    required this.title,
    required this.decisionType,
    this.description,
    required this.criteria,
    required this.options,
    this.risks = const [],
    this.createdAt,
    this.outcome,
  });

  /// Unique identifier.
  final String id;

  /// Decision title/question (e.g. "Which job offer should I accept?").
  final String title;

  /// The type of decision being evaluated.
  final DecisionType decisionType;

  /// Optional description/context.
  final String? description;

  /// Evaluation criteria with weights.
  final List<DecisionCriterion> criteria;

  /// Options being evaluated.
  final List<DecisionOption> options;

  /// Associated risks.
  final List<DecisionRisk> risks;

  /// When the analysis was created.
  final DateTime? createdAt;

  /// Outcome if the decision has been made and tracked.
  final DecisionOutcome? outcome;

  /// The top-recommended option based on weighted scoring.
  DecisionOption? get topRecommendation {
    if (options.isEmpty) return null;
    final scored = options.map((o) {
      return _ScoredOption(o, o.calculateWeightedScore(criteria));
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.first.option;
  }

  /// Weighted scores for all options (optionId → score 0–100).
  Map<String, double> get weightedScores {
    final result = <String, double>{};
    for (final option in options) {
      result[option.id] = option.calculateWeightedScore(criteria);
    }
    return result;
  }

  /// Overall confidence in the recommendation (0.0–1.0).
  ///
  /// Based on:
  /// - Number of criteria vs options (more criteria = higher confidence)
  /// - Score gap between top two options (wider gap = higher confidence)
  /// - Risk assessment
  double get confidence {
    if (options.length < 2 || criteria.isEmpty) return 0.0;

    // Criterion ratio confidence
    final criterionRatio = criteria.length / (options.length * 2);
    final criterionConfidence = criterionRatio.clamp(0.2, 0.4);

    // Score gap confidence
    final scores = weightedScores.values.toList()..sort((a, b) => b.compareTo(a));
    final gap = scores.length > 1 ? scores[0] - scores[1] : 0.0;
    final gapConfidence = (gap / 50.0).clamp(0.0, 0.4);

    // Risk factor
    final highRisks = risks.where((r) => r.riskScore >= 50).length;
    final riskConfidence = (1.0 - (highRisks / (risks.length + 1)) * 0.2);

    return (criterionConfidence + gapConfidence + riskConfidence * 0.2)
        .clamp(0.0, 1.0);
  }

  /// Trade-off insights comparing the top two options.
  List<String> get tradeOffInsights {
    if (options.length < 2) return [];

    final scored = options.map((o) {
      return _ScoredOption(o, o.calculateWeightedScore(criteria));
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));

    final top = scored[0];
    final second = scored[1];
    final insights = <String>[];

    // Find criteria where the second option scores higher
    for (final criterion in criteria) {
      final topScore = top.option.scores[criterion.id] ?? 0.0;
      final secondScore = second.option.scores[criterion.id] ?? 0.0;

      if (secondScore > topScore) {
        insights.add(
          '${second.option.title} scores higher on '
          '${criterion.name} (${secondScore.toStringAsFixed(0)} vs '
          '${topScore.toStringAsFixed(0)})',
        );
      }
    }

    return insights;
  }

  DecisionAnalysis copyWith({
    String? id,
    String? title,
    DecisionType? decisionType,
    String? description,
    List<DecisionCriterion>? criteria,
    List<DecisionOption>? options,
    List<DecisionRisk>? risks,
    DateTime? createdAt,
    DecisionOutcome? outcome,
    bool clearOutcome = false,
  }) {
    return DecisionAnalysis(
      id: id ?? this.id,
      title: title ?? this.title,
      decisionType: decisionType ?? this.decisionType,
      description: description ?? this.description,
      criteria: criteria ?? this.criteria,
      options: options ?? this.options,
      risks: risks ?? this.risks,
      createdAt: createdAt ?? this.createdAt,
      outcome: clearOutcome ? null : (outcome ?? this.outcome),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'decisionType': decisionType.name,
      'description': description,
      'criteria': criteria.map((c) => c.toMap()).toList(),
      'options': options.map((o) => o.toMap()).toList(),
      'risks': risks.map((r) => r.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'outcome': outcome?.toMap(),
    };
  }

  factory DecisionAnalysis.fromMap(Map<String, dynamic> map) {
    return DecisionAnalysis(
      id: map['id'] as String,
      title: map['title'] as String,
      decisionType: DecisionType.values.firstWhere(
        (t) => t.name == (map['decisionType'] as String),
        orElse: () => DecisionType.custom,
      ),
      description: map['description'] as String?,
      criteria: (map['criteria'] as List?)
              ?.map((c) => DecisionCriterion.fromMap(
                  Map<String, dynamic>.from(c as Map)))
              .toList() ??
          [],
      options: (map['options'] as List?)
              ?.map((o) => DecisionOption.fromMap(
                  Map<String, dynamic>.from(o as Map)))
              .toList() ??
          [],
      risks: (map['risks'] as List?)
              ?.map((r) =>
                  DecisionRisk.fromMap(Map<String, dynamic>.from(r as Map)))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      outcome: map['outcome'] != null
          ? DecisionOutcome.fromMap(
              Map<String, dynamic>.from(map['outcome'] as Map))
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionAnalysis && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DecisionAnalysis(id: $id, title: $title, options: ${options.length}, '
      'confidence: ${confidence.toStringAsFixed(2)})';
}

/// Internal helper for sorting options by score.
class _ScoredOption {
  _ScoredOption(this.option, this.score);
  final DecisionOption option;
  final double score;
}
