import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.dailyStreak,
    required this.weeklyStreak,
  });

  final int dailyStreak;
  final int weeklyStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Streaks', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _StreakRow(label: 'Daily', value: dailyStreak),
          const SizedBox(height: AppSpacing.sm),
          _StreakRow(label: 'Weekly', value: weeklyStreak),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text('$value', style: theme.textTheme.titleMedium),
      ],
    );
  }
}
