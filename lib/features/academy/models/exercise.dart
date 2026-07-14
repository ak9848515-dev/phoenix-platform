/// The type of exercise within a lesson.
enum ExerciseType {
  /// A coding exercise where the user writes code.
  coding,

  /// A written/essay exercise where the user reflects.
  written,

  /// A reflection exercise for journaling.
  reflection,

  /// A practical task or project exercise.
  practical,
}

/// An exercise within a lesson.
///
/// Immutable. Supports coding, written, reflection, and practical exercises.
class Exercise {
  const Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.hints = const [],
    this.expectedOutput,
    this.solution,
    this.points = 20,
  });

  /// Unique identifier.
  final String id;

  /// Short title.
  final String title;

  /// Full description / prompt.
  final String description;

  /// The type of exercise.
  final ExerciseType type;

  /// Optional hints the user can reveal.
  final List<String> hints;

  /// Expected output (for coding exercises).
  final String? expectedOutput;

  /// Reference solution (for coding/written exercises).
  final String? solution;

  /// Points awarded for completion.
  final int points;

  Exercise copyWith({
    String? id,
    String? title,
    String? description,
    ExerciseType? type,
    List<String>? hints,
    String? expectedOutput,
    String? solution,
    int? points,
  }) {
    return Exercise(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      hints: hints ?? this.hints,
      expectedOutput: expectedOutput ?? this.expectedOutput,
      solution: solution ?? this.solution,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'hints': hints,
      'expectedOutput': expectedOutput,
      'solution': solution,
      'points': points,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: ExerciseType.values.firstWhere(
        (t) => t.name == (map['type'] as String),
        orElse: () => ExerciseType.written,
      ),
      hints: List<String>.from(map['hints'] as List? ?? []),
      expectedOutput: map['expectedOutput'] as String?,
      solution: map['solution'] as String?,
      points: map['points'] as int? ?? 20,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Exercise(id: $id, title: $title, type: $type)';
}
