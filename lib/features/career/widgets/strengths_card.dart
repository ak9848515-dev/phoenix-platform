import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';
import '../services/career_service.dart';

class StrengthsCard extends StatelessWidget {
  const StrengthsCard({super.key, required this.strengths});

  final List<StrengthItem> strengths;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (strengths.isEmpty) {
      return const SizedBox.shrink();
    }

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_outlined,
                size: 20,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Your Strengths', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '${strengths.length} skills',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...strengths.map(
            (strength) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _StrengthRow(strength: strength, theme: theme),
            ),
          ),
        ],
      ),
    );
  }
}

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({required this.strength, required this.theme});

  final StrengthItem strength;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (strength.confidence * 100).round();

    final Color dotColor = switch (confidencePercent) {
      >= 80 => theme.colorScheme.tertiary,
      >= 60 => theme.colorScheme.secondary,
      _ => theme.colorScheme.primary,
    };

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strength.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${strength.category} • $confidencePercent% confidence',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
