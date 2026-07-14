import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/academy_lesson.dart';
import '../models/academy_module.dart';
import '../models/learning_path.dart';
import '../models/learning_progress.dart';
import '../models/lesson_state.dart';
import '../services/academy_service.dart';

/// Displays a full learning path with its modules and lessons.
///
/// Shows module progress, lesson states, and allows navigating
/// to individual lessons.
class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  AcademyService? _academyService;
  LearningPath? _path;
  LearningProgress? _progress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _academyService = AppBootstrap.maybeAcademyService;
    _loadPath();
  }

  void _loadPath() {
    final svc = _academyService;
    if (svc == null) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final pathId = args?['pathId'] as String?;
    if (pathId == null) return;

    setState(() {
      _path = svc.findPathById(pathId);
      _progress = svc.getProgressForPath(pathId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = _path;

    if (path == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text('Learning path not found',
                style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    final color = Color(path.color);
    final progress = _progress;
    final percent = progress != null
        ? (progress.completionPercentage * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Path header
          _buildPathHeader(context, path, color, percent),
          const SizedBox(height: AppSpacing.lg),

          // Progress bar
          if (progress != null) ...[
            PhoenixCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Overall Progress',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                      Text('$percent%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PhoenixProgressIndicator(
                    value: progress.completionPercentage,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${progress.completedModules} of ${progress.totalModules} modules completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Modules
          Text(
            'Modules',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ...path.modules.map((module) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ModuleCard(
              module: module,
              progress: progress,
              color: color,
              theme: theme,
              onLessonTap: (lessonId) {
                Navigator.of(context).pushNamed(
                  AppRoutes.academyLesson,
                  arguments: {
                    'pathId': path.id,
                    'lessonId': lessonId,
                  },
                );
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPathHeader(
    BuildContext context,
    LearningPath path,
    Color color,
    int percent,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      path.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      path.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _HeaderChip(
                icon: Icons.schedule_rounded,
                label: '${path.estimatedHours}h',
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeaderChip(
                icon: Icons.auto_awesome_rounded,
                label: '${path.modules.length} modules',
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeaderChip(
                icon: Icons.trending_up_rounded,
                label: _difficultyLabel(path.difficulty),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _difficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return 'Beginner';
    }
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.progress,
    required this.color,
    required this.theme,
    required this.onLessonTap,
  });

  final AcademyModule module;
  final LearningProgress? progress;
  final Color color;
  final ThemeData theme;
  final void Function(String lessonId) onLessonTap;

  @override
  Widget build(BuildContext context) {
    // Find module progress
    final moduleProgress = progress?.moduleProgresses
        .where((mp) => mp.moduleId == module.id)
        .firstOrNull;

    final completed = moduleProgress?.completedCount ?? 0;
    final total = module.lessons.length;
    final modulePercent =
        total > 0 ? (completed / total * 100).round() : 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.folder_rounded,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          module.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$completed / $total lessons',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$modulePercent%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.expand_more_rounded, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
        children: module.lessons.map((lesson) {
          final lp = moduleProgress?.lessonProgress
              .where((lp) => lp.lessonId == lesson.id)
              .firstOrNull;

          return _LessonRow(
            lesson: lesson,
            lessonProgress: lp,
            color: color,
            theme: theme,
            onTap: () => onLessonTap(lesson.id),
          );
        }).toList(),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.lessonProgress,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  final AcademyLesson lesson;
  final LessonProgress? lessonProgress;
  final Color color;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = lessonProgress?.state ?? LessonState.locked;
    final isActionable = state.isActionable;
    final isFinished = state.isFinished;

    IconData icon;
    Color iconColor;

    switch (state) {
      case LessonState.locked:
        icon = Icons.lock_outline_rounded;
        iconColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
      case LessonState.available:
        icon = Icons.play_circle_outline_rounded;
        iconColor = color;
      case LessonState.inProgress:
        icon = Icons.hourglass_top_rounded;
        iconColor = AppColors.warning;
      case LessonState.completed:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.primary;
      case LessonState.mastered:
        icon = Icons.auto_awesome_rounded;
        iconColor = AppColors.warning;
    }

    return InkWell(
      onTap: isActionable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isFinished || isActionable
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    '${lesson.durationMinutes} min',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (lessonProgress != null && isFinished)
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
                  '${lessonProgress!.score}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
