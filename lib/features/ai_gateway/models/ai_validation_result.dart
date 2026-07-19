/// Result of validating and normalizing an AI provider response.
///
/// Immutable. Contains the validated domain model as a [Map], or
/// detailed error information if validation failed.
class AIValidationResult {
  const AIValidationResult({
    this.isValid = false,
    this.isRetryable = false,
    this.domainMap,
    this.errors = const [],
    this.metadata,
    this.retryReason,
    this.references = const [],
    this.qualityScore = 0.0,
  });



  /// Whether the response passed all validation checks.
  final bool isValid;

  /// Whether the error is retryable (suggest re-sending the prompt).
  final bool isRetryable;

  /// The validated and normalized domain model as a [Map].
  ///
  /// Only set when [isValid] is `true`.
  final Map<String, dynamic>? domainMap;

  /// Validation errors (only set when [isValid] is `false`).
  final List<AIValidationError> errors;

  /// Metadata about the validation process.
  final AIResponseMetadata? metadata;

  /// Human-readable reason suggesting a retry, if applicable.
  final String? retryReason;

  /// Extracted references from the response content.
  final List<String> references;

  /// Quality score (0.0–1.0) for the response.
  final double qualityScore;

  /// Creates a successful validation result.
  factory AIValidationResult.success(
    Map<String, dynamic> domainMap, {
    AIResponseMetadata? metadata,
    List<String> references = const [],
    double qualityScore = 1.0,
  }) =>
      AIValidationResult(
        isValid: true,
        domainMap: domainMap,
        metadata: metadata,
        references: references,
        qualityScore: qualityScore,
      );

  /// Creates a failed validation result.
  factory AIValidationResult.failure({
    required List<AIValidationError> errors,
    bool isRetryable = false,
    String? retryReason,
    AIResponseMetadata? metadata,
    List<String> references = const [],
    double qualityScore = 0.0,
  }) =>
      AIValidationResult(
        isValid: false,
        isRetryable: isRetryable,
        errors: errors,
        retryReason: retryReason,
        metadata: metadata,
        references: references,
        qualityScore: qualityScore,
      );

  @override
  String toString() =>
      'AIValidationResult(valid: $isValid, retryable: $isRetryable, '
      'errors: ${errors.length}, metadata: $metadata)';
}

/// A single validation error with actionable details.
///
/// Designed for both developer debugging and potential UI display.
class AIValidationError {
  const AIValidationError({
    required this.code,
    required this.message,
    this.field,
    this.expected,
    this.actual,
  });

  /// Error code for programmatic handling.
  final String code;

  /// Human-readable error message.
  final String message;

  /// The field path that failed validation (if applicable).
  final String? field;

  /// Expected value or description.
  final String? expected;

  /// Actual value or description.
  final String? actual;

  @override
  String toString() =>
      'AIValidationError(code: $code, field: $field, message: $message)';
}

/// Comprehensive validation report for logging and debugging.
class ValidationReport {
  const ValidationReport({
    required this.promptType,
    required this.templateVersion,
    required this.totalChecks,
    required this.passedChecks,
    required this.failedChecks,
    required this.startedAt,
    required this.completedAt,
    this.errors = const [],
    this.warnings = const [],
    this.result,
  });

  /// The prompt type that was validated.
  final String promptType;

  /// Template version used for validation.
  final int templateVersion;

  /// Total number of validation checks performed.
  final int totalChecks;

  /// Number of checks that passed.
  final int passedChecks;

  /// Number of checks that failed.
  final int failedChecks;

  /// When validation started.
  final DateTime startedAt;

  /// When validation completed.
  final DateTime completedAt;

  /// Validation errors.
  final List<AIValidationError> errors;

  /// Validation warnings (non-blocking).
  final List<AIValidationError> warnings;

  /// The final validation result.
  final AIValidationResult? result;

  /// Duration of validation in milliseconds.
  int get durationMs =>
      completedAt.difference(startedAt).inMilliseconds;

  /// Whether validation passed with zero errors.
  bool get isPassed => failedChecks == 0;

  /// Whether there are any warnings.
  bool get hasWarnings => warnings.isNotEmpty;

  @override
  String toString() =>
      'ValidationReport(type: $promptType, checks: $passedChecks/$totalChecks, '
      'errors: ${errors.length}, duration: ${durationMs}ms)';
}

/// Metadata about a validated AI response.
class AIResponseMetadata {
  const AIResponseMetadata({
    required this.promptType,
    required this.templateVersion,
    required this.schemaVersion,
    this.rawLength = 0,
    this.parseTimeMs = 0,
    this.providerName,
    this.normalizations = const [],
    this.qualityScore = 1.0,
  });

  /// The prompt type of the validated response.
  final String promptType;

  /// Template version used.
  final int templateVersion;

  /// Schema version used for validation.
  final int schemaVersion;

  /// Length of the raw response in characters.
  final int rawLength;

  /// Time taken to parse and validate (ms).
  final int parseTimeMs;

  /// Name of the provider that generated the response.
  final String? providerName;

  /// List of normalizations that were applied.
  final List<String> normalizations;

  /// Quality score (0.0–1.0) for the response.
  final double qualityScore;

  /// Creates a copy with an updated quality score.
  AIResponseMetadata copyWithQualityScore(double score) =>
      AIResponseMetadata(
        promptType: promptType,
        templateVersion: templateVersion,
        schemaVersion: schemaVersion,
        rawLength: rawLength,
        parseTimeMs: parseTimeMs,
        providerName: providerName,
        normalizations: normalizations,
        qualityScore: score,
      );

  @override
  String toString() =>
      'AIResponseMetadata(type: $promptType, template: v$templateVersion, '
      'schema: v$schemaVersion, raw: ${rawLength}chars, parse: ${parseTimeMs}ms, '
      'quality: $qualityScore)';
}

// ═════════════════════════════════════════════════════════════════════
// Error Codes
// ═════════════════════════════════════════════════════════════════════

/// Canonical validation error codes.
class ValidationErrorCode {
  ValidationErrorCode._();

  static const String malformedJson = 'MALFORMED_JSON';
  static const String missingField = 'MISSING_FIELD';
  static const String typeMismatch = 'TYPE_MISMATCH';
  static const String unexpectedField = 'UNEXPECTED_FIELD';
  static const String invalidEnum = 'INVALID_ENUM';
  static const String arrayTooShort = 'ARRAY_TOO_SHORT';
  static const String arrayTooLong = 'ARRAY_TOO_LONG';
  static const String stringTooLong = 'STRING_TOO_LONG';
  static const String valueOutOfRange = 'VALUE_OUT_OF_RANGE';
  static const String unsupportedVersion = 'UNSUPPORTED_VERSION';
  static const String responseTooLarge = 'RESPONSE_TOO_LARGE';
  static const String unknownType = 'UNKNOWN_TYPE';
  static const String validationTimeout = 'VALIDATION_TIMEOUT';

  /// Whether an error code indicates a retryable error.
  static bool isRetryable(String code) {
    switch (code) {
      case malformedJson:
      case missingField:
      case invalidEnum:
      case responseTooLarge:
        return true;
      default:
        return false;
    }
  }

  /// Returns a human-readable retry suggestion for an error code.
  static String? retryReason(String code) {
    switch (code) {
      case malformedJson:
        return 'Provider returned malformed JSON. Retry may help.';
      case missingField:
        return 'Required field missing. Consider adding more context.';
      case invalidEnum:
        return 'Invalid enum value. The provider may need clearer instructions.';
      case responseTooLarge:
        return 'Response exceeds maximum size. Consider reducing context.';
      default:
        return null;
    }
  }
}
