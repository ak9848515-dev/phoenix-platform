import 'lesson_content.dart' show LessonContentSection;
import 'exercise.dart' show Exercise;
import 'quiz_question.dart' show QuizQuestion;

/// An individual lesson within an Academy module.
///
/// Immutable. Contains content sections, exercises, quizzes, and assessments.
/// Progress state is tracked separately in [LearningProgress].
class AcademyLesson {
  const AcademyLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.sections,
    this.exercises = const [],
    this.quizzes = const [],
    this.prerequisiteLessonIds = const [],
    this.tags = const [],
    required this.contentVersion,
  });

  /// Unique identifier.
  final String id;

  /// Lesson title.
  final String title;

  /// Short description.
  final String description;

  /// Estimated duration in minutes.
  final int durationMinutes;

  /// Content sections composing the lesson body.
  final List<LessonContentSection> sections;

  /// Optional exercises.
  final List<Exercise> exercises;

  /// Optional quiz questions.
  final List<QuizQuestion> quizzes;

  /// IDs of lessons that must be completed before this one.
  final List<String> prerequisiteLessonIds;

  /// Tags for categorisation (e.g. 'dart', 'flutter', 'async').
  final List<String> tags;

  /// Content version for cache invalidation.
  final int contentVersion;

  AcademyLesson copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    List<LessonContentSection>? sections,
    List<Exercise>? exercises,
    List<QuizQuestion>? quizzes,
    List<String>? prerequisiteLessonIds,
    List<String>? tags,
    int? contentVersion,
  }) {
    return AcademyLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sections: sections ?? this.sections,
      exercises: exercises ?? this.exercises,
      quizzes: quizzes ?? this.quizzes,
      prerequisiteLessonIds:
          prerequisiteLessonIds ?? this.prerequisiteLessonIds,
      tags: tags ?? this.tags,
      contentVersion: contentVersion ?? this.contentVersion,
    );
  }

  /// The total points available from all quizzes and exercises.
  int get totalPoints {
    final quizPoints = quizzes.fold(0, (sum, q) => sum + q.points);
    final exercisePoints = exercises.fold(0, (sum, e) => sum + e.points);
    return quizPoints + exercisePoints;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'sections': sections.map((s) => s.toMap()).toList(),
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'quizzes': quizzes.map((q) => q.toMap()).toList(),
      'prerequisiteLessonIds': prerequisiteLessonIds,
      'tags': tags,
      'contentVersion': contentVersion,
    };
  }

  factory AcademyLesson.fromMap(Map<String, dynamic> map) {
    return AcademyLesson(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      durationMinutes: map['durationMinutes'] as int,
      sections: (map['sections'] as List?)
              ?.map((s) => LessonContentSection.fromMap(
                  Map<String, dynamic>.from(s as Map)))
              .toList() ??
          [],
      exercises: (map['exercises'] as List?)
              ?.map((e) =>
                  Exercise.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      quizzes: (map['quizzes'] as List?)
              ?.map((q) =>
                  QuizQuestion.fromMap(Map<String, dynamic>.from(q as Map)))
              .toList() ??
          [],
      prerequisiteLessonIds:
          List<String>.from(map['prerequisiteLessonIds'] as List? ?? []),
      tags: List<String>.from(map['tags'] as List? ?? []),
      contentVersion: map['contentVersion'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademyLesson && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AcademyLesson(id: $id, title: $title, duration: ${durationMinutes}min)';
}
