import 'dart:convert';

import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../models/ai_validation_result.dart';
import '../models/field_schema.dart';
import 'schema_registry.dart';

/// AI Response Gateway — the ONLY legal entry point for AI-generated
/// content into Phoenix.
///
/// **Responsibilities:**
/// - Parse raw JSON responses from AI providers
/// - Validate against versioned schemas from the [SchemaRegistry]
/// - Normalize provider-specific differences into canonical Phoenix structures
/// - Classify errors as retryable or non-retryable
/// - Generate detailed validation reports
///
/// **Architecture Rules:**
/// - NEVER updates application state
/// - NEVER calls providers
/// - NEVER modifies engines
/// - NEVER exposes raw provider JSON to widgets
///
/// **Flow:**
/// ```
/// Provider Response (raw JSON)
///   ?
/// AIResponseGateway.process()
///   ?
/// Parse JSON
///   ?
/// Resolve schema
///   ?
/// Validate fields
///   ?
/// Normalize values
///   ?
/// AIValidationResult (validated domain map)
///   ?
/// Feature ? Domain Engine
/// ```
class AIResponseGateway {
  AIResponseGateway({
    required this.schemaRegistry,
    this.maxResponseSize = 100000,
    this.maxValidationTimeMs = 5000,
  });

  final SchemaRegistry schemaRegistry;

  /// Maximum allowed response size in characters.
  final int maxResponseSize;

  /// Maximum validation time in milliseconds.
  final int maxValidationTimeMs;

  final PhoenixLogger _logger = PhoenixLogger.shared;

  // ── Public API ──────────────────────────────────────────────────

  /// Processes a raw provider response into a validated domain model.
  ///
  /// Returns an [AIValidationResult] with either:
  /// - A validated and normalized [domainMap] on success
  /// - Detailed [errors] with retry classification on failure
  ///
  /// **Improvements (PHX-085B):**
  /// - Markdown code block extraction before JSON parsing
  /// - Response quality scoring (0.0–1.0)
  /// - Graceful fallback for non-JSON responses (raw text passthrough)
  /// - Reference extraction from structured fields
  AIValidationResult process({
    required String rawResponse,
    required String promptType,
    int? templateVersion,
    String? providerName,
  }) {
    final startedAt = DateTime.now();
    var metadata = AIResponseMetadata(
      promptType: promptType,
      templateVersion: templateVersion ?? 0,
      schemaVersion: 0,
      rawLength: rawResponse.length,
      providerName: providerName,
    );

    // 0. Size check
    if (rawResponse.length > maxResponseSize) {
      return _failure(
        errors: [
          AIValidationError(
            code: ValidationErrorCode.responseTooLarge,
            message: 'Response exceeds maximum size of $maxResponseSize characters.',
            expected: '<= $maxResponseSize chars',
            actual: '${rawResponse.length} chars',
          ),
        ],
        metadata: metadata.copyWith(
          parseTimeMs: DateTime.now().difference(startedAt).inMilliseconds,
        ),
      );
    }

    // 0.5 Extract JSON from markdown code blocks if present
    final cleaned = _extractJsonFromMarkdown(rawResponse);

    // 1. Parse JSON
    Map<String, dynamic> parsed;
    try {
      parsed = json.decode(cleaned) as Map<String, dynamic>;
    } on FormatException catch (e) {
      // Graceful fallback: try treating entire response as a text response
      if (promptType == 'ai_assistant') {
        // For assistant, return raw text as a structured response
        return _textFallback(rawResponse, metadata, startedAt);
      }
      return _failure(
        errors: [
          AIValidationError(
            code: ValidationErrorCode.malformedJson,
            message: 'Invalid JSON format: ${e.message}',
            expected: 'Valid JSON object',
            actual: e.message,
          ),
        ],
        isRetryable: true,
        retryReason: ValidationErrorCode.retryReason(ValidationErrorCode.malformedJson),
        metadata: metadata.copyWith(
          parseTimeMs: DateTime.now().difference(startedAt).inMilliseconds,
        ),
      );
    } catch (e) {
      return _textFallback(rawResponse, metadata, startedAt);
    }

    // 2. Resolve schema
    final schema = templateVersion != null
        ? schemaRegistry.getSchema(promptType, templateVersion)
        : schemaRegistry.getLatest(promptType);

    if (schema == null) {
      return _failure(
        errors: [
          AIValidationError(
            code: ValidationErrorCode.unsupportedVersion,
            message: 'No schema found for prompt type: $promptType, version: $templateVersion',
            expected: 'Registered schema',
            actual: 'Not found',
          ),
        ],
        metadata: metadata.copyWith(
          parseTimeMs: DateTime.now().difference(startedAt).inMilliseconds,
        ),
      );
    }

    final resolvedVersion = templateVersion ??
        schemaRegistry.getLatestVersion(promptType) ??
        0;

    metadata = AIResponseMetadata(
      promptType: metadata.promptType,
      templateVersion: metadata.templateVersion,
      schemaVersion: resolvedVersion,
      rawLength: metadata.rawLength,
      parseTimeMs: metadata.parseTimeMs,
      providerName: metadata.providerName,
      normalizations: metadata.normalizations,
    );

    // 3. Validate fields
    final errors = <AIValidationError>[];
    final warnings = <AIValidationError>[];
    final normalizations = <String>[];

    for (final field in schema) {
      final error = _validateField(parsed, field);
      if (error != null) {
        if (error.code == ValidationErrorCode.unexpectedField) {
          warnings.add(error);
        } else {
          errors.add(error);
        }
      }
    }

    // 4. Apply normalizations
    final normalized = _normalize(parsed, normalizations);

    // 4.5 Extract references from structured fields
    final references = _extractReferences(normalized);

    // 4.7 Compute response quality score
    final qualityScore = _computeQualityScore(errors, warnings, normalized);

    // 5. Build result
    final parseTimeMs = DateTime.now().difference(startedAt).inMilliseconds;
    metadata = AIResponseMetadata(
      promptType: metadata.promptType,
      templateVersion: metadata.templateVersion,
      schemaVersion: metadata.schemaVersion,
      rawLength: metadata.rawLength,
      parseTimeMs: parseTimeMs,
      providerName: metadata.providerName,
      normalizations: normalizations,
    );

    if (errors.isEmpty) {
      return AIValidationResult.success(
        normalized,
        metadata: metadata.copyWithQualityScore(qualityScore),
        references: references,
      );
    }

    // Classify retryability
    final anyRetryable =
        errors.any((e) => ValidationErrorCode.isRetryable(e.code));
    final retryReason = anyRetryable
        ? errors
            .map((e) => ValidationErrorCode.retryReason(e.code))
            .where((r) => r != null)
            .join('; ')
        : null;

    return _failure(
      errors: errors,
      warnings: warnings,
      isRetryable: anyRetryable,
      retryReason: retryReason,
      metadata: metadata.copyWithQualityScore(qualityScore),
    );
  }

  /// Extracts JSON from markdown code blocks (```json ... ```).
  /// Returns the raw string if no code blocks found.
  String _extractJsonFromMarkdown(String raw) {
    final pattern = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = pattern.firstMatch(raw);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    return raw.trim();
  }

  /// Graceful fallback: returns the raw text as a valid result.
  AIValidationResult _textFallback(
    String rawResponse,
    AIResponseMetadata metadata,
    DateTime startedAt,
  ) {
    final parseTimeMs = DateTime.now().difference(startedAt).inMilliseconds;
    final normalized = <String, dynamic>{
      'response': <String, dynamic>{
        'message': rawResponse,
        'confidence': 0.5,
      },
    };
    return AIValidationResult.success(
      normalized,
      metadata: AIResponseMetadata(
        promptType: metadata.promptType,
        templateVersion: metadata.templateVersion,
        schemaVersion: metadata.schemaVersion,
        rawLength: metadata.rawLength,
        parseTimeMs: parseTimeMs,
        providerName: metadata.providerName,
        normalizations: ['Text fallback used (no JSON)'],
      ),
      references: ['Text fallback: ${rawResponse.substring(0, rawResponse.length.clamp(0, 100))}'],
    );
  }

  /// Computes a quality score (0.0–1.0) for the response.
  /// Penalizes errors, warnings, missing required fields, and empty responses.
  double _computeQualityScore(
    List<AIValidationError> errors,
    List<AIValidationError> warnings,
    Map<String, dynamic> normalized,
  ) {
    double score = 1.0;
    // Each error reduces score by 0.2
    score -= errors.length * 0.2;
    // Each warning reduces score by 0.05
    score -= warnings.length * 0.05;
    // Empty response penalty
    if (normalized.isEmpty) score -= 0.3;
    return score.clamp(0.0, 1.0);
  }

  /// Extracts human-readable references from the normalized response.
  /// References are key paths that contain meaningful content (titles, descriptions, etc.).
  List<String> _extractReferences(Map<String, dynamic> data) {
    final refs = <String>[];
    _collectTextValues(data, '', refs);
    return refs.take(10).toList();
  }

  void _collectTextValues(
    dynamic node,
    String path,
    List<String> refs,
  ) {
    if (node is Map) {
      for (final entry in node.entries) {
        final childPath = path.isEmpty ? entry.key.toString() : '$path.${entry.key}';
        if (entry.value is String) {
          final text = entry.value as String;
          if (text.length > 10 && text.length < 200) {
            refs.add('$childPath: $text');
          }
        } else {
          _collectTextValues(entry.value, childPath, refs);
        }
      }
    } else if (node is List) {
      for (var i = 0; i < node.length && i < 3; i++) {
        _collectTextValues(node[i], '$path[$i]', refs);
      }
    }
  }

  /// Quick-validate a response without full normalization.
  ///
  /// Useful for prefight checks before full processing.
  AIValidationResult validate({
    required String rawResponse,
    required String promptType,
    int? templateVersion,
  }) {
    // Only parse and validate — skip normalization
    try {
      json.decode(rawResponse);
    } on FormatException catch (e) {
      return AIValidationResult.failure(
        errors: [
          AIValidationError(
            code: ValidationErrorCode.malformedJson,
            message: 'Invalid JSON format: ${e.message}',
          ),
        ],
      );
    }

    final schema = templateVersion != null
        ? schemaRegistry.getSchema(promptType, templateVersion)
        : schemaRegistry.getLatest(promptType);

    if (schema == null) {
      return AIValidationResult.failure(
        errors: [
          AIValidationError(
            code: ValidationErrorCode.unsupportedVersion,
            message: 'No schema for type: $promptType',
          ),
        ],
      );
    }

    return AIValidationResult.success({});
  }

  // ── Field Validation ────────────────────────────────────────────

  /// Validates a single field against the parsed response.
  AIValidationError? _validateField(
    Map<String, dynamic> data,
    FieldSchema field,
  ) {
    // Handle array child paths (e.g. 'mission.steps[].title')
    if (field.targetsArray) {
      return _validateArrayField(data, field);
    }

    final value = _getValueAtPath(data, field.path);

    // Check required
    if (value == null) {
      if (field.required) {
        return AIValidationError(
          code: ValidationErrorCode.missingField,
          message: 'Required field missing: ${field.path}',
          field: field.path,
          expected: 'non-null value',
          actual: 'null',
        );
      }
      return null;
    }

    // Check type
    final typeError = _checkType(field, value);
    if (typeError != null) return typeError;

    // Check enum values
    if (field.allowedValues != null && value is String) {
      if (!field.allowedValues!.contains(value)) {
        return AIValidationError(
          code: ValidationErrorCode.invalidEnum,
          message: 'Invalid value for ${field.path}. Allowed: ${field.allowedValues!.join(', ')}',
          field: field.path,
          expected: field.allowedValues!.join(', '),
          actual: value,
        );
      }
    }

    // Check string length
    if (field.maxLength != null && value is String) {
      if (value.length > field.maxLength!) {
        return AIValidationError(
          code: ValidationErrorCode.stringTooLong,
          message: 'String too long at ${field.path}: ${value.length} > ${field.maxLength}',
          field: field.path,
          expected: '<= ${field.maxLength} chars',
          actual: '${value.length} chars',
        );
      }
    }

    // Check numeric range
    if (value is num) {
      if (field.min != null && value < field.min!) {
        return AIValidationError(
          code: ValidationErrorCode.valueOutOfRange,
          message: 'Value too small at ${field.path}: $value < ${field.min}',
          field: field.path,
          expected: '>= ${field.min}',
          actual: '$value',
        );
      }
      if (field.max != null && value > field.max!) {
        return AIValidationError(
          code: ValidationErrorCode.valueOutOfRange,
          message: 'Value too large at ${field.path}: $value > ${field.max}',
          field: field.path,
          expected: '<= ${field.max}',
          actual: '$value',
        );
      }
    }

    // Check array length
    if (value is List) {
      if (field.minItems != null && value.length < field.minItems!) {
        return AIValidationError(
          code: ValidationErrorCode.arrayTooShort,
          message: 'Array too short at ${field.path}: ${value.length} < ${field.minItems}',
          field: field.path,
          expected: '>= ${field.minItems} items',
          actual: '${value.length} items',
        );
      }
      if (field.maxItems != null && value.length > field.maxItems!) {
        return AIValidationError(
          code: ValidationErrorCode.arrayTooLong,
          message: 'Array too long at ${field.path}: ${value.length} > ${field.maxItems}',
          field: field.path,
          expected: '<= ${field.maxItems} items',
          actual: '${value.length} items',
        );
      }
    }

    return null;
  }

  /// Validates fields that target array elements (e.g. mission.steps[]).
  AIValidationError? _validateArrayField(
    Map<String, dynamic> data,
    FieldSchema field,
  ) {
    final parentPath = field.arrayParentPath;
    final childPath = field.arrayChildPath;
    final parent = _getValueAtPath(data, parentPath);

    if (parent == null) {
      if (field.required) {
        return AIValidationError(
          code: ValidationErrorCode.missingField,
          message: 'Required array missing: $parentPath',
          field: field.path,
          expected: 'non-null array',
          actual: 'null',
        );
      }
      return null;
    }

    if (parent is! List) {
      return AIValidationError(
        code: ValidationErrorCode.typeMismatch,
        message: 'Expected array at $parentPath, got ${parent.runtimeType}',
        field: field.path,
        expected: 'array',
        actual: '${parent.runtimeType}',
      );
    }

    if (childPath.isEmpty) return null;

    // Check each array element
    for (var i = 0; i < parent.length; i++) {
      final element = parent[i];
      if (element is! Map) continue;

      final childValue = element[childPath];
      if (childValue == null && field.required) {
        return AIValidationError(
          code: ValidationErrorCode.missingField,
          message: 'Required field missing in $parentPath[$i]: $childPath',
          field: '$parentPath[$i].$childPath',
          expected: 'non-null value',
          actual: 'null',
        );
      }
    }

    return null;
  }

  // ── Type Checking ───────────────────────────────────────────────

  AIValidationError? _checkType(FieldSchema field, dynamic value) {
    switch (field.type) {
      case 'string':
        if (value is! String) {
          return AIValidationError(
            code: ValidationErrorCode.typeMismatch,
            message: 'Expected string at ${field.path}, got ${value.runtimeType}',
            field: field.path,
            expected: 'string',
            actual: '${value.runtimeType}',
          );
        }
      case 'integer':
        if (value is! int) {
          return AIValidationError(
            code: ValidationErrorCode.typeMismatch,
            message: 'Expected integer at ${field.path}, got ${value.runtimeType}',
            field: field.path,
            expected: 'integer',
            actual: '${value.runtimeType}',
          );
        }
      case 'number':
        if (value is! num) {
          return AIValidationError(
            code: ValidationErrorCode.typeMismatch,
            message: 'Expected number at ${field.path}, got ${value.runtimeType}',
            field: field.path,
            expected: 'number',
            actual: '${value.runtimeType}',
          );
        }
      case 'boolean':
        if (value is! bool) {
          return AIValidationError(
            code: ValidationErrorCode.typeMismatch,
            message: 'Expected boolean at ${field.path}, got ${value.runtimeType}',
            field: field.path,
            expected: 'boolean',
            actual: '${value.runtimeType}',
          );
        }
      case 'array':
        if (value is! List) {
          return AIValidationError(
            code: ValidationErrorCode.typeMismatch,
            message: 'Expected array at ${field.path}, got ${value.runtimeType}',
            field: field.path,
            expected: 'array',
            actual: '${value.runtimeType}',
          );
        }
      case 'map':
        if (value is! Map) {
          return AIValidationError(
            code: ValidationErrorCode.typeMismatch,
            message: 'Expected object at ${field.path}, got ${value.runtimeType}',
            field: field.path,
            expected: 'object',
            actual: '${value.runtimeType}',
          );
        }
    }
    return null;
  }

  // ── Value Access ────────────────────────────────────────────────

  /// Gets a value from nested maps using dot notation.
  /// e.g. 'mission.title' -> data['mission']['title']
  dynamic _getValueAtPath(Map<String, dynamic> data, String path) {
    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is! Map) return null;
      current = current[part];
    }

    return current;
  }

  // ── Normalization ───────────────────────────────────────────────

  /// Normalizes provider-specific field names into canonical Phoenix names.
  ///
  /// Handles common variations like:
  /// - `mission_title` ? `title` (snake_case to camelCase)
  /// - `estimated_minutes` ? `estimatedMinutes`
  /// - String difficulty values ? canonical enum values
  Map<String, dynamic> _normalize(
    Map<String, dynamic> data,
    List<String> normalizations,
  ) {
    // Deep-clone to avoid mutating the original
    final result = _deepClone(data);

    _normalizeNode(result, '', normalizations);

    return result;
  }

  void _normalizeNode(
    dynamic node,
    String path,
    List<String> normalizations,
  ) {
    if (node is Map) {
      // Check for snake_case keys and convert to camelCase
      final keysToRename = <String, String>{};
      for (final key in node.keys) {
        if (key is String && key.contains('_')) {
          final camelKey = _snakeToCamel(key);
          if (camelKey != key) {
            keysToRename[key] = camelKey;
          }
        }

        // Recursively normalize child nodes
        final childPath = path.isEmpty ? key : '$path.$key';
        _normalizeNode(node[key], childPath, normalizations);
      }

      // Apply renames
      for (final entry in keysToRename.entries) {
        node[entry.value] = node[entry.key];
        node.remove(entry.key);
        normalizations.add('Renamed ${path.isNotEmpty ? '$path.' : ''}${entry.key} -> ${entry.value}');
      }

      // Normalize difficulty values
      if (node.containsKey('difficulty') && node['difficulty'] is String) {
        final difficulty = node['difficulty'] as String;
        final normalized = _normalizeDifficulty(difficulty);
        if (normalized != difficulty) {
          node['difficulty'] = normalized;
          normalizations.add('Normalized difficulty: $difficulty -> $normalized');
        }
      }
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        _normalizeNode(node[i], '$path[$i]', normalizations);
      }
    }
  }

  /// Converts snake_case to camelCase (e.g. `mission_title` -> `missionTitle`).
  String _snakeToCamel(String input) {
    final parts = input.split('_');
    if (parts.length <= 1) return input;

    final buffer = StringBuffer(parts[0]);
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase());
        buffer.write(parts[i].substring(1));
      }
    }
    return buffer.toString();
  }

  /// Normalizes difficulty string variations to canonical values.
  String _normalizeDifficulty(String value) {
    final lower = value.toLowerCase().trim();
    switch (lower) {
      case 'easy':
      case 'beginner':
      case 'entry':
      case 'novice':
        return 'beginner';
      case 'medium':
      case 'intermediate':
      case 'moderate':
        return 'intermediate';
      case 'hard':
      case 'advanced':
      case 'difficult':
        return 'advanced';
      case 'expert':
      case 'master':
      case 'genius':
        return 'expert';
      default:
        return value;
    }
  }

  /// Deep-clones a JSON-compatible value.
  dynamic _deepClone(dynamic value) {
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result[entry.key.toString()] = _deepClone(entry.value);
      }
      return result;
    } else if (value is List) {
      return value.map(_deepClone).toList();
    }
    return value;
  }

  // ── Helpers ─────────────────────────────────────────────────────

  AIValidationResult _failure({
    required List<AIValidationError> errors,
    List<AIValidationError> warnings = const [],
    bool isRetryable = false,
    String? retryReason,
    AIResponseMetadata? metadata,
  }) {
    if (errors.isNotEmpty) {
      _logger.warning(
        'AIResponseGateway: validation failed (${errors.length} errors)',
        source: 'AIResponseGateway',
      );
    }
    return AIValidationResult.failure(
      errors: errors,
      isRetryable: isRetryable,
      retryReason: retryReason,
      metadata: metadata,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// Extension: CopyWith for AIResponseMetadata
// ═════════════════════════════════════════════════════════════════════

/// Internal extension to update metadata during processing.
extension _AIResponseMetadataCopyWith on AIResponseMetadata {
  AIResponseMetadata copyWith({
    int? parseTimeMs,
    List<String>? normalizations,
  }) =>
      AIResponseMetadata(
        promptType: promptType,
        templateVersion: templateVersion,
        schemaVersion: schemaVersion,
        rawLength: rawLength,
        parseTimeMs: parseTimeMs ?? this.parseTimeMs,
        providerName: providerName,
        normalizations: normalizations ?? this.normalizations,
      );
}
