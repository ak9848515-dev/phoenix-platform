/// Types of habits the Habit Intelligence Engine supports.
///
/// Architecture supports unlimited future types — just add a new
/// enum value. No business logic is owned here.
enum HabitType {
  learning,
  health,
  exercise,
  reading,
  meditation,
  coding,
  career,
  finance,
  productivity,
  family,
  custom;

  /// Human-readable label.
  String get label {
    switch (this) {
      case HabitType.learning:
        return 'Learning';
      case HabitType.health:
        return 'Health';
      case HabitType.exercise:
        return 'Exercise';
      case HabitType.reading:
        return 'Reading';
      case HabitType.meditation:
        return 'Meditation';
      case HabitType.coding:
        return 'Coding';
      case HabitType.career:
        return 'Career';
      case HabitType.finance:
        return 'Finance';
      case HabitType.productivity:
        return 'Productivity';
      case HabitType.family:
        return 'Family';
      case HabitType.custom:
        return 'Custom';
    }
  }

  /// Icon name for display.
  String get iconName {
    switch (this) {
      case HabitType.learning:
        return 'school';
      case HabitType.health:
        return 'favorite';
      case HabitType.exercise:
        return 'fitness_center';
      case HabitType.reading:
        return 'menu_book';
      case HabitType.meditation:
        return 'self_improvement';
      case HabitType.coding:
        return 'code';
      case HabitType.career:
        return 'work';
      case HabitType.finance:
        return 'account_balance';
      case HabitType.productivity:
        return 'checklist';
      case HabitType.family:
        return 'family_restroom';
      case HabitType.custom:
        return 'star';
    }
  }

  /// Parses from a string.
  static HabitType fromString(String value) {
    return HabitType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => HabitType.custom,
    );
  }

  /// All built-in types (excludes custom).
  static List<HabitType> get builtIn =>
      HabitType.values.where((t) => t != HabitType.custom).toList();
}
