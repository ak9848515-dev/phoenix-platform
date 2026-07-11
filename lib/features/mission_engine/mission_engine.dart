import 'dart:convert';

/// Immutable mission entity used by the mission engine foundation.
class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.estimatedDuration,
    required this.completed,
    required this.completionDate,
    required this.xpReward,
    this.academyId,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final int estimatedDuration;
  final bool completed;
  final DateTime? completionDate;
  final int xpReward;
  final String? academyId;

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    int? estimatedDuration,
    bool? completed,
    DateTime? completionDate,
    int? xpReward,
    String? academyId,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      completed: completed ?? this.completed,
      completionDate: completionDate ?? this.completionDate,
      xpReward: xpReward ?? this.xpReward,
      academyId: academyId ?? this.academyId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'estimatedDuration': estimatedDuration,
      'completed': completed,
      'completionDate': completionDate?.toIso8601String(),
      'xpReward': xpReward,
      'academyId': academyId,
    };
  }

  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      priority: map['priority'] as String,
      estimatedDuration: map['estimatedDuration'] as int,
      completed: map['completed'] as bool,
      completionDate: map['completionDate'] == null
          ? null
          : DateTime.parse(map['completionDate'] as String),
      xpReward: map['xpReward'] as int,
      academyId: map['academyId'] as String?,
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
        other.category == category &&
        other.priority == priority &&
        other.estimatedDuration == estimatedDuration &&
        other.completed == completed &&
        other.completionDate == completionDate &&
        other.xpReward == xpReward &&
        other.academyId == academyId;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    priority,
    estimatedDuration,
    completed,
    completionDate,
    xpReward,
    academyId,
  );

  @override
  String toString() {
    return 'Mission(id: $id, title: $title, completed: $completed)';
  }
}
