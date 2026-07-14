import 'dart:convert';

import 'lesson.dart';

/// Legacy curriculum mission DTO used by the repository layer.
///
/// Represents a group of lessons within a stage of the old Academy hierarchy.
/// Distinguished from [mission_engine.Mission] by name for clarity.
class CurriculumMission {
  const CurriculumMission({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final List<Lesson> lessons;

  CurriculumMission copyWith({
    String? id,
    String? title,
    String? description,
    List<Lesson>? lessons,
  }) {
    return CurriculumMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      lessons: lessons ?? this.lessons,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'lessons': lessons.map((lesson) => lesson.toMap()).toList(),
    };
  }

  factory CurriculumMission.fromMap(Map<String, dynamic> map) {
    final lessonsData = map['lessons'];

    return CurriculumMission(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      lessons: lessonsData == null
          ? const <Lesson>[]
          : (lessonsData as List)
                .map(
                  (item) =>
                      Lesson.fromMap(Map<String, dynamic>.from(item as Map)),
                )
                .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CurriculumMission.fromJson(String source) =>
      CurriculumMission.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CurriculumMission &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.lessons.length == lessons.length;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, Object.hashAll(lessons));

  @override
  String toString() {
    return 'Mission(id: $id, title: $title, description: $description, lessons: $lessons)';
  }
}
