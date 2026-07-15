import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/habit.dart';
import '../models/habit_statistics.dart';
import '../services/habit_service.dart';
import '../widgets/habit_card.dart';
import '../widgets/streak_indicator.dart';
import 'habit_create_screen.dart';
import 'habit_detail_screen.dart';

/// Habit Dashboard — main view for tracking habits.
///
/// Shows:
/// - Overall streak and stats
/// - Today's habits with completion toggles
/// - Quick insights
class HabitDashboardScreen extends StatefulWidget {
  const HabitDashboardScreen({super.key});

  @override
  State<HabitDashboardScreen> createState() => _HabitDashboardScreenState();
}

class _HabitDashboardScreenState extends State<HabitDashboardScreen> {
  HabitService? _service;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = AppBootstrap.maybeHabitService;
    _service?.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _service?.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final svc = _service;
    if (svc == null) {
      return const PhoenixLoadingWidget(
        icon: Icons.checklist_rounded,
        title: 'Preparing your habits...',
        subtitle: 'Loading habit data and trends.',
      );
    }

    final habits = svc.activeHabits;
    final allStats = svc.allStatistics();
    final insights = svc.overallInsights();

    // Calculate overall stats
    int totalStreak = 0;
    double avgScore = 0;
    if (habits.isNotEmpty) {
      totalStreak = allStats.values
          .map((s) => s.currentStreak)
          .reduce((a, b) => a > b ? a : b);
      avgScore = allStats.values
              .fold(0.0, (sum, s) => sum + s.habitScore) /
          allStats.length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, svc, totalStreak, avgScore),
          const SizedBox(height: AppSpacing.lg),
          if (habits.isEmpty) _buildEmptyState(context, svc)
          else ...[
            // Today's habits
            _buildSectionTitle(context, 'Today', Icons.today_rounded),
            const SizedBox(height: AppSpacing.sm),
            ...habits.map((habit) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HabitCard(
                habit: habit,
                isCompleted: svc.isCompletedToday(habit.id),
                streak: allStats[habit.id]?.currentStreak ?? 0,
                onToggle: () => _toggleHabit(svc, habit),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HabitDetailScreen(habitId: habit.id),
                  ),
                ),
              ),
            )),
            const SizedBox(height: AppSpacing.lg),
            // Insights
            if (insights.isNotEmpty) ...[
              _buildSectionTitle(
                  context, 'Insights', Icons.lightbulb_rounded),
              const SizedBox(height: AppSpacing.sm),
              ...insights.take(3).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildInsightCard(context, insight),
              )),
              const SizedBox(height: AppSpacing.lg),
            ],
            // Quick stats
            _buildSectionTitle(context, 'Overview', Icons.bar_chart_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildOverviewGrid(context, habits, allStats),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    HabitService svc,
    int totalStreak,
    double avgScore,
  ) {
    final theme = Theme.of(context);
    final habits = svc.activeHabits;

    return PhoenixCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.checklist_rounded,
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
                  'Habits',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${habits.length} active habits',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          StreakIndicator(
            streak: totalStreak,
            size: StreakSize.medium,
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const HabitCreateScreen(),
              ),
            ),
            tooltip: 'Add Habit',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HabitService svc) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.checklist_outlined,
              size: 64, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No habits yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start tracking your daily habits to build\npowerful routines.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const HabitCreateScreen(),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create First Habit'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, dynamic insight) {
    final theme = Theme.of(context);
    final icon = _insightIcon(insight.type.name);
    final color = _insightColor(insight.type.name);

    return PhoenixCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (insight.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(
    BuildContext context,
    List<Habit> habits,
    Map<String, HabitStatistics> allStats,
  ) {
    final totalCompleted = allStats.values.fold(
        0, (sum, s) => sum + s.totalCompletions);
    final avgCompletion = allStats.values.isEmpty
        ? 0.0
        : allStats.values.fold(0.0, (sum, s) => sum + s.completionRate) /
            allStats.values.length;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '${habits.length}',
            label: 'Active Habits',
            icon: Icons.checklist_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '$totalCompleted',
            label: 'Completions',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '${(avgCompletion * 100).round()}%',
            label: 'Avg Rate',
            icon: Icons.trending_up_rounded,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleHabit(HabitService svc, Habit habit) async {
    if (svc.isCompletedToday(habit.id)) {
      await svc.undoToday(habit.id);
    } else {
      await svc.completeHabit(habit.id);
    }
  }

  IconData _insightIcon(String type) {
    switch (type) {
      case 'streak':
        return Icons.local_fire_department_rounded;
      case 'encouragement':
        return Icons.celebration_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'recommendation':
        return Icons.lightbulb_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _insightColor(String type) {
    switch (type) {
      case 'streak':
        return AppColors.warning;
      case 'encouragement':
        return AppColors.success;
      case 'warning':
        return Colors.orange;
      case 'recommendation':
        return AppColors.primary;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  ThemeData get theme => Theme.of(context);
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
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
    );
  }
}
