import 'dart:convert';

import 'mission.dart';

/// Immutable representation of a stage within a level.
class Stage {
  const Stage({
    required this.id,
    required this.title,
    required this.missions,
  });

  final String id;
  final String title;
  final List<Mission> missions;

  Stage copyWith({String? id, String? title, List<Mission>? missions}) {
    return Stage(
      id: id ?? this.id,
      title: title ?? this.title,
      missions: missions ?? this.missions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'missions': missions.map((mission) => mission.toMap()).toList(),
    };
  }

  factory Stage.fromMap(Map<String, dynamic> map) {
    final missionsData = map['missions'];

    return Stage(
      id: map['id'] as String,
      title: map['title'] as String,
      missions: missionsData == null
          ? const <Mission>[]
          : (missionsData as List)
              .map((item) => Mission.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Stage.fromJson(String source) => Stage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Stage && other.id == id && other.title == title && other.missions.length == missions.length;
  }

  @override
  int get hashCode => Object.hash(id, title, Object.hashAll(missions));

  @override
  String toString() {
    return 'Stage(id: $id, title: $title, missions: $missions)';
  }
}
