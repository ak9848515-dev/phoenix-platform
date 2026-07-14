import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../services/habit_service.dart';
import '../widgets/consistency_chart.dart';
import '../widgets/habit_calendar.dart';
import '../widgets/streak_indicator.dart';

/// Full detail view for a single habit with analytics and insights.
class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final habit = svc.getHabit(widget.habitId);
    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Not Found')),
        body: const Center(child: Text('Habit not found')),
      );
    }

    final stats = svc.statisticsFor(widget.habitId);
    final weeklyTrend = svc.weeklyTrendFor(widget.habitId);
    final monthlyTrend = svc.monthlyTrendFor(widget.habitId);
    final insights = svc.insightsFor(widget.habitId);
    final entries = svc.entriesForHabit(widget.habitId);
    final isCompleted = svc.isCompletedToday(widget.habitId);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              // Future: edit habit screen
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final navigator = Navigator.of(context);
              // ignore: use_build_context_synchronously
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Habit'),
                  content: Text('Are you sure you want to delete "${habit.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await svc.deleteHabit(widget.habitId);
                if (mounted) navigator.pop(true);
              }
            },
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak & Score section
            _buildStreakSection(context, stats, isCompleted),
            const SizedBox(height: AppSpacing.lg),
            // Completion toggle
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  if (isCompleted) {
                    await svc.undoToday(widget.habitId);
                  } else {
                    await svc.completeHabit(widget.habitId);
                  }
                },
                icon: Icon(isCompleted
                    ? Icons.undo_rounded
                    : Icons.check_circle_rounded),
                label: Text(isCompleted
                    ? 'Undo Completion'
                    : 'Complete Today'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Stats grid
            _buildStatsGrid(context, stats),
            const SizedBox(height: AppSpacing.lg),
            // Weekly trend chart
            _buildSectionTitle(context, 'Weekly Trend', Icons.trending_up_rounded),
            const SizedBox(height: AppSpacing.sm),
            PhoenixCard(
              child: ConsistencyChart(dataPoints: weeklyTrend.dataPoints),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Monthly trend chart
            _buildSectionTitle(context, 'Monthly Trend', Icons.date_range_rounded),
            const SizedBox(height: AppSpacing.sm),
            PhoenixCard(
              child: ConsistencyChart(dataPoints: monthlyTrend.dataPoints),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Calendar
            _buildSectionTitle(context, 'Calendar', Icons.calendar_month_rounded),
            const SizedBox(height: AppSpacing.sm),
            PhoenixCard(
              child: HabitCalendar(entries: entries),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Insights
            if (insights.isNotEmpty) ...[
              _buildSectionTitle(context, 'Insights', Icons.lightbulb_rounded),
              const SizedBox(height: AppSpacing.sm),
              ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildInsightCard(context, insight),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection(
    BuildContext context,
    dynamic stats,
    bool isCompleted,
  ) {
    final theme = Theme.of(context);
    final color = _scoreColor(stats.habitScore);

    return PhoenixCard(
      child: Row(
        children: [
          StreakIndicator(
            streak: stats.currentStreak,
            longestStreak: stats.longestStreak,
            size: StreakSize.large,
          ),
          const Spacer(),
          ConsistencyScore(
            score: stats.completionRate,
            label: 'Completion Rate',
            size: 70,
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                '${stats.habitScore.round()}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'Score',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic stats) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '${stats.totalCompletions}',
            label: 'Completed',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '${stats.longestStreak}',
            label: 'Best Streak',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '${(stats.weeklyConsistency * 100).round()}%',
            label: 'Weekly',
            icon: Icons.trending_up_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '${(stats.monthlyConsistency * 100).round()}%',
            label: 'Monthly',
            icon: Icons.date_range_rounded,
            color: Colors.teal,
          ),
        ),
      ],
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
    return PhoenixCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                size: 18, color: AppColors.primary),
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

  Color _scoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return Colors.orange;
  }
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
          Icon(icon, size: 16, color: color),
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
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
