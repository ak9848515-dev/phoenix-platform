import '../models/academy_lesson.dart';
import '../models/learning_path.dart';
import '../models/learning_progress.dart';
import '../models/lesson_state.dart';
import '../models/quiz_question.dart';

/// Core engine for the Academy learning experience.
///
/// The Learning Engine owns:
/// - Progress calculation (path, module, lesson level)
/// - Lesson state transitions (locked → available → inProgress → completed → mastered)
/// - Scoring & quiz evaluation
/// - Prerequisite unlock logic
/// - Module progress computation
///
/// **Never** directly persists. All progress is stored through
/// [AcademyService] → [UserStateService].
///
/// **Never** duplicates Mission Engine, Knowledge DNA, or AI logic.
class LearningEngine {
  const LearningEngine();

  // ── Initialisation ───────────────────────────────────────────────

  /// Creates initial [LearningProgress] for a user starting a path.
  ///
  /// The first lesson is set to [LessonState.available]; all others
  /// start as [LessonState.locked].
  LearningProgress createInitialProgress(LearningPath path) {
    final moduleProgresses = path.modules.map((module) {
      final lessonProgress = module.lessons.map((lesson) {
        return LessonProgress(
          lessonId: lesson.id,
          state: lesson.prerequisiteLessonIds.isEmpty
              ? LessonState.available
              : LessonState.locked,
        );
      }).toList();
      return ModuleProgress(
        moduleId: module.id,
        lessonProgress: lessonProgress,
      );
    }).toList();

    return LearningProgress(
      pathId: path.id,
      moduleProgresses: moduleProgresses,
      startedAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
  }

  // ── Path Progress ────────────────────────────────────────────────

  /// Returns the overall [LearningProgress] for a path, computing
  /// module and lesson states from stored lesson progresses.
  LearningProgress computeProgress(
    LearningPath path,
    Map<String, LessonProgress> storedProgress,
  ) {
    final now = DateTime.now();

    final moduleProgresses = path.modules.map((module) {
      final lessonProgresses = module.lessons.map((lesson) {
        // Use stored progress if available, otherwise compute default
        final stored = storedProgress[lesson.id];

        if (stored != null) {
          // Check if prerequisites have been met (in case they weren't when stored)
          final updatedState = _resolveState(lesson, stored, storedProgress);
          return stored.copyWith(state: updatedState);
        }

        // No progress yet — compute initial state
        final initial = _isUnlocked(lesson, storedProgress)
            ? LessonState.available
            : LessonState.locked;
        return LessonProgress(lessonId: lesson.id, state: initial);
      }).toList();

      return ModuleProgress(
        moduleId: module.id,
        lessonProgress: lessonProgresses,
      );
    }).toList();

    return LearningProgress(
      pathId: path.id,
      moduleProgresses: moduleProgresses,
      startedAt: DateTime.now(),
      lastActivityAt: now,
    );
  }

  /// Resolves the correct state for a lesson given stored progress
  /// and prerequisite completion.
  LessonState _resolveState(
    AcademyLesson lesson,
    LessonProgress stored,
    Map<String, LessonProgress> allProgress,
  ) {
    // If it's already finished or in progress, keep that state
    if (stored.state.isFinished) return stored.state;
    if (stored.state == LessonState.inProgress) return stored.state;

    // Check prerequisites
    if (_isUnlocked(lesson, allProgress)) return LessonState.available;

    return LessonState.locked;
  }

  /// Whether a lesson's prerequisites are met.
  bool _isUnlocked(
    AcademyLesson lesson,
    Map<String, LessonProgress> allProgress,
  ) {
    if (lesson.prerequisiteLessonIds.isEmpty) return true;
    return lesson.prerequisiteLessonIds.every((preReqId) {
      final preReq = allProgress[preReqId];
      return preReq != null && preReq.state.isFinished;
    });
  }

  // ── Lesson Actions ───────────────────────────────────────────────

  /// Starts a lesson. Returns updated [LessonProgress].
  LessonProgress startLesson(LessonProgress progress) {
    if (!progress.state.isActionable) return progress;
    return progress.copyWith(
      state: LessonState.inProgress,
      startedAt: progress.startedAt ?? DateTime.now(),
      attempts: progress.attempts + 1,
    );
  }

  /// Records a quiz answer and returns updated progress.
  LessonProgress answerQuiz(
    LessonProgress progress,
    QuizQuestion question,
    int selectedAnswer,
  ) {
    final answers = Map<String, int>.from(progress.quizAnswers);
    answers[question.id] = selectedAnswer;
    return progress.copyWith(quizAnswers: answers);
  }

  /// Completes an exercise within a lesson.
  LessonProgress completeExercise(
    LessonProgress progress,
    String exerciseId,
  ) {
    final completions = Map<String, bool>.from(progress.exerciseCompletions);
    completions[exerciseId] = true;
    return progress.copyWith(exerciseCompletions: completions);
  }

  /// Scores quiz answers and potentially completes the lesson.
  ///
  /// Returns the updated [LessonProgress] with calculated score.
  /// If score is passing (≥60%), the lesson is marked completed.
  LessonProgress scoreAndComplete(
    LessonProgress progress,
    AcademyLesson lesson, {
    int passingScore = 60,
  }) {
    // Calculate quiz score
    final totalQuizPoints = lesson.quizzes.fold(0, (sum, q) => sum + q.points);
    final earnedQuizPoints = lesson.quizzes.fold(0, (sum, q) {
      final answer = progress.quizAnswers[q.id];
      if (answer != null && q.isCorrect(answer)) return sum + q.points;
      return sum;
    });

    // Calculate exercise score
    final totalExercisePoints =
        lesson.exercises.fold(0, (sum, e) => sum + e.points);
    final completedExercisePoints = lesson.exercises.fold(0, (sum, e) {
      if (progress.exerciseCompletions[e.id] == true) return sum + e.points;
      return sum;
    });

    final totalAvailable = totalQuizPoints + totalExercisePoints;
    final earned = earnedQuizPoints + completedExercisePoints;
    final score =
        totalAvailable > 0 ? ((earned / totalAvailable) * 100).round() : 100;

    final isPassing = score >= passingScore;

    return progress.copyWith(
      score: score,
      state: isPassing ? LessonState.completed : progress.state,
      completedAt: isPassing ? DateTime.now() : null,
    );
  }

  /// Marks a lesson as mastered.
  LessonProgress masterLesson(LessonProgress progress) {
    if (!progress.state.isFinished) return progress;
    return progress.copyWith(state: LessonState.mastered);
  }

  // ── Queries ──────────────────────────────────────────────────────

  /// Returns the next available (unstarted) lesson in a path.
  LessonProgress? findNextLesson(LearningProgress progress) {
    for (final mp in progress.moduleProgresses) {
      for (final lp in mp.lessonProgress) {
        if (lp.state == LessonState.available) return lp;
      }
    }
    return null;
  }

  /// Returns the lesson currently in progress (for "Continue Learning").
  LessonProgress? findCurrentLesson(LearningProgress progress) {
    for (final mp in progress.moduleProgresses) {
      for (final lp in mp.lessonProgress) {
        if (lp.state == LessonState.inProgress) return lp;
      }
    }
    return null;
  }

  /// Returns the percentage of lessons completed in a module.
  double moduleCompletionPercentage(
    ModuleProgress moduleProgress,
  ) {
    return moduleProgress.completionPercentage;
  }

  /// Returns the percentage of lessons completed in a path.
  double pathCompletionPercentage(LearningProgress progress) {
    return progress.completionPercentage;
  }

  /// Returns a map of lessonId → LessonProgress for efficient lookups.
  Map<String, LessonProgress> toMap(List<LessonProgress> progresses) {
    return {for (final p in progresses) p.lessonId: p};
  }
}
