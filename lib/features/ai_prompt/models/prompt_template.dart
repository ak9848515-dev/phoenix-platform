import 'prompt_specification.dart';

/// A versioned, reusable prompt template.
///
/// Each [PromptTemplate] contains all the fixed parts of a prompt
/// (system instructions, output schema, constraints) and is combined
/// with user-specific context from [AIContextSnapshot] at build time.
///
/// **Versioning:**
/// Templates are versioned to allow iteration without breaking
/// existing features. The [PromptTemplateRegistry] stores all versions.
///
/// **Immutability:**
/// Templates are immutable. To update a template, create a new version.
class PromptTemplate {
  const PromptTemplate({
    required this.id,
    required this.version,
    required this.promptType,
    required this.purpose,
    required this.objective,
    required this.systemInstructions,
    required this.outputSchema,
    required this.constraints,
    required this.userInstructionsTemplate,
    this.tone = 'professional',
    this.difficulty = 'intermediate',
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.isActive = true,
    this.deprecatedAt,
  });

  /// Unique template ID (e.g. 'mission_generation').
  final String id;

  /// Version number (starts at 1).
  final int version;

  /// Prompt type identifier.
  final String promptType;

  /// Brief description of what this template does.
  final String purpose;

  /// The exact outcome expected from the AI.
  final String objective;

  /// System-level instructions with placeholders for context injection.
  /// Placeholders use {{variable_name}} syntax.
  final String systemInstructions;

  /// Expected JSON/structured output schema.
  final String outputSchema;

  /// Constraints and limitations the AI must follow.
  final String constraints;

  /// User instructions template with {{variable_name}} placeholders.
  final String userInstructionsTemplate;

  /// Expected tone.
  final String tone;

  /// Difficulty level.
  final String difficulty;

  /// AI temperature parameter.
  final double temperature;

  /// Maximum tokens.
  final int maxTokens;

  /// Whether this template version is active for new prompts.
  final bool isActive;

  /// When this version was deprecated (null if still active).
  final DateTime? deprecatedAt;

  /// Full template identifier including version.
  String get templateId => '${id}_v$version';

  /// Builds a [PromptSpecification] by injecting context into this template.
  PromptSpecification build({
    required List<ContextReference> context,
    String? targetAudience,
  }) {
    // Inject context references into system instructions and user template
    String resolvedSystem = systemInstructions;
    String resolvedUser = userInstructionsTemplate;

    for (final ref in context) {
      resolvedSystem = resolvedSystem.replaceAll(
        '{{${ref.key}}}',
        ref.value,
      );
      resolvedUser = resolvedUser.replaceAll(
        '{{${ref.key}}}',
        ref.value,
      );
    }

    return PromptSpecification(
      templateId: templateId,
      templateVersion: version,
      promptType: promptType,
      purpose: purpose,
      objective: objective,
      systemInstructions: resolvedSystem,
      userInstructions: resolvedUser,
      outputSchema: outputSchema,
      constraints: constraints,
      contextReferences: context,
      tone: tone,
      difficulty: difficulty,
      targetAudience: targetAudience ?? '',
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  @override
  String toString() =>
      'PromptTemplate(id: $id, version: $version, type: $promptType, '
      'active: $isActive)';
}
