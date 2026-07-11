import 'dart:convert';

/// Immutable representation of a lesson within a mission.
class Lesson {
  const Lesson({required this.id, required this.title, required this.duration});

  final String id;
  final String title;
  final String duration;

  Lesson copyWith({String? id, String? title, String? duration}) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'title': title, 'duration': duration};
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      title: map['title'] as String,
      duration: map['duration'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Lesson.fromJson(String source) =>
      Lesson.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Lesson &&
        other.id == id &&
        other.title == title &&
        other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(id, title, duration);

  @override
  String toString() {
    return 'Lesson(id: $id, title: $title, duration: $duration)';
  }
}
