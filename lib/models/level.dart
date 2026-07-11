import 'dart:convert';

import 'stage.dart';

/// Immutable representation of a level within an academy.
class Level {
  const Level({required this.id, required this.title, required this.stages});

  final String id;
  final String title;
  final List<Stage> stages;

  Level copyWith({String? id, String? title, List<Stage>? stages}) {
    return Level(
      id: id ?? this.id,
      title: title ?? this.title,
      stages: stages ?? this.stages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'stages': stages.map((stage) => stage.toMap()).toList(),
    };
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    final stagesData = map['stages'];

    return Level(
      id: map['id'] as String,
      title: map['title'] as String,
      stages: stagesData == null
          ? const <Stage>[]
          : (stagesData as List)
                .map(
                  (item) =>
                      Stage.fromMap(Map<String, dynamic>.from(item as Map)),
                )
                .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Level.fromJson(String source) =>
      Level.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Level &&
        other.id == id &&
        other.title == title &&
        other.stages.length == stages.length;
  }

  @override
  int get hashCode => Object.hash(id, title, Object.hashAll(stages));

  @override
  String toString() {
    return 'Level(id: $id, title: $title, stages: $stages)';
  }
}
