/// The progress state of a lesson within the Academy.
///
/// States flow in one direction:
///   locked → available → inProgress → completed → mastered
///
/// - [locked]: Lesson is not yet accessible (prerequisite not met).
/// - [available]: Lesson is ready to start.
/// - [inProgress]: Lesson has been started but not finished.
/// - [completed]: Lesson has been completed (passing score achieved).
/// - [mastered]: Lesson has been reviewed and reinforced.
enum LessonState {
  locked,
  available,
  inProgress,
  completed,
  mastered;

  /// Whether the lesson is actionable by the user.
  bool get isActionable =>
      this == available || this == inProgress;

  /// Whether the lesson is finished.
  bool get isFinished => this == completed || this == mastered;

  /// Returns the next state after starting the lesson.
  LessonState get start => inProgress;

  /// Returns the next state after completing the lesson.
  LessonState get complete => completed;

  /// Returns the next state after mastering the lesson.
  LessonState get master => mastered;

  /// Parses from a string (for serialization).
  static LessonState fromString(String value) {
    return LessonState.values.firstWhere(
      (s) => s.name == value,
      orElse: () => LessonState.locked,
    );
  }
}
