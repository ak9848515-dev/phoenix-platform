/// Defines the expected structure and constraints for a single field
/// in an AI response JSON payload.
///
/// Used by [SchemaRegistry] to define what valid responses look like,
/// and by [AIResponseGateway] to validate responses against those rules.
///
/// Supports nested paths (e.g. 'mission.steps[].title') for deep validation.
class FieldSchema {
  const FieldSchema({
    required this.path,
    required this.type,
    this.required = false,
    this.min,
    this.max,
    this.minItems,
    this.maxItems,
    this.maxLength,
    this.allowedValues,
  });

  /// Dot-notation path to the field (e.g. 'mission.title', 'mission.steps[].title').
  final String path;

  /// Expected Dart type: 'string', 'integer', 'number', 'boolean', 'array', 'map'.
  final String type;

  /// Whether this field is required.
  final bool required;

  /// Minimum numeric value (for integer/number).
  final num? min;

  /// Maximum numeric value (for integer/number).
  final num? max;

  /// Minimum array length (for array).
  final int? minItems;

  /// Maximum array length (for array).
  final int? maxItems;

  /// Maximum string length (for string).
  final int? maxLength;

  /// Allowed enum values (for string with restricted values).
  final List<String>? allowedValues;

  // ── Factory constructors ─────────────────────────────────────────

  const FieldSchema.string(
    String path, {
    bool required = false,
    int? maxLength,
    List<String>? allowedValues,
  }) : this(
          path: path,
          type: 'string',
          required: required,
          maxLength: maxLength,
          allowedValues: allowedValues,
        );

  const FieldSchema.integer(
    String path, {
    bool required = false,
    int? min,
    int? max,
  }) : this(
          path: path,
          type: 'integer',
          required: required,
          min: min,
          max: max,
        );

  const FieldSchema.number(
    String path, {
    bool required = false,
    num? min,
    num? max,
  }) : this(
          path: path,
          type: 'number',
          required: required,
          min: min,
          max: max,
        );

  const FieldSchema.boolean(
    String path, {
    bool required = false,
  }) : this(
          path: path,
          type: 'boolean',
          required: required,
        );

  const FieldSchema.array(
    String path, {
    bool required = false,
    int? minItems,
    int? maxItems,
  }) : this(
          path: path,
          type: 'array',
          required: required,
          minItems: minItems,
          maxItems: maxItems,
        );

  /// Whether this path targets an array element (contains `[]`).
  bool get targetsArray => path.contains('[]');

  /// The parent path without the array element notation.
  /// e.g. 'mission.steps[].title' -> 'mission.steps'
  String get arrayParentPath {
    final idx = path.indexOf('[]');
    if (idx == -1) return path;
    return path.substring(0, idx);
  }

  /// The child path after the array notation.
  /// e.g. 'mission.steps[].title' -> 'title'
  String get arrayChildPath {
    final idx = path.indexOf('[]');
    if (idx == -1) return '';
    return path.substring(idx + 3); // skip '[]' and '.'
  }

  /// The top-level key (first segment of the path).
  String get rootKey {
    final dotIdx = path.indexOf('.');
    if (dotIdx == -1) return path;
    return path.substring(0, dotIdx);
  }

  @override
  String toString() =>
      'FieldSchema($path: $type${required ? ', required' : ''})';
}
