import '../../academy/services/academy_service.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../growth_index/models/growth_trend.dart';
import '../../habit/services/habit_service.dart';
import '../../timeline/services/timeline_service.dart';
import '../../personal_knowledge/services/knowledge_service.dart';
import '../../decision/services/decision_intelligence_service.dart';
import '../../memory_graph/services/memory_graph_service.dart';
import '../models/daily_recommendation.dart';

/// Pure computation engine for the Phoenix Daily Brief.
///
/// [DailyBriefEngine] owns all intelligence for:
/// - Collecting recommendations from all six platform services
/// - Computing priority, urgency, and confidence scores
/// - Ranking and ordering recommendations
/// - Determining today's focus
///
/// **Architecture Rules:**
/// - Pure Dart — no Flutter, no AI, no persistence
/// - Consumes services only — never owns data
/// - Engine logic only — never generates UI strings
class DailyBriefEngine {
  DailyBriefEngine({
    required this._academyService,
    required this._habitService,
    required this._timelineService,
    required this._knowledgeService,
    required this._decisionService,
    required this._memoryGraphService,
    this._growthEngine,
  });

  final AcademyService _academyService;
  final HabitService _habitService;
  final TimelineService _timelineService;
  final KnowledgeService _knowledgeService;
  final DecisionIntelligenceService _decisionService;
  final MemoryGraphService _memoryGraphService;
  final GrowthIndexEngine? _growthEngine;

  // ── Public API ──────────────────────────────────────────────────────

  /// Collects all recommendations from all six services, scored and ranked.
  List<DailyRecommendation> collectRecommendations() {
    final recs = <DailyRecommendation>[
      ..._recommendationsFromAcademy(),
      ..._recommendationsFromHabits(),
      ..._recommendationsFromTimeline(),
      ..._recommendationsFromKnowledge(),
      ..._recommendationsFromDecisions(),
      ..._recommendationsFromGraph(),
      ..._recommendationsFromGrowth(),
    ];
    return rankByPriority(recs);
  }

  /// Ranks recommendations by descending priority score.
  List<DailyRecommendation> rankByPriority(
    List<DailyRecommendation> recommendations,
  ) {
    final sorted = List<DailyRecommendation>.from(recommendations)
      ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return sorted;
  }

  /// Returns the single highest-priority action for today.
  DailyRecommendation? topFocus(
    List<DailyRecommendation> recommendations,
  ) {
    final ranked = rankByPriority(recommendations);
    if (ranked.isEmpty) return null;
    return ranked.first;
  }

  /// Filters and orders insights (non-critical, reflective items).
  List<DailyRecommendation> orderInsights(
    List<DailyRecommendation> recommendations,
  ) {
    final insights = recommendations
        .where((r) => r.priority != RecommendationPriority.critical)
        .toList();
    // Order: highest confidence first
    insights.sort((a, b) => b.confidence.compareTo(a.confidence));
    return insights;
  }

  /// Computes the urgency score for a single recommendation (0.0–1.0).
  ///
  /// Urgency factors:
  /// - Time sensitivity (streak at risk, pending decisions, etc.)
  /// - Blocking status (prevents other progress)
  /// - Freshness (recent activity needs follow-up)
  double computeUrgency(DailyRecommendation recommendation) {
    // Base urgency from metadata factors set during collection
    final baseUrgency = recommendation.urgency;

    // Boost if the recommendation has high-confidence metadata signals
    final hasTimeSignal =
        recommendation.metadata['timeSensitive'] as bool? ?? false;
    final hasBlockingSignal =
        recommendation.metadata['isBlocking'] as bool? ?? false;

    var urgency = baseUrgency;
    if (hasTimeSignal) urgency = (urgency + 0.3).clamp(0.0, 1.0);
    if (hasBlockingSignal) urgency = (urgency + 0.2).clamp(0.0, 1.0);

    return urgency;
  }

  /// Computes the confidence score for a single recommendation (0.0–1.0).
  ///
  /// Confidence factors:
  /// - Data completeness (enough data to make a recommendation)
  /// - Signal consistency (multiple signals point the same way)
  /// - Recency (fresh data is more reliable)
  double computeConfidence(DailyRecommendation recommendation) {
    // Base confidence from metadata
    final hasData = recommendation.metadata['hasData'] as bool? ?? false;
    final signalCount = recommendation.metadata['signalCount'] as int? ?? 0;

    if (!hasData) return 0.1;
    if (signalCount >= 3) return 0.9;
    if (signalCount >= 2) return 0.7;
    if (signalCount >= 1) return 0.5;
    return 0.3;
  }

  // ── Academy Recommendations ─────────────────────────────────────────

  List<DailyRecommendation> _recommendationsFromAcademy() {
    final recs = <DailyRecommendation>[];

    // Current in-progress lesson — high priority
    final currentProgress = _academyService.currentLesson;
    if (currentProgress != null && !currentProgress.state.isFinished) {
      recs.add(DailyRecommendation(
        id: 'academy-resume-${currentProgress.lessonId}',
        type: RecommendationType.learning,
        title: 'Resume lesson',
        description: 'You have an active lesson in progress.',
        priority: RecommendationPriority.high,
        urgency: 0.7,
        confidence: 0.9,
        sourceService: 'AcademyService',
        metadata: {
          'lessonId': currentProgress.lessonId,
          'hasData': true,
          'signalCount': 2,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    // Next available lesson — medium priority
    final nextLesson = _academyService.nextLesson;
    if (nextLesson != null) {
      recs.add(DailyRecommendation(
        id: 'academy-next-${nextLesson.lessonId}',
        type: RecommendationType.learning,
        title: 'Start next lesson',
        description: 'Your next lesson is ready to begin.',
        priority: RecommendationPriority.medium,
        urgency: 0.5,
        confidence: 0.8,
        sourceService: 'AcademyService',
        metadata: {
          'lessonId': nextLesson.lessonId,
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    // DNA-based path recommendation
    final recommendedPaths = _academyService.getRecommendedPathsFromDna();
    if (recommendedPaths.isNotEmpty) {
      final topPath = recommendedPaths.first;
      recs.add(DailyRecommendation(
        id: 'academy-path-${topPath.id}',
        type: RecommendationType.learning,
        title: 'Explore "${topPath.title}"',
        description:
            'Targets your growth areas with ${topPath.modules.length} modules.',
        priority: RecommendationPriority.medium,
        urgency: 0.4,
        confidence: 0.7,
        sourceService: 'AcademyService',
        metadata: {
          'pathId': topPath.id,
          'hasData': true,
          'signalCount': 2,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    // Active path summary — low priority context
    final activePaths = _academyService.allProgress;
    final inProgressCount =
        activePaths.where((p) =>
                p.completionPercentage < 1.0 && p.completionPercentage > 0.0)
            .length;
    if (inProgressCount > 0 && recs.isEmpty) {
      recs.add(DailyRecommendation(
        id: 'academy-continue',
        type: RecommendationType.learning,
        title: 'Continue learning',
        description: 'You have $inProgressCount active path'
            '${inProgressCount == 1 ? '' : 's'} in progress.',
        priority: RecommendationPriority.low,
        urgency: 0.3,
        confidence: 0.6,
        sourceService: 'AcademyService',
        metadata: {
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    return recs;
  }

  // ── Habit Recommendations ───────────────────────────────────────────

  List<DailyRecommendation> _recommendationsFromHabits() {
    final recs = <DailyRecommendation>[];
    final activeHabits = _habitService.activeHabits;

    if (activeHabits.isEmpty) {
      return recs;
    }

    // Overall habit insights
    final overallInsights = _habitService.overallInsights();
    if (overallInsights.isNotEmpty) {
      final top = overallInsights.first;
      final desc = top.description ?? top.title;
      recs.add(DailyRecommendation(
        id: 'habit-insight',
        type: RecommendationType.habit,
        title: top.title,
        description: desc,
        priority: RecommendationPriority.medium,
        urgency: 0.5,
        confidence: 0.8,
        sourceService: 'HabitService',
        metadata: {
          'hasData': true,
          'signalCount': activeHabits.length,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    // Completion status
    final completedToday =
        activeHabits.where((h) => _habitService.isCompletedToday(h.id)).length;
    final pendingCount = activeHabits.length - completedToday;
    if (pendingCount > 0) {
      recs.add(DailyRecommendation(
        id: 'habit-pending',
        type: RecommendationType.habit,
        title: 'Complete $pendingCount remaining habit'
            '${pendingCount == 1 ? '' : 's'}',
        description:
            '$completedToday/${activeHabits.length} done today.',
        priority:
            pendingCount > 2 ? RecommendationPriority.high : RecommendationPriority.medium,
        urgency: pendingCount > 2 ? 0.8 : 0.5,
        confidence: 0.9,
        sourceService: 'HabitService',
        metadata: {
          'hasData': true,
          'signalCount': 2,
          'timeSensitive': true,
          'isBlocking': false,
        },
      ));
    }

    if (recs.isEmpty) {
      recs.add(DailyRecommendation(
        id: 'habit-all-done',
        type: RecommendationType.habit,
        title: 'All habits complete',
        description:
            'All ${activeHabits.length} habits completed today!',
        priority: RecommendationPriority.low,
        urgency: 0.1,
        confidence: 0.9,
        sourceService: 'HabitService',
        metadata: {
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    return recs;
  }

  // ── Timeline Recommendations ────────────────────────────────────────

  List<DailyRecommendation> _recommendationsFromTimeline() {
    final recs = <DailyRecommendation>[];

    // Today's events
    final todayEvents = _timelineService.todayEvents;
    if (todayEvents.isNotEmpty) {
      final categories =
          todayEvents.map((e) => e.category.label).toSet().join(', ');
      recs.add(DailyRecommendation(
        id: 'timeline-today',
        type: RecommendationType.timeline,
        title: 'Review today\'s activity',
        description:
            '${todayEvents.length} event${todayEvents.length == 1 ? '' : 's'} today across $categories.',
        priority: RecommendationPriority.medium,
        urgency: 0.5,
        confidence: 0.9,
        sourceService: 'TimelineService',
        metadata: {
          'eventCount': todayEvents.length,
          'hasData': true,
          'signalCount': 2,
          'timeSensitive': true,
          'isBlocking': false,
        },
      ));
    }

    // Milestones
    final milestones = _timelineService.milestones;
    if (milestones.isNotEmpty) {
      final recent = milestones.take(3).map((m) => m.title).join(', ');
      recs.add(DailyRecommendation(
        id: 'timeline-milestones',
        type: RecommendationType.timeline,
        title: 'Recent milestones',
        description: recent,
        priority: RecommendationPriority.low,
        urgency: 0.2,
        confidence: 0.8,
        sourceService: 'TimelineService',
        metadata: {
          'milestoneCount': milestones.length,
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    // Weekly summary
    final weekEvents = _timelineService.thisWeekEvents;
    if (todayEvents.isEmpty && weekEvents.isNotEmpty) {
      recs.add(DailyRecommendation(
        id: 'timeline-week',
        type: RecommendationType.timeline,
        title: 'Weekly review',
        description:
            '${weekEvents.length} events this week.',
        priority: RecommendationPriority.low,
        urgency: 0.3,
        confidence: 0.7,
        sourceService: 'TimelineService',
        metadata: {
          'eventCount': weekEvents.length,
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    return recs;
  }

  // ── Knowledge Recommendations ───────────────────────────────────────

  List<DailyRecommendation> _recommendationsFromKnowledge() {
    final recs = <DailyRecommendation>[];
    final analytics = _knowledgeService.analytics;
    final nodeCount = analytics['nodeCount'] as int? ?? 0;
    final edgeCount = analytics['edgeCount'] as int? ?? 0;

    if (nodeCount == 0) return recs;

    // Knowledge engine insights
    final insights = _knowledgeService.insights;
    if (insights.isNotEmpty) {
      final top = insights.first;
      final desc = top.description ?? top.title;
      recs.add(DailyRecommendation(
        id: 'knowledge-insight',
        type: RecommendationType.knowledge,
        title: top.title,
        description: desc,
        priority: RecommendationPriority.medium,
        urgency: 0.4,
        confidence: 0.8,
        sourceService: 'KnowledgeService',
        metadata: {
          'hasData': true,
          'signalCount': insights.length,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    // Low-coverage domains
    final domainCoverage = analytics['domainCoverage'];
    if (domainCoverage != null && domainCoverage is Map) {
      final lowCoverage = (domainCoverage as Map<String, dynamic>)
          .entries
          .where((e) => (e.value is num) && (e.value as num) < 0.5)
          .map((e) => e.key)
          .toList();
      if (lowCoverage.isNotEmpty) {
        recs.add(DailyRecommendation(
          id: 'knowledge-gap-${lowCoverage.first}',
          type: RecommendationType.knowledge,
          title: 'Explore ${lowCoverage.first} domain',
          description:
              'Lowest coverage area in your knowledge graph.',
          priority: RecommendationPriority.medium,
          urgency: 0.4,
          confidence: 0.7,
          sourceService: 'KnowledgeService',
          metadata: {
            'hasData': true,
            'signalCount': 2,
            'timeSensitive': false,
            'isBlocking': false,
          },
        ));
      }
    }

    // Static summary
    if (recs.isEmpty && nodeCount > 0) {
      recs.add(DailyRecommendation(
        id: 'knowledge-summary',
        type: RecommendationType.knowledge,
        title: '$nodeCount knowledge nodes',
        description:
            '$nodeCount nodes connected by $edgeCount edges.',
        priority: RecommendationPriority.low,
        urgency: 0.2,
        confidence: 0.8,
        sourceService: 'KnowledgeService',
        metadata: {
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    return recs;
  }

  // ── Decision Recommendations ────────────────────────────────────────

  List<DailyRecommendation> _recommendationsFromDecisions() {
    final recs = <DailyRecommendation>[];
    final analyses = _decisionService.allAnalyses;

    if (analyses.isEmpty) return recs;

    // Decisions without recorded outcomes — follow-up needed
    final pendingFollowUp =
        analyses.where((a) => a.outcome == null).toList();
    if (pendingFollowUp.isNotEmpty) {
      final decision = pendingFollowUp.first;
      recs.add(DailyRecommendation(
        id: 'decision-followup-${decision.id}',
        type: RecommendationType.decision,
        title: 'Follow up on "${decision.title}"',
        description: 'No outcome recorded yet.',
        priority: RecommendationPriority.medium,
        urgency: 0.5,
        confidence: 0.8,
        sourceService: 'DecisionIntelligenceService',
        metadata: {
          'decisionId': decision.id,
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    // Most recent outcome — reflection
    final withOutcomes = analyses
        .where((a) => a.outcome != null && a.outcome!.outcomeDate != null)
        .toList();
    if (withOutcomes.isNotEmpty) {
      final latest = withOutcomes.reduce((a, b) {
        final aTime = a.outcome!.outcomeDate!;
        final bTime = b.outcome!.outcomeDate!;
        return aTime.isAfter(bTime) ? a : b;
      });
      recs.add(DailyRecommendation(
        id: 'decision-reflect-${latest.id}',
        type: RecommendationType.decision,
        title: 'Reflect on "${latest.title}"',
        description: latest.outcome!.satisfaction != null
            ? 'Rated ${latest.outcome!.satisfaction}/10.'
            : 'How did it turn out?',
        priority: RecommendationPriority.low,
        urgency: 0.3,
        confidence: 0.7,
        sourceService: 'DecisionIntelligenceService',
        metadata: {
          'decisionId': latest.id,
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    return recs;
  }

  // ── Growth Index Recommendations ───────────────────────────────────

  /// Generates recommendations based on growth scores and trends.
  ///
  /// Reads from [GrowthIndexEngine.snapshot] to create:
  /// 1. Weakest dimension focus — high priority if score < 0.6
  /// 2. Declining trend alert — medium priority if any dimension declining
  /// 3. Growth summary — low priority context
  List<DailyRecommendation> _recommendationsFromGrowth() {
    final engine = _growthEngine;
    if (engine == null || engine.snapshot == null) return [];

    final snapshot = engine.snapshot!;
    final recs = <DailyRecommendation>[];

    // 1. Weakest dimension — high priority focus
    final weakest = snapshot.weakestDimension;
    if (weakest.score < 0.6) {
      recs.add(DailyRecommendation(
        id: 'growth-weakest-${weakest.dimension.name}',
        type: RecommendationType.learning,
        title: 'Focus on ${weakest.dimension.displayName}',
        description:
            'Your ${weakest.dimension.displayName} score is '
            '${(weakest.score * 100).round()}% — '
            'the lowest area. Improving it will boost overall growth.',
        priority: RecommendationPriority.high,
        urgency: 0.7,
        confidence: 0.8,
        sourceService: 'GrowthIndexEngine',
        metadata: {
          'dimension': weakest.dimension.name,
          'score': weakest.score,
          'trend': weakest.trend.name,
          'hasData': true,
          'signalCount': 3,
          'timeSensitive': true,
          'isBlocking': false,
        },
      ));
    }

    // 2. Declining trends — medium priority alert
    final declining = snapshot.allMetrics
        .where((m) => m.trend == GrowthTrend.declining && m.score > 0.1)
        .toList();
    for (final dim in declining.take(2)) {
      recs.add(DailyRecommendation(
        id: 'growth-declining-${dim.dimension.name}',
        type: RecommendationType.learning,
        title: '${dim.dimension.displayName} is declining',
        description:
            'Your ${dim.dimension.displayName} score dropped '            'from ${((dim.previousScore ?? 0.0) * 100).round()}% '
            'to ${(dim.score * 100).round()}%.'
            'Review what changed and take action.',
        priority: RecommendationPriority.medium,
        urgency: 0.5,
        confidence: 0.7,
        sourceService: 'GrowthIndexEngine',
        metadata: {
          'dimension': dim.dimension.name,
          'score': dim.score,
          'trend': dim.trend.name,
          'hasData': true,
          'signalCount': 2,
          'timeSensitive': true,
          'isBlocking': false,
        },
      ));
    }

    // 3. Improving trends — low praise
    final improving = snapshot.allMetrics
        .where((m) => m.trend == GrowthTrend.improving && m.score > 0.1)
        .toList();
    if (improving.isNotEmpty) {
      final top = improving.first;
      recs.add(DailyRecommendation(
        id: 'growth-improving-${top.dimension.name}',
        type: RecommendationType.learning,
        title: '${top.dimension.displayName} is improving',
        description:
            'Your ${top.dimension.displayName} score increased to '
            '${(top.score * 100).round()}%. '
            'Keep up the momentum!',
        priority: RecommendationPriority.low,
        urgency: 0.2,
        confidence: 0.8,
        sourceService: 'GrowthIndexEngine',
        metadata: {
          'dimension': top.dimension.name,
          'score': top.score,
          'trend': top.trend.name,
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    return recs;
  }

  // ── Memory Graph Recommendations ────────────────────────────────────

  List<DailyRecommendation> _recommendationsFromGraph() {
    final recs = <DailyRecommendation>[];
    final graph = _memoryGraphService.graph;
    final entityCount = graph.entityCount;

    if (entityCount == 0) return recs;

    // Graph insights
    final insights = _memoryGraphService.insights();
    if (insights.isNotEmpty) {
      final top = insights.first;
      recs.add(DailyRecommendation(
        id: 'graph-insight',
        type: RecommendationType.graph,
        title: top.title,
        description: top.description ?? 'Memory graph insight.',
        priority: RecommendationPriority.low,
        urgency: 0.3,
        confidence: 0.7,
        sourceService: 'MemoryGraphService',
        metadata: {
          'hasData': true,
          'signalCount': insights.length,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    // Graph stats
    if (recs.isEmpty) {
      recs.add(DailyRecommendation(
        id: 'graph-summary',
        type: RecommendationType.graph,
        title: '$entityCount entities mapped',
        description:
            '${graph.relationCount} relationships in your memory graph.',
        priority: RecommendationPriority.low,
        urgency: 0.1,
        confidence: 0.8,
        sourceService: 'MemoryGraphService',
        metadata: {
          'hasData': true,
          'signalCount': 1,
          'timeSensitive': false,
          'isBlocking': false,
        },
      ));
    }

    return recs;
  }
}
