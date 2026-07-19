/// Parameters for a content generation request.
///
/// Each content type has its own set of optional parameters.
/// Common params (userId, context) are handled by the AI pipeline automatically.
class GenerationRequest {
  const GenerationRequest({
    required this.contentType,
    this.title,
    this.description,
    this.targetRole,
    this.technologies = const [],
    this.skillFocus = const [],
    this.difficulty,
    this.estimatedDuration,
    this.additionalContext = const {},
  });

  /// The type of content to generate (course, project, etc.).
  final String contentType;

  /// Optional title hint for the content.
  final String? title;

  /// Optional description hint.
  final String? description;

  /// Target role (for interview questions, resume enhancements).
  final String? targetRole;

  /// Technologies to focus on (for projects, portfolio).
  final List<String> technologies;

  /// Skill areas to focus on.
  final List<String> skillFocus;

  /// Preferred difficulty level.
  final String? difficulty;

  /// Preferred duration in weeks/hours.
  final int? estimatedDuration;

  /// Additional context parameters for generation.
  final Map<String, dynamic> additionalContext;
}
