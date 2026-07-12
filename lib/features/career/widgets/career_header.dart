import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';

class CareerHeader extends StatelessWidget {
  const CareerHeader({
    super.key,
    required this.identityTitle,
    required this.careerScore,
    required this.jobReadiness,
  });

  final String identityTitle;
  final double careerScore;
  final String jobReadiness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scorePercent = (careerScore * 100).round();

    final Color scoreColor = switch (jobReadiness) {
      'Ready' => theme.colorScheme.tertiary,
      'Nearly Ready' => theme.colorScheme.secondary,
      'Building' => theme.colorScheme.primary,
      'Exploring' => theme.colorScheme.tertiary.withValues(alpha: 0.8),
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  size: 28,
                  color: scoreColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Career Readiness',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      identityTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$scorePercent%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      jobReadiness,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PhoenixProgressIndicator(value: careerScore, valueColor: scoreColor),
        ],
      ),
    );
  }
}
