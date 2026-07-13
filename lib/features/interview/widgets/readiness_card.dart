import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';

/// Displays interview readiness scores.
class ReadinessCard extends StatelessWidget {
  const ReadinessCard({
    super.key,
    required this.technicalScore,
    required this.behavioralScore,
    required this.communicationScore,
  });

  final double technicalScore;
  final double behavioralScore;
  final double communicationScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Readiness Breakdown', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ScoreBar(
            label: 'Technical',
            score: technicalScore,
            color: theme.colorScheme.primary,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScoreBar(
            label: 'Behavioral',
            score: behavioralScore,
            color: theme.colorScheme.tertiary,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScoreBar(
            label: 'Communication',
            score: communicationScore,
            color: Colors.green,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({
    required this.label,
    required this.score,
    required this.color,
    required this.theme,
  });

  final String label;
  final double score;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text(
              '${(score * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        PhoenixProgressIndicator(value: score, minHeight: 8, valueColor: color),
      ],
    );
  }
}
