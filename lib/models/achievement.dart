import 'dart:convert';

/// Immutable representation of an earned achievement.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final String unlockedAt;

  Achievement copyWith({String? id, String? title, String? description, String? unlockedAt}) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'unlockedAt': unlockedAt,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      unlockedAt: map['unlockedAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Achievement.fromJson(String source) => Achievement.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Achievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.unlockedAt == unlockedAt;
  }

  @override
  int get hashCode => Object.hash(id, title, description, unlockedAt);

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, unlockedAt: $unlockedAt)';
  }
}
