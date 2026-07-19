import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../ai_capability_router/models/ai_request.dart';
import '../../ai_capability_router/models/ai_capability.dart';
import '../../ai_capability_router/router/ai_capability_router.dart';
import '../../ai_context/engine/ai_context_engine.dart';
import '../../ai_context/models/ai_context_snapshot.dart';
import '../../ai_gateway/services/ai_response_gateway.dart';
import '../../ai_prompt/services/prompt_builder_service.dart';
import '../../ai_prompt/models/prompt_specification.dart';
import '../../adaptive_learning/engine/adaptive_learning_engine.dart';
import '../../decision_intelligence/engine/decision_engine.dart';
import '../../growth_intelligence/engine/growth_intelligence_engine.dart';
import '../../knowledge_relationship/services/knowledge_relationship_service.dart';
import '../../resume_intelligence/engine/resume_intelligence_engine.dart';
import '../models/assistant_conversation.dart';
import '../models/assistant_response.dart';
import 'assistant_suggestion_engine.dart';

/// Phoenix Assistant Service — the intelligent operating interface of Phoenix OS.
///
/// **Responsibilities:**
/// - Consumes [AIContextSnapshot] to understand the user completely
/// - Builds prompts through [PromptBuilderService]
/// - Routes requests through [AICapabilityRouter]
/// - Validates responses through [AIResponseGateway]
/// - Enriches responses with structured metadata and suggestions
/// - Maintains conversation memory
///
/// **Architecture Flow:**
/// ```
/// User Message
///   ↓
/// AIContextEngine.snapshot  (full user context)
///   ↓
/// PromptBuilderService.buildAssistant(snapshot, userMessage)
///   ↓
/// AICapabilityRouter.route(AIRequest)
///   ↓
/// AIResponseGateway.process(rawResponse, 'ai_assistant')
///   ↓
/// AssistantSuggestionEngine.buildSuggestions(snapshot)
///   ↓
/// PhoenixAssistantResponse → UI + Conversation Memory
/// ```
///
/// **Non-responsibilities:**
/// - NEVER calls AI providers directly
/// - NEVER modifies engines
/// - NEVER contains UI logic
class PhoenixAssistantService {
  PhoenixAssistantService({
    required this._aiContextEngine,
    required this._promptBuilderService,
    required this._aiCapabilityRouter,
    required this._aiResponseGateway,
    required this._knowledgeRelationshipService,
    this._decisionEngine,
    this._growthIntelligenceEngine,
    this._adaptiveLearningEngine,
    this._resumeIntelligenceEngine,
  });

  final AIContextEngine _aiContextEngine;
  final PromptBuilderService _promptBuilderService;
  final AICapabilityRouter _aiCapabilityRouter;
  final AIResponseGateway _aiResponseGateway;
  final KnowledgeRelationshipService _knowledgeRelationshipService;
  final DecisionEngine? _decisionEngine;
  final GrowthIntelligenceEngine? _growthIntelligenceEngine;
  final AdaptiveLearningEngine? _adaptiveLearningEngine;
  final ResumeIntelligenceEngine? _resumeIntelligenceEngine;
  final AssistantSuggestionEngine _suggestionEngine =
      const AssistantSuggestionEngine();
  final PhoenixLogger _logger = PhoenixLogger.shared;

  static const String _storageKey = 'phx_assistant_conversation';

  // ── Conversation Memory ────────────────────────────────────────────

  /// Loads the persisted conversation.
  Future<AssistantConversation?> loadConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AssistantConversation.fromJsonString(raw);
    } catch (e) {
      _logger.warning('Failed to load conversation: $e',
          source: 'PhoenixAssistantService');
      return null;
    }
  }

  /// Persists the conversation.
  Future<void> saveConversation(AssistantConversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, conversation.toJsonString());
  }

  /// Clears all conversation history.
  Future<void> clearConversation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _logger.info('Conversation cleared', source: 'PhoenixAssistantService');
  }

  // ── Chat ────────────────────────────────────────────────────────────

  /// Processes a user message and returns a context-aware response.
  ///
  /// Full pipeline execution:
  /// 1. Read AIContextSnapshot (full user context)
  /// 2. Detect intent from message
  /// 3. Build prompt via PromptBuilderService
  /// 4. Route through AICapabilityRouter
  /// 5. Validate through AIResponseGateway
  /// 6. Build structured PhoenixAssistantResponse
  /// 7. Enrich with suggestions from AssistantSuggestionEngine
  Future<PhoenixAssistantResponse> chat({
    required String userMessage,
    AssistantConversation? conversation,
  }) async {
    final startedAt = DateTime.now();

    try {
      // 1. Get current user context
      final context = _aiContextEngine.snapshot;

      if (!context.isReady) {
        return _buildContextResponse(context, userMessage);
      }

      // 2. Detect intent
      final intent = _suggestionEngine.detectIntent(userMessage);

      // 3. Build prompt specification
      final promptSpec = _promptBuilderService.buildAssistant(
        context,
        userMessage: userMessage,
      );

      if (promptSpec == null) {
        _logger.warning('Failed to build assistant prompt',
            source: 'PhoenixAssistantService');
        return _buildFallbackResponse(context, userMessage, intent);
      }

      // 4. Create AI request and route
      final request = AIRequest(
        capability: AICapability.generalChat,
        prompt: _specToString(promptSpec),
        context: {
          'promptType': 'ai_assistant',
          'userMessage': userMessage,
          'conversationId': conversation?.id,
        },
        temperature: 0.8,
        maxTokens: 1024,
      );

      final result = await _aiCapabilityRouter.route(request);

      if (!result.isSuccess || result.response.output.isEmpty) {
        _logger.warning('Router returned unsuccessful result',
            source: 'PhoenixAssistantService');
        return _buildFallbackResponse(context, userMessage, intent);
      }

      // 5. Validate through AI Response Gateway
      final rawOutput = result.response.output;
      final validationResult = _aiResponseGateway.process(
        rawResponse: rawOutput,
        promptType: PromptType.aiAssistant,
        templateVersion: 1,
        providerName: result.response.provider.name,
      );

      String message;
      Map<String, dynamic>? validatedData;

      if (validationResult.isValid) {
        validatedData = validationResult.domainMap;
        // Extract message from validated response, preferring the
        // structured 'message' field, falling back to the raw output
        message = _extractMessage(validatedData) ?? rawOutput;
      } else {
        message = rawOutput;
        _logger.warning('Gateway validation had warnings, using raw output',
            source: 'PhoenixAssistantService');
      }

      // 6. Build structured response
      final generationTimeMs =
          DateTime.now().difference(startedAt).inMilliseconds;

      final suggestions = _suggestionEngine.buildSuggestions(context);

      // Parse structured data for enrichment
      final structuredResponse = _extractStructuredResponse(validatedData);

      // PHX-087: Enrich with knowledge relationship intelligence
      final knowledgeRel = _knowledgeRelationshipService.buildForContext(context);

      return PhoenixAssistantResponse(
        message: message,
        responseType: intent == AssistantResponseType.greeting
            ? AssistantResponseType.greeting
            : structuredResponse?.responseType ?? intent,
        confidence: validationResult.isValid ? 0.85 : 0.5,
        suggestions: suggestions,
        providerName: result.response.provider.displayName,
        generatedAt: DateTime.now(),
        relatedMissionId: structuredResponse?.relatedMissionId,
        relatedProjectId: structuredResponse?.relatedProjectId,
        recommendedNextAction: structuredResponse?.recommendedNextAction,
        suggestedFollowUp: structuredResponse?.suggestedFollowUp,
        referencedContext: _buildReferencedContext(context),
        modelName: null,
        tokensUsed: result.response.estimatedTokens,
        generationTimeMs: generationTimeMs,
        knowledgeInterconnections: knowledgeRel.hasInterconnections
            ? knowledgeRel.interconnections
                .map((l) => l.topic)
                .toList()
            : null,
        knowledgePrerequisites: knowledgeRel.hasPrerequisites
            ? knowledgeRel.prerequisites
                .map((l) => l.topic)
                .toList()
            : null,
        knowledgeMissing: knowledgeRel.hasMissingKnowledge
            ? knowledgeRel.missingKnowledge
            : null,
        knowledgeCareerImpact: knowledgeRel.hasCareerImpact
            ? knowledgeRel.careerImpact
            : null,
        knowledgePortfolioImpact: knowledgeRel.hasPortfolioImpact
            ? knowledgeRel.portfolioImpact
            : null,
        knowledgeNextLearningPath: knowledgeRel.hasNextLearningPath
            ? knowledgeRel.nextLearningPath
            : null,
        knowledgeRecommendedMinutes:
            knowledgeRel.recommendedDuration > 0
                ? knowledgeRel.recommendedDuration
                : null,
      );
    } catch (e) {
      _logger.error('Assistant chat failed: $e',
          source: 'PhoenixAssistantService');
      return PhoenixAssistantResponse.error();
    }
  }

  /// Generates a greeting response for initial conversation start.
  Future<PhoenixAssistantResponse> greeting() async {
    try {
      final context = _aiContextEngine.snapshot;
      final identity = context.identity;
      final decisionSnap = _decisionEngine?.snapshot;
      final forecastSnap = _growthIntelligenceEngine?.snapshot;
      final adaptiveSnap = _adaptiveLearningEngine?.snapshot;
      final resumeSnap = _resumeIntelligenceEngine?.snapshot;

      final timeGreeting = _timeBasedGreeting();
      final message = StringBuffer()
        ..writeln(
            '$timeGreeting! I\'m your Phoenix Assistant. 👋')
        ..writeln()
        ..write(
            'I can see you\'re working toward becoming a ')
        ..write(identity.targetIdentity.isNotEmpty
            ? identity.targetIdentity
            : 'amazing version of yourself')
        ..writeln('.')
        ..writeln()
        ..writeln(
            'Here\'s what I can help you with today:')
        ..writeln()
        ..writeln(
            '📊 **Progress** — How you\'re tracking on your journey')
        ..writeln(
            '🎯 **Missions** — What to focus on next')
        ..writeln(
            '📚 **Learning** — Knowledge insights and skill gaps')
        ..writeln(
            '💼 **Career** — Readiness and interview preparation')
        ..writeln(
            '🔄 **Recommendations** — Personalised next steps');

      // Add Decision Intelligence top recommendation if available
      if (decisionSnap?.top != null) {
        final top = decisionSnap!.top!;
        message.writeln();
        message.writeln(
            '🎯 **Recommended Now**: ${top.title}');
        message.writeln(
            '   ${top.description} (${top.score.overall}/100 confidence)');
      }

      // Add Growth Forecast if available
      if (forecastSnap != null && forecastSnap.milestones.isNotEmpty) {
        final next = forecastSnap.milestones.first;
        message.writeln();
        message.writeln(
            '🏆 **Next Milestone**: ${next.title}');
        message.writeln(
            '   ~${next.daysRemaining ?? "?"} days away (${next.confidence}% confidence)');
      }

      // Add Adaptive Learning strategy if available
      if (adaptiveSnap != null && adaptiveSnap.hasData) {
        final top = adaptiveSnap.topAdaptation;
        if (top != null) {
          message.writeln();
          message.writeln(
              '🧠 **Learning Strategy**: ${top.type.displayName}');
          message.writeln(
              '   ${top.reason.why}');
        }
      }

      // Add Resume Intelligence if available
      if (resumeSnap != null && resumeSnap.hasData) {
        message.writeln();
        message.writeln(
            '📄 **Resume Health**: ${resumeSnap.overallScore.round()}/100 — ${resumeSnap.healthLabel}');
        if (resumeSnap.topRecommendation != null) {
          message.writeln(
              '   ${resumeSnap.topRecommendation!.description}');
        }
      }

      final suggestions = _suggestionEngine.greetingSuggestions(context);

      return PhoenixAssistantResponse(
        message: message.toString(),
        responseType: AssistantResponseType.greeting,
        confidence: 0.95,
        suggestions: suggestions,
        providerName: 'phoenix',
        generatedAt: DateTime.now(),
        recommendedNextAction: decisionSnap?.top?.title,
        referencedContext: _buildReferencedContext(context),
      );
    } catch (e) {
      _logger.error('Greeting generation failed: $e',
          source: 'PhoenixAssistantService');
      return PhoenixAssistantResponse.error(
        message:
            'Welcome! I\'m your Phoenix Assistant. Ask me anything about your '
            'growth journey.',
      );
    }
  }

  // ── Fallback Strategies ─────────────────────────────────────────────

  /// Builds a response when the context is not fully ready.
  PhoenixAssistantResponse _buildContextResponse(
    AIContextSnapshot context,
    String userMessage,
  ) {
    final intent = _suggestionEngine.detectIntent(userMessage);
    final name = context.identity.name.isNotEmpty
        ? context.identity.name
        : 'there';

    final message = StringBuffer()
      ..writeln('Hey $name! 👋')
      ..writeln()
      ..writeln(
          'Your Phoenix profile is still being set up, so I don\'t have '
          'full context yet. But I can still help!')
      ..writeln()
      ..writeln(
          'In the meantime, you can explore your missions, start a learning '
          'path, or build your profile.')
      ..writeln()
      ..writeln('What would you like to do?');

    return PhoenixAssistantResponse(
      message: message.toString(),
      responseType: intent,
      confidence: 0.6,
      suggestions: const [
        AssistantSuggestion(
          label: 'Start Onboarding',
          route: '/onboarding',
          description: 'Set up your Phoenix profile',
        ),
        AssistantSuggestion(
          label: 'Explore Missions',
          route: '/',
          description: 'See what missions are available',
        ),
      ],
      providerName: 'phoenix',
      generatedAt: DateTime.now(),
    );
  }

  /// Builds a deterministic fallback when the AI pipeline fails.
  PhoenixAssistantResponse _buildFallbackResponse(
    AIContextSnapshot context,
    String userMessage,
    AssistantResponseType intent,
  ) {
    String message;
    String? nextAction;

    switch (intent) {
      case AssistantResponseType.progress:
        message = _fallbackProgress(context);
        nextAction = 'View your full progress';
        break;
      case AssistantResponseType.mission:
        message = _fallbackMission(context);
        nextAction = 'Open mission center';
        break;
      case AssistantResponseType.learning:
        message = _fallbackLearning(context);
        nextAction = 'Continue learning';
        break;
      case AssistantResponseType.career:
        message = _fallbackCareer(context);
        nextAction = 'View career readiness';
        break;
      case AssistantResponseType.portfolio:
        message = _fallbackPortfolio(context);
        nextAction = 'Open portfolio';
        break;
      case AssistantResponseType.recommendation:
        message = _fallbackRecommendation(context);
        nextAction = 'See all recommendations';
        break;
      case AssistantResponseType.greeting:
        message = _fallbackGreeting(context);
        break;
      default:
        message = _fallbackGeneral(context);
        break;
    }

    final suggestions = _suggestionEngine.buildSuggestions(context);

    return PhoenixAssistantResponse(
      message: message,
      responseType: intent,
      confidence: 0.7,
      suggestions: suggestions,
      providerName: 'phoenix',
      generatedAt: DateTime.now(),
      recommendedNextAction: nextAction,
      referencedContext: _buildReferencedContext(context),
    );
  }

  // ── Deterministic Fallback Responses ────────────────────────────────

  String _fallbackProgress(AIContextSnapshot c) {
    return 'Here\'s your current overview:\n\n'
        '- **Level ${c.growth.level}** — ${c.growth.totalXp} XP earned\n'
        '- **Growth Index**: ${(c.growth.growthIndex * 100).round()}%\n'
        '- **Active Missions**: ${c.mission.activeCount}\n'
        '- **Completed Missions**: ${c.mission.completedCount}\n'
        '- **Knowledge Score**: ${(c.knowledge.knowledgeScore * 100).round()}%\n'
        '- **Career Score**: ${(c.career.careerScore * 100).round()}%\n\n'
        'You\'re making great progress! Keep building momentum.';
  }

  String _fallbackMission(AIContextSnapshot c) {
    if (c.mission.currentMission.isEmpty) {
      return 'You don\'t have an active mission right now. '
          'Check your mission center to start a new one, or ask me for '
          'a recommendation!';
    }
    return 'Your current mission is:\n\n'
        '**${c.mission.currentMission}**\n'
        'Priority: ${c.mission.currentPriority}\n\n'
        '${c.mission.reason.isNotEmpty ? "Why? ${c.mission.reason}" : ""}';
  }

  String _fallbackLearning(AIContextSnapshot c) {
    final buf = StringBuffer()
      ..writeln('Your learning profile:\n')
      ..writeln(
          '- **Knowledge Score**: ${(c.knowledge.knowledgeScore * 100).round()}%')
      ..writeln(
          '- **Learning Progress**: ${(c.knowledge.learningProgress * 100).round()}%');

    if (c.knowledge.masteredSkills.isNotEmpty) {
      buf.writeln(
          '- **Strengths**: ${c.knowledge.masteredSkills.join(', ')}');
    }
    if (c.knowledge.weakSkills.isNotEmpty) {
      buf.writeln(
          '- **Areas to grow**: ${c.knowledge.weakSkills.join(', ')}\n');
      buf.writeln(
          'Focus on ${c.knowledge.weakSkills.first} to improve fastest.');
    } else {
      buf.writeln(
          '\nKeep exploring new topics to build your knowledge graph.');
    }

    return buf.toString();
  }

  String _fallbackCareer(AIContextSnapshot c) {
    return 'Your career overview:\n\n'
        '- **Target Role**: ${c.career.targetRole.isNotEmpty ? c.career.targetRole : "Not set"}\n'
        '- **Career Readiness**: ${c.career.careerReadiness.isNotEmpty ? c.career.careerReadiness : "Getting started"}\n'
        '- **Career Score**: ${(c.career.careerScore * 100).round()}%\n'
        '- **Resume Score**: ${(c.career.resumeScore * 100).round()}%\n'
        '- **Interview Readiness**: ${(c.career.interviewReadiness * 100).round()}%\n'
        '- **Applications**: ${c.career.applicationCount}\n\n'
        'Keep building your portfolio and skills to improve readiness.';
  }

  String _fallbackPortfolio(AIContextSnapshot c) {
    return 'Your portfolio snapshot:\n\n'
        '- **Score**: ${(c.portfolio.portfolioScore * 100).round()}%\n'
        '- **Projects**: ${c.portfolio.projectCount}\n'
        '- **Technologies**: ${c.portfolio.technologyCount}\n'
        '- **Achievements**: ${c.portfolio.achievementCount}\n\n'
        'Complete missions and projects to strengthen your portfolio.';
  }

  String _fallbackRecommendation(AIContextSnapshot c) {
    if (c.recommendation.topRecommendation.isEmpty) {
      return 'All caught up! Complete your current missions and I\'ll '
          'have new recommendations ready for you.';
    }
    return 'My top recommendation:\n\n'
        '**${c.recommendation.topRecommendation}**\n'
        'Priority level: ${c.recommendation.topPriority}/10\n'
        'Confidence: ${(c.recommendation.confidence * 100).round()}%\n\n'
        'This will make a real impact on your growth journey!';
  }

  String _fallbackGreeting(AIContextSnapshot c) {
    final name = c.identity.name.isNotEmpty ? c.identity.name : 'there';
    final timeGreeting = _timeBasedGreeting();
    return '$timeGreeting, $name! 👋\n\n'
        'I\'m your Phoenix Assistant. I can help you with progress updates, '
        'mission guidance, learning advice, career planning, and more.\n\n'
        'What would you like to explore today?';
  }

  String _fallbackGeneral(AIContextSnapshot c) {
    final name = c.identity.name.isNotEmpty ? c.identity.name : 'there';
    return 'Hi $name! 👋\n\n'
        'I understand you\'re asking about something. Here\'s a quick '
        'summary of where you are:\n\n'
        '- **Level ${c.growth.level}** with ${c.growth.totalXp} XP\n'
        '- **${c.mission.activeCount} active** missions\n'
        '- **Career**: ${c.career.careerReadiness.isNotEmpty ? c.career.careerReadiness : "Building"}'
        '\n\nFeel free to ask about progress, missions, learning, career, '
        'or anything else about your growth journey!';
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Builds a human-readable context summary for the response metadata.
  String _buildReferencedContext(AIContextSnapshot c) {
    final parts = <String>[];
    if (c.identity.name.isNotEmpty) parts.add('identity');
    if (c.growth.totalXp > 0) parts.add('growth');
    if (c.mission.currentMission.isNotEmpty) parts.add('missions');
    if (c.knowledge.nodeCount > 0) parts.add('knowledge');
    if (c.career.careerScore > 0) parts.add('career');
    if (c.portfolio.projectCount > 0) parts.add('portfolio');
    if (c.recommendation.topRecommendation.isNotEmpty) {
      parts.add('recommendations');
    }
    return parts.join(', ');
  }

  /// Extracts the 'message' field from validated response data.
  String? _extractMessage(Map<String, dynamic>? data) {
    if (data == null) return null;
    final response = data['response'];
    if (response is Map) {
      final message = response['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return data['message'] as String?;
  }

  /// Extracts structured fields from validated response data.
  AssistantResponse? _extractStructuredResponse(Map<String, dynamic>? data) {
    if (data == null) return null;
    final response = data['response'];
    if (response is! Map) return null;

    try {
      return AssistantResponse(
        responseType: response['responseType'] != null
            ? AssistantResponseType.values.firstWhere(
                (t) => t.name == response['responseType'],
                orElse: () => AssistantResponseType.general,
              )
            : null,
        relatedMissionId: response['relatedMissionId'] as String?,
        relatedProjectId: response['relatedProjectId'] as String?,
        recommendedNextAction: response['recommendedNextAction'] as String?,
        suggestedFollowUp: response['suggestedFollowUp'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  /// Converts a [PromptSpecification] to a full prompt string for the router.
  String _specToString(PromptSpecification spec) {
    final buf = StringBuffer()
      ..writeln(spec.systemInstructions)
      ..writeln()
      ..writeln(spec.userInstructions);

    if (spec.outputSchema.isNotEmpty) {
      buf.writeln();
      buf.writeln('Output format:');
      buf.writeln(spec.outputSchema);
    }

    if (spec.constraints.isNotEmpty) {
      buf.writeln();
      buf.writeln('Constraints:');
      buf.writeln(spec.constraints);
    }

    return buf.toString();
  }

  String _timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

/// Internal helper for parsing structured fields from validated responses.
class AssistantResponse {
  const AssistantResponse({
    this.responseType,
    this.relatedMissionId,
    this.relatedProjectId,
    this.recommendedNextAction,
    this.suggestedFollowUp,
  });

  final AssistantResponseType? responseType;
  final String? relatedMissionId;
  final String? relatedProjectId;
  final String? recommendedNextAction;
  final String? suggestedFollowUp;
}
