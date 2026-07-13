import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../../decision/services/decision_service.dart';
import '../../journey/models/journey_stage.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../../mission_engine/mission_service.dart';
import '../../progress_engine/progress_service.dart';
import '../models/career_profile.dart';

/// Measures how close the user is to becoming employable.
///
/// Aggregates data from Identity, Journey, Mission, Knowledge DNA,
/// Progress, and Decision modules into a single [CareerProfile] with
/// readiness scores, strengths, skill gaps, and estimated timeline.
///
/// Presentation only. No AI, no persistence, no networking.
class CareerService {
  CareerService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  // ─────────────────────────────────────────────────────────────────────
  // Internal service accessors
  // ─────────────────────────────────────────────────────────────────────
  // Internal service accessors
  // ─────────────────────────────────────────────────────────────────────

  MissionService get _missionService => MissionService(repository: repository);

  ProgressService get _progressService =>
      ProgressService(repository: repository);

  KnowledgeDNAService get _knowledgeDnaService =>
      KnowledgeDNAService(repository: repository);

  DecisionService get _decisionService =>
      DecisionService(repository: repository);

  // ─────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────

  /// Builds the career readiness profile from all integrated modules.
  CareerProfile buildProfile() {
    final identity = repository.selectedIdentity;
    final journey = repository.journey;
    final currentStage = repository.currentJourneyStage;
    final missionProgress = _missionService.buildProgress();
    final progressSummary = _progressService.buildSummary();
    final knowledgeAnalysis = _knowledgeDnaService.buildAnalysis();
    final topDecision = _decisionService.getDecision();

    // ── Career score ──────────────────────────────────────────────────
    // Weighted combination of journey completion, mission progress,
    // knowledge DNA, and progress level.
    final careerScore =
        (journey.completion * 0.30 +
                missionProgress.completionPercentage * 0.20 +
                knowledgeAnalysis.knowledgeScore * 0.30 +
                (progressSummary.level / identity.targetLevel) * 0.20)
            .clamp(0.0, 1.0);

    // ── Job readiness label ───────────────────────────────────────────
    final jobReadiness = _deriveJobReadiness(careerScore);

    // ── Strengths (from Knowledge DNA + Journey) ──────────────────────
    final strengths = <String>[
      if (knowledgeAnalysis.skillStrengths.isNotEmpty)
        ...knowledgeAnalysis.skillStrengths.take(3),
      if (journey.stages.isNotEmpty &&
          journey.stages
              .where((s) => s.status == StageStatus.completed)
              .isNotEmpty)
        ...journey.stages
            .where((s) => s.status == StageStatus.completed)
            .map((s) => s.title),
    ];

    // ── Skill gaps (from Knowledge DNA + Journey) ─────────────────────
    final skillGaps = <String>[
      if (knowledgeAnalysis.skillWeaknesses.isNotEmpty)
        ...knowledgeAnalysis.skillWeaknesses.take(3),
      if (currentStage.requiredSkills.isNotEmpty)
        ...currentStage.requiredSkills,
    ];

    // ── Next goal ─────────────────────────────────────────────────────
    final nextGoal = topDecision.title;

    // ── Estimated weeks remaining ─────────────────────────────────────
    final completedStages = journey.stages
        .where((s) => s.status == StageStatus.completed)
        .length;
    final remainingStages = journey.stages.length - completedStages;
    final averageDaysPerStage =
        journey.estimatedDuration != null && journey.stages.isNotEmpty
        ? journey.estimatedDuration! ~/ journey.stages.length
        : 21;
    final estimatedWeeks = (remainingStages * averageDaysPerStage / 7)
        .round()
        .clamp(4, 52);

    // ── Portfolio / Resume / Interview readiness ──────────────────────
    // Derived from journey completion and progress level.
    final portfolioProgress =
        (journey.completion * 0.5 + missionProgress.completionPercentage * 0.3)
            .clamp(0.0, 1.0);
    final resumeProgress = (journey.completion * 0.4 + 0.1).clamp(0.0, 1.0);
    final interviewReadiness =
        (knowledgeAnalysis.confidenceScore * 0.4 + careerScore * 0.3).clamp(
          0.0,
          1.0,
        );

    return CareerProfile(
      id: 'career-${identity.id}',
      identityId: identity.id,
      careerScore: careerScore,
      jobReadiness: jobReadiness,
      strengths: strengths,
      skillGaps: skillGaps,
      nextGoal: nextGoal,
      estimatedWeeks: estimatedWeeks,
      portfolioProgress: portfolioProgress,
      resumeProgress: resumeProgress,
      interviewReadiness: interviewReadiness,
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────

  String _deriveJobReadiness(double score) {
    if (score >= 0.8) return 'Ready';
    if (score >= 0.6) return 'Nearly Ready';
    if (score >= 0.4) return 'Building';
    if (score >= 0.2) return 'Exploring';
    return 'Starting Out';
  }

  /// Returns a scored list of strengths with confidence for UI display.
  List<StrengthItem> getStrengthDetails() {
    final profile = buildProfile();
    final knowledgeAnalysis = _knowledgeDnaService.buildAnalysis();

    return profile.strengths.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      // Earlier strengths in the list have higher confidence
      final confidence = (1.0 - index * 0.15).clamp(0.4, 1.0);
      final category = knowledgeAnalysis.skillStrengths.contains(name)
          ? 'Knowledge'
          : 'Journey';
      return StrengthItem(
        name: name,
        confidence: confidence,
        category: category,
      );
    }).toList();
  }

  /// Returns a scored list of skill gaps with priority for UI display.
  List<GapItem> getGapDetails() {
    final profile = buildProfile();
    final currentStage = repository.currentJourneyStage;

    return profile.skillGaps.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      // Earlier gaps are more urgent
      final priority = index == 0
          ? 'High'
          : index == 1
          ? 'Medium'
          : 'Low';
      final isCurrent =
          currentStage.requiredSkills.contains(name) ||
          currentStage.requiredSkills.any((s) => name.contains(s));
      return GapItem(name: name, priority: priority, isCurrentStage: isCurrent);
    }).toList();
  }
}

/// A strength item with confidence and category for UI display.
class StrengthItem {
  const StrengthItem({
    required this.name,
    required this.confidence,
    required this.category,
  });

  final String name;
  final double confidence;
  final String category;
}

/// A skill gap item with priority and stage context for UI display.
class GapItem {
  const GapItem({
    required this.name,
    required this.priority,
    required this.isCurrentStage,
  });

  final String name;
  final String priority;
  final bool isCurrentStage;
}
