import 'academy_lesson.dart' show AcademyLesson;

/// A module within a learning path.
///
/// Immutable. Modules group related lessons into a coherent unit.
class AcademyModule {
  const AcademyModule({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
    this.order = 0,
    this.iconName = 'school',
  });

  /// Unique identifier.
  final String id;

  /// Module title.
  final String title;

  /// Short description of what this module covers.
  final String description;

  /// Lessons in this module, in order.
  final List<AcademyLesson> lessons;

  /// Display order within the learning path.
  final int order;

  /// Material icon name for the module.
  final String iconName;

  /// Total estimated duration across all lessons.
  int get totalDurationMinutes =>
      lessons.fold(0, (sum, l) => sum + l.durationMinutes);

  /// Total points available across all lessons.
  int get totalPoints => lessons.fold(0, (sum, l) => sum + l.totalPoints);

  AcademyModule copyWith({
    String? id,
    String? title,
    String? description,
    List<AcademyLesson>? lessons,
    int? order,
    String? iconName,
  }) {
    return AcademyModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      lessons: lessons ?? this.lessons,
      order: order ?? this.order,
      iconName: iconName ?? this.iconName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lessons': lessons.map((l) => l.toMap()).toList(),
      'order': order,
      'iconName': iconName,
    };
  }

  factory AcademyModule.fromMap(Map<String, dynamic> map) {
    return AcademyModule(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      lessons: (map['lessons'] as List?)
              ?.map((l) =>
                  AcademyLesson.fromMap(Map<String, dynamic>.from(l as Map)))
              .toList() ??
          [],
      order: map['order'] as int? ?? 0,
      iconName: map['iconName'] as String? ?? 'school',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademyModule && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AcademyModule(id: $id, title: $title, lessons: ${lessons.length})';
}
