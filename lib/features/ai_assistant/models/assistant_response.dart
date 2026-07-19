/// Response type categories for the Phoenix Assistant.
///
/// Every assistant response is classified into exactly one type,
/// enabling the UI to render appropriate action buttons and context.
enum AssistantResponseType {
  /// General conversational response.
  general,

  /// Progress and statistics summary.
  progress,

  /// Mission or task guidance.
  mission,

  /// Learning and knowledge guidance.
  learning,

  /// Career and professional development.
  career,

  /// Portfolio and project showcase.
  portfolio,

  /// Recommendation or next-action suggestion.
  recommendation,

  /// Greeting and onboarding.
  greeting,

  /// Interview preparation.
  interview,

  /// Insight or analysis.
  insight,

  /// Error or unavailable response.
  error;

  /// Human-readable label for UI use.
  String get displayName {
    switch (this) {
      case AssistantResponseType.general:
        return 'General';
      case AssistantResponseType.progress:
        return 'Progress';
      case AssistantResponseType.mission:
        return 'Mission';
      case AssistantResponseType.learning:
        return 'Learning';
      case AssistantResponseType.career:
        return 'Career';
      case AssistantResponseType.portfolio:
        return 'Portfolio';
      case AssistantResponseType.recommendation:
        return 'Recommendation';
      case AssistantResponseType.greeting:
        return 'Greeting';
      case AssistantResponseType.interview:
        return 'Interview';
      case AssistantResponseType.insight:
        return 'Insight';
      case AssistantResponseType.error:
        return 'Error';
    }
  }
}

/// A structured action suggestion for the user.
///
/// Contains a human-readable label and a Phoenix route that the
/// UI can navigate to when tapped.
class AssistantSuggestion {
  const AssistantSuggestion({
    required this.label,
    required this.route,
    this.description,
    this.icon,
  });

  /// Display label for the action button.
  final String label;

  /// Phoenix route to navigate to (e.g., `/missions`, `/academy`).
  final String route;

  /// Optional short description of what this action does.
  final String? description;

  /// Optional icon data for visual rendering.
  final String? icon;

  Map<String, dynamic> toJson() => {
        'label': label,
        'route': route,
        'description': description,
        'icon': icon,
      };

  factory AssistantSuggestion.fromJson(Map<String, dynamic> json) =>
      AssistantSuggestion(
        label: json['label'] as String,
        route: json['route'] as String,
        description: json['description'] as String?,
        icon: json['icon'] as String?,
      );
}

/// Structured, context-aware response from the Phoenix Assistant.
///
/// Every response includes:
/// - A conversational message
/// - A classified response type
/// - Confidence and provenance metadata
/// - Contextual navigation suggestions
/// - Optional references to related Phoenix content
///
/// **Architecture Rules:**
/// - Immutable, read-only data object
/// - Contains no business logic
/// - UI consumes this model only — never raw provider JSON
class PhoenixAssistantResponse {
  const PhoenixAssistantResponse({
    required this.message,
    required this.responseType,
    required this.confidence,
    required this.suggestions,
    required this.providerName,
    required this.generatedAt,
    this.relatedMissionId,
    this.relatedProjectId,
    this.recommendedNextAction,
    this.suggestedFollowUp,
    this.referencedContext,
    this.modelName,
    this.tokensUsed,
    this.generationTimeMs,
    this.knowledgeInterconnections,
    this.knowledgePrerequisites,
    this.knowledgeMissing,
    this.knowledgeCareerImpact,
    this.knowledgePortfolioImpact,
    this.knowledgeNextLearningPath,
    this.knowledgeRecommendedMinutes,
  });

  /// The conversational message text.
  final String message;

  /// Classified type of this response.
  final AssistantResponseType responseType;

  /// Confidence score from the AI pipeline (0.0–1.0).
  final double confidence;

  /// Navigation suggestions derived from context.
  final List<AssistantSuggestion> suggestions;

  /// AI provider name used for this response.
  final String providerName;

  /// When this response was generated.
  final DateTime generatedAt;

  /// Optional ID of the related mission.
  final String? relatedMissionId;

  /// Optional ID of the related project.
  final String? relatedProjectId;

  /// Optional recommended next action description.
  final String? recommendedNextAction;

  /// Optional follow-up question or prompt.
  final String? suggestedFollowUp;

  /// Optional description of the context referenced for this response.
  final String? referencedContext;

  /// Optional AI model name used.
  final String? modelName;

  /// Optional token usage count.
  final int? tokensUsed;

  /// Optional generation time in milliseconds.
  final int? generationTimeMs;

  // ── PHX-087: Knowledge Relationship Intelligence ──────────────────

  /// Related topics that interconnect with the answer.
  final List<String>? knowledgeInterconnections;

  /// Topics to master first.
  final List<String>? knowledgePrerequisites;

  /// Knowledge gaps relevant to the conversation.
  final List<String>? knowledgeMissing;

  /// Career impact description.
  final String? knowledgeCareerImpact;

  /// Portfolio impact description.
  final String? knowledgePortfolioImpact;

  /// Suggested next learning steps.
  final List<String>? knowledgeNextLearningPath;

  /// Recommended session duration (minutes).
  final int? knowledgeRecommendedMinutes;

  /// Whether this response is actionable (has suggestions or next actions).
  bool get isActionable =>
      suggestions.isNotEmpty ||
      recommendedNextAction != null ||
      relatedMissionId != null;

  /// Whether this response indicates an error state.
  bool get isError => responseType == AssistantResponseType.error;

  /// Whether the confidence is high enough for reliable use.
  bool get isReliable => confidence >= 0.5;

  /// Creates a copy with the given fields replaced.
  PhoenixAssistantResponse copyWith({
    String? message,
    AssistantResponseType? responseType,
    double? confidence,
    List<AssistantSuggestion>? suggestions,
    String? providerName,
    DateTime? generatedAt,
    String? relatedMissionId,
    String? relatedProjectId,
    String? recommendedNextAction,
    String? suggestedFollowUp,
    String? referencedContext,
    String? modelName,
    int? tokensUsed,
    int? generationTimeMs,
    List<String>? knowledgeInterconnections,
    List<String>? knowledgePrerequisites,
    List<String>? knowledgeMissing,
    String? knowledgeCareerImpact,
    String? knowledgePortfolioImpact,
    List<String>? knowledgeNextLearningPath,
    int? knowledgeRecommendedMinutes,
  }) =>
      PhoenixAssistantResponse(
        message: message ?? this.message,
        responseType: responseType ?? this.responseType,
        confidence: confidence ?? this.confidence,
        suggestions: suggestions ?? this.suggestions,
        providerName: providerName ?? this.providerName,
        generatedAt: generatedAt ?? this.generatedAt,
        relatedMissionId: relatedMissionId ?? this.relatedMissionId,
        relatedProjectId: relatedProjectId ?? this.relatedProjectId,
        recommendedNextAction:
            recommendedNextAction ?? this.recommendedNextAction,
        suggestedFollowUp: suggestedFollowUp ?? this.suggestedFollowUp,
        referencedContext: referencedContext ?? this.referencedContext,
        modelName: modelName ?? this.modelName,
        tokensUsed: tokensUsed ?? this.tokensUsed,
        generationTimeMs: generationTimeMs ?? this.generationTimeMs,
        knowledgeInterconnections:
            knowledgeInterconnections ?? this.knowledgeInterconnections,
        knowledgePrerequisites:
            knowledgePrerequisites ?? this.knowledgePrerequisites,
        knowledgeMissing: knowledgeMissing ?? this.knowledgeMissing,
        knowledgeCareerImpact:
            knowledgeCareerImpact ?? this.knowledgeCareerImpact,
        knowledgePortfolioImpact:
            knowledgePortfolioImpact ?? this.knowledgePortfolioImpact,
        knowledgeNextLearningPath:
            knowledgeNextLearningPath ?? this.knowledgeNextLearningPath,
        knowledgeRecommendedMinutes:
            knowledgeRecommendedMinutes ?? this.knowledgeRecommendedMinutes,
      );

  @override
  String toString() =>
      'PhoenixAssistantResponse(type: ${responseType.displayName}, '
      'confidence: ${(confidence * 100).round()}%, '
      'suggestions: ${suggestions.length})';

  Map<String, dynamic> toJson() => {
        'message': message,
        'responseType': responseType.name,
        'confidence': confidence,
        'suggestions': suggestions.map((s) => s.toJson()).toList(),
        'providerName': providerName,
        'generatedAt': generatedAt.toIso8601String(),
        'relatedMissionId': relatedMissionId,
        'relatedProjectId': relatedProjectId,
        'recommendedNextAction': recommendedNextAction,
        'suggestedFollowUp': suggestedFollowUp,
        'referencedContext': referencedContext,
        'modelName': modelName,
        'tokensUsed': tokensUsed,
        'generationTimeMs': generationTimeMs,
        'knowledgeInterconnections': knowledgeInterconnections,
        'knowledgePrerequisites': knowledgePrerequisites,
        'knowledgeMissing': knowledgeMissing,
        'knowledgeCareerImpact': knowledgeCareerImpact,
        'knowledgePortfolioImpact': knowledgePortfolioImpact,
        'knowledgeNextLearningPath': knowledgeNextLearningPath,
        'knowledgeRecommendedMinutes': knowledgeRecommendedMinutes,
      };

  /// Creates an error response for failed generations.
  factory PhoenixAssistantResponse.error({
    String message = 'I apologize, but I was unable to generate a response. '
        'Please try again or rephrase your question.',
    String providerName = 'none',
  }) =>
      PhoenixAssistantResponse(
        message: message,
        responseType: AssistantResponseType.error,
        confidence: 0.0,
        suggestions: [],
        providerName: providerName,
        generatedAt: DateTime.now(),
      );

  /// Creates a fallback response for offline/empty states.
  factory PhoenixAssistantResponse.offline() =>
      PhoenixAssistantResponse(
        message: 'I\'m currently offline. Please check your connection and '
            'try again. Your existing data is still available.',
        responseType: AssistantResponseType.general,
        confidence: 0.0,
        suggestions: [],
        providerName: 'offline',
        generatedAt: DateTime.now(),
      );
}
