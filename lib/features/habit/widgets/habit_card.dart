import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/habit.dart';
import '../models/habit_type.dart';

/// A card displaying a single habit with completion toggle.
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    this.isCompleted = false,
    this.streak = 0,
    this.onToggle,
    this.onTap,
  });

  final Habit habit;
  final bool isCompleted;
  final int streak;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(habit.type);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isCompleted
              ? color.withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isCompleted
                ? color.withValues(alpha: 0.06)
                : theme.colorScheme.surface,
          ),
          child: Row(
            children: [
              // Type icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isCompleted ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(habit.type),
                  size: 22,
                  color: isCompleted ? color : color.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Title & info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          habit.type.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (streak > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.local_fire_department_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            '$streak',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (habit.schedule.timeOfDay != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.schedule_rounded,
                              size: 12, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            habit.schedule.timeOfDay!.formatted,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Completion toggle
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? color
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? color
                          : theme.colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForType(HabitType type) {
    switch (type) {
      case HabitType.learning:
        return AppColors.primary;
      case HabitType.health:
        return Colors.red;
      case HabitType.exercise:
        return Colors.orange;
      case HabitType.reading:
        return Colors.indigo;
      case HabitType.meditation:
        return Colors.teal;
      case HabitType.coding:
        return Colors.blue;
      case HabitType.career:
        return const Color(0xFF7C3AED);
      case HabitType.finance:
        return Colors.green;
      case HabitType.productivity:
        return Colors.amber;
      case HabitType.family:
        return Colors.pink;
      case HabitType.custom:
        return Colors.grey;
    }
  }

  IconData _iconForType(HabitType type) {
    switch (type) {
      case HabitType.learning:
        return Icons.school_rounded;
      case HabitType.health:
        return Icons.favorite_rounded;
      case HabitType.exercise:
        return Icons.fitness_center_rounded;
      case HabitType.reading:
        return Icons.menu_book_rounded;
      case HabitType.meditation:
        return Icons.self_improvement_rounded;
      case HabitType.coding:
        return Icons.code_rounded;
      case HabitType.career:
        return Icons.work_rounded;
      case HabitType.finance:
        return Icons.account_balance_rounded;
      case HabitType.productivity:
        return Icons.checklist_rounded;
      case HabitType.family:
        return Icons.family_restroom_rounded;
      case HabitType.custom:
        return Icons.star_rounded;
    }
  }
}
