import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../../memory/services/memory_service.dart';
import '../../mission_engine/mission_engine.dart' as mission_engine;
import '../../mission_engine/mission_service.dart';
import '../../progress_engine/progress_service.dart';
import '../../recommendation/models/recommendation.dart';
import '../../recommendation/services/recommendation_service.dart';
import '../models/decision.dart';

/// The Decision Engine selects the user's next highest-impact action.
///
/// **Inputs**
/// - Identity (via Repository)
/// - Journey (via Repository)
/// - Current Stage (via Repository)
/// - Mission Progress (via MissionService)
/// - Knowledge DNA (via KnowledgeDNAService)
/// - Progress (via ProgressService)
/// - Memory (via MemoryService)
/// - Recommendations (via RecommendationService)
///
/// **Output**
/// A single [Decision] with a confidence score, priority, and source module
/// attribution. The engine favours recommendations that align with the
/// current Journey stage, address Knowledge DNA weaknesses, and respect
/// the user's progress momentum.
///
/// **Rules**
/// - No AI
/// - No persistence
/// - No networking
/// - Recommendation is one of the inputs; DecisionService owns the final decision
class DecisionService {
  DecisionService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  // ─────────────────────────────────────────────────────────────────────
  // Internal service accessors (lazy, stateless)
  // ─────────────────────────────────────────────────────────────────────

  MissionService get _missionService => MissionService(repository: repository);

  ProgressService get _progressService =>
      ProgressService(repository: repository);

  KnowledgeDNAService get _knowledgeDnaService =>
      KnowledgeDNAService(repository: repository);

  MemoryService get _memoryService => MemoryService(repository: repository);

  RecommendationService get _recommendationService =>
      RecommendationService(repository: repository);

  // ─────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────

  /// Returns the single highest-impact decision for the user's next action.
  Decision getDecision() {
    final candidates = getCandidates();
    return candidates.first;
  }

  /// Returns all candidate decisions ranked by confidence descending.
  List<Decision> getCandidates() {
    final candidates = <Decision>[];

    // 1 — Recommendation input (highest weight)
    candidates.addAll(_buildFromRecommendations());

    // 2 — Journey stage urgency
    candidates.add(_buildFromJourney());

    // 3 — Mission progress gaps
    candidates.addAll(_buildFromMissions());

    // 4 — Knowledge DNA weaknesses
    candidates.add(_buildFromKnowledgeDna());

    // 5 — Progress momentum / streak preservation
    candidates.add(_buildFromProgress());

    // 6 — Memory signals (pinned memories, recent milestones)
    candidates.add(_buildFromMemory());

    // Sort by confidence descending, then priority descending
    candidates.sort((a, b) {
      final confidenceCmp = b.confidence.compareTo(a.confidence);
      if (confidenceCmp != 0) return confidenceCmp;
      return _priorityWeight(b.priority).compareTo(_priorityWeight(a.priority));
    });

    return candidates;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Candidate builders
  // ─────────────────────────────────────────────────────────────────────

  List<Decision> _buildFromRecommendations() {
    final recommendations = _recommendationService.getSampleRecommendations();

    return recommendations.map((rec) {
      final confidence = switch (rec.priority) {
        RecommendationPriority.critical => 0.95,
        RecommendationPriority.high => 0.75,
        RecommendationPriority.medium => 0.50,
        RecommendationPriority.low => 0.25,
      };

      return Decision(
        id: 'decision-${rec.id}',
        title: rec.title,
        description: rec.description,
        reason: rec.reason,
        priority: switch (rec.priority) {
          RecommendationPriority.critical => DecisionPriority.critical,
          RecommendationPriority.high => DecisionPriority.high,
          RecommendationPriority.medium => DecisionPriority.medium,
          RecommendationPriority.low => DecisionPriority.low,
        },
        estimatedDuration: rec.estimatedDuration,
        sourceModule: 'recommendation',
        confidence: confidence,
        actionLabel: rec.actionLabel,
      );
    }).toList();
  }

  Decision _buildFromJourney() {
    final journey = repository.journey;
    final currentStage = repository.currentJourneyStage;

    final confidence = (1.0 - journey.completion).clamp(0.3, 0.85);

    final remainingMissions =
        currentStage.missions.length -
        (currentStage.completion * currentStage.missions.length).round();
    final nextMissionIndex = currentStage.missions.length - remainingMissions;
    final nextMission =
        remainingMissions > 0 &&
            nextMissionIndex >= 0 &&
            nextMissionIndex < currentStage.missions.length
        ? currentStage.missions[nextMissionIndex]
        : null;

    return Decision(
      id: 'decision-journey-stage',
      title: nextMission != null
          ? 'Continue: $nextMission'
          : 'Progress ${currentStage.title} Stage',
      description:
          'You are in the ${currentStage.title} stage of your '
          '${journey.title} journey. Focus on completing the remaining '
          'missions to unlock the next stage.',
      reason:
          'Stage ${journey.currentStage + 1} of ${journey.stages.length}: '
          '$remainingMissions mission${remainingMissions == 1 ? '' : 's'} '
          'remaining in ${currentStage.title}.',
      priority: confidence >= 0.7
          ? DecisionPriority.high
          : DecisionPriority.medium,
      estimatedDuration: 30,
      sourceModule: 'journey',
      confidence: confidence,
      actionLabel: nextMission != null ? 'Continue Learning' : 'View Journey',
    );
  }

  List<Decision> _buildFromMissions() {
    final missionProgress = _missionService.buildProgress();
    final allMissions = <mission_engine.Mission>[
      ...missionProgress.dailyMissions,
      ...missionProgress.weeklyMissions,
    ];

    mission_engine.Mission? nextMission;
    try {
      nextMission = allMissions.firstWhere((m) => !m.isCompleted);
    } catch (_) {
      return [];
    }

    final confidence =
        ((1.0 - missionProgress.completionPercentage) * 0.6 + 0.2).clamp(
          0.2,
          0.8,
        );

    return [
      Decision(
        id: 'decision-mission-next',
        title: nextMission.title,
        description: nextMission.description,
        reason:
            'You have completed ${missionProgress.completedCount} of '
            '${missionProgress.completedCount + missionProgress.pendingCount} '
            'missions. This is your next task.',
        priority: confidence >= 0.5
            ? DecisionPriority.high
            : DecisionPriority.medium,
        estimatedDuration: nextMission.estimatedDuration,
        sourceModule: 'mission',
        confidence: confidence,
        actionLabel: 'Start Mission',
      ),
    ];
  }

  Decision _buildFromKnowledgeDna() {
    final analysis = _knowledgeDnaService.buildAnalysis();

    final confidence = ((1.0 - analysis.knowledgeScore) * 0.7).clamp(0.1, 0.7);

    final weaknessDescription = analysis.skillWeaknesses.isNotEmpty
        ? analysis.skillWeaknesses.first
        : 'emerging areas';

    return Decision(
      id: 'decision-knowledge-gap',
      title: 'Strengthen: $weaknessDescription',
      description:
          'Your Knowledge DNA shows room to grow in '
          '${analysis.skillWeaknesses.length} '
          'area${analysis.skillWeaknesses.length == 1 ? '' : 's'}. '
          'Focusing on ${weaknessDescription.toLowerCase()} will '
          'accelerate your overall growth.',
      reason:
          'Knowledge score: ${(analysis.knowledgeScore * 100).round()}%. '
          'Weakest areas: ${analysis.skillWeaknesses.take(2).join(', ')}.',
      priority: confidence >= 0.5
          ? DecisionPriority.medium
          : DecisionPriority.low,
      estimatedDuration: 20,
      sourceModule: 'knowledge_dna',
      confidence: confidence,
      actionLabel: 'Start Learning',
    );
  }

  Decision _buildFromProgress() {
    final progressSummary = _progressService.buildSummary();

    final streakWeight = (progressSummary.streaks.daily / 10.0).clamp(0.0, 0.5);
    final confidence = (0.2 + streakWeight).clamp(0.2, 0.7);

    final hasActiveStreak = progressSummary.streaks.daily > 0;

    return Decision(
      id: 'decision-progress-streak',
      title: hasActiveStreak
          ? 'Keep Your ${progressSummary.streaks.daily}-Day Streak'
          : 'Start Your Streak Today',
      description: hasActiveStreak
          ? 'Complete a mission today to maintain your '
                '${progressSummary.streaks.daily}-day streak and keep '
                'building momentum.'
          : 'Complete your first mission to start a learning streak '
                'and build consistent habits.',
      reason:
          'Level ${progressSummary.level} • '
          '${progressSummary.streaks.daily}-day streak • '
          '${(progressSummary.completionPercentage * 100).round()}% '
          'mission completion.',
      priority: hasActiveStreak
          ? DecisionPriority.high
          : DecisionPriority.medium,
      estimatedDuration: 15,
      sourceModule: 'progress',
      confidence: confidence,
      actionLabel: hasActiveStreak ? 'Continue Streak' : 'Start Now',
    );
  }

  Decision _buildFromMemory() {
    final pinnedMemories = _memoryService.getPinnedMemories();
    final recentMemories = _memoryService.getRecentMemories(count: 2);

    // Confidence based on how many pinned memories need attention.
    // More pinned items = more context the user cares about.
    final confidence = (0.15 + pinnedMemories.length * 0.05).clamp(0.15, 0.35);

    final hasUnreviewed = recentMemories.isNotEmpty;

    return Decision(
      id: 'decision-memory-review',
      title: hasUnreviewed ? 'Review Recent Milestones' : 'Add a Memory Entry',
      description:
          'You have ${pinnedMemories.length} pinned memor${pinnedMemories.length == 1 ? 'y' : 'ies'} '
          'and ${recentMemories.length} recent entr${recentMemories.length == 1 ? 'y' : 'ies'}. '
          'Reflecting on your journey helps reinforce learning.',
      reason:
          'Memory keeps your journey visible. '
          '${pinnedMemories.isNotEmpty ? 'Pinned memories: ${pinnedMemories.map((m) => m.title).join(', ')}' : 'No pinned memories yet.'}',
      priority: DecisionPriority.low,
      estimatedDuration: 10,
      sourceModule: 'memory',
      confidence: confidence,
      actionLabel: hasUnreviewed ? 'Review Memories' : 'Add Memory',
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────

  static double _priorityWeight(DecisionPriority priority) {
    return switch (priority) {
      DecisionPriority.critical => 4.0,
      DecisionPriority.high => 3.0,
      DecisionPriority.medium => 2.0,
      DecisionPriority.low => 1.0,
    };
  }
}
