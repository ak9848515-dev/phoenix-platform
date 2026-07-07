import 'dart:convert';

import 'level.dart';

/// Immutable representation of a learning academy and its levels.
class Academy {
  const Academy({
    required this.id,
    required this.title,
    required this.description,
    required this.levels,
  });

  final String id;
  final String title;
  final String description;
  final List<Level> levels;

  Academy copyWith({
    String? id,
    String? title,
    String? description,
    List<Level>? levels,
  }) {
    return Academy(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      levels: levels ?? this.levels,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'levels': levels.map((level) => level.toMap()).toList(),
    };
  }

  factory Academy.fromMap(Map<String, dynamic> map) {
    final levelsData = map['levels'];

    return Academy(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      levels: levelsData == null
          ? const <Level>[]
          : (levelsData as List)
              .map((item) => Level.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Academy.fromJson(String source) => Academy.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Academy &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.levels.length == levels.length;
  }

  @override
  int get hashCode => Object.hash(id, title, description, Object.hashAll(levels));

  @override
  String toString() {
    return 'Academy(id: $id, title: $title, description: $description, levels: $levels)';
  }
}
