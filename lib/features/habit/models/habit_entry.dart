import 'dart:convert';

/// A daily tracking entry for a habit completion.
///
/// Immutable. Represents whether a habit was completed on a given date,
/// with optional notes and count.
class HabitEntry {
  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = true,
    this.count = 1,
    this.notes,
    this.skipped = false,
    this.skipReason,
    this.createdAt,
  });

  /// Unique identifier.
  final String id;

  /// ID of the habit this entry belongs to.
  final String habitId;

  /// The date this entry is for (date only, time is ignored).
  final DateTime date;

  /// Whether the habit was completed.
  final bool completed;

  /// Number of completions (useful for targets > 1 per day).
  final int count;

  /// Optional notes about this completion.
  final String? notes;

  /// Whether this day was intentionally skipped.
  final bool skipped;

  /// Reason for skipping.
  final String? skipReason;

  /// When this entry was created.
  final DateTime? createdAt;

  /// Date-only key for grouping (yyyy-MM-dd).
  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? completed,
    int? count,
    String? notes,
    bool? skipped,
    String? skipReason,
    DateTime? createdAt,
    bool clearNotes = false,
    bool clearSkipReason = false,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      count: count ?? this.count,
      notes: clearNotes ? null : (notes ?? this.notes),
      skipped: skipped ?? this.skipped,
      skipReason: clearSkipReason ? null : (skipReason ?? this.skipReason),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'completed': completed,
      'count': count,
      'notes': notes,
      'skipped': skipped,
      'skipReason': skipReason,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory HabitEntry.fromMap(Map<String, dynamic> map) {
    return HabitEntry(
      id: map['id'] as String,
      habitId: map['habitId'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      completed: map['completed'] as bool? ?? true,
      count: map['count'] as int? ?? 1,
      notes: map['notes'] as String?,
      skipped: map['skipped'] as bool? ?? false,
      skipReason: map['skipReason'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory HabitEntry.fromJson(String source) =>
      HabitEntry.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HabitEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'HabitEntry(habitId: $habitId, date: $dateKey, completed: $completed)';
}
