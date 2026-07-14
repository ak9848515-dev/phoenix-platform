import 'dart:convert';

import 'habit_schedule.dart' show HabitSchedule;
import 'habit_type.dart' show HabitType;

/// A habit tracked by the Habit Intelligence Engine.
///
/// Immutable. Use [copyWith] to produce modified copies.
/// Use [toMap] / [fromMap] for serialization.
class Habit {
  const Habit({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.schedule = const HabitSchedule(),
    this.targetPerDay = 1,
    this.goal,
    this.createdAt,
    this.isActive = true,
    this.color,
    this.sortOrder = 0,
  });

  /// Unique identifier.
  final String id;

  /// Short title (e.g. "Morning Run", "Read 20 pages").
  final String title;

  /// Optional description.
  final String? description;

  /// Habit category.
  final HabitType type;

  /// When and how often to perform this habit.
  final HabitSchedule schedule;

  /// Target completions per day (e.g. 3 for "Drink 3 glasses of water").
  final int targetPerDay;

  /// Optional long-term goal (e.g. "Run a marathon", "Read 50 books").
  final String? goal;

  /// When the habit was created.
  final DateTime? createdAt;

  /// Whether the habit is active (paused/inactive habits are hidden).
  final bool isActive;

  /// Optional display color override (hex string, e.g. "#4CAF50").
  final String? color;

  /// Display sort order (lower = higher priority).
  final int sortOrder;

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    HabitType? type,
    HabitSchedule? schedule,
    int? targetPerDay,
    String? goal,
    DateTime? createdAt,
    bool? isActive,
    String? color,
    int? sortOrder,
    bool clearDescription = false,
    bool clearGoal = false,
    bool clearColor = false,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      type: type ?? this.type,
      schedule: schedule ?? this.schedule,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      goal: clearGoal ? null : (goal ?? this.goal),
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      color: clearColor ? null : (color ?? this.color),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'schedule': schedule.toMap(),
      'targetPerDay': targetPerDay,
      'goal': goal,
      'createdAt': createdAt?.toIso8601String(),
      'isActive': isActive,
      'color': color,
      'sortOrder': sortOrder,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      type: HabitType.fromString(map['type'] as String? ?? 'custom'),
      schedule: map['schedule'] != null
          ? HabitSchedule.fromMap(
              Map<String, dynamic>.from(map['schedule'] as Map))
          : const HabitSchedule(),
      targetPerDay: map['targetPerDay'] as int? ?? 1,
      goal: map['goal'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      isActive: map['isActive'] as bool? ?? true,
      color: map['color'] as String?,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory Habit.fromJson(String source) =>
      Habit.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Habit && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Habit(id: $id, title: $title, type: $type, active: $isActive)';
}
