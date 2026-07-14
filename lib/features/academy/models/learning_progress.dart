import 'lesson_state.dart' show LessonState;

/// Tracks a user's progress through a single lesson.
///
/// Immutable. Stored per-user via [UserStateService].
class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    this.state = LessonState.locked,
    this.score = 0,
    this.quizAnswers = const {},
    this.exerciseCompletions = const {},
    this.startedAt,
    this.completedAt,
    this.attempts = 0,
  });

  /// The lesson ID.
  final String lessonId;

  /// Current state.
  final LessonState state;

  /// Overall score (0-100).
  final int score;

  /// Quiz answers: questionId → selectedAnswerIndex.
  final Map<String, int> quizAnswers;

  /// Exercise completions: exerciseId → isCompleted.
  final Map<String, bool> exerciseCompletions;

  /// When the lesson was started.
  final DateTime? startedAt;

  /// When the lesson was completed.
  final DateTime? completedAt;

  /// Number of attempts.
  final int attempts;

  LessonProgress copyWith({
    String? lessonId,
    LessonState? state,
    int? score,
    Map<String, int>? quizAnswers,
    Map<String, bool>? exerciseCompletions,
    DateTime? startedAt,
    DateTime? completedAt,
    int? attempts,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      state: state ?? this.state,
      score: score ?? this.score,
      quizAnswers: quizAnswers ?? this.quizAnswers,
      exerciseCompletions: exerciseCompletions ?? this.exerciseCompletions,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'state': state.name,
      'score': score,
      'quizAnswers': quizAnswers,
      'exerciseCompletions': exerciseCompletions,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'attempts': attempts,
    };
  }

  factory LessonProgress.fromMap(Map<String, dynamic> map) {
    return LessonProgress(
      lessonId: map['lessonId'] as String,
      state: LessonState.values.firstWhere(
        (s) => s.name == (map['state'] as String? ?? 'locked'),
        orElse: () => LessonState.locked,
      ),
      score: map['score'] as int? ?? 0,
      quizAnswers: Map<String, int>.from(map['quizAnswers'] as Map? ?? {}),
      exerciseCompletions:
          Map<String, bool>.from(map['exerciseCompletions'] as Map? ?? {}),
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      attempts: map['attempts'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonProgress && other.lessonId == lessonId;

  @override
  int get hashCode => lessonId.hashCode;
}

/// Tracks a user's progress through a module.
///
/// Immutable. Computed from [LessonProgress] entries.
class ModuleProgress {
  const ModuleProgress({
    required this.moduleId,
    required this.lessonProgress,
  });

  /// The module ID.
  final String moduleId;

  /// Progress for each lesson in the module.
  final List<LessonProgress> lessonProgress;

  /// Number of completed lessons.
  int get completedCount =>
      lessonProgress.where((lp) => lp.state.isFinished).length;

  /// Number of lessons in progress.
  int get inProgressCount =>
      lessonProgress.where((lp) => lp.state == LessonState.inProgress).length;

  /// Total lessons.
  int get totalCount => lessonProgress.length;

  /// Completion percentage (0.0–1.0).
  double get completionPercentage =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  /// Average score across completed lessons.
  double get averageScore {
    final completed = lessonProgress.where((lp) => lp.state.isFinished);
    if (completed.isEmpty) return 0.0;
    return completed.fold(0, (sum, lp) => sum + lp.score) / completed.length;
  }

  ModuleProgress copyWith({
    String? moduleId,
    List<LessonProgress>? lessonProgress,
  }) {
    return ModuleProgress(
      moduleId: moduleId ?? this.moduleId,
      lessonProgress: lessonProgress ?? this.lessonProgress,
    );
  }
}

/// Tracks a user's progress through a learning path.
///
/// Immutable. This is the top-level progress object stored via
/// [UserStateService] and computed by the [LearningEngine].
class LearningProgress {
  const LearningProgress({
    required this.pathId,
    this.moduleProgresses = const [],
    this.startedAt,
    this.lastActivityAt,
    this.totalScore = 0,
  });

  /// The learning path ID.
  final String pathId;

  /// Progress for each module in the path.
  final List<ModuleProgress> moduleProgresses;

  /// When the user started this path.
  final DateTime? startedAt;

  /// Last activity timestamp.
  final DateTime? lastActivityAt;

  /// Cumulative score across all completed lessons.
  final int totalScore;

  /// Number of completed modules.
  int get completedModules =>
      moduleProgresses.where((mp) => mp.completionPercentage >= 1.0).length;

  /// Total modules.
  int get totalModules => moduleProgresses.length;

  /// Overall completion percentage (0.0–1.0).
  double get completionPercentage {
    if (moduleProgresses.isEmpty) return 0.0;
    final completed = moduleProgresses.fold(
        0, (sum, mp) => sum + mp.completedCount);
    final total =
        moduleProgresses.fold(0, (sum, mp) => sum + mp.totalCount);
    return total > 0 ? completed / total : 0.0;
  }

  /// The first lesson in progress (for "Continue Learning").
  LessonProgress? get currentLesson {
    for (final mp in moduleProgresses) {
      for (final lp in mp.lessonProgress) {
        if (lp.state == LessonState.inProgress) return lp;
      }
    }
    // Fall back to first available lesson
    for (final mp in moduleProgresses) {
      for (final lp in mp.lessonProgress) {
        if (lp.state == LessonState.available) return lp;
      }
    }
    return null;
  }

  LearningProgress copyWith({
    String? pathId,
    List<ModuleProgress>? moduleProgresses,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    int? totalScore,
  }) {
    return LearningProgress(
      pathId: pathId ?? this.pathId,
      moduleProgresses: moduleProgresses ?? this.moduleProgresses,
      startedAt: startedAt ?? this.startedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pathId': pathId,
      'moduleProgresses':
          moduleProgresses.map((mp) => _moduleProgressToMap(mp)).toList(),
      'startedAt': startedAt?.toIso8601String(),
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'totalScore': totalScore,
    };
  }

  Map<String, dynamic> _moduleProgressToMap(ModuleProgress mp) {
    return {
      'moduleId': mp.moduleId,
      'lessonProgress':
          mp.lessonProgress.map((lp) => lp.toMap()).toList(),
    };
  }

  factory LearningProgress.fromMap(Map<String, dynamic> map) {
    return LearningProgress(
      pathId: map['pathId'] as String,
      moduleProgresses: (map['moduleProgresses'] as List?)
              ?.map((mp) => _moduleProgressFromMap(
                  Map<String, dynamic>.from(mp as Map)))
              .toList() ??
          [],
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'] as String)
          : null,
      lastActivityAt: map['lastActivityAt'] != null
          ? DateTime.parse(map['lastActivityAt'] as String)
          : null,
      totalScore: map['totalScore'] as int? ?? 0,
    );
  }

  static ModuleProgress _moduleProgressFromMap(Map<String, dynamic> map) {
    return ModuleProgress(
      moduleId: map['moduleId'] as String,
      lessonProgress: (map['lessonProgress'] as List?)
              ?.map((lp) =>
                  LessonProgress.fromMap(Map<String, dynamic>.from(lp as Map)))
              .toList() ??
          [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningProgress && other.pathId == pathId;

  @override
  int get hashCode => pathId.hashCode;

  @override
  String toString() =>
      'LearningProgress(pathId: $pathId, ${(completionPercentage * 100).round()}%)';
}
