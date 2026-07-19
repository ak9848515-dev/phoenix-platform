import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../ai_capability_router/models/ai_capability.dart';
import '../../ai_capability_router/models/ai_request.dart';
import '../../ai_capability_router/router/ai_capability_router.dart';
import '../../ai_context/engine/ai_context_engine.dart';
import '../../ai_context/models/ai_context_snapshot.dart';
import '../../ai_gateway/services/ai_response_gateway.dart';
import '../../ai_prompt/services/prompt_builder_service.dart';
import '../../ai_prompt/models/prompt_specification.dart';
import '../models/generated_content.dart';
import '../models/generation_metadata.dart';
import '../models/generation_request.dart';
import 'content_repository.dart';

/// Result of a content generation attempt.
class ContentGenerationResult {
  const ContentGenerationResult({
    this.success = false,
    this.error,
    this.isFromCache = false,
    this.providerName,
    this.generationTimeMs,
  });

  final bool success;
  final String? error;
  final bool isFromCache;
  final String? providerName;
  final int? generationTimeMs;

  @override
  String toString() =>
      'ContentGenerationResult(success: $success, cache: $isFromCache, '
      'provider: $providerName, time: ${generationTimeMs}ms)';
}

/// Central coordinator for AI-powered content generation.
///
/// Wraps the complete AI pipeline (Context → Prompt → Router → Gateway)
/// for standalone content generation across 5 content types:
/// - Courses / Learning Paths
/// - Portfolio Projects
/// - Portfolio Enhancements
/// - Resume Enhancements
/// - Interview Questions
///
/// **Architecture Rules:**
/// - NEVER bypasses any layer of the AI pipeline
/// - NEVER calls providers directly
/// - NEVER creates prompt strings directly
/// - ALWAYS validates through AIResponseGateway
/// - ALWAYS persists through ContentRepository
class ContentGeneratorCoordinator {
  // ignore_for_file: prefer_initializing_formals

  ContentGeneratorCoordinator({
    required AIContextEngine aiContextEngine,
    required PromptBuilderService promptBuilderService,
    required AICapabilityRouter aiCapabilityRouter,
    required AIResponseGateway aiResponseGateway,
    required ContentRepository repository,
  })  : _aiContextEngine = aiContextEngine,
        _promptBuilderService = promptBuilderService,
        _aiCapabilityRouter = aiCapabilityRouter,
        _aiResponseGateway = aiResponseGateway,
        _repository = repository;

  final AIContextEngine _aiContextEngine;
  final PromptBuilderService _promptBuilderService;
  final AICapabilityRouter _aiCapabilityRouter;
  final AIResponseGateway _aiResponseGateway;
  final ContentRepository _repository;
  final PhoenixLogger _logger = PhoenixLogger.shared;

  // ── Public API ──────────────────────────────────────────────────

  /// Generates a course/learning path.
  Future<ContentGenerationResult> generateCourse(
    GenerationRequest request,
  ) async {
    final startTime = DateTime.now();
    final context = _aiContextEngine.snapshot;

    // Build prompt using the learning_path_generation template
    final prompt = _buildGenerationPrompt(
      promptType: 'learning_path_generation',
      context: context,
      request: request,
    );
    if (prompt == null) {
      return ContentGenerationResult(
        success: false,
        error: 'Could not build prompt. Template may be missing.',
      );
    }

    final aiRequest = AIRequest(
      capability: AICapability.learning,
      prompt: _buildFullPrompt(prompt, request),
      context: {
        'contentType': 'course',
        'templateId': prompt.templateId,
        'templateVersion': prompt.templateVersion,
      },
      temperature: prompt.temperature,
      maxTokens: prompt.maxTokens,
    );

    final result = await _aiCapabilityRouter.route(aiRequest);
    if (!result.isSuccess) {
      return _cacheFallback(
        'course',
        error: result.response.error ?? 'Provider failed.',
      );
    }

    final rawResponse = result.response.output;
    final providerName = result.route.displayName;
    final genTimeMs = DateTime.now().difference(startTime).inMilliseconds;

    // Validate through gateway
    final validation = _aiResponseGateway.process(
      rawResponse: rawResponse,
      promptType: 'learning_path_generation',
      templateVersion: prompt.templateVersion,
      providerName: providerName,
    );

    if (!validation.isValid || validation.domainMap == null) {
      return _cacheFallback(
        'course',
        error: 'Validation failed.',
      );
    }

    // Parse into GeneratedCourse
    final course = _parseCourse(validation.domainMap!, providerName);
    if (course == null) {
      return _cacheFallback('course',
          error: 'Failed to parse course from response.');
    }

    // Persist
    await _repository.saveCourse(course);

    _logger.info('Course generated: ${course.title} ($providerName, ${genTimeMs}ms)',
        source: 'ContentGeneratorCoordinator');

    return ContentGenerationResult(
      success: true,
      providerName: providerName,
      generationTimeMs: genTimeMs,
    );
  }

  /// Generates a portfolio project.
  Future<ContentGenerationResult> generateProject(
    GenerationRequest request,
  ) async {
    final startTime = DateTime.now();
    final context = _aiContextEngine.snapshot;

    final prompt = _buildGenerationPrompt(
      promptType: 'project_generation',
      context: context,
      request: request,
    );
    if (prompt == null) {
      return ContentGenerationResult(
        success: false,
        error: 'Could not build prompt.',
      );
    }

    final aiRequest = AIRequest(
      capability: AICapability.learning,
      prompt: _buildFullPrompt(prompt, request),
      context: {
        'contentType': 'project',
        'templateId': prompt.templateId,
        'templateVersion': prompt.templateVersion,
      },
      temperature: prompt.temperature,
      maxTokens: prompt.maxTokens,
    );

    final result = await _aiCapabilityRouter.route(aiRequest);
    if (!result.isSuccess) {
      return _cacheFallback(
        'project',
        error: result.response.error ?? 'Provider failed.',
      );
    }

    final rawResponse = result.response.output;
    final providerName = result.route.displayName;
    final genTimeMs = DateTime.now().difference(startTime).inMilliseconds;

    final validation = _aiResponseGateway.process(
      rawResponse: rawResponse,
      promptType: 'project_generation',
      templateVersion: prompt.templateVersion,
      providerName: providerName,
    );

    if (!validation.isValid || validation.domainMap == null) {
      return _cacheFallback(
        'project',
        error: 'Validation failed.',
      );
    }

    final project =
        _parseProject(validation.domainMap!, providerName);
    if (project == null) {
      return _cacheFallback('project',
          error: 'Failed to parse project.');
    }

    await _repository.saveProject(project);

    _logger.info('Project generated: ${project.title} ($providerName, ${genTimeMs}ms)',
        source: 'ContentGeneratorCoordinator');

    return ContentGenerationResult(
      success: true,
      providerName: providerName,
      generationTimeMs: genTimeMs,
    );
  }

  /// Generates portfolio enhancement suggestions.
  Future<ContentGenerationResult> generatePortfolioEnhancement(
    GenerationRequest request,
  ) async {
    final startTime = DateTime.now();
    final context = _aiContextEngine.snapshot;

    final prompt = _buildGenerationPrompt(
      promptType: 'project_generation',
      context: context,
      request: request,
    );
    if (prompt == null) {
      return ContentGenerationResult(
        success: false,
        error: 'Could not build prompt.',
      );
    }

    // Build a modified prompt focused on enhancement analysis
    final enhancementPrompt = PromptSpecification(
      templateId: prompt.templateId,
      templateVersion: prompt.templateVersion,
      promptType: prompt.promptType,
      purpose: 'Analyze portfolio and suggest improvements',
      objective: 'Output structured portfolio enhancement suggestions',
      systemInstructions:
          'You are Phoenix Portfolio Advisor. Analyze {{user_name}}\'s portfolio '
          'and suggest improvements. Score the current portfolio and recommend '
          'projects to fill skill gaps.',
      userInstructions:
          'Portfolio analysis for {{user_name}}. '
          'Current technologies: ${request.technologies.join(", ")}. '
          'Skill focus: ${request.skillFocus.join(", ")}. '
          'Generate improvement suggestions to make the portfolio stronger.',
      outputSchema: _kPortfolioEnhancementSchema,
      constraints: 'ONLY valid JSON. Actionable suggestions. '
          'Score between 0-100.',
      tone: 'professional',
      difficulty: 'intermediate',
      temperature: 0.4,
      maxTokens: 1536,
    );

    final aiRequest = AIRequest(
      capability: AICapability.learning,
      prompt: _buildFullPrompt(enhancementPrompt, request),
      context: {'contentType': 'portfolio_enhancement'},
      temperature: 0.4,
      maxTokens: 1536,
    );

    final result = await _aiCapabilityRouter.route(aiRequest);
    if (!result.isSuccess) {
      return _cacheFallback(
        'portfolioEnhancement',
        error: result.response.error ?? 'Provider failed.',
      );
    }

    final rawResponse = result.response.output;
    final providerName = result.route.displayName;
    final genTimeMs = DateTime.now().difference(startTime).inMilliseconds;

    final validation = _aiResponseGateway.process(
      rawResponse: rawResponse,
      promptType: 'project_generation',
      templateVersion: prompt.templateVersion,
      providerName: providerName,
    );

    if (!validation.isValid || validation.domainMap == null) {
      return _cacheFallback(
        'portfolioEnhancement',
        error: 'Validation failed.',
      );
    }

    final enh = _parsePortfolioEnhancement(
        validation.domainMap!, providerName);
    if (enh == null) {
      return _cacheFallback('portfolioEnhancement',
          error: 'Failed to parse portfolio enhancement.');
    }

    await _repository.savePortfolioEnhancement(enh);

    _logger.info(
        'Portfolio enhancement generated ($providerName, ${genTimeMs}ms)',
        source: 'ContentGeneratorCoordinator');

    return ContentGenerationResult(
      success: true,
      providerName: providerName,
      generationTimeMs: genTimeMs,
    );
  }

  /// Generates resume enhancement suggestions.
  Future<ContentGenerationResult> generateResumeEnhancement(
    GenerationRequest request,
  ) async {
    final startTime = DateTime.now();
    final context = _aiContextEngine.snapshot;

    final prompt = _buildGenerationPrompt(
      promptType: 'career_coaching',
      context: context,
      request: request,
    );
    if (prompt == null) {
      return ContentGenerationResult(
        success: false,
        error: 'Could not build prompt.',
      );
    }

    final resumePrompt = PromptSpecification(
      templateId: prompt.templateId,
      templateVersion: prompt.templateVersion,
      promptType: prompt.promptType,
      purpose: 'Analyze resume and suggest improvements',
      objective: 'Output resume enhancement suggestions with ATS score',
      systemInstructions:
          'You are Phoenix Resume Advisor. Analyze {{user_name}}\'s resume '
          'and suggest improvements. Focus on ATS optimization, keyword gaps, '
          'and formatting improvements.',
      userInstructions:
          'Resume analysis for {{user_name}} targeting ${request.targetRole ?? "a role"}. '
          'Skill focus: ${request.skillFocus.join(", ")}. '
          'Generate ATS-optimized suggestions.',
      outputSchema: _kResumeEnhancementSchema,
      constraints: 'ONLY valid JSON. ATS-friendly suggestions. '
          'Score between 0-100.',
      tone: 'professional',
      difficulty: 'intermediate',
      temperature: 0.4,
      maxTokens: 1536,
    );

    final aiRequest = AIRequest(
      capability: AICapability.resume,
      prompt: _buildFullPrompt(resumePrompt, request),
      context: {'contentType': 'resume_enhancement'},
      temperature: 0.4,
      maxTokens: 1536,
    );

    final result = await _aiCapabilityRouter.route(aiRequest);
    if (!result.isSuccess) {
      return _cacheFallback(
        'resumeEnhancement',
        error: result.response.error ?? 'Provider failed.',
      );
    }

    final rawResponse = result.response.output;
    final providerName = result.route.displayName;
    final genTimeMs = DateTime.now().difference(startTime).inMilliseconds;

    final validation = _aiResponseGateway.process(
      rawResponse: rawResponse,
      promptType: 'career_coaching',
      templateVersion: prompt.templateVersion,
      providerName: providerName,
    );

    if (!validation.isValid || validation.domainMap == null) {
      return _cacheFallback(
        'resumeEnhancement',
        error: 'Validation failed.',
      );
    }

    final enh = _parseResumeEnhancement(
        validation.domainMap!, providerName);
    if (enh == null) {
      return _cacheFallback('resumeEnhancement',
          error: 'Failed to parse resume enhancement.');
    }

    await _repository.saveResumeEnhancement(enh);

    _logger.info(
        'Resume enhancement generated ($providerName, ${genTimeMs}ms)',
        source: 'ContentGeneratorCoordinator');

    return ContentGenerationResult(
      success: true,
      providerName: providerName,
      generationTimeMs: genTimeMs,
    );
  }

  /// Generates interview questions for practice.
  Future<ContentGenerationResult> generateInterviewQuestions(
    GenerationRequest request,
  ) async {
    final startTime = DateTime.now();
    final context = _aiContextEngine.snapshot;

    final prompt = _buildGenerationPrompt(
      promptType: 'interview_generation',
      context: context,
      request: request,
    );
    if (prompt == null) {
      return ContentGenerationResult(
        success: false,
        error: 'Could not build prompt.',
      );
    }

    final aiRequest = AIRequest(
      capability: AICapability.interview,
      prompt: _buildFullPrompt(prompt, request),
      context: {
        'contentType': 'interview',
        'templateId': prompt.templateId,
        'templateVersion': prompt.templateVersion,
      },
      temperature: prompt.temperature,
      maxTokens: prompt.maxTokens,
    );

    final result = await _aiCapabilityRouter.route(aiRequest);
    if (!result.isSuccess) {
      return _cacheFallback(
        'interviewQuestions',
        error: result.response.error ?? 'Provider failed.',
      );
    }

    final rawResponse = result.response.output;
    final providerName = result.route.displayName;
    final genTimeMs = DateTime.now().difference(startTime).inMilliseconds;

    final validation = _aiResponseGateway.process(
      rawResponse: rawResponse,
      promptType: 'interview_generation',
      templateVersion: prompt.templateVersion,
      providerName: providerName,
    );

    if (!validation.isValid || validation.domainMap == null) {
      return _cacheFallback(
        'interviewQuestions',
        error: 'Validation failed.',
      );
    }

    final questions = _parseInterviewQuestions(
        validation.domainMap!, providerName, request.targetRole);
    if (questions == null) {
      return _cacheFallback('interviewQuestions',
          error: 'Failed to parse interview questions.');
    }

    await _repository.saveInterviewQuestions(questions);

    _logger.info(
        'Interview questions generated for ${request.targetRole ?? "unknown"} '
        '($providerName, ${genTimeMs}ms)',
        source: 'ContentGeneratorCoordinator');

    return ContentGenerationResult(
      success: true,
      providerName: providerName,
      generationTimeMs: genTimeMs,
    );
  }

  // ── Repository access ───────────────────────────────────────────

  ContentRepository get repository => _repository;

  // ── Parsing: Courses ────────────────────────────────────────────

  GeneratedCourse? _parseCourse(
    Map<String, dynamic> data,
    String providerName,
  ) {
    try {
      final root = data['learningPath'] as Map<String, dynamic>? ??
          data['learning_path'] as Map<String, dynamic>? ??
          data['course'] as Map<String, dynamic>? ??
          data;

      final modulesData = root['modules'] as List<dynamic>? ?? [];
      final modules = modulesData.map((m) {
        final mm = m as Map<String, dynamic>;
        return CourseModule(
          id: mm['id'] as String? ??
              'mod-${DateTime.now().millisecondsSinceEpoch}',
          title: mm['title'] as String? ?? '',
          description: mm['description'] as String? ?? '',
          topics: _toStringList(mm['topics']),
          estimatedHours: (mm['estimatedHours'] ??
              mm['estimated_hours'] ??
              8) as int,
          prerequisites: _toStringList(mm['prerequisites']),
          projects: _toStringList(mm['projects']),
        );
      }).toList();

      return GeneratedCourse(
        id: root['id'] as String? ??
            'course-${DateTime.now().millisecondsSinceEpoch}',
        title: root['title'] as String? ?? '',
        description: root['description'] as String? ?? '',
        modules: modules,
        estimatedWeeks: (root['estimatedWeeks'] ??
            root['estimated_weeks'] ??
            1) as int,
        difficulty: root['difficulty'] as String? ?? 'intermediate',
        prerequisites: _toStringList(root['prerequisites']),
        learningOutcomes: _toStringList(
            root['outcomes'] ?? root['learningOutcomes'] ?? root['learning_outcomes']),
        skillTags: _toStringList(
            root['skillTags'] ?? root['skill_tags'] ?? root['skills']),
        metadata: GenerationMetadata(
          generatedAt: DateTime.now(),
          contentType: ContentType.course,
          provider: providerName,
          generationTimeMs: null,
        ),
      );
    } catch (e) {
      _logger.error('Failed to parse course: $e',
          source: 'ContentGeneratorCoordinator');
      return null;
    }
  }

  // ── Parsing: Projects ──────────────────────────────────────────

  GeneratedProject? _parseProject(
    Map<String, dynamic> data,
    String providerName,
  ) {
    try {
      final root = data['project'] as Map<String, dynamic>? ?? data;

      final milestonesData =
          root['milestones'] as List<dynamic>? ?? [];
      final milestones = milestonesData.map((m) {
        final mm = m as Map<String, dynamic>;
        return ProjectMilestone(
          id: mm['id'] as String? ??
              'ms-${DateTime.now().millisecondsSinceEpoch}',
          title: mm['title'] as String? ?? '',
          description: mm['description'] as String? ?? '',
          estimatedHours: (mm['estimatedHours'] ??
              mm['estimated_hours'] ??
              10) as int,
          deliverables: _toStringList(
              mm['deliverables']),
        );
      }).toList();

      return GeneratedProject(
        id: root['id'] as String? ??
            'proj-${DateTime.now().millisecondsSinceEpoch}',
        title: root['title'] as String? ?? '',
        description: root['description'] as String? ?? '',
        technologies: _toStringList(
            root['technologies']),
        estimatedWeeks: (root['estimatedWeeks'] ??
            root['estimated_weeks'] ??
            2) as int,
        difficulty: root['difficulty'] as String? ?? 'intermediate',
        milestones: milestones,
        learningOutcomes: _toStringList(
            root['learningOutcomes'] ?? root['learning_outcomes']),
        portfolioImpact: root['portfolioImpact'] as String? ??
            root['portfolio_impact'] as String? ??
            '',
        deliverables: _toStringList(
            root['deliverables']),
        metadata: GenerationMetadata(
          generatedAt: DateTime.now(),
          contentType: ContentType.project,
          provider: providerName,
          generationTimeMs: null,
        ),
      );
    } catch (e) {
      _logger.error('Failed to parse project: $e',
          source: 'ContentGeneratorCoordinator');
      return null;
    }
  }

  // ── Parsing: Portfolio Enhancement ─────────────────────────────

  GeneratedPortfolioEnhancement? _parsePortfolioEnhancement(
    Map<String, dynamic> data,
    String providerName,
  ) {
    try {
      final root = data['portfolio'] as Map<String, dynamic>? ??
          data['portfolioAdvice'] as Map<String, dynamic>? ??
          data;

      return GeneratedPortfolioEnhancement(
        id: 'pe-${DateTime.now().millisecondsSinceEpoch}',
        suggestedProjects: _toStringList(
            root['suggestedProjects'] ?? root['suggested_projects']),
        skillGaps: _toStringList(
            root['skillGaps'] ?? root['skill_gaps']),
        improvementIdeas: _toStringList(
            root['improvementIdeas'] ?? root['improvement_ideas']),
        recommendedTechnologies: _toStringList(
            root['recommendedTechnologies'] ?? root['recommended_technologies']),
        portfolioScore:
            (root['portfolioScore'] ?? root['portfolio_score'] ?? 0) as int,
        summary: root['summary'] as String? ?? '',
        metadata: GenerationMetadata(
          generatedAt: DateTime.now(),
          contentType: ContentType.portfolioEnhancement,
          provider: providerName,
          generationTimeMs: null,
        ),
      );
    } catch (e) {
      _logger.error('Failed to parse portfolio enhancement: $e',
          source: 'ContentGeneratorCoordinator');
      return null;
    }
  }

  // ── Parsing: Resume Enhancement ────────────────────────────────

  GeneratedResumeEnhancement? _parseResumeEnhancement(
    Map<String, dynamic> data,
    String providerName,
  ) {
    try {
      final root = data['resume'] as Map<String, dynamic>? ??
          data['careerAdvice'] as Map<String, dynamic>? ??
          data;

      return GeneratedResumeEnhancement(
        id: 're-${DateTime.now().millisecondsSinceEpoch}',
        suggestedSections: _toStringList(
            root['suggestedSections'] ?? root['suggested_sections']),
        bulletPointImprovements: _toStringList(
            root['bulletPointImprovements'] ?? root['bullet_point_improvements']),
        missingKeywords: _toStringList(
            root['missingKeywords'] ?? root['missing_keywords']),
        formattingSuggestions: _toStringList(
            root['formattingSuggestions'] ?? root['formatting_suggestions']),
        atsScore: (root['atsScore'] ?? root['ats_score'] ?? 0) as int,
        summary: root['summary'] as String? ?? '',
        metadata: GenerationMetadata(
          generatedAt: DateTime.now(),
          contentType: ContentType.resumeEnhancement,
          provider: providerName,
          generationTimeMs: null,
        ),
      );
    } catch (e) {
      _logger.error('Failed to parse resume enhancement: $e',
          source: 'ContentGeneratorCoordinator');
      return null;
    }
  }

  // ── Parsing: Interview Questions ───────────────────────────────

  GeneratedInterviewQuestions? _parseInterviewQuestions(
    Map<String, dynamic> data,
    String providerName,
    String? targetRole,
  ) {
    try {
      final root = data['interview'] as Map<String, dynamic>? ?? data;

      final sections = root['sections'] as List<dynamic>? ?? [];
      List<InterviewQuestionItem> technical = [];
      List<InterviewQuestionItem> behavioral = [];
      List<InterviewQuestionItem> situational = [];

      for (final section in sections) {
        final s = section as Map<String, dynamic>;
        final name = (s['name'] as String? ?? '').toLowerCase();
        final questions = (s['questions'] as List<dynamic>?)
                ?.map((q) => _parseQuestionItem(q as Map<String, dynamic>))
                .toList() ??
            [];

        if (name.contains('technical')) {
          technical.addAll(questions);
        } else if (name.contains('behavioral')) {
          behavioral.addAll(questions);
        } else {
          situational.addAll(questions);
        }
      }

      // Fallback: if sections structure not present, try flat lists
      if (sections.isEmpty) {
        technical = (root['technicalQuestions'] as List<dynamic>?)
                ?.map((q) => _parseQuestionItem(q as Map<String, dynamic>))
                .toList() ??
            [];
        behavioral = (root['behavioralQuestions'] as List<dynamic>?)
                ?.map((q) => _parseQuestionItem(q as Map<String, dynamic>))
                .toList() ??
            [];
      }

      return GeneratedInterviewQuestions(
        id: 'iq-${DateTime.now().millisecondsSinceEpoch}',
        targetRole:
            targetRole ?? root['targetRole'] as String? ?? '',
        technicalQuestions: technical,
        behavioralQuestions: behavioral,
        situationalQuestions: situational,
        overallTips: _toStringList(
            root['overallTips'] ?? root['overall_tips']),
        estimatedMinutes: (root['estimatedMinutes'] ??
            root['estimated_minutes'] ??
            30) as int,
        difficulty: root['difficulty'] as String? ?? 'intermediate',
        metadata: GenerationMetadata(
          generatedAt: DateTime.now(),
          contentType: ContentType.interviewQuestions,
          provider: providerName,
          generationTimeMs: null,
        ),
      );
    } catch (e) {
      _logger.error('Failed to parse interview questions: $e',
          source: 'ContentGeneratorCoordinator');
      return null;
    }
  }

  InterviewQuestionItem _parseQuestionItem(Map<String, dynamic> data) {
    return InterviewQuestionItem(
      id: data['id'] as String? ??
          'q-${DateTime.now().millisecondsSinceEpoch}',
      question: data['question'] as String? ?? '',
      expectedAnswer: data['expectedAnswer'] as String? ??
          data['expected_answer'] as String? ??
          '',
      tips: _toStringList(data['tips']),
      difficulty: data['difficulty'] as String? ?? 'medium',
      category: data['category'] as String?,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  /// Builds a prompt specification for generation using the PromptBuilder.
  PromptSpecification? _buildGenerationPrompt({
    required String promptType,
    required AIContextSnapshot context,
    required GenerationRequest request,
  }) {
    return _promptBuilderService.build(
      promptType: promptType,
      context: context,
    );
  }

  /// Builds a complete prompt string from a PromptSpecification + request.
  String _buildFullPrompt(
    PromptSpecification spec,
    GenerationRequest request,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('## System Instructions');
    buffer.writeln(spec.systemInstructions);
    buffer.writeln();

    if (spec.userInstructions.isNotEmpty) {
      buffer.writeln('## User Instructions');
      buffer.writeln(spec.userInstructions);
      buffer.writeln();
    }

    // Inject request-specific context
    if (request.title != null || request.skillFocus.isNotEmpty) {
      buffer.writeln('## Request Details');
      if (request.title != null) {
        buffer.writeln('Title hint: ${request.title}');
      }
      if (request.description != null) {
        buffer.writeln('Description: ${request.description}');
      }
      if (request.targetRole != null) {
        buffer.writeln('Target role: ${request.targetRole}');
      }
      if (request.technologies.isNotEmpty) {
        buffer.writeln(
            'Technologies: ${request.technologies.join(", ")}');
      }
      if (request.skillFocus.isNotEmpty) {
        buffer.writeln(
            'Skill focus: ${request.skillFocus.join(", ")}');
      }
      if (request.difficulty != null) {
        buffer.writeln('Difficulty: ${request.difficulty}');
      }
      if (request.estimatedDuration != null) {
        buffer.writeln(
            'Estimated duration: ${request.estimatedDuration} weeks');
      }
      buffer.writeln();
    }

    buffer.writeln('## Output Format');
    buffer.writeln(
        'Respond ONLY with valid JSON matching the schema below.');
    buffer.writeln(
        'Do NOT include markdown code blocks or extra text.');
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

  /// Returns a failure result for the given generation type.
  ContentGenerationResult _cacheFallback(
    String type, {
    String? error,
  }) {
    _logger.warning(
        'Content generation failed for $type, no cache fallback available: $error',
        source: 'ContentGeneratorCoordinator');
    return ContentGenerationResult(
      success: false,
      error: error ?? 'Generation failed.',
      isFromCache: false,
    );
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [value.toString()];
  }

  // ── Output Schemas ─────────────────────────────────────────────

  static const String _kPortfolioEnhancementSchema = '''{
  "portfolio": {
    "portfolioScore": "integer (0-100)",
    "summary": "string",
    "suggestedProjects": ["string"],
    "skillGaps": ["string"],
    "improvementIdeas": ["string"],
    "recommendedTechnologies": ["string"]
  }
}''';

  static const String _kResumeEnhancementSchema = '''{
  "resume": {
    "atsScore": "integer (0-100)",
    "summary": "string",
    "suggestedSections": ["string"],
    "bulletPointImprovements": ["string"],
    "missingKeywords": ["string"],
    "formattingSuggestions": ["string"]
  }
}''';
}
