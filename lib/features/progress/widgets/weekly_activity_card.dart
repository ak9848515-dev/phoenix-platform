import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class WeeklyActivityCard extends StatelessWidget {
  const WeeklyActivityCard({super.key, required this.days});

  final List<DayActivity> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Activity', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              return _DayBar(
                label: day.label,
                value: day.value,
                maxValue: _maxValue(),
                color: theme.colorScheme.primary,
                theme: theme,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  double _maxValue() {
    if (days.isEmpty) return 1.0;
    final max = days.fold<double>(
      0,
      (max, day) => day.value > max ? day.value : max,
    );
    return max > 0 ? max : 1.0;
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.theme,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final barHeight = maxValue > 0 ? (value / maxValue) * 80.0 : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toInt().toString(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 24,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 24,
              height: barHeight.clamp(0, 80),
              decoration: BoxDecoration(
                color: value > 0 ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
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

class DayActivity {
  const DayActivity({required this.label, required this.value});

  final String label;
  final double value;
}
