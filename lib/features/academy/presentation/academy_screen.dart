import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/learning_path.dart';
import '../models/learning_progress.dart';
import '../services/academy_service.dart';

/// The Academy Home screen — Phoenix's learning platform.
///
/// Displays:
/// - Continue Learning (resume last active lesson)
/// - Learning Paths grid (all available paths)
/// - Path Progress (most active path)
/// - Recommended Paths (based on Knowledge DNA)
/// - Recent Activity timeline
/// - Quick Stats
///
/// This screen replaces the old static [AcademyScreen].
class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  AcademyService? _academyService;
  LearningProgress? _activeProgress;
  List<LearningPath> _paths = [];
  List<LearningPath> _recommendedPaths = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _academyService = AppBootstrap.maybeAcademyService;
    if (_academyService != null) {
      _academyService!.addListener(_onProgressChanged);
      _loadData();
    }
  }

  @override
  void dispose() {
    _academyService?.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  void _loadData() {
    final svc = _academyService;
    if (svc == null) return;
    setState(() {
      _paths = svc.allPaths;
      _activeProgress = svc.activePathProgress;
      _recommendedPaths = svc.getRecommendedPathsFromDna();
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = _academyService;

    if (svc == null) {
      return const PhoenixLoadingWidget(
        icon: Icons.school_rounded,
        title: 'Preparing your Academy...',
        subtitle: 'Loading learning paths and progress.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, svc),
          const SizedBox(height: AppSpacing.lg),
          if (_activeProgress != null) ...[
            _buildContinueLearning(context, svc),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildProgressOverview(context),
          const SizedBox(height: AppSpacing.lg),
          _buildLearningPaths(context),
          const SizedBox(height: AppSpacing.lg),
          if (_recommendedPaths.isNotEmpty) ...[
            _buildRecommendedPaths(context),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AcademyService svc) {
    final theme = Theme.of(context);
    final totalPaths = svc.allPaths.length;
    final activeCount = svc.allProgress.length;

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academy',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Master new skills through structured learning paths',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _QuickStat(
                value: '$totalPaths',
                label: 'Paths',
                icon: Icons.auto_awesome_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              _QuickStat(
                value: '$activeCount',
                label: 'Active',
                icon: Icons.trending_up_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.md),
              _QuickStat(
                value: '${_activeProgress?.totalScore ?? 0}',
                label: 'Points',
                icon: Icons.emoji_events_rounded,
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning(BuildContext context, AcademyService svc) {
    final theme = Theme.of(context);
    final progress = _activeProgress!;
    final current = svc.currentLesson;

    if (current == null) {
      return const SizedBox.shrink();
    }

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                color: theme.colorScheme.tertiary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Continue Learning',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.lessonId,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tap to resume your progress',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.academyLesson,
                      arguments: {
                        'pathId': progress.pathId,
                        'lessonId': current.lessonId,
                      },
                    );
                  },
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: theme.colorScheme.tertiary,
                  ),
                  tooltip: 'Resume lesson',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _activeProgress;

    if (progress == null) return const SizedBox.shrink();

    final percent = (progress.completionPercentage * 100).round();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Path Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percent%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixProgressIndicator(value: progress.completionPercentage),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                value: '${progress.completedModules}',
                label: 'Modules Done',
                theme: theme,
              ),
              _MiniStat(
                value: '${progress.totalModules - progress.completedModules}',
                label: 'Remaining',
                theme: theme,
              ),
              _MiniStat(
                value: '${progress.totalScore}',
                label: 'Score',
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPaths(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Learning Paths',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...(_paths.map((path) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _LearningPathCard(
            path: path,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.academyLesson,
                arguments: {'pathId': path.id},
              );
            },
          ),
        ))),
      ],
    );
  }

  Widget _buildRecommendedPaths(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Recommended for You',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...(_recommendedPaths.take(2).map(
          (path) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _LearningPathCard(
              path: path,
              compact: true,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.academyLesson,
                  arguments: {'pathId': path.id},
                );
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixPrimaryButton(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.missionCenter,
            ),
            label: 'View Missions',
            icon: Icons.rocket_launch_outlined,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          PhoenixPrimaryButton(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.knowledgeDna,
            ),
            label: 'View Knowledge DNA',
            icon: Icons.biotech_outlined,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

/// A compact stat widget for the header.
class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A mini stat row item.
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.theme,
  });

  final String value;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Card for a learning path in the grid/list.
class _LearningPathCard extends StatelessWidget {
  const _LearningPathCard({
    required this.path,
    required this.onTap,
    this.compact = false,
  });

  final LearningPath path;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(path.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFor(path.iconName),
                color: color,
                size: compact ? 22 : 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path.title,
                    style: (compact
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      path.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${path.estimatedHours}h',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.school_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${path.modules.length} modules',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'smartphone':
        return Icons.smartphone_rounded;
      case 'terminal':
        return Icons.terminal_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'account_tree':
        return Icons.account_tree_rounded;
      case 'lan':
        return Icons.lan_rounded;
      case 'business':
        return Icons.business_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}
