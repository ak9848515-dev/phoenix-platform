/// Metadata about generated content for tracking and provenance.
class GenerationMetadata {
  const GenerationMetadata({
    required this.generatedAt,
    required this.contentType,
    this.provider = '',
    this.promptVersion = 'v2',
    this.schemaVersion = 1,
    this.generationTimeMs,
    this.confidence = 0.8,
    this.fromCache = false,
    this.isOffline = false,
  });

  final DateTime generatedAt;
  final String contentType;
  final String provider;
  final String promptVersion;
  final int schemaVersion;
  final int? generationTimeMs;
  final double confidence;
  final bool fromCache;
  final bool isOffline;

  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'contentType': contentType,
        'provider': provider,
        'promptVersion': promptVersion,
        'schemaVersion': schemaVersion,
        if (generationTimeMs != null) 'generationTimeMs': generationTimeMs,
        'confidence': confidence,
        'fromCache': fromCache,
        'isOffline': isOffline,
      };

  factory GenerationMetadata.fromJson(Map<String, dynamic> json) =>
      GenerationMetadata(
        generatedAt: json['generatedAt'] != null
            ? DateTime.parse(json['generatedAt'] as String)
            : DateTime.now(),
        contentType: json['contentType'] as String? ?? '',
        provider: json['provider'] as String? ?? '',
        promptVersion: json['promptVersion'] as String? ?? 'v2',
        schemaVersion: json['schemaVersion'] as int? ?? 1,
        generationTimeMs: json['generationTimeMs'] as int?,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
        fromCache: json['fromCache'] as bool? ?? false,
        isOffline: json['isOffline'] as bool? ?? false,
      );

  @override
  String toString() =>
      'GenerationMetadata(type: $contentType, provider: $provider, '
      'generated: ${generatedAt.toIso8601String()})';
}

/// Types of content that can be generated.
class ContentType {
  ContentType._();

  static const String course = 'course';
  static const String project = 'project';
  static const String portfolioEnhancement = 'portfolio_enhancement';
  static const String resumeEnhancement = 'resume_enhancement';
  static const String interviewQuestions = 'interview_questions';

  static const List<String> all = [
    course,
    project,
    portfolioEnhancement,
    resumeEnhancement,
    interviewQuestions,
  ];

  static String displayName(String type) {
    switch (type) {
      case course:
        return 'Course / Learning Path';
      case project:
        return 'Portfolio Project';
      case portfolioEnhancement:
        return 'Portfolio Enhancement';
      case resumeEnhancement:
        return 'Resume Enhancement';
      case interviewQuestions:
        return 'Interview Questions';
      default:
        return type;
    }
  }

  static String iconName(String type) {
    switch (type) {
      case course:
        return 'school';
      case project:
        return 'code';
      case portfolioEnhancement:
        return 'folder_special';
      case resumeEnhancement:
        return 'description';
      case interviewQuestions:
        return 'record_voice_over';
      default:
        return 'auto_awesome';
    }
  }
}
