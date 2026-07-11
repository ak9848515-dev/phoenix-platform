import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    super.key,
    required this.totalXp,
    required this.currentLevel,
    required this.currentStreak,
  });

  final int totalXp;
  final int currentLevel;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress Summary', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _ProgressRow(
            icon: Icons.stars_outlined,
            label: 'Total XP',
            value: totalXp.toString(),
            iconColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProgressRow(
            icon: Icons.trending_up_outlined,
            label: 'Current Level',
            value: currentLevel.toString(),
            iconColor: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProgressRow(
            icon: Icons.local_fire_department_outlined,
            label: 'Current Streak',
            value: '$currentStreak days',
            iconColor: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
