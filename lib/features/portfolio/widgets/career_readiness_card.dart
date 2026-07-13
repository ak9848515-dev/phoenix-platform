import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';

/// Displays detailed career readiness metrics from the Career Profile.
class CareerReadinessCard extends StatelessWidget {
  const CareerReadinessCard({
    super.key,
    required this.careerScore,
    required this.careerReadiness,
    required this.strengthAreas,
    required this.improvementAreas,
  });

  final double careerScore;
  final String careerReadiness;
  final List<String> strengthAreas;
  final List<String> improvementAreas;

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
                Icons.trending_up_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Career Readiness', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Career Score',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PhoenixProgressIndicator(value: careerScore, minHeight: 8),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(careerScore * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Status',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      careerReadiness,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (strengthAreas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Strengths',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...strengthAreas
                .take(3)
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green.shade400,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(s, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          if (improvementAreas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Focus Areas',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.orange.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...improvementAreas
                .take(3)
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 14,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(s, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
