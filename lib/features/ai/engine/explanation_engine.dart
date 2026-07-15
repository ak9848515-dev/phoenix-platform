import '../models/daily_recommendation.dart' show DailyRecommendation, RecommendationPriority;
import '../models/evidence.dart' show Evidence;
import '../models/explanation.dart' show Explanation;
import '../models/reason_chain.dart' show ReasonChain;
import 'cross_feature_reasoner.dart' show CrossFeatureReasoner, CrossFeatureResult;
import 'daily_brief_engine.dart' show DailyBriefEngine;

/// Produces explainable recommendations by enriching raw recommendations
/// with reasoning chains and supporting evidence.
///
/// [ExplanationEngine] consumes [DailyBriefEngine] for recommendations
/// and [CrossFeatureReasoner] for cross-domain context, then builds
/// a traceable [ReasonChain] for each [DailyRecommendation].
///
/// **Architecture Rules:**
/// - Pure computation — no persistence, no AI
/// - Consumes engines only — no direct service access
/// - Every recommendation must explain itself
class ExplanationEngine {
  ExplanationEngine({
    required this._briefEngine,
    required this._crossFeatureEngine,
  });

  final DailyBriefEngine _briefEngine;
  final CrossFeatureReasoner _crossFeatureEngine;

  // ── Public API ──────────────────────────────────────────────────────

  /// Generates explanations for all current recommendations.
  List<Explanation> explainAll() {
    final recommendations = _briefEngine.collectRecommendations();
    final crossResult = _crossFeatureEngine.reason();

    return recommendations.map((rec) {
      final reasonChain = _buildReasonChain(rec, crossResult);
      return _buildExplanation(rec, reasonChain);
    }).toList();
  }

  /// Generates an explanation for a single recommendation.
  Explanation explain(DailyRecommendation recommendation) {
    final crossResult = _crossFeatureEngine.reason();
    final reasonChain = _buildReasonChain(recommendation, crossResult);
    return _buildExplanation(recommendation, reasonChain);
  }

  /// Returns the top-N most confident explanations.
  List<Explanation> topExplanations({int count = 3}) {
    final all = explainAll();
    all.sort((a, b) => b.confidence.compareTo(a.confidence));
    return all.take(count).toList();
  }

  // ── Reason Chain Building ───────────────────────────────────────────

  /// Builds a step-by-step [ReasonChain] for a recommendation.
  ReasonChain _buildReasonChain(
    DailyRecommendation recommendation,
    CrossFeatureResult crossResult,
  ) {
    final steps = <String>[];
    final evidenceList = <Evidence>[];

    // Step 1: Source domain context
    steps.add('Source: ${recommendation.sourceService}');
    evidenceList.add(Evidence(
      statement: 'Recommended by ${recommendation.sourceService}',
      source: recommendation.sourceService,
      relevance: 0.8,
    ));

    // Step 2: Priority and urgency
    final priorityLabel = _priorityLabel(recommendation.priority);
    steps.add('Priority: $priorityLabel '
        '(urgency ${(recommendation.urgency * 100).round()}%, '
        'confidence ${(recommendation.confidence * 100).round()}%)');

    // Step 3: Cross-reference with cross-feature insights
    final matchingInsights = crossResult.insights
        .where((i) => i.sourceDomains
            .any((d) => d.contains(recommendation.sourceService)))
        .toList();
    if (matchingInsights.isNotEmpty) {
      steps.add('Cross-domain signal: ${matchingInsights.first.title}');
      evidenceList.add(Evidence(
        statement: matchingInsights.first.description,
        source: matchingInsights.first.sourceDomains.join(', '),
        relevance: matchingInsights.first.confidence,
      ));
    }

    // Step 4: Risk check
    final matchingRisks = crossResult.risks
        .where((r) => r.confidence >= 0.6)
        .toList();
    if (matchingRisks.isNotEmpty) {
      final topRisk = matchingRisks.first;
      steps.add('Risk consideration: ${topRisk.title}');
      evidenceList.add(Evidence(
        statement: topRisk.description,
        source: 'CrossFeatureReasoner',
        relevance: topRisk.confidence,
      ));
    }

    // Step 5: Opportunity alignment
    final matchingOpps = crossResult.opportunities
        .where((o) => o.estimatedImpact >= 0.5)
        .toList();
    if (matchingOpps.isNotEmpty) {
      final topOpp = matchingOpps.first;
      steps.add('Opportunity alignment: ${topOpp.title}');
      evidenceList.add(Evidence(
        statement: topOpp.description,
        source: 'CrossFeatureReasoner',
        relevance: topOpp.confidence,
      ));
    }

    // Final confidence: blend recommendation confidence with evidence
    final blendedConfidence = (recommendation.confidence * 0.6 +
        (evidenceList.isNotEmpty
            ? evidenceList
                    .map((e) => e.relevance)
                    .reduce((a, b) => a + b) /
                evidenceList.length *
                0.4
            : 0.0))
        .clamp(0.0, 1.0);

    return ReasonChain(
      conclusion: recommendation.title,
      evidence: evidenceList,
      steps: steps,
      confidence: blendedConfidence,
    );
  }

  // ── Explanation Assembly ────────────────────────────────────────────

  /// Assembles a complete [Explanation] from a recommendation and its chain.
  Explanation _buildExplanation(
    DailyRecommendation recommendation,
    ReasonChain reasonChain,
  ) {
    return Explanation(
      recommendation: recommendation,
      reasonChain: reasonChain,
      title: recommendation.title,
      description: recommendation.description ?? '',
      confidence: reasonChain.confidence,
      priority: recommendation.urgency * recommendation.priority.rank / 4.0,
      sourceDomains: [recommendation.sourceService],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Maps a [DailyRecommendation] priority to a user-friendly label.
  String _priorityLabel(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return 'Critical';
      case RecommendationPriority.high:
        return 'High';
      case RecommendationPriority.medium:
        return 'Medium';
      case RecommendationPriority.low:
        return 'Low';
    }
  }
}
