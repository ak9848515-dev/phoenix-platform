import 'dart:convert';

import 'academy.dart';

/// Immutable representation of a plugin that can reference an academy.
class Plugin {
  const Plugin({
    required this.id,
    required this.name,
    required this.description,
    required this.academy,
  });

  final String id;
  final String name;
  final String description;
  final Academy academy;

  Plugin copyWith({String? id, String? name, String? description, Academy? academy}) {
    return Plugin(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      academy: academy ?? this.academy,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'academy': academy.toMap(),
    };
  }

  factory Plugin.fromMap(Map<String, dynamic> map) {
    return Plugin(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      academy: Academy.fromMap(Map<String, dynamic>.from(map['academy'] as Map)),
    );
  }

  String toJson() => json.encode(toMap());

  factory Plugin.fromJson(String source) => Plugin.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Plugin &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.academy == academy;
  }

  @override
  int get hashCode => Object.hash(id, name, description, academy);

  @override
  String toString() {
    return 'Plugin(id: $id, name: $name, description: $description, academy: $academy)';
  }
}
