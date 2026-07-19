import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../ai_context/builders/context_builders.dart';
import '../../ai_context/models/ai_context_snapshot.dart';
import '../models/prompt_specification.dart';
import '../models/prompt_template.dart';
import 'prompt_template_registry.dart';

/// Prompt Builder Service — provider-neutral prompt generation.
///
/// Transforms [AIContextSnapshot] into [PromptSpecification] by:
/// 1. Selecting the appropriate [PromptTemplate] from the registry
/// 2. Extracting focused context via [ContextBuilders]
/// 3. Injecting context into the template
/// 4. Returning an immutable, provider-neutral [PromptSpecification]
///
/// **Architecture Rules:**
/// - NEVER calls AI providers
/// - NEVER modifies AI Context Engine
/// - NEVER modifies engines
/// - Output is provider-neutral (no Gemini/OpenAI/Claude formatting)
///
/// **Flow:**
/// ```
/// Feature → AIContextEngine → AIContextSnapshot
///   ↓
/// PromptBuilderService.build(type, snapshot)
///   ↓
/// PromptTemplateRegistry.getLatest(type)
///   ↓
/// ContextBuilders.{type}(snapshot)
///   ↓
/// PromptTemplate.build(context) → PromptSpecification
///   ↓
/// Feature sends to AI Capability Router
/// ```
class PromptBuilderService {
  PromptBuilderService({
    required this.templateRegistry,
  });

  final PromptTemplateRegistry templateRegistry;
  final PhoenixLogger _logger = PhoenixLogger.shared;

  // ── Prompt Diagnostics Tracking ─────────────────────────────────

  /// Tracks prompt build statistics for diagnostics.
  int _totalPromptsBuilt = 0;
  int _failedBuilds = 0;
  final Map<String, int> _buildCountByType = {};
  final Map<String, double> _estimatedTokensByType = {};

  /// Total prompts built since initialization.
  int get totalPromptsBuilt => _totalPromptsBuilt;

  /// Total failed builds since initialization.
  int get failedBuilds => _failedBuilds;

  /// Build counts by prompt type.
  Map<String, int> get buildCountByType => Map.unmodifiable(_buildCountByType);

  /// Average estimated tokens by prompt type.
  Map<String, double> get averageTokensByType =>
      Map.unmodifiable(_estimatedTokensByType);

  /// Resets all prompt build statistics.
  void resetDiagnostics() {
    _totalPromptsBuilt = 0;
    _failedBuilds = 0;
    _buildCountByType.clear();
    _estimatedTokensByType.clear();
  }

  // ── Public API ──────────────────────────────────────────────────

  /// Builds a [PromptSpecification] for the given prompt type.
  ///
  /// Returns `null` if the template or context is unavailable.
  PromptSpecification? build({
    required String promptType,
    required AIContextSnapshot context,
    int? templateVersion,
    String? targetAudience,
  }) {
    // 0. Get template
    final template = templateVersion != null
        ? templateRegistry.getVersion(_templateIdForType(promptType), templateVersion)
        : templateRegistry.getLatest(_templateIdForType(promptType));

    if (template == null) {
      _failedBuilds++;
      _logger.warning('Template not found for type: $promptType',
          source: 'PromptBuilderService');
      return null;
    }

    // 2. Build context references from AIContextSnapshot
    final contextRefs = _buildContextReferences(promptType, context);

    // 3. Build specification from template
    try {
      final spec = template.build(
        context: contextRefs,
        targetAudience: targetAudience,
      );

      // Track diagnostics
      _totalPromptsBuilt++;
      _buildCountByType[promptType] = (_buildCountByType[promptType] ?? 0) + 1;
      final estimatedTokens = estimateTokens(spec);
      final avgTokens = _estimatedTokensByType[promptType] ?? 0.0;
      final count = _buildCountByType[promptType] ?? 1;
      _estimatedTokensByType[promptType] =
          avgTokens + ((estimatedTokens - avgTokens) / count);

      _logger.debug('Built prompt: ${spec.templateId} '
          '(${contextRefs.length} refs, ~$estimatedTokens tokens)',
          source: 'PromptBuilderService');

      return spec;
    } catch (e) {
      _failedBuilds++;
      _logger.error('Failed to build prompt: $e',
          source: 'PromptBuilderService');
      return null;
    }
  }

  /// Estimates the number of tokens in a prompt specification.
  ///
  /// Uses a 4:1 character-to-token ratio approximation, which is
  /// a reasonable heuristic for English text.
  int estimateTokens(PromptSpecification spec) {
    final totalChars =
        spec.systemInstructions.length +
        spec.userInstructions.length +
        spec.outputSchema.length +
        spec.constraints.length +
        spec.objective.length +
        spec.purpose.length;
    // Rough estimation: ~4 chars per token for English
    return (totalChars / 4).ceil();
  }

  /// Returns a diagnostics summary for the prompt builder,
  /// which can be consumed by the DiagnosticsService.
  Map<String, dynamic> diagnosticsSummary() {
    return {
      'totalPromptsBuilt': _totalPromptsBuilt,
      'failedBuilds': _failedBuilds,
      'buildsByType': Map.from(_buildCountByType),
      'avgTokensByType': _estimatedTokensByType.map(
        (k, v) => MapEntry(k, v.roundToDouble()),
      ),
      'registryTemplateCount': templateRegistry.allTemplateIds.length,
    };
  }

  /// Builds a mission generation prompt.
  PromptSpecification? buildMission(AIContextSnapshot context) =>
      build(promptType: PromptType.mission, context: context);

  /// Builds a project generation prompt.
  PromptSpecification? buildProject(AIContextSnapshot context) =>
      build(promptType: PromptType.project, context: context);

  /// Builds an assessment generation prompt.
  PromptSpecification? buildAssessment(AIContextSnapshot context) =>
      build(promptType: PromptType.assessment, context: context);

  /// Builds an interview question generation prompt.
  PromptSpecification? buildInterview(AIContextSnapshot context) =>
      build(promptType: PromptType.interview, context: context);

  /// Builds a career coaching prompt.
  PromptSpecification? buildCareerCoaching(AIContextSnapshot context) =>
      build(promptType: PromptType.careerCoaching, context: context);

  /// Builds an AI assistant prompt with a user message.
  PromptSpecification? buildAssistant(
    AIContextSnapshot context, {
    required String userMessage,
  }) {
    final spec = build(
      promptType: PromptType.aiAssistant,
      context: context,
    );
    if (spec == null) return null;

    // Inject the user's message into the userInstructions
    final withMessage = PromptSpecification(
      templateId: spec.templateId,
      templateVersion: spec.templateVersion,
      promptType: spec.promptType,
      purpose: spec.purpose,
      objective: spec.objective,
      systemInstructions: spec.systemInstructions,
      userInstructions: spec.userInstructions
          .replaceAll('{{user_message}}', userMessage),
      outputSchema: spec.outputSchema,
      constraints: spec.constraints,
      contextReferences: spec.contextReferences,
      tone: spec.tone,
      difficulty: spec.difficulty,
      targetAudience: spec.targetAudience,
      temperature: spec.temperature,
      maxTokens: spec.maxTokens,
    );
    return withMessage;
  }

  /// Builds a decision intelligence prompt.
  PromptSpecification? buildDecision(AIContextSnapshot context) =>
      build(promptType: PromptType.decisionIntelligence, context: context);

  /// Builds a learning path generation prompt.
  PromptSpecification? buildLearningPath(AIContextSnapshot context) =>
      build(promptType: PromptType.learningPath, context: context);

  /// Validates a [PromptSpecification] is complete.
  bool validate(PromptSpecification spec) {
    if (!spec.isValid) {
      _logger.warning('Invalid prompt specification: ${spec.templateId}',
          source: 'PromptBuilderService');
      return false;
    }
    return true;
  }

  // ── Helpers ─────────────────────────────────────────────────────

  /// Maps [PromptType] constants to template IDs.
  String _templateIdForType(String promptType) {
    switch (promptType) {
      case PromptType.mission:
        return 'mission_generation';
      case PromptType.project:
        return 'project_generation';
      case PromptType.assessment:
        return 'assessment_generation';
      case PromptType.interview:
        return 'interview_generation';
      case PromptType.careerCoaching:
        return 'career_coaching';
      case PromptType.aiAssistant:
        return 'ai_assistant';
      case PromptType.decisionIntelligence:
        return 'decision_intelligence';
      case PromptType.learningPath:
        return 'learning_path_generation';
      case 'learning_experience':
        return 'learning_experience_generation';
      default:
        return promptType;
    }
  }

  /// Builds [ContextReference] list from [AIContextSnapshot] for a prompt type.
  List<ContextReference> _buildContextReferences(
    String promptType,
    AIContextSnapshot context,
  ) {
    // Use ContextBuilders to extract focused context
    final aiContext = _getBuilderContext(promptType, context);
    if (aiContext == null) return [];

    // Convert ContextSection to ContextReference
    return aiContext.sections.map((section) {
      return ContextReference(
        key: section.key,
        value: section.value,
      );
    }).toList();
  }

  /// Gets the focused [AIContext] for a prompt type.
  AIContext? _getBuilderContext(String promptType, AIContextSnapshot context) {
    switch (promptType) {
      case PromptType.mission:
        return ContextBuilders.mission(context);
      case PromptType.project:
        return ContextBuilders.project(context);
      case PromptType.assessment:
        return ContextBuilders.assessment(context);
      case PromptType.interview:
        return ContextBuilders.interview(context);
      case PromptType.careerCoaching:
        return ContextBuilders.career(context);
      case PromptType.aiAssistant:
        return ContextBuilders.assistant(context);
      case PromptType.decisionIntelligence:
        return ContextBuilders.decision(context);
      default:
        // For learning_path and others, use assistant (full context)
        return ContextBuilders.assistant(context);
    }
  }
}
