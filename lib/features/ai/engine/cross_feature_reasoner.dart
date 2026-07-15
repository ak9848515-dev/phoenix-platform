import '../../academy/services/academy_service.dart';
import '../../habit/services/habit_service.dart';
import '../../timeline/services/timeline_service.dart';
import '../../personal_knowledge/services/knowledge_service.dart';
import '../../decision/services/decision_intelligence_service.dart';
import '../../memory_graph/services/memory_graph_service.dart';
import '../models/phoenix_insight.dart' show PhoenixInsight;
import '../models/phoenix_opportunity.dart' show PhoenixOpportunity;
import '../models/phoenix_risk.dart' show PhoenixRisk, RiskSeverity;

/// Pure reasoning engine that discovers relationships between multiple
/// Phoenix platform domains.
///
/// [CrossFeatureReasoner] combines signals from two or more services to
/// produce:
/// - [PhoenixInsight] — meaningful cross-domain patterns
/// - [PhoenixRisk] — negative patterns that could impact progress
/// - [PhoenixOpportunity] — positive patterns worth pursuing
///
/// **Architecture Rules:**
/// - Pure computation — no persistence, no AI, no repositories
/// - Consumes services only — never owns data
/// - Engine logic only — never generates UI strings
class CrossFeatureReasoner {
  CrossFeatureReasoner({
    required this._academyService,
    required this._habitService,
    required this._timelineService,
    required this._knowledgeService,
    required this._decisionService,
    required this._memoryGraphService,
  });

  final AcademyService _academyService;
  final HabitService _habitService;
  final TimelineService _timelineService;
  final KnowledgeService _knowledgeService;
  final DecisionIntelligenceService _decisionService;
  final MemoryGraphService _memoryGraphService;

  // ── Public API ──────────────────────────────────────────────────────

  /// Generates all cross-domain insights, risks, and opportunities.
  CrossFeatureResult reason() {
    return CrossFeatureResult(
      insights: _generateInsights(),
      risks: _generateRisks(),
      opportunities: _generateOpportunities(),
    );
  }

  // ── Insight Generation ──────────────────────────────────────────────

  /// Generates cross-domain insights by combining signals from multiple
  /// services.
  List<PhoenixInsight> _generateInsights() {
    final candidates = <PhoenixInsight?>[
      _insightLearningHabitSynergy(),
      _insightKnowledgeDecisionPattern(),
      _insightGraphTimelineConnection(),
      _insightTimelineDecisionUrgency(),
    ];
    return candidates.whereType<PhoenixInsight>().toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// R1: Learning activity decreasing + Habit consistency increasing
  ///     → User may benefit from shorter learning sessions
  PhoenixInsight? _insightLearningHabitSynergy() {
    final currentLesson = _academyService.currentLesson;
    final nextLesson = _academyService.nextLesson;
    final activeHabits = _habitService.activeHabits;
    final overallStats = _habitService.allStatistics();

    // Detect low learning activity: no current lesson AND no next lesson
    final noLearningActivity = currentLesson == null && nextLesson == null;

    // Detect habit momentum: any habit has streak of 3+ days
    final hasHabitMomentum =
        overallStats.values.any((s) => s.hasStreak);

    // Detect high habit consistency: average completion rate > 60%
    var avgCompletionRate = 0.0;
    if (overallStats.isNotEmpty) {
      avgCompletionRate = overallStats.values
              .fold(0.0, (sum, s) => sum + s.completionRate) /
          overallStats.length;
    }
    final habitConsistent = avgCompletionRate > 0.6;

    if (activeHabits.isNotEmpty &&
        noLearningActivity &&
        (hasHabitMomentum || habitConsistent)) {
      final confidence = (hasHabitMomentum ? 0.4 : 0.0) +
          (habitConsistent ? 0.4 : 0.0);
      return PhoenixInsight(
        id: 'insight-learning-habit-synergy',
        title: 'Learning + Habit Synergy',
        description:
            'Your habits are strong but there is no active learning. '
            'Try pairing a short 5-minute lesson with an existing habit '
            'to build a learning routine.',
        confidence: confidence.clamp(0.0, 1.0),
        priority: 0.65,
        sourceDomains: ['AcademyService', 'HabitService'],
      );
    }

    return null;
  }

  /// R2: Decision outcomes + Knowledge growth
  ///     → Highlight successful learning patterns from past decisions
  PhoenixInsight? _insightKnowledgeDecisionPattern() {
    final analyses = _decisionService.allAnalyses;
    final analytics = _knowledgeService.analytics;
    final nodeCount = analytics['nodeCount'] as int? ?? 0;

    // Find decisions with positive outcomes
    final positiveOutcomes =
        analyses.where((a) =>
            a.outcome != null &&
            (a.outcome!.satisfaction ?? 0) >= 7);
    final totalWithOutcomes =
        analyses.where((a) => a.outcome != null).length;

    if (positiveOutcomes.isNotEmpty && nodeCount > 0) {
      final ratio = positiveOutcomes.length / totalWithOutcomes;
      return PhoenixInsight(
        id: 'insight-decision-knowledge-pattern',
        title: 'Informed Decisions Drive Growth',
        description:
            '${positiveOutcomes.length} of $totalWithOutcomes past decisions '
            'had highly satisfactory outcomes (7+). Combined with '
            'your $nodeCount knowledge nodes, this suggests your '
            'domain knowledge is translating into good choices.',
        confidence: ratio.clamp(0.3, 0.95),
        priority: 0.7,
        sourceDomains: ['DecisionIntelligenceService', 'KnowledgeService'],
      );
    }

    return PhoenixInsight(
      id: 'insight-decision-knowledge-potential',
      title: 'Track Decisions to Learn',
      description:
          'Recording decision outcomes builds a feedback loop '
          'that strengthens your knowledge graph over time.',
      confidence: 0.4,
      priority: 0.3,
      sourceDomains: ['DecisionIntelligenceService', 'KnowledgeService'],
    );
  }

  /// R3: Timeline milestone overdue + Decision pending
  ///     → Suggest immediate action
  PhoenixInsight? _insightTimelineDecisionUrgency() {
    final milestones = _timelineService.milestones;
    final analyses = _decisionService.allAnalyses;
    final pendingFollowUp =
        analyses.where((a) => a.outcome == null).toList();

    if (milestones.length >= 2 && pendingFollowUp.isNotEmpty) {
      return PhoenixInsight(
        id: 'insight-timeline-decision-urgency',
        title: 'Milestones + Pending Decisions',
        description:
            'You have ${milestones.length} milestones and '
            '${pendingFollowUp.length} decisions awaiting follow-up. '
            'Recording outcomes for past decisions helps connect your '
            'timeline achievements to the choices that led to them.',
        confidence: 0.7,
        priority: 0.75,
        sourceDomains: ['TimelineService', 'DecisionIntelligenceService'],
      );
    }

    return null;
  }

  /// R4: Graph connections + Timeline milestones
  ///     → Detected pattern in entity relationships
  PhoenixInsight? _insightGraphTimelineConnection() {
    final graph = _memoryGraphService.graph;
    final milestones = _timelineService.milestones;

    if (graph.entityCount >= 3 && milestones.length >= 2) {
      return PhoenixInsight(
        id: 'insight-graph-timeline-connection',
        title: 'Memory Graph Reflects Your Journey',
        description:
            'Your memory graph contains ${graph.entityCount} entities, '
            'and your timeline has ${milestones.length} milestones. '
            'Each milestone likely maps to one or more entities — '
            'explore the graph to rediscover past achievements.',
        confidence: 0.7,
        priority: 0.55,
        sourceDomains: ['MemoryGraphService', 'TimelineService'],
      );
    }

    return PhoenixInsight(
      id: 'insight-graph-timeline-seed',
      title: 'Build Your Memory Graph',
      description:
          'Complete missions and decisions to populate your memory '
          'graph. Each new entity creates connections that reveal '
          'hidden patterns in your personal journey.',
      confidence: 0.5,
      priority: 0.35,
      sourceDomains: ['MemoryGraphService', 'TimelineService'],
    );
  }

  // ── Risk Generation ─────────────────────────────────────────────────

  /// Generates cross-domain risks by detecting negative patterns.
  List<PhoenixRisk> _generateRisks() {
    final candidates = <PhoenixRisk?>[
      _riskHabitStreakTimelineWorkload(),
      _riskDecisionStagnation(),
      _riskKnowledgeStagnation(),
    ];
    return candidates.whereType<PhoenixRisk>().toList()
      ..sort((a, b) => b.severity.rank.compareTo(a.severity.rank));
  }

  /// R5: Habit streak broken + Timeline workload high
  ///     → Risk of burnout or overcommitment
  PhoenixRisk? _riskHabitStreakTimelineWorkload() {
    final overallStats = _habitService.allStatistics();
    final weekEvents = _timelineService.thisWeekEvents;

    // Detect broken streaks: any habit has currentStreak < 3 and longestStreak >= 3
    // meaning the user had a streak that was lost
    final hasBrokenStreak = overallStats.values.any(
        (s) => s.currentStreak < 3 && s.longestStreak >= 3);

    // Detect high workload: 5+ events this week
    final highWorkload = weekEvents.length >= 5;

    if (hasBrokenStreak && highWorkload) {
      return PhoenixRisk(
        id: 'risk-habit-streak-workload',
        title: 'Streak at Risk — High Workload',
        description:
            'You have ${weekEvents.length} events this week and a habit '
            'streak was recently broken. High workload may be interfering '
            'with habit consistency. Consider reducing today\'s load to '
            'rebuild your streak.',
        severity: _severityFromCounts(
          weekEvents.length,
          overallStats.values.fold(0, (sum, s) => sum + s.currentStreak),
        ),
        confidence: 0.75,
      );
    }

    // Moderate risk: high workload even without broken streak
    if (highWorkload) {
      return PhoenixRisk(
        id: 'risk-high-workload',
        title: 'Busy Week Ahead',
        description:
            'You have ${weekEvents.length} events this week. '
            'Keep up with your habits to avoid breaking your streak.',
        severity: RiskSeverity.low,
        confidence: 0.6,
      );
    }

    return null;
  }

  /// R6: Pending decisions accumulating → Decision stagnation
  PhoenixRisk? _riskDecisionStagnation() {
    final analyses = _decisionService.allAnalyses;
    final pendingFollowUp =
        analyses.where((a) => a.outcome == null).toList();

    if (pendingFollowUp.length >= 3) {
      return PhoenixRisk(
        id: 'risk-decision-stagnation',
        title: 'Pending Decisions Accumulating',
        description:
            'You have ${pendingFollowUp.length} decisions without recorded '
            'outcomes. Tracking outcomes improves future decision quality. '
            'Take 2 minutes to follow up on each one.',
        severity: RiskSeverity.medium,
        confidence: 0.8,
      );
    }

    if (pendingFollowUp.isNotEmpty && analyses.length >= 3) {
      return PhoenixRisk(
        id: 'risk-decision-followup',
        title: 'Unrecorded Decision Outcome',
        description:
            'One of your past decisions has no outcome recorded. '
            'Quick follow-ups build a valuable decision history.',
        severity: RiskSeverity.low,
        confidence: 0.6,
      );
    }

    return null;
  }

  /// R7: Knowledge graph small or empty → Stagnation risk
  PhoenixRisk? _riskKnowledgeStagnation() {
    final analytics = _knowledgeService.analytics;
    final nodeCount = analytics['nodeCount'] as int? ?? 0;
    final hasLearning = _academyService.currentLesson != null ||
        _academyService.nextLesson != null;

    if (nodeCount == 0 &&
        _habitService.activeHabits.isEmpty &&
        !hasLearning) {
      return PhoenixRisk(
        id: 'risk-knowledge-stagnation',
        title: 'No Active Growth Signals',
        description:
            'Your knowledge graph is empty, no habits are tracked, '
            'and no lessons are in progress. Start with one small '
            'action — a single lesson or a simple daily habit — to '
            'build momentum.',
        severity: RiskSeverity.high,
        confidence: 0.9,
      );
    }

    if (nodeCount < 3 && hasLearning) {
      return PhoenixRisk(
        id: 'risk-knowledge-graph-sparse',
        title: 'Knowledge Graph is Sparse',
        description:
            'Your knowledge graph has only $nodeCount nodes. '
            'Complete more missions and decisions to populate it '
            'and unlock cross-domain insights.',
        severity: RiskSeverity.low,
        confidence: 0.5,
      );
    }

    return null;
  }

  // ── Opportunity Generation ──────────────────────────────────────────

  /// Generates cross-domain opportunities by detecting positive patterns.
  List<PhoenixOpportunity> _generateOpportunities() {
    final candidates = <PhoenixOpportunity?>[
      _opportunityLearningPathFromGaps(),
      _opportunityHabitLearningPairing(),
      _opportunityGraphExploration(),
    ];
    return candidates.whereType<PhoenixOpportunity>().toList()
      ..sort((a, b) => b.estimatedImpact.compareTo(a.estimatedImpact));
  }

  /// O1: Knowledge gap + Available learning path → High-impact learning
  PhoenixOpportunity? _opportunityLearningPathFromGaps() {
    final analytics = _knowledgeService.analytics;
    final recommendedPaths = _academyService.getRecommendedPathsFromDna();

    if (recommendedPaths.isNotEmpty) {
      final topPath = recommendedPaths.first;
      // Estimate impact from gap coverage
      final domainCoverage = analytics['domainCoverage'];
      var gapCount = 0;
      if (domainCoverage != null && domainCoverage is Map) {
        gapCount = (domainCoverage as Map<String, dynamic>)
            .entries
            .where((e) => (e.value is num) && (e.value as num) < 0.5)
            .length;
      }
      final impact = (0.5 + gapCount * 0.1).clamp(0.0, 1.0);

      return PhoenixOpportunity(
        id: 'opportunity-learning-path-${topPath.id}',
        title: 'Target "${topPath.title}"',
        description:
            'This learning path addresses your knowledge gaps '
            'with ${topPath.modules.length} focused modules. '
            'Completing it would strengthen your weakest areas.',
        estimatedImpact: impact,
        confidence: 0.75,
      );
    }

    return null;
  }

  /// O2: Strong habit streak + Learning opportunity → Pair them
  PhoenixOpportunity? _opportunityHabitLearningPairing() {
    final overallStats = _habitService.allStatistics();
    final hasLearning = _academyService.currentLesson != null ||
        _academyService.nextLesson != null;

    // Find the strongest habit
    final bestHabit = overallStats.entries
        .where((e) => e.value.hasStreak)
        .toList();

    if (bestHabit.isNotEmpty && !hasLearning) {
      final habit = _habitService.getHabit(bestHabit.first.key);
      return PhoenixOpportunity(
        id: 'opportunity-habit-learning-pair',
        title: 'Pair Learning with "${habit?.title ?? 'Your Best Habit'}"',
        description:
            'You have a strong habit streak. Try adding a 5-minute '
            'lesson right after this habit to build a learning routine '
            'on top of existing momentum.',
        estimatedImpact: 0.8,
        confidence: 0.7,
      );
    }

    return null;
  }

  /// O3: Graph has untapped entities → Exploration opportunity
  PhoenixOpportunity? _opportunityGraphExploration() {
    final graph = _memoryGraphService.graph;
    final clusters = _memoryGraphService.detectClusters();

    if (graph.entityCount >= 5 && clusters.length >= 2) {
      final largest = clusters
          .reduce((a, b) => a.entityCount > b.entityCount ? a : b);
      return PhoenixOpportunity(
        id: 'opportunity-graph-explore-${largest.id}',
        title: 'Explore "${largest.label}" Cluster',
        description:
            'Your largest memory cluster contains ${largest.entityCount} '
            'entities. Exploring its connections may reveal insights '
            'about your strongest skill areas.',
        estimatedImpact: 0.6,
        confidence: 0.65,
      );
    }

    return null;
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Determines risk severity from event count and streak health.
  RiskSeverity _severityFromCounts(int eventCount, int totalStreak) {
    if (eventCount >= 8 && totalStreak == 0) return RiskSeverity.high;
    if (eventCount >= 5) return RiskSeverity.medium;
    return RiskSeverity.low;
  }
}

/// Result container for all cross-feature reasoning output.
class CrossFeatureResult {
  const CrossFeatureResult({
    this.insights = const [],
    this.risks = const [],
    this.opportunities = const [],
  });

  /// Cross-domain insights discovered.
  final List<PhoenixInsight> insights;

  /// Risks detected across domains.
  final List<PhoenixRisk> risks;

  /// Opportunities detected across domains.
  final List<PhoenixOpportunity> opportunities;

  /// Whether any signals were detected at all.
  bool get hasSignals =>
      insights.isNotEmpty || risks.isNotEmpty || opportunities.isNotEmpty;
}
