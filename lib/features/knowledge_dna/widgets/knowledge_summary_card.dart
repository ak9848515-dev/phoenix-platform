import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';

class KnowledgeSummaryCard extends StatelessWidget {
  const KnowledgeSummaryCard({
    super.key,
    required this.overallScore,
    required this.strongestCategory,
    required this.weakestCategory,
  });

  final double overallScore;
  final String strongestCategory;
  final String weakestCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scorePercent = (overallScore * 100).round();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Knowledge Summary', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$scorePercent%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Overall Score',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixProgressIndicator(value: overallScore),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _CategoryBadge(
                  label: 'Strongest',
                  value: strongestCategory,
                  color: theme.colorScheme.tertiary,
                  theme: theme,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CategoryBadge(
                  label: 'Needs Focus',
                  value: weakestCategory,
                  color: theme.colorScheme.error,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
