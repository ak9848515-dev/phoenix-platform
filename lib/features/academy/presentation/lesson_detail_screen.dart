import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/academy_lesson.dart';
import '../models/exercise.dart';
import '../models/learning_path.dart';
import '../models/lesson_content.dart';
import '../models/lesson_state.dart';
import '../models/learning_progress.dart';
import '../models/quiz_question.dart';
import '../services/academy_service.dart';

/// Displays a single lesson with content sections, quizzes, and exercises.
///
/// Supports:
/// - Content sections (text, code) in a scrollable view
/// - Quiz questions with multiple choice
/// - Exercises with hints
/// - Progress tracking
/// - AI explanation integration
class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  AcademyService? _academyService;
  AcademyLesson? _lesson;
  LearningPath? _path;
  LessonProgress? _progress;

  bool _isLoading = true;
  String? _selectedTab;
  final Map<String, int> _selectedAnswers = {};
  final Set<String> _completedExercises = {};
  final Set<String> _revealedHints = {};
  String? _aiExplanation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _academyService = AppBootstrap.maybeAcademyService;
    _loadLesson();
  }

  void _loadLesson() {
    final svc = _academyService;
    if (svc == null) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final pathId = args?['pathId'] as String?;
    final lessonId = args?['lessonId'] as String?;
    if (pathId == null || lessonId == null) return;

    final path = svc.findPathById(pathId);
    if (path == null) return;

    // Find the lesson in the path
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

    final progress = svc.getProgressForPath(pathId);

    // Find lesson progress
    LessonProgress? lessonProgress;
    for (final mp in progress.moduleProgresses) {
      for (final lp in mp.lessonProgress) {
        if (lp.lessonId == lessonId) {
          lessonProgress = lp;
          break;
        }
      }
      if (lessonProgress != null) break;
    }

    setState(() {
      _path = path;
      _lesson = lesson;
      _progress = lessonProgress;
      _selectedTab = lesson!.sections.isNotEmpty ? 'content' : 'quiz';
      _isLoading = false;
    });

    // Mark as started
    svc.startLesson(pathId, lessonId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final lesson = _lesson;
    if (lesson == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text('Lesson not found', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(lesson),
        _buildTabBar(lesson),
        Expanded(child: _buildTabContent(lesson)),
      ],
    );
  }

  Widget _buildHeader(AcademyLesson lesson) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                ),
                const Spacer(),
                if (_progress?.state == LessonState.inProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_top_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'In Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_progress?.state.isFinished == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${_progress!.score}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              lesson.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              lesson.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 14, color: Colors.white70),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${lesson.durationMinutes} min',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.quiz_rounded,
                    size: 14, color: Colors.white70),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${lesson.quizzes.length} quiz',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (lesson.exercises.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.code_rounded,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${lesson.exercises.length} exercises',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(AcademyLesson lesson) {
    final theme = Theme.of(context);
    final tabs = <String>[];
    if (lesson.sections.isNotEmpty) tabs.add('content');
    if (lesson.quizzes.isNotEmpty) tabs.add('quiz');
    if (lesson.exercises.isNotEmpty) tabs.add('exercises');

    if (tabs.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          final label = tab == 'content' ? 'Content' : tab == 'quiz' ? 'Quiz' : 'Exercises';

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(AcademyLesson lesson) {
    switch (_selectedTab) {
      case 'quiz':
        return _buildQuizContent(lesson);
      case 'exercises':
        return _buildExercisesContent(lesson);
      default:
        return _buildContentSections(lesson);
    }
  }

  Widget _buildContentSections(AcademyLesson lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lesson.sections.map((section) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _buildSection(section),
          )),
          const SizedBox(height: AppSpacing.md),
          // AI Explanation button
          if (_aiExplanation == null)
            PhoenixPrimaryButton(
              onPressed: _loadAiExplanation,
              label: 'Ask AI to Explain',
              icon: Icons.auto_awesome_rounded,
              fullWidth: true,
            )
          else
            PhoenixCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 18, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'AI Explanation',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _aiExplanation!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          // Complete button
          if (_progress?.state.isFinished != true)
            PhoenixPrimaryButton(
              onPressed: _completeLesson,
              label: 'Complete Lesson',
              icon: Icons.check_circle_outline_rounded,
              fullWidth: true,
            ),
        ],
      ),
    );
  }

  Widget _buildSection(LessonContentSection section) {
    final theme = Theme.of(context);

    switch (section.type) {
      case LessonContentType.text:
        return _buildTextSection(section, theme);
      case LessonContentType.code:
        return _buildCodeSection(section, theme);
      case LessonContentType.image:
        return _buildImageSection(section, theme);
    }
  }

  Widget _buildTextSection(LessonContentSection section, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: SelectableText(
        section.data,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildCodeSection(LessonContentSection section, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.language != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                section.language!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          SelectableText(
            section.data,
            style: const TextStyle(
              color: Color(0xFFD4D4D4),
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(LessonContentSection section, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.image_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
          if (section.caption != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              section.caption!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizContent(AcademyLesson lesson) {
    final theme = Theme.of(context);

    if (lesson.quizzes.isEmpty) {
      return Center(
        child: Text('No quiz questions for this lesson.',
            style: theme.textTheme.bodyMedium),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lesson.quizzes.map((question) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _QuizCard(
              question: question,
              selectedAnswer: _selectedAnswers[question.id],
              onAnswer: (answer) {
                setState(() {
                  _selectedAnswers[question.id] = answer;
                });
                if (_lesson != null && _path != null) {
                  _academyService?.answerQuiz(
                    _path!.id,
                    _lesson!.id,
                    question,
                    answer,
                  );
                }
              },
              theme: theme,
            ),
          )),
          const SizedBox(height: AppSpacing.md),
          PhoenixPrimaryButton(
            onPressed: _completeLesson,
            label: 'Complete & Score',
            icon: Icons.check_circle_outline_rounded,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesContent(AcademyLesson lesson) {
    final theme = Theme.of(context);

    if (lesson.exercises.isEmpty) {
      return Center(
        child: Text('No exercises for this lesson.',
            style: theme.textTheme.bodyMedium),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lesson.exercises.map((exercise) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _ExerciseCard(
              exercise: exercise,
              isCompleted: _completedExercises.contains(exercise.id),
              revealedHints: _revealedHints,
              onComplete: () {
                setState(() {
                  _completedExercises.add(exercise.id);
                });
                if (_lesson != null && _path != null) {
                  _academyService?.completeExercise(
                    _path!.id,
                    _lesson!.id,
                    exercise.id,
                  );
                }
              },
              onRevealHint: (exerciseId, hintIndex) {
                setState(() {
                  _revealedHints.add('$exerciseId-$hintIndex');
                });
              },
              theme: theme,
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _loadAiExplanation() async {
    final svc = _academyService;
    final lesson = _lesson;
    if (svc == null || lesson == null) return;

    try {
      final explanation = await svc.explainLesson(lesson);
      setState(() => _aiExplanation = explanation);
    } catch (_) {
      setState(() => _aiExplanation = 'AI explanation is not available right now.');
    }
  }

  Future<void> _completeLesson() async {
    final svc = _academyService;
    final path = _path;
    final lesson = _lesson;
    if (svc == null || path == null || lesson == null) return;

    await svc.completeLesson(path.id, lesson.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson completed! 🎉'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}

/// Card for a quiz question with multiple-choice options.
class _QuizCard extends StatefulWidget {
  const _QuizCard({
    required this.question,
    required this.selectedAnswer,
    required this.onAnswer,
    required this.theme,
  });

  final QuizQuestion question;
  final int? selectedAnswer;
  final void Function(int) onAnswer;
  final ThemeData theme;

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  bool _showExplanation = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final answered = widget.selectedAnswer != null;
    final isCorrect = answered && q.isCorrect(widget.selectedAnswer!);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: answered
              ? (isCorrect ? AppColors.primary : AppColors.error)
              : widget.theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: answered ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${q.points} pts',
                  style: widget.theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (answered)
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isCorrect ? AppColors.primary : AppColors.error,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            q.question,
            style: widget.theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(q.options.length, (index) {
            final isSelected = widget.selectedAnswer == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: answered
                    ? null
                    : () {
                        widget.onAnswer(index);
                        setState(() => _showExplanation = true);
                      },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isCorrect
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1))
                        : widget.theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (isCorrect ? AppColors.primary : AppColors.error)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (isCorrect ? AppColors.primary : AppColors.error)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : widget.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        child: Center(
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          q.options[index],
                          style: widget.theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_showExplanation && answered)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        size: 18, color: AppColors.info),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        q.explanation,
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card for an exercise with hints and completion button.
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.isCompleted,
    required this.revealedHints,
    required this.onComplete,
    required this.onRevealHint,
    required this.theme,
  });

  final Exercise exercise;
  final bool isCompleted;
  final Set<String> revealedHints;
  final VoidCallback onComplete;
  final void Function(String exerciseId, int hintIndex) onRevealHint;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                exercise.type == ExerciseType.coding
                    ? Icons.code_rounded
                    : exercise.type == ExerciseType.reflection
                        ? Icons.edit_note_rounded
                        : Icons.assignment_rounded,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  exercise.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            exercise.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Hints
          if (exercise.hints.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              children: List.generate(exercise.hints.length, (index) {
                final key = '${exercise.id}-$index';
                final revealed = revealedHints.contains(key);
                return GestureDetector(
                  onTap: revealed
                      ? null
                      : () => onRevealHint(exercise.id, index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: revealed
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      revealed ? exercise.hints[index] : 'Hint ${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: revealed
                            ? AppColors.warning
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          const SizedBox(height: AppSpacing.md),
          if (!isCompleted)
            PhoenixPrimaryButton(
              onPressed: onComplete,
              label: 'Mark Complete',
              icon: Icons.check_rounded,
            ),
        ],
      ),
    );
  }
}
