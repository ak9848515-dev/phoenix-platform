import 'dart:convert';

import 'achievement.dart';
import 'knowledge_dna.dart';
import 'progress.dart';

/// Immutable representation of a user profile and their learning state.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.progress,
    required this.knowledgeDNA,
    required this.achievements,
  });

  final String id;
  final String name;
  final String email;
  final List<Progress> progress;
  final KnowledgeDNA knowledgeDNA;
  final List<Achievement> achievements;

  User copyWith({
    String? id,
    String? name,
    String? email,
    List<Progress>? progress,
    KnowledgeDNA? knowledgeDNA,
    List<Achievement>? achievements,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      progress: progress ?? this.progress,
      knowledgeDNA: knowledgeDNA ?? this.knowledgeDNA,
      achievements: achievements ?? this.achievements,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'progress': progress.map((item) => item.toMap()).toList(),
      'knowledgeDNA': knowledgeDNA.toMap(),
      'achievements': achievements.map((item) => item.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    final progressData = map['progress'];
    final achievementsData = map['achievements'];

    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      progress: progressData == null
          ? const <Progress>[]
          : (progressData as List)
              .map((item) => Progress.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList(),
      knowledgeDNA: KnowledgeDNA.fromMap(Map<String, dynamic>.from(map['knowledgeDNA'] as Map)),
      achievements: achievementsData == null
          ? const <Achievement>[]
          : (achievementsData as List)
              .map((item) => Achievement.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.progress.length == progress.length &&
        other.knowledgeDNA == knowledgeDNA &&
        other.achievements.length == achievements.length;
  }

  @override
  int get hashCode => Object.hash(id, name, email, Object.hashAll(progress), knowledgeDNA, Object.hashAll(achievements));

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, progress: $progress, knowledgeDNA: $knowledgeDNA, achievements: $achievements)';
  }
}
