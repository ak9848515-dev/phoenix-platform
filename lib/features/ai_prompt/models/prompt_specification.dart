/// Immutable, provider-neutral AI prompt specification.
///
/// Represents a complete prompt that can be sent to any AI provider,
/// with structured fields for system instructions, user context,
/// output schema, and constraints.
///
/// Provider formatting (e.g. Gemini's `contents`, OpenAI's `messages`)
/// happens AFTER this specification is built, in the provider adapter layer.
class PromptSpecification {
  const PromptSpecification({
    required this.templateId,
    required this.templateVersion,
    required this.promptType,
    required this.purpose,
    required this.objective,
    required this.systemInstructions,
    required this.userInstructions,
    required this.outputSchema,
    required this.constraints,
    this.contextReferences = const [],
    this.tone = 'professional',
    this.difficulty = 'intermediate',
    this.targetAudience = '',
    this.temperature = 0.7,
    this.maxTokens = 2048,
  });

  /// Unique template identifier (e.g. 'mission_generation_v1').
  final String templateId;

  /// Template version number.
  final int templateVersion;

  /// Type of prompt (e.g. 'mission', 'project', 'assessment').
  final String promptType;

  /// Brief description of what this prompt does.
  final String purpose;

  /// The exact outcome expected from the AI.
  final String objective;

  /// System-level instructions (role, behavior, formatting rules).
  final String systemInstructions;

  /// User-level instructions (what to generate, with what context).
  final String userInstructions;

  /// Expected JSON/structured output schema.
  final String outputSchema;

  /// Constraints and limitations the AI must follow.
  final String constraints;

  /// Context references from [AIContextSnapshot] as key-value pairs.
  final List<ContextReference> contextReferences;

  /// Expected tone (e.g. 'professional', 'encouraging', 'challenging').
  final String tone;

  /// Content difficulty level (e.g. 'beginner', 'intermediate', 'advanced').
  final String difficulty;

  /// Target audience description.
  final String targetAudience;

  /// AI temperature parameter (0.0–1.0).
  final double temperature;

  /// Maximum tokens for the response.
  final int maxTokens;

  /// Validates the specification is complete enough to be useful.
  bool get isValid =>
      templateId.isNotEmpty &&
      objective.isNotEmpty &&
      systemInstructions.isNotEmpty &&
      outputSchema.isNotEmpty;

  /// Converts to a map for serialization or debugging.
  Map<String, dynamic> toMap() => {
        'templateId': templateId,
        'templateVersion': templateVersion,
        'promptType': promptType,
        'purpose': purpose,
        'objective': objective,
        'systemInstructions': systemInstructions,
        'userInstructions': userInstructions,
        'outputSchema': outputSchema,
        'constraints': constraints,
        'contextReferences':
            contextReferences.map((r) => r.toMap()).toList(),
        'tone': tone,
        'difficulty': difficulty,
        'targetAudience': targetAudience,
        'temperature': temperature,
        'maxTokens': maxTokens,
      };

  @override
  String toString() =>
      'PromptSpecification(id: $templateId, type: $promptType, '
      'valid: $isValid)';
}

/// A single context reference within a [PromptSpecification].
///
/// Provides the AI with user-specific data from the
/// [AIContextSnapshot] without needing to query engines directly.
class ContextReference {
  const ContextReference({
    required this.key,
    required this.value,
    this.description = '',
  });

  /// Reference key (e.g. 'user_name', 'growth_index').
  final String key;

  /// Reference value (e.g. 'Explorer', '0.75').
  final String value;

  /// Optional human-readable description for the AI.
  final String description;

  /// Whether this reference has meaningful data.
  bool get hasValue => value.isNotEmpty && value != '0';

  Map<String, dynamic> toMap() => {
        'key': key,
        'value': value,
        'description': description,
      };

  @override
  String toString() => '$key: $value';
}

// ═════════════════════════════════════════════════════════════════════
// Prompt Type Constants
// ═════════════════════════════════════════════════════════════════════

/// Canonical prompt type identifiers.
class PromptType {
  PromptType._();

  static const String mission = 'mission';
  static const String project = 'project';
  static const String assessment = 'assessment';
  static const String interview = 'interview';
  static const String careerCoaching = 'career_coaching';
  static const String recommendation = 'recommendation';
  static const String aiAssistant = 'ai_assistant';
  static const String decisionIntelligence = 'decision_intelligence';
  static const String learningPath = 'learning_path';

  /// All supported prompt types.
  static const List<String> all = [
    mission,
    project,
    assessment,
    interview,
    careerCoaching,
    recommendation,
    aiAssistant,
    decisionIntelligence,
    learningPath,
  ];

  /// Display name for each type.
  static String displayName(String type) {
    switch (type) {
      case mission:
        return 'Mission Generation';
      case project:
        return 'Project Generation';
      case assessment:
        return 'Assessment Generation';
      case interview:
        return 'Interview Questions';
      case careerCoaching:
        return 'Career Coaching';
      case recommendation:
        return 'Recommendation';
      case aiAssistant:
        return 'AI Assistant';
      case decisionIntelligence:
        return 'Decision Intelligence';
      case learningPath:
        return 'Learning Path';
      default:
        return type;
    }
  }
}
