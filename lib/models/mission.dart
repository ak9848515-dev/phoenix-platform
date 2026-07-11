import 'dart:convert';

import 'lesson.dart';

/// Immutable representation of a mission composed of lessons.
class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final List<Lesson> lessons;

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    List<Lesson>? lessons,
  }) {
    return Mission(
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

  factory Mission.fromMap(Map<String, dynamic> map) {
    final lessonsData = map['lessons'];

    return Mission(
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

  factory Mission.fromJson(String source) =>
      Mission.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Mission &&
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
