import '../models/decision_analysis.dart';
import '../models/decision_criterion.dart';
import '../models/decision_option.dart';
import '../models/decision_outcome.dart';
import '../models/decision_risk.dart';
import '../models/decision_type.dart';

/// Core decision analysis utility.
///
/// Owns:
/// - Weighted scoring of options against criteria
/// - Trade-off analysis between competing options
/// - Risk assessment and scoring
/// - Confidence calculation
/// - Recommendation building
///
/// **Note:** This is NOT an engine in the Phoenix architecture sense.
/// It is a pure utility class consumed by [DecisionIntelligenceService].
/// The Phoenix intelligence engine that evaluates all engine snapshots
/// is [DecisionIntelligenceOrchestrator].
///
/// **Never** duplicates Knowledge DNA, Mission Engine, Academy, or AI logic.
/// Integration with those modules happens in [DecisionIntelligenceService].
class DecisionAnalyzer {
  const DecisionAnalyzer();

  // ── Analysis ──────────────────────────────────────────────────────

  /// Performs a full decision analysis.
  DecisionAnalysis analyze({
    required String id,
    required String title,
    required DecisionType decisionType,
    String? description,
    required List<DecisionCriterion> criteria,
    required List<DecisionOption> options,
    List<DecisionRisk> risks = const [],
    DecisionOutcome? outcome,
  }) {
    return DecisionAnalysis(
      id: id,
      title: title,
      decisionType: decisionType,
      description: description,
      criteria: _normaliseWeights(criteria),
      options: options,
      risks: risks,
      createdAt: DateTime.now(),
      outcome: outcome,
    );
  }

  // ── Scoring ──────────────────────────────────────────────────────

  /// Normalises criterion weights so they sum to 1.0.
  List<DecisionCriterion> _normaliseWeights(List<DecisionCriterion> criteria) {
    final totalWeight = criteria.fold(0.0, (sum, c) => sum + c.weight);
    if (totalWeight <= 0) return criteria;

    return criteria.map((c) {
      return c.copyWith(weight: c.weight / totalWeight);
    }).toList();
  }

  /// Calculates the weighted score for a single option.
  double scoreOption(
    DecisionOption option,
    List<DecisionCriterion> criteria,
  ) {
    return option.calculateWeightedScore(criteria);
  }

  /// Returns all options scored and sorted (highest first).
  List<ScoredOption> rankOptions(
    List<DecisionOption> options,
    List<DecisionCriterion> criteria,
  ) {
    final normalised = _normaliseWeights(criteria);
    final scored = options.map((o) {
      return ScoredOption(o, o.calculateWeightedScore(normalised));
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  // ── Trade-off Analysis ───────────────────────────────────────────

  /// Identifies trade-offs between the top two options.
  List<TradeOffInsight> analyzeTradeOffs(
    List<DecisionOption> options,
    List<DecisionCriterion> criteria,
  ) {
    if (options.length < 2) return [];

    final scored = rankOptions(options, criteria);
    final top = scored[0];
    final second = scored[1];
    final insights = <TradeOffInsight>[];

    for (final criterion in criteria) {
      final topScore = top.option.scores[criterion.id] ?? 0.0;
      final secondScore = second.option.scores[criterion.id] ?? 0.0;

      if (secondScore > topScore) {
        insights.add(TradeOffInsight(
          criterionName: criterion.name,
          leaderOptionId: second.option.id,
          leaderScore: secondScore,
          followerOptionId: top.option.id,
          followerScore: topScore,
          gap: secondScore - topScore,
        ));
      }
    }

    return insights;
  }

  // ── Risk Assessment ──────────────────────────────────────────────

  /// Assesses the overall risk level of a decision.
  RiskAssessment assessRisk(List<DecisionRisk> risks) {
    if (risks.isEmpty) {
      return const RiskAssessment(
        level: 'Negligible',
        score: 0,
        highRiskCount: 0,
      );
    }

    final avgScore =
        risks.fold(0.0, (sum, r) => sum + r.riskScore) / risks.length;
    final highRisks = risks.where((r) => r.riskScore >= 50).length;

    String level;
    if (avgScore >= 75) {
      level = 'Critical';
    } else if (avgScore >= 50) {
      level = 'High';
    } else if (avgScore >= 25) {
      level = 'Medium';
    } else if (avgScore >= 10) {
      level = 'Low';
    } else {
      level = 'Negligible';
    }

    return RiskAssessment(
      level: level,
      score: avgScore.round(),
      highRiskCount: highRisks,
    );
  }

  // ── Outcome Tracking ─────────────────────────────────────────────

  /// Records an outcome and returns lessons learned analysis.
  OutcomeAnalysis analyzeOutcome(
    DecisionAnalysis analysis,
    DecisionOutcome outcome,
  ) {
    final predictedScore = analysis.weightedScores[outcome.selectedOptionId];

    final accuracy = predictedScore != null && outcome.actualScore != null
        ? (100.0 - (predictedScore - outcome.actualScore!).abs()).clamp(0.0, 100.0)
        : null;

    return OutcomeAnalysis(
      decisionId: analysis.id,
      predictedScore: predictedScore,
      actualScore: outcome.actualScore,
      accuracy: accuracy,
      satisfaction: outcome.satisfaction,
      metExpectations: outcome.metExpectations,
    );
  }
}

/// An option with its computed score.
class ScoredOption {
  ScoredOption(this.option, this.score);
  final DecisionOption option;
  final double score;
}

/// A trade-off insight comparing two options on a criterion.
class TradeOffInsight {
  const TradeOffInsight({
    required this.criterionName,
    required this.leaderOptionId,
    required this.leaderScore,
    required this.followerOptionId,
    required this.followerScore,
    required this.gap,
  });

  final String criterionName;
  final String leaderOptionId;
  final double leaderScore;
  final String followerOptionId;
  final double followerScore;
  final double gap;
}

/// Overall risk assessment result.
class RiskAssessment {
  const RiskAssessment({
    required this.level,
    required this.score,
    required this.highRiskCount,
  });

  final String level;
  final int score;
  final int highRiskCount;
}

/// Analysis of a decision outcome.
class OutcomeAnalysis {
  const OutcomeAnalysis({
    required this.decisionId,
    this.predictedScore,
    this.actualScore,
    this.accuracy,
    this.satisfaction,
    required this.metExpectations,
  });

  final String decisionId;
  final double? predictedScore;
  final int? actualScore;
  final double? accuracy;
  final int? satisfaction;
  final bool metExpectations;
}
