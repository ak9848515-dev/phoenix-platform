import 'package:flutter/foundation.dart';

import '../../ai/services/ai_mentor_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../engine/learning_engine.dart';
import '../engine/learning_path_registry.dart';
import '../models/academy_lesson.dart';
import '../models/learning_path.dart';
import '../models/learning_progress.dart';
import '../models/lesson_state.dart';
import '../models/quiz_question.dart';

/// Public API for the Phoenix Academy Experience.
///
/// [AcademyService] is the ONLY entry point for Academy functionality.
/// Screens and widgets never interact with [LearningEngine] or
/// [LearningPathRegistry] directly.
///
/// Responsibilities:
/// - Learning path discovery and access
/// - Lesson progress tracking (start, quiz, exercise, complete, master)
/// - Continue Learning (resume last active lesson)
/// - AI-powered explanations (via [AIMentorService])
/// - Mission generation via callback (never duplicates MissionEngine)
/// - Knowledge DNA integration (skill gap analysis)
/// - Recommendation integration (personalised path suggestions)
/// - Persistence through [UserStateService]
///
/// **Architecture Rules:**
/// - NEVER duplicate Mission Engine logic
/// - NEVER duplicate Knowledge DNA logic
/// - NEVER duplicate AI logic
/// - NEVER duplicate UserState logic
class AcademyService extends ChangeNotifier {
  AcademyService({
    required this._userStateService,
    required this._aiMentorService,
    LearningEngine? learningEngine,
    LearningPathRegistry? pathRegistry,
  })  : _learningEngine = learningEngine ?? const LearningEngine(),
        _pathRegistry = pathRegistry ?? const LearningPathRegistry();

  final UserStateService _userStateService;
  final AIMentorService _aiMentorService;
  final LearningEngine _learningEngine;
  final LearningPathRegistry _pathRegistry;

  /// Callback invoked when a lesson is completed.
  /// Receives the completed lesson. Should generate missions or
  /// trigger other side effects through the appropriate services.
  void Function(AcademyLesson lesson)? onLessonCompleted;

  // ── Path Discovery ────────────────────────────────────────────────

  /// All available learning paths.
  List<LearningPath> get allPaths => _pathRegistry.allPaths;

  /// Returns a path by ID.
  LearningPath? findPathById(String id) => _pathRegistry.findById(id);

  /// Returns paths matching career tags.
  List<LearningPath> findPathsByTags(List<String> tags) =>
      _pathRegistry.findByTags(tags);

  // ── Progress Access ───────────────────────────────────────────────

  /// Returns stored [LearningProgress] for a path, or creates initial
  /// progress if none exists.
  LearningProgress getProgressForPath(String pathId) {
    final path = _pathRegistry.findById(pathId);
    if (path == null) {
      return LearningProgress(pathId: pathId);
    }

    // Load from user state if available
    final progresses = _getStoredProgresses();
    final stored = progresses.firstWhere(
      (p) => p.pathId == pathId,
      orElse: () => LearningProgress(pathId: pathId),
    );

    // If no stored progress, create initial
    if (stored.moduleProgresses.isEmpty) {
      return _learningEngine.createInitialProgress(path);
    }

    // Convert stored LessonProgress list to map
    final progressMap = <String, LessonProgress>{};
    for (final mp in stored.moduleProgresses) {
      for (final lp in mp.lessonProgress) {
        progressMap[lp.lessonId] = lp;
      }
    }

    // Compute current state considering prerequisites
    return _learningEngine.computeProgress(path, progressMap);
  }

  /// All path progresses the user has started.
  List<LearningProgress> get allProgress => _getStoredProgresses();

  /// The most recently active path (for "Continue Learning").
  LearningProgress? get activePathProgress {
    final progresses = _getStoredProgresses();
    if (progresses.isEmpty) return null;
    final inProgress = progresses
        .where((p) => p.completionPercentage < 1.0)
        .toList();
    if (inProgress.isEmpty) return progresses.first;
    return inProgress.reduce((a, b) {
      final aTime = a.lastActivityAt ?? DateTime(2000);
      final bTime = b.lastActivityAt ?? DateTime(2000);
      return aTime.isAfter(bTime) ? a : b;
    });
  }

  /// The current lesson in progress across all paths.
  LessonProgress? get currentLesson {
    final active = activePathProgress;
    if (active == null) return null;
    return _learningEngine.findCurrentLesson(active);
  }

  /// The next available lesson (for recommendations).
  LessonProgress? get nextLesson {
    final active = activePathProgress;
    if (active == null) return null;
    return _learningEngine.findNextLesson(active);
  }

  // ── Lesson Actions ───────────────────────────────────────────────

  /// Starts a lesson and persists the progress.
  Future<void> startLesson(String pathId, String lessonId) async {
    await _updateProgress(pathId, (progress) {
      final updated = _updateLessonInProgress(
        progress, lessonId,
        (lp) => _learningEngine.startLesson(lp),
      );
      return updated.copyWith(lastActivityAt: DateTime.now());
    });
  }

  /// Records a quiz answer.
  Future<void> answerQuiz(
    String pathId,
    String lessonId,
    QuizQuestion question,
    int selectedAnswer,
  ) async {
    await _updateProgress(pathId, (progress) {
      final updated = _updateLessonInProgress(
        progress, lessonId,
        (lp) => _learningEngine.answerQuiz(lp, question, selectedAnswer),
      );
      return updated.copyWith(lastActivityAt: DateTime.now());
    });
  }

  /// Completes an exercise.
  Future<void> completeExercise(
    String pathId,
    String lessonId,
    String exerciseId,
  ) async {
    await _updateProgress(pathId, (progress) {
      final updated = _updateLessonInProgress(
        progress, lessonId,
        (lp) => _learningEngine.completeExercise(lp, exerciseId),
      );
      return updated.copyWith(lastActivityAt: DateTime.now());
    });
  }

  /// Scores and completes a lesson. Also triggers mission generation
  /// via [onLessonCompleted] callback if set.
  Future<void> completeLesson(String pathId, String lessonId) async {
    // Get the lesson data
    final path = _pathRegistry.findById(pathId);
    if (path == null) return;

    AcademyLesson? lesson;
    for (final module in path.modules) {
      for (final l in module.lessons) {
        if (l.id == lessonId) {
          lesson = l;
          break;
        }
      }
      if (lesson != null) break;
    }
    if (lesson == null) return;
    final completedLesson = lesson;

    await _updateProgress(pathId, (progress) {
      final updated = _updateLessonInProgress(progress, lessonId, (lp) {
        return _learningEngine.scoreAndComplete(lp, completedLesson);
      });

      // If lesson completed, fire callback
      final lessonProgress = _findLessonInProgress(updated, lessonId);
      if (lessonProgress?.state == LessonState.completed) {
        onLessonCompleted?.call(completedLesson);
      }

      return updated.copyWith(
        lastActivityAt: DateTime.now(),
        totalScore: _recalculateTotalScore(updated),
      );
    });
  }

  /// Marks a lesson as mastered.
  // ignore: unused_element
  Future<void> masterLesson(String pathId, String lessonId) async {
    await _updateProgress(pathId, (progress) {
      final updated = _updateLessonInProgress(
        progress, lessonId,
        (lp) => _learningEngine.masterLesson(lp),
      );
      return updated.copyWith(lastActivityAt: DateTime.now());
    });
  }

  // ── AI Integration ───────────────────────────────────────────────

  /// Gets an AI explanation for a lesson.
  Future<String> explainLesson(AcademyLesson lesson) async {
    final response = await _aiMentorService.chat(
      'Explain this lesson in simple terms: ${lesson.title}\n\n'
      '${lesson.description}',
    );
    return response.content;
  }

  /// Gets an AI summary of a topic.
  Future<String> summarizeTopic(String topic) async {
    final response = await _aiMentorService.chat(
      'Give me a concise summary of $topic covering the key points '
      'I need to know.',
    );
    return response.content;
  }

  /// Gets AI recommendations for what lesson to take next.
  Future<String> getNextRecommendation(LearningProgress progress) async {
    final completed = progress.completedModules;
    final total = progress.totalModules;
    final response = await _aiMentorService.chat(
      'I have completed $completed out of $total modules in my learning path. '
      'What should I focus on next to make the most progress?',
    );
    return response.content;
  }

  // ── Knowledge DNA Integration ────────────────────────────────────

  /// Returns paths recommended based on Knowledge DNA skill gaps.
  List<LearningPath> getRecommendedPathsFromDna() {
    final dna = _userStateService.currentState.knowledgeDNA;
    final weakAreas = dna?.weakAreas ?? [];
    if (weakAreas.isEmpty) return _pathRegistry.allPaths.take(3).toList();
    final byTags = _pathRegistry.findByTags(weakAreas);
    if (byTags.isNotEmpty) return byTags;
    return _pathRegistry.allPaths.take(3).toList();
  }

  // ── Persistence Helpers ──────────────────────────────────────────

  List<LearningProgress> _getStoredProgresses() {
    return _userStateService.currentState.learningProgress;
  }

  Future<void> _updateProgress(
    String pathId,
    LearningProgress Function(LearningProgress) updater,
  ) async {
    final currentProgress = _getStoredProgresses();
    final index = currentProgress.indexWhere((p) => p.pathId == pathId);

    final updated = updater(
      index >= 0
          ? currentProgress[index]
          : LearningProgress(pathId: pathId),
    );

    final newProgresses = List<LearningProgress>.from(currentProgress);
    if (index >= 0) {
      newProgresses[index] = updated;
    } else {
      newProgresses.add(updated);
    }

    await _userStateService.setLearningProgress(newProgresses);
    notifyListeners();
  }

  LearningProgress _updateLessonInProgress(
    LearningProgress progress,
    String lessonId,
    LessonProgress Function(LessonProgress) updater,
  ) {
    final newModuleProgresses = progress.moduleProgresses.map((mp) {
      final lessonIndex = mp.lessonProgress.indexWhere(
        (lp) => lp.lessonId == lessonId,
      );
      if (lessonIndex < 0) return mp;

      final newLessons = List<LessonProgress>.from(mp.lessonProgress);
      newLessons[lessonIndex] = updater(newLessons[lessonIndex]);
      return mp.copyWith(lessonProgress: newLessons);
    }).toList();

    return progress.copyWith(moduleProgresses: newModuleProgresses);
  }

  LessonProgress? _findLessonInProgress(
    LearningProgress progress,
    String lessonId,
  ) {
    for (final mp in progress.moduleProgresses) {
      for (final lp in mp.lessonProgress) {
        if (lp.lessonId == lessonId) return lp;
      }
    }
    return null;
  }

  int _recalculateTotalScore(LearningProgress progress) {
    var total = 0;
    for (final mp in progress.moduleProgresses) {
      for (final lp in mp.lessonProgress) {
        total += lp.score;
      }
    }
    return total;
  }

  // ── Diagnostics ──────────────────────────────────────────────────

  Map<String, dynamic> diagnostics() {
    return {
      'pathCount': _pathRegistry.allPaths.length,
      'activeProgressCount': allProgress.length,
      'hasCurrentLesson': currentLesson != null,
    };
  }
}
