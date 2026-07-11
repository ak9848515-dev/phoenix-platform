import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class KnowledgeBalanceCard extends StatelessWidget {
  const KnowledgeBalanceCard({
    super.key,
    required this.knowledgeScore,
    required this.confidenceScore,
    required this.retentionScore,
    required this.learningVelocity,
  });

  final double knowledgeScore;
  final double confidenceScore;
  final double retentionScore;
  final double learningVelocity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Learning Balance', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _BalanceRow(
            label: 'Knowledge',
            value: knowledgeScore,
            color: theme.colorScheme.primary,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BalanceRow(
            label: 'Confidence',
            value: confidenceScore,
            color: theme.colorScheme.tertiary,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BalanceRow(
            label: 'Retention',
            value: retentionScore,
            color: theme.colorScheme.secondary,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BalanceRow(
            label: 'Velocity',
            value: learningVelocity,
            color: theme.colorScheme.primary,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final String label;
  final double value;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 36,
          child: Text(
            '$percent%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
