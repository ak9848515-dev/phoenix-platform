import 'dart:convert';

/// Schedule configuration for a habit.
///
/// Defines how often a habit should be performed, which days of the week,
/// and at what time of day.
///
/// Immutable. Use [copyWith] to produce modified copies.
class HabitSchedule {
  const HabitSchedule({
    this.frequency = HabitFrequency.daily,
    this.daysOfWeek = const [],
    this.timeOfDay,
    this.customIntervalDays,
  });

  /// How often the habit should be performed.
  final HabitFrequency frequency;

  /// Specific days of the week (1=Monday, 7=Sunday).
  /// Empty means any day is valid.
  final List<int> daysOfWeek;

  /// Optional preferred time of day.
  final TimeOfDay? timeOfDay;

  /// Custom interval in days (only used with [HabitFrequency.custom]).
  final int? customIntervalDays;

  HabitSchedule copyWith({
    HabitFrequency? frequency,
    List<int>? daysOfWeek,
    TimeOfDay? timeOfDay,
    int? customIntervalDays,
    bool clearTimeOfDay = false,
    bool clearCustomInterval = false,
  }) {
    return HabitSchedule(
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      timeOfDay: clearTimeOfDay ? null : (timeOfDay ?? this.timeOfDay),
      customIntervalDays: clearCustomInterval
          ? null
          : (customIntervalDays ?? this.customIntervalDays),
    );
  }

  /// Whether today is a scheduled day.
  bool isScheduledToday() {
    if (frequency == HabitFrequency.daily) return true;
    if (daysOfWeek.isEmpty) return true;
    final today = DateTime.now().weekday;
    return daysOfWeek.contains(today);
  }

  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency.name,
      'daysOfWeek': daysOfWeek,
      'timeOfDay': timeOfDay?.toMap(),
      'customIntervalDays': customIntervalDays,
    };
  }

  factory HabitSchedule.fromMap(Map<String, dynamic> map) {
    return HabitSchedule(
      frequency: HabitFrequency.fromString(map['frequency'] as String? ?? 'daily'),
      daysOfWeek: List<int>.from(map['daysOfWeek'] as List? ?? []),
      timeOfDay: map['timeOfDay'] != null
          ? TimeOfDay.fromMap(Map<String, dynamic>.from(map['timeOfDay'] as Map))
          : null,
      customIntervalDays: map['customIntervalDays'] as int?,
    );
  }

  String toJson() => json.encode(toMap());
  factory HabitSchedule.fromJson(String source) =>
      HabitSchedule.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitSchedule &&
          other.frequency == frequency &&
          other.customIntervalDays == customIntervalDays;

  @override
  int get hashCode => Object.hash(frequency, customIntervalDays);

  @override
  String toString() => 'HabitSchedule(frequency: $frequency)';
}

/// How often a habit should be performed.
enum HabitFrequency {
  daily,
  weekly,
  weekday,
  weekend,
  custom,
  monthly;

  String get label {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.weekday:
        return 'Weekdays';
      case HabitFrequency.weekend:
        return 'Weekends';
      case HabitFrequency.custom:
        return 'Custom';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }

  static HabitFrequency fromString(String value) {
    return HabitFrequency.values.firstWhere(
      (f) => f.name == value,
      orElse: () => HabitFrequency.daily,
    );
  }
}

/// A time of day (hour and minute).
class TimeOfDay {
  const TimeOfDay({required this.hour, required this.minute});

  final int hour;
  final int minute;

  String get formatted {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  Map<String, dynamic> toMap() => {'hour': hour, 'minute': minute};

  factory TimeOfDay.fromMap(Map<String, dynamic> map) => TimeOfDay(
        hour: map['hour'] as int? ?? 0,
        minute: map['minute'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'TimeOfDay($formatted)';
}
