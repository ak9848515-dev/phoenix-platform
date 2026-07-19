import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../ai_capability_router/models/ai_capability.dart';
import '../../ai_capability_router/models/ai_request.dart';
import '../../ai_capability_router/router/ai_capability_router.dart';
import '../../ai_context/engine/ai_context_engine.dart';
import '../../ai_context/models/ai_context_snapshot.dart';
import '../../ai_gateway/services/ai_response_gateway.dart';
import '../../ai_prompt/models/prompt_specification.dart';
import '../../ai_prompt/services/prompt_builder_service.dart';
import '../models/learning_experience.dart';
import 'learning_experience_orchestrator.dart';
import 'learning_experience_registry.dart';

/// Result of a learning experience generation attempt.
///
/// Encapsulates both success and failure states with enough
/// information for the UI to display meaningful status.
class GenerationResult {
  const GenerationResult({
    this.experience,
    this.error,
    this.isFromCache = false,
    this.isOffline = false,
    this.providerName,
    this.generationTimeMs,
    this.attemptedProviders = const [],
  });

  /// The generated (or cached) learning experience, if available.
  final LearningExperience? experience;

  /// Error message if generation failed.
  final String? error;

  /// Whether the result came from cache (previous valid generation).
  final bool isFromCache;

  /// Whether the device was offline and no generation was attempted.
  final bool isOffline;

  /// Name of the AI provider that generated the content.
  final String? providerName;

  /// Time taken for generation in milliseconds.
  final int? generationTimeMs;

  /// List of providers that were attempted before success or failure.
  final List<String> attemptedProviders;

  /// Whether the generation was successful.
  bool get isSuccess => experience != null && error == null;

  /// Whether the generation failed completely (no cached version either).
  bool get isFailure => experience == null && error != null;

  @override
  String toString() =>
      'GenerationResult(success: $isSuccess, cache: $isFromCache, '
      'offline: $isOffline, provider: $providerName, '
      'time: ${generationTimeMs}ms)';
}

/// The Phoenix Learning Experience Generator.
///
/// This is the **first production AI feature** in Phoenix. It connects the
/// complete AI pipeline end-to-end:
///
/// ```
/// AIContextEngine
///   ↓
/// PromptBuilderService
///   ↓
/// AICapabilityRouter → Provider Adapter
///   ↓
/// AIResponseGateway
///   ↓
/// LearningExperience ← parse
///   ↓
/// LearningExperienceOrchestrator → domain engines
///   ↓
/// LearningExperienceRegistry → cache
/// ```
///
/// **Architecture Rules:**
/// - NEVER bypasses any layer of the AI pipeline
/// - NEVER calls providers directly
/// - NEVER creates prompt strings directly
/// - NEVER sends raw provider output to engines
/// - ALWAYS validates through AIResponseGateway
/// - ALWAYS distributes through LearningExperienceOrchestrator
class LearningExperienceGenerator {
  LearningExperienceGenerator({
    required this.aiContextEngine,
    required this.promptBuilderService,
    required this.aiCapabilityRouter,
    required this.aiResponseGateway,
    required this.orchestrator,
    required this.registry,
  });

  final AIContextEngine aiContextEngine;
  final PromptBuilderService promptBuilderService;
  final AICapabilityRouter aiCapabilityRouter;
  final AIResponseGateway aiResponseGateway;
  final LearningExperienceOrchestrator orchestrator;
  final LearningExperienceRegistry registry;

  final PhoenixLogger _logger = PhoenixLogger.shared;

  // ── Public API ──────────────────────────────────────────────────

  /// Generates today's learning experience.
  ///
  /// Uses the current AI context to generate a complete [LearningExperience]
  /// covering all 10 sections (Goal, Mission, Micro Lessons, Project,
  /// Assessment, Interview Practice, Revision, Reflection, Next Step).
  ///
  /// Returns a [GenerationResult] with the experience and metadata.
  Future<GenerationResult> generateToday() async {
    final startTime = DateTime.now();

    // 1. Check offline mode (no connectivity check — mock adapters always work)
    // In production, this would check network connectivity.

    // 2. Get AI context
    final context = aiContextEngine.snapshot;

    // 3. Build prompt
    final prompt = promptBuilderService.build(
      promptType: 'learning_experience',
      context: context,
    );
    if (prompt == null) {
      return _fallbackToCache(
        error: 'Failed to build prompt. Prompt template may be missing.',
      );
    }

    // 4. Route through AI Capability Router
    final request = AIRequest(
      capability: AICapability.learning,
      prompt: _buildFullPrompt(prompt),
      context: {
        'promptType': 'learning_experience',
        'schemaVersion': ExperienceMetadata.currentVersion,
        'templateId': prompt.templateId,
        'templateVersion': prompt.templateVersion,
      },
      temperature: prompt.temperature,
      maxTokens: prompt.maxTokens,
    );

    final result = await aiCapabilityRouter.route(request);

    if (!result.isSuccess) {
      final attempted = result.attemptedProviders
          .map((p) => p.displayName)
          .toList();
      return _fallbackToCache(
        error: result.response.error ?? 'All AI providers failed.',
        attemptedProviders: attempted,
      );
    }

    final rawResponse = result.response.output;
    final providerName = result.route.displayName;
    final generationTimeMs =
        DateTime.now().difference(startTime).inMilliseconds;

    // 5. Validate through AI Response Gateway
    final validation = aiResponseGateway.process(
      rawResponse: rawResponse,
      promptType: 'learning_experience',
      templateVersion: prompt.templateVersion,
      providerName: providerName,
    );

    if (!validation.isValid || validation.domainMap == null) {
      final errorMessages = validation.errors
          .map((e) => '${e.field ?? "field"}: ${e.message}')
          .join('; ');
      return _fallbackToCache(
        error: 'Validation failed: $errorMessages',
        attemptedProviders: [providerName],
      );
    }

    // 6. Parse validated map into LearningExperience
    final experience = _parseExperience(validation.domainMap!, context);
    if (experience == null) {
      return _fallbackToCache(
        error: 'Failed to parse validated response into LearningExperience.',
        attemptedProviders: [providerName],
      );
    }

    // 7. Cache the result for offline/failure fallback
    registry.register(experience);

    // 8. Distribute through orchestrator
    final distributed = await orchestrator.distribute(experience);
    if (!distributed) {
      _logger.warning(
        'LearningExperienceGenerator: distribution had warnings',
        category: LogCategory.engine,
        source: 'LearningExperienceGenerator',
      );
    }

    _logger.info(
      'LearningExperience generated successfully',
      category: LogCategory.engine,
      source: 'LearningExperienceGenerator',
      metadata: {
        'provider': providerName,
        'timeMs': generationTimeMs,
        'goal': experience.goal.title,
        'distributed': distributed,
      },
    );

    return GenerationResult(
      experience: experience,
      providerName: providerName,
      generationTimeMs: generationTimeMs,
      attemptedProviders: [providerName],
    );
  }

  /// Regenerates today's learning experience.
  ///
  /// Same as [generateToday] but explicitly does NOT use cache.
  /// The previous version remains available in the registry for comparison.
  Future<GenerationResult> regenerateToday() async {
    // Clear current cached experience before regenerating
    // (don't clear registry — keep history for comparison)
    return generateToday();
  }

  /// Generates a learning experience for a specific goal.
  ///
  /// Uses the given goal as context override.
  Future<GenerationResult> generateForGoal(String goal) async {
    final startTime = DateTime.now();
    final context = aiContextEngine.snapshot;

    // Create a modified context with the specific goal
    // The prompt template will use this as the primary focus
    final prompt = promptBuilderService.build(
      promptType: 'learning_experience',
      context: context,
    );

    if (prompt == null) {
      return _fallbackToCache(
        error: 'Failed to build prompt.',
      );
    }

    // Inject the specific goal into user instructions
    final goalPrompt = PromptSpecification(
      templateId: prompt.templateId,
      templateVersion: prompt.templateVersion,
      promptType: prompt.promptType,
      purpose: prompt.purpose,
      objective: 'Generate a learning experience focused on: $goal',
      systemInstructions: prompt.systemInstructions,
      userInstructions:
          '${prompt.userInstructions}\n\nSPECIFIC FOCUS: $goal',
      outputSchema: prompt.outputSchema,
      constraints: prompt.constraints,
      contextReferences: prompt.contextReferences,
      tone: prompt.tone,
      difficulty: prompt.difficulty,
      targetAudience: prompt.targetAudience,
      temperature: prompt.temperature,
      maxTokens: prompt.maxTokens,
    );

    final request = AIRequest(
      capability: AICapability.learning,
      prompt: _buildFullPrompt(goalPrompt),
      context: {
        'promptType': 'learning_experience',
        'schemaVersion': ExperienceMetadata.currentVersion,
        'templateId': prompt.templateId,
        'templateVersion': prompt.templateVersion,
        'goal': goal,
      },
      temperature: prompt.temperature,
      maxTokens: prompt.maxTokens,
    );

    final result = await aiCapabilityRouter.route(request);

    if (!result.isSuccess) {
      return _fallbackToCache(
        error: result.response.error ?? 'All AI providers failed.',
      );
    }

    final rawResponse = result.response.output;
    final providerName = result.route.displayName;
    final genTime = DateTime.now().difference(startTime).inMilliseconds;

    final validation = aiResponseGateway.process(
      rawResponse: rawResponse,
      promptType: 'learning_experience',
      templateVersion: prompt.templateVersion,
      providerName: providerName,
    );

    if (!validation.isValid || validation.domainMap == null) {
      return _fallbackToCache(
        error: 'Validation failed.',
        attemptedProviders: [providerName],
      );
    }

    final experience = _parseExperience(validation.domainMap!, context);
    if (experience == null) {
      return _fallbackToCache(
        error: 'Failed to parse validated response.',
        attemptedProviders: [providerName],
      );
    }

    registry.register(experience);
    await orchestrator.distribute(experience);

    return GenerationResult(
      experience: experience,
      providerName: providerName,
      generationTimeMs: genTime,
      attemptedProviders: [providerName],
    );
  }

  /// Returns the latest cached learning experience, if available.
  LearningExperience? getLatest() => registry.latest;

  /// Whether a cached learning experience is available.
  bool get hasCached => registry.latest != null;

  // ── Helpers ─────────────────────────────────────────────────────

  /// Attempts to fall back to the cached learning experience.
  GenerationResult _fallbackToCache({
    String? error,
    List<String> attemptedProviders = const [],
  }) {
    final cached = registry.latest;
    if (cached != null) {
      _logger.info(
        'LearningExperienceGenerator: falling back to cached version',
        category: LogCategory.engine,
        source: 'LearningExperienceGenerator',
        metadata: {'error': error, 'hasCache': true},
      );
      return GenerationResult(
        experience: cached,
        isFromCache: true,
        error: error,
        attemptedProviders: attemptedProviders,
      );
    }

    _logger.error(
      'LearningExperienceGenerator: generation failed, no cache available',
      category: LogCategory.engine,
      source: 'LearningExperienceGenerator',
      errorDetail: error,
    );

    return GenerationResult(
      error: error ?? 'Generation failed with no cached version.',
      attemptedProviders: attemptedProviders,
    );
  }

  /// Parses a validated domain map into a [LearningExperience].
  LearningExperience? _parseExperience(
    Map<String, dynamic> data,
    AIContextSnapshot context,
  ) {
    try {
      // Navigate to the experience root (may be nested under 'experience' key)
      final root = data['experience'] as Map<String, dynamic>? ?? data;

      // SECTION 1: Goal (required)
      final goalData = root['goal'] as Map<String, dynamic>?;
      if (goalData == null) {
        _logger.warning('Missing goal in AI response',
            category: LogCategory.engine,
            source: 'LearningExperienceGenerator');
        return null;
      }

      final goal = GoalSection(
        id: goalData['id'] as String? ?? _generateId('goal'),
        title: goalData['title'] as String? ?? 'Learning Goal',
        description: goalData['description'] as String? ?? '',
        objective: (goalData['objective'] ?? goalData['objectives'] ?? '') as String,
        estimatedMinutes: (goalData['estimatedMinutes'] ?? goalData['estimated_minutes'] ?? 30) as int,
        priority: (goalData['priority'] ?? 'medium') as String,
      );

      // SECTION 2: Mission (optional)
      final missionData = root['mission'] as Map<String, dynamic>?;
      final mission = missionData != null
          ? MissionSection(
              id: missionData['id'] as String? ?? _generateId('mission'),
              title: missionData['title'] as String? ?? '',
              description: missionData['description'] as String? ?? '',
              objectives: _castStringList(missionData['objectives']),
              estimatedMinutes: (missionData['estimatedMinutes'] ??
                  missionData['estimated_minutes'] ?? 30) as int,
              difficulty: (missionData['difficulty'] ?? 'intermediate') as String,
              successCriteria: _castStringList(missionData['successCriteria']),
            )
          : null;

      // SECTION 3: Micro Lessons (optional)
      final lessonsData = root['lessons'] as List<dynamic>?;
      final lessons = lessonsData != null
          ? lessonsData.map((l) => MicroLesson(
              id: (l['id'] as String?) ?? _generateId('lesson'),
              title: (l['title'] as String?) ?? '',
              summary: (l['summary'] as String?) ?? '',
              estimatedMinutes: (l['estimatedMinutes'] ?? l['estimated_minutes'] ?? 15) as int,
              prerequisites: _castStringList(l['prerequisites']),
              content: _castStringList(l['content'] ?? l['topics']),
            )).toList()
          : <MicroLesson>[];

      // SECTION 4: Project (optional)
      final projectData = root['project'] as Map<String, dynamic>?;
      final project = projectData != null
          ? ProjectSection(
              id: projectData['id'] as String? ?? _generateId('project'),
              title: projectData['title'] as String? ?? '',
              description: projectData['description'] as String? ?? '',
              estimatedHours: (projectData['estimatedHours'] ??
                  projectData['estimated_hours'] ??
                  projectData['estimatedWeeks'] ?? 2) as int,
              deliverables: _castStringList(projectData['deliverables']),
              technologies: _castStringList(projectData['technologies']),
              difficulty: (projectData['difficulty'] ?? 'intermediate') as String,
            )
          : null;

      // SECTION 5: Assessment (optional)
      final assessmentData = root['assessment'] as Map<String, dynamic>?;
      final assessment = assessmentData != null
          ? AssessmentSection(
              id: assessmentData['id'] as String? ?? _generateId('assessment'),
              title: assessmentData['title'] as String? ?? '',
              type: (assessmentData['type'] ?? 'quiz') as String,
              passingScore: (assessmentData['passingScore'] ??
                  assessmentData['passing_score'] ?? 80) as int,
              estimatedMinutes: (assessmentData['estimatedMinutes'] ??
                  assessmentData['estimated_minutes'] ?? 15) as int,
              questions: _parseQuestions(assessmentData['questions']),
            )
          : null;

      // SECTION 6: Interview Practice (optional)
      final interviewData = root['interview'] as Map<String, dynamic>?;
      final interview = interviewData != null
          ? InterviewSection(
              technicalQuestions:
                  _parseInterviewQuestions(interviewData['technicalQuestions'] ??
                      interviewData['technical_questions']),
              behavioralQuestions:
                  _parseInterviewQuestions(interviewData['behavioralQuestions'] ??
                      interviewData['behavioral_questions']),
              estimatedMinutes: (interviewData['estimatedMinutes'] ??
                  interviewData['estimated_minutes'] ?? 30) as int,
            )
          : null;

      // SECTION 7: Revision (optional)
      final revisionData = root['revision'] as Map<String, dynamic>?;
      final revision = revisionData != null
          ? RevisionSection(
              keyPoints: _castStringList(revisionData['keyPoints'] ??
                  revisionData['key_points']),
              flashCards: _parseFlashCards(revisionData['flashCards'] ??
                  revisionData['flash_cards']),
              quickReview: (revisionData['quickReview'] ??
                  revisionData['quick_review'] ?? '') as String,
              estimatedMinutes: (revisionData['estimatedMinutes'] ??
                  revisionData['estimated_minutes'] ?? 10) as int,
            )
          : null;

      // SECTION 8: Reflection (optional)
      final reflectionData = root['reflection'] as Map<String, dynamic>?;
      final reflection = reflectionData != null
          ? ReflectionSection(
              whatWasLearned: _castStringList(reflectionData['whatWasLearned'] ??
                  reflectionData['what_was_learned']),
              challenges: _castStringList(reflectionData['challenges']),
              confidenceScore: (reflectionData['confidenceScore'] ??
                  reflectionData['confidence_score'] ?? 0.5) as double,
              prompts: _castStringList(reflectionData['prompts']),
            )
          : null;

      // SECTION 9: Next Step (optional)
      final nextStepData = root['nextStep'] as Map<String, dynamic>? ??
          root['next_step'] as Map<String, dynamic>?;
      final nextStep = nextStepData != null
          ? NextStepSection(
              tomorrowObjective: (nextStepData['tomorrowObjective'] ??
                  nextStepData['tomorrow_objective'] ??
                  nextStepData['objective'] ??
                  'Continue learning') as String,
              unlockCondition: (nextStepData['unlockCondition'] ??
                  nextStepData['unlock_condition'] ?? '') as String,
              suggestedNextExperience: (nextStepData['suggestedNextExperience'] ??
                  nextStepData['suggested_next_experience'] ?? '') as String,
            )
          : null;

      // SECTION 10: Metadata
      final metaData = root['metadata'] as Map<String, dynamic>? ??
          root['meta'] as Map<String, dynamic>?;
      final metadata = ExperienceMetadata(
        schemaVersion: (metaData?['schemaVersion'] ??
            metaData?['schema_version'] ??
            ExperienceMetadata.currentVersion) as int,
        generatedAt: DateTime.now(),
        provider: (metaData?['provider'] ?? '') as String,
        promptVersion: (metaData?['promptVersion'] ??
            metaData?['prompt_version'] ?? 'v1') as String,
        templateId: (metaData?['templateId'] ??
            metaData?['template_id'] ?? 'learning_experience') as String,
      );

      return LearningExperience(
        goal: goal,
        mission: mission,
        lessons: lessons,
        project: project,
        assessment: assessment,
        interview: interview,
        revision: revision,
        reflection: reflection,
        nextStep: nextStep,
        metadata: metadata,
      );
    } catch (e, stack) {
      _logger.error(
        'Failed to parse LearningExperience from validated response: $e',
        category: LogCategory.engine,
        source: 'LearningExperienceGenerator',
        errorDetail: '$e\n$stack',
      );
      return null;
    }
  }

  List<String> _castStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [value.toString()];
  }

  List<AssessmentQuestion> _parseQuestions(dynamic questionsData) {
    if (questionsData == null) return [];
    final list = questionsData as List<dynamic>;
    return list.map((q) {
      final qm = q as Map<String, dynamic>;
      return AssessmentQuestion(
        id: (qm['id'] as String?) ?? _generateId('q'),
        question: (qm['question'] as String?) ?? '',
        options: _castStringList(qm['options']),
        correctAnswer: (qm['correctAnswer'] ?? qm['correct_answer'] ?? '') as String,
        explanation: (qm['explanation'] ?? '') as String,
        points: (qm['points'] ?? 1) as int,
        type: (qm['type'] ?? 'multiple_choice') as String,
      );
    }).toList();
  }

  List<InterviewQuestion> _parseInterviewQuestions(dynamic questionsData) {
    if (questionsData == null) return [];
    final list = questionsData as List<dynamic>;
    return list.map((q) {
      final qm = q as Map<String, dynamic>;
      return InterviewQuestion(
        id: (qm['id'] as String?) ?? _generateId('iq'),
        question: (qm['question'] as String?) ?? '',
        expectedAnswer: (qm['expectedAnswer'] ?? qm['expected_answer'] ?? '') as String,
        tips: _castStringList(qm['tips']),
        difficulty: (qm['difficulty'] ?? 'medium') as String,
      );
    }).toList();
  }

  List<FlashCard> _parseFlashCards(dynamic cardsData) {
    if (cardsData == null) return [];
    final list = cardsData as List<dynamic>;
    return list.map((c) {
      final cm = c as Map<String, dynamic>;
      return FlashCard(
        front: (cm['front'] ?? cm['question'] ?? '') as String,
        back: (cm['back'] ?? cm['answer'] ?? '') as String,
      );
    }).toList();
  }

  String _generateId(String prefix) =>
      '$prefix-${DateTime.now().millisecondsSinceEpoch}';

  /// Builds a complete prompt string from a PromptSpecification.
  String _buildFullPrompt(PromptSpecification spec) {
    final buffer = StringBuffer();

    buffer.writeln('## System Instructions');
    buffer.writeln(spec.systemInstructions);
    buffer.writeln();

    if (spec.userInstructions.isNotEmpty) {
      buffer.writeln('## User Instructions');
      buffer.writeln(spec.userInstructions);
      buffer.writeln();
    }

    buffer.writeln('## Output Format');
    buffer.writeln('Respond ONLY with valid JSON matching the schema below.');
    buffer.writeln('Do NOT include markdown code blocks, explanations, or extra text.');
    buffer.writeln();

    if (spec.outputSchema.isNotEmpty) {
      buffer.writeln('## Schema');
      buffer.writeln(spec.outputSchema);
      buffer.writeln();
    }

    if (spec.constraints.isNotEmpty) {
      buffer.writeln('## Constraints');
      buffer.writeln(spec.constraints);
    }

    return buffer.toString();
  }
}
