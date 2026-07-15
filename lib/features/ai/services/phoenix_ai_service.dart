import '../../academy/services/academy_service.dart';
import '../../habit/services/habit_service.dart';
import '../../timeline/services/timeline_service.dart';
import '../../personal_knowledge/services/knowledge_service.dart';
import '../../decision/services/decision_intelligence_service.dart';
import '../../memory_graph/services/memory_graph_service.dart';
import '../engine/cross_feature_reasoner.dart';
import '../engine/daily_brief_engine.dart';
import '../models/daily_recommendation.dart';
import '../models/phoenix_daily_brief.dart';

/// Phoenix AI Core — produces a unified daily intelligence summary.
///
/// [PhoenixAIService] is an **orchestration-only** service. It delegates
/// all computation to [DailyBriefEngine] and [CrossFeatureReasoner], then
/// formats results into the [PhoenixDailyBrief] presentation model.
///
/// **Responsibilities:**
/// - Injecting the six PHX-062 intelligence services into both engines
/// - Orchestrating brief generation (collect → rank → format)
/// - Orchestrating cross-feature analysis (insights, risks, opportunities)
/// - Building human-readable section strings from engine recommendations
/// - Computing overall confidence from recommendation scores
///
/// **Architecture Rules:**
/// - Consumes services only — never reads from UserState directly
/// - Never duplicates engine logic (all computation in engines)
/// - Never persists data
/// - Never makes AI calls
class PhoenixAIService {
  PhoenixAIService({
    required AcademyService academyService,
    required HabitService habitService,
    required TimelineService timelineService,
    required KnowledgeService knowledgeService,
    required DecisionIntelligenceService decisionService,
    required MemoryGraphService memoryGraphService,
    DailyBriefEngine? briefEngine,
    CrossFeatureReasoner? crossFeatureEngine,
  })  : _dailyBriefEngine = briefEngine ??
            DailyBriefEngine(
              academyService: academyService,
              habitService: habitService,
              timelineService: timelineService,
              knowledgeService: knowledgeService,
              decisionService: decisionService,
              memoryGraphService: memoryGraphService,
            ),
        _crossFeatureEngine = crossFeatureEngine ??
            CrossFeatureReasoner(
              academyService: academyService,
              habitService: habitService,
              timelineService: timelineService,
              knowledgeService: knowledgeService,
              decisionService: decisionService,
              memoryGraphService: memoryGraphService,
            );

  final DailyBriefEngine _dailyBriefEngine;
  final CrossFeatureReasoner _crossFeatureEngine;

  // ── Daily Brief Generation ──────────────────────────────────────────

  /// Generates the daily intelligence brief from all six services.
  ///
  /// Orchestration flow:
  /// 1. [DailyBriefEngine.collectRecommendations] — gather all scored recs
  /// 2. [DailyBriefEngine.topFocus] — determine today's single focus
  /// 3. Format sections from typed recommendation groups
  /// 4. Compute overall confidence
  /// 5. Return the [PhoenixDailyBrief]
  PhoenixDailyBrief generateBrief() {
    // 1. Collect all recommendations from the engine
    final recommendations = _dailyBriefEngine.collectRecommendations();

    // 2. Compute overall confidence (average of all recommendation confidences)
    final confidenceScore = _computeOverallConfidence(recommendations);

    // 3. Determine today's top focus
    final top = _dailyBriefEngine.topFocus(recommendations);
    final todaysFocus = _formatFocus(top);

    // 4. Group recommendations by type for section building
    final byType = _groupByType(recommendations);

    // 5. Build each section from its typed recommendations
    final learningRecommendation =
        _firstDescription(byType[RecommendationType.learning]) ??
            'Continue your current learning path. Consistency matters more than speed.';

    final habitInsight =
        _firstDescription(byType[RecommendationType.habit]) ??
            'No active habits tracked yet. Start with one small daily habit to build momentum.';

    final timelineReminder =
        _firstDescription(byType[RecommendationType.timeline]) ??
            'No recent activity. Start a lesson or complete a habit to build your timeline.';

    final knowledgeInsight =
        _firstDescription(byType[RecommendationType.knowledge]) ??
            'Your knowledge graph is empty. Complete missions and decisions to populate it.';

    final decisionFollowUp =
        _firstDescription(byType[RecommendationType.decision]) ??
            'No decisions analyzed yet. Use the Decision tool when facing an important choice.';

    final overallDailySummary = _buildSummary(recommendations);

    return PhoenixDailyBrief(
      todaysFocus: todaysFocus,
      learningRecommendation: learningRecommendation,
      habitInsight: habitInsight,
      knowledgeInsight: knowledgeInsight,
      timelineReminder: timelineReminder,
      decisionFollowUp: decisionFollowUp,
      overallDailySummary: overallDailySummary,
      recommendations: recommendations,
      confidenceScore: confidenceScore,
      generatedAt: DateTime.now(),
    );
  }

  // ── Formatting Helpers ──────────────────────────────────────────────

  /// Formats the top focus recommendation into a human-readable sentence.
  String _formatFocus(DailyRecommendation? top) {
    if (top == null) {
      return 'Complete your missions for today. '
          'Every action builds momentum toward your goals.';
    }
    return '${top.title} — ${top.description ?? ""}';
  }

  /// Returns the first non-null description from a list of recommendations.
  String? _firstDescription(List<DailyRecommendation>? recs) {
    if (recs == null || recs.isEmpty) return null;
    final first = recs.first;
    final desc = first.description;
    if (desc != null && desc.isNotEmpty) return desc;
    return first.title;
  }

  /// Groups recommendations by their type.
  Map<RecommendationType, List<DailyRecommendation>> _groupByType(
    List<DailyRecommendation> recommendations,
  ) {
    final grouped = <RecommendationType, List<DailyRecommendation>>{};
    for (final rec in recommendations) {
      grouped.putIfAbsent(rec.type, () => []).add(rec);
    }
    return grouped;
  }

  /// Computes overall confidence as the average of all recommendation
  /// confidences, re-computed through the engine for consistency.
  double _computeOverallConfidence(List<DailyRecommendation> recommendations) {
    if (recommendations.isEmpty) return 0.0;
    var total = 0.0;
    for (final rec in recommendations) {
      total += _dailyBriefEngine.computeConfidence(rec);
    }
    return total / recommendations.length;
  }

  /// Builds a holistic one-paragraph summary from all recommendations.
  String _buildSummary(List<DailyRecommendation> recommendations) {
    final buffer = StringBuffer();

    // Count actionable items
    final actionable =
        recommendations.where((r) => r.isActionable).length;
    final learningCount =
        recommendations.where((r) => r.type == RecommendationType.learning).length;
    final habitCount =
        recommendations.where((r) => r.type == RecommendationType.habit).length;
    final decisionCount =
        recommendations.where((r) => r.type == RecommendationType.decision).length;

    buffer.write(
      'Today, you have $actionable actionable recommendation'
      '${actionable == 1 ? '' : 's'} across your platform. ',
    );

    if (learningCount > 0) {
      buffer.write('$learningCount learning opportunit'
          '${learningCount == 1 ? 'y' : 'ies'} to explore. ');
    }
    if (habitCount > 0) {
      buffer.write('$habitCount habit insight${habitCount == 1 ? '' : 's'} to review. ');
    }
    if (decisionCount > 0) {
      buffer.write('$decisionCount decision follow-up${decisionCount == 1 ? '' : 's'}. ');
    }

    // Overall confidence
    final confidencePct = (_computeOverallConfidence(recommendations) * 100).round();
    buffer.write(
      'Brief confidence: $confidencePct%. '
      'Keep building momentum — every action compounds.',
    );

    return buffer.toString();
  }

  // ── Cross-Feature Analysis ──────────────────────────────────────────

  /// Runs the [CrossFeatureReasoner] across all six services.
  ///
  /// Returns insights, risks, and opportunities discovered by combining
  /// signals from multiple feature domains. No persistence, no AI.
  ///
  /// Callers access the three result categories through the returned
  /// [CrossFeatureResult]:
  /// ```dart
  /// final result = service.analyzeCrossFeature();
  /// result.insights   // List<PhoenixInsight>
  /// result.risks      // List<PhoenixRisk>
  /// result.opportunities  // List<PhoenixOpportunity>
  /// ```
  CrossFeatureResult analyzeCrossFeature() {
    return _crossFeatureEngine.reason();
  }
}
