import 'dart:convert';

import '../../../shared/infrastructure/ai_content/ingest_package.dart';
import '../../../shared/infrastructure/ai_content/metadata.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../mission_engine/engine/mission_engine.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../../personal_knowledge/engine/knowledge_engine.dart';
import '../../memory_engine/engine/memory_engine.dart';
import '../../daily_brief/engine/daily_brief_engine.dart';
import '../../career/engine/career_engine.dart';
import '../../progress_engine/achievement_engine.dart';
import '../models/learning_experience.dart';

/// The Phoenix Learning Experience Orchestrator.
///
/// Coordinates AI-generated content distribution to domain engines.
///
/// **Architecture Rules:**
/// - Orchestrator NEVER manipulates engine internals — calls engine.ingest() only
/// - Each engine owns its own merge/replace/duplicate logic
/// - Never accesses repositories directly
/// - Never stores business state
///
/// **Mission Ownership:**
/// - Active missions → [MissionEngine].ingest() (single source of truth)
/// - Mission history/reflection/timeline → [MemoryEngine].ingest() (audit trail only)
class LearningExperienceOrchestrator {
  LearningExperienceOrchestrator({
    required this.missionEngine,
    required this.portfolioEngine,
    required this.knowledgeEngine,
    required this.careerEngine,
    required this.memoryEngine,
    required this.dailyBriefEngine,
    required this.achievementEngine,
  });

  final MissionEngine missionEngine;
  final PortfolioEngine portfolioEngine;
  final KnowledgeEngine knowledgeEngine;
  final CareerEngine careerEngine;
  final MemoryEngine memoryEngine;
  final DailyBriefEngine dailyBriefEngine;
  final AchievementEngine achievementEngine;

  final PhoenixLogger _logger = PhoenixLogger.shared;

  bool _isProcessing = false;

  /// Whether the orchestrator is currently processing a learning experience.
  bool get isProcessing => _isProcessing;

  /// Distributes a validated [LearningExperience] to all domain engines
  /// via their ingest() methods.
  ///
  /// Returns `true` if all distributions succeeded, `false` otherwise.
  /// Errors are logged — a single failed distribution never blocks others.
  Future<bool> distribute(LearningExperience experience) async {
    if (_isProcessing) {
      _logger.warning(
        'Orchestrator already processing a learning experience',
        category: LogCategory.engine,
        source: 'LearningExperienceOrchestrator',
      );
      return false;
    }

    _isProcessing = true;

    // Build shared metadata once
    final baseMetadata = AIContentMetadata(
      source: AIContentMetadata.sourceAI,
      provider: experience.metadata.provider,
      promptVersion: experience.metadata.promptVersion,
      schemaVersion: experience.metadata.schemaVersion,
      generatedAt: experience.metadata.generatedAt,
      contextVersion: experience.metadata.schemaVersion,
      confidenceScore: 0.9,
      contentHash: '',
    );

    final results = <Future<bool>>[];

    // Mission → MissionEngine (active mission data)
    results.add(_distributeGoalAndMission(experience, baseMetadata));

    // Lessons → KnowledgeEngine
    results.add(_distributeLessons(experience, baseMetadata));

    // Project → PortfolioEngine
    results.add(_distributeProject(experience, baseMetadata));

    // Assessment → AchievementEngine
    results.add(_distributeAssessment(experience, baseMetadata));

    // Interview → CareerEngine
    results.add(_distributeInterview(experience, baseMetadata));

    // Revision → KnowledgeEngine
    results.add(_distributeRevision(experience, baseMetadata));

    // Reflection → MemoryEngine (history/timeline only, not active mission)
    results.add(_distributeReflection(experience, baseMetadata));

    // NextStep → DailyBriefEngine
    results.add(_distributeNextStep(experience, baseMetadata));

    final outcomes = await Future.wait(results);
    _isProcessing = false;

    final allSucceeded = outcomes.every((r) => r);
    _logger.info(
      allSucceeded
          ? 'LearningExperience distributed: ${experience.goal.title}'
          : 'LearningExperience distributed with warnings: ${experience.goal.title}',
      category: LogCategory.engine,
      source: 'LearningExperienceOrchestrator',
      metadata: {
        'goalId': experience.goal.id,
        'allSucceeded': allSucceeded,
      },
    );

    return allSucceeded;
  }

  /// Distributes Goal and Mission to [MissionEngine] (active mission state)
  /// and [MemoryEngine] (history/audit trail only).
  Future<bool> _distributeGoalAndMission(
    LearningExperience exp,
    AIContentMetadata baseMeta,
  ) async {
    try {
      // Route the mission to MissionEngine as active mission data
      if (exp.hasMission) {
        final mission = exp.mission!;
        final missionHash = _hashContent(mission.title + mission.description);
        missionEngine.ingest(IngestPackage(
          type: 'mission',
          content: {
            'id': mission.id,
            'title': mission.title,
            'description': mission.description,
            'estimatedMinutes': mission.estimatedMinutes,
            'difficulty': mission.difficulty,
          },
          metadata: baseMeta.copyWith(contentHash: missionHash),
        ));
      }

      // Store only history/reflection in MemoryEngine (not active mission state)
      final goalHash = _hashContent(exp.goal.title + exp.goal.description);
      await memoryEngine.ingest(IngestPackage(
        type: 'history',
        content: {
          'title': 'Goal: ${exp.goal.title}',
          'content': exp.goal.description,
        },
        metadata: baseMeta.copyWith(contentHash: goalHash),
      ));

      return true;
    } catch (e) {
      _logger.error('Failed goal/mission: $e',
          category: LogCategory.engine,
          source: 'LearningExperienceOrchestrator',
          errorDetail: e.toString());
      return false;
    }
  }

  Future<bool> _distributeLessons(
    LearningExperience exp,
    AIContentMetadata baseMeta,
  ) async {
    try {
      if (exp.lessons.isEmpty) return true;
      for (final lesson in exp.lessons) {
        final hash = _hashContent(lesson.title + lesson.summary);
        knowledgeEngine.ingest(IngestPackage(
          type: 'lesson',
          content: {
            'id': lesson.id,
            'title': lesson.title,
            'summary': lesson.summary,
          },
          metadata: baseMeta.copyWith(contentHash: hash),
        ));
      }
      await knowledgeEngine.refresh();
      return true;
    } catch (e) {
      _logger.error('Failed lessons: $e',
          category: LogCategory.engine,
          source: 'LearningExperienceOrchestrator',
          errorDetail: e.toString());
      return false;
    }
  }

  Future<bool> _distributeProject(
    LearningExperience exp,
    AIContentMetadata baseMeta,
  ) async {
    try {
      if (exp.project == null) return true;
      final hash = _hashContent(exp.project!.title + exp.project!.description);
      portfolioEngine.ingest(IngestPackage(
        type: 'project',
        content: {
          'id': exp.project!.id,
          'title': exp.project!.title,
          'description': exp.project!.description,
          'estimatedHours': exp.project!.estimatedHours,
          'technologies': exp.project!.technologies,
        },
        metadata: baseMeta.copyWith(contentHash: hash),
      ));
      await portfolioEngine.refresh();
      return true;
    } catch (e) {
      _logger.error('Failed project: $e',
          category: LogCategory.engine,
          source: 'LearningExperienceOrchestrator',
          errorDetail: e.toString());
      return false;
    }
  }

  Future<bool> _distributeAssessment(
    LearningExperience exp,
    AIContentMetadata baseMeta,
  ) async {
    try {
      if (exp.assessment == null) return true;
      final hash = _hashContent(exp.assessment!.title);
      achievementEngine.ingest(IngestPackage(
        type: 'milestone',
        content: {
          'id': exp.assessment!.id,
          'title': exp.assessment!.title,
          'description': 'Assessment: ${exp.assessment!.type}',
        },
        metadata: baseMeta.copyWith(contentHash: hash),
      ));
      await achievementEngine.refresh();
      return true;
    } catch (e) {
      _logger.error('Failed assessment: $e',
          category: LogCategory.engine,
          source: 'LearningExperienceOrchestrator',
          errorDetail: e.toString());
      return false;
    }
  }

  Future<bool> _distributeInterview(
    LearningExperience exp,
    AIContentMetadata baseMeta,
  ) async {
    try {
      if (exp.interview == null) return true;
      final interview = exp.interview!;
      final hash = _hashContent('interview-${interview.totalQuestions}');
      careerEngine.ingest(IngestPackage(
        type: 'interview',
        content: {
          'id': 'interview-${_sanitizeId(exp.goal.title)}',
          'questions': [
            ...interview.technicalQuestions,
            ...interview.behavioralQuestions,
          ],
        },
        metadata: baseMeta.copyWith(contentHash: hash),
      ));
      await careerEngine.refresh();
      return true;
    } catch (e) {
      _logger.error('Failed interview: $e',
          category: LogCategory.engine,
          source: 'LearningExperienceOrchestrator',
          errorDetail: e.toString());
      return false;
    }
  }

  Future<bool> _distributeRevision(
    LearningExperience exp,
    AIContentMetadata baseMeta,
  ) async {
    try {
      if (exp.revision == null) return true;
      final revision = exp.revision!;
      final hash = _hashContent('revision-${revision.keyPoints.length}');
      knowledgeEngine.ingest(IngestPackage(
        type: 'revision',
        content: {
          'id': 'revision-${_sanitizeId(exp.goal.title)}',
          'keyPoints': revision.keyPoints,
          'flashCards': revision.flashCards.map((f) => {
            'front': f.front,
            'back': f.back,
          }).toList(),
        },
        metadata: baseMeta.copyWith(contentHash: hash),
      ));
      await knowledgeEngine.refresh();
      return true;
    } catch (e) {
      _logger.error('Failed revision: $e',
          category: LogCategory.engine,
          source: 'LearningExperienceOrchestrator',
          errorDetail: e.toString());
      return false;
    }
  }

  /// Reflection → [MemoryEngine] only (history/timeline, never active mission state).
  Future<bool> _distributeReflection(
    LearningExperience exp,
    AIContentMetadata baseMeta,
  ) async {
    try {
      if (exp.reflection == null) return true;
      final reflection = exp.reflection!;
      for (final prompt in reflection.prompts) {
        final hash = _hashContent('reflection-$prompt');
        await memoryEngine.ingest(IngestPackage(
          type: 'reflection',
          content: {
            'title': 'Reflection prompt',
            'content': prompt,
          },
          metadata: baseMeta.copyWith(contentHash: hash),
        ));
      }
      return true;
    } catch (e) {
      _logger.error('Failed reflection: $e',
          category: LogCategory.engine,
          source: 'LearningExperienceOrchestrator',
          errorDetail: e.toString());
      return false;
    }
  }

  Future<bool> _distributeNextStep(
    LearningExperience exp,
    AIContentMetadata baseMeta,
  ) async {
    try {
      if (exp.nextStep == null) return true;
      final hash = _hashContent(exp.nextStep!.tomorrowObjective);

      // Store next step in DailyBriefEngine via memory (context for daily brief)
      await memoryEngine.ingest(IngestPackage(
        type: 'history',
        content: {
          'title': 'Next: ${exp.nextStep!.tomorrowObjective}',
          'content': 'Tomorrow: ${exp.nextStep!.tomorrowObjective}\n'
              'Unlock: ${exp.nextStep!.unlockCondition}',
        },
        metadata: baseMeta.copyWith(contentHash: hash),
      ));
      await dailyBriefEngine.rebuild();
      return true;
    } catch (e) {
      _logger.error('Failed next step: $e',
          category: LogCategory.engine,
          source: 'LearningExperienceOrchestrator',
          errorDetail: e.toString());
      return false;
    }
  }

  String _hashContent(String input) =>
      base64Encode(utf8.encode(input)).substring(0, 16);

  String _sanitizeId(String input) => input
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
