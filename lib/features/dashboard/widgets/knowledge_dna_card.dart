import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class KnowledgeDNACard extends StatelessWidget {
  const KnowledgeDNACard({
    super.key,
    required this.confidence,
    required this.retention,
    required this.consistency,
  });

  final double confidence;
  final double retention;
  final double consistency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Knowledge DNA', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(label: 'Confidence', value: confidence),
          const SizedBox(height: AppSpacing.sm),
          _MetricRow(label: 'Retention', value: retention),
          const SizedBox(height: AppSpacing.sm),
          _MetricRow(label: 'Consistency', value: consistency),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (value * 100).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text('$percent%', style: theme.textTheme.titleMedium),
      ],
    );
  }
}
