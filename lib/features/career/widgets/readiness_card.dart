import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../../../theme/spacing.dart';

class ReadinessCard extends StatelessWidget {
  const ReadinessCard({
    super.key,
    required this.portfolioProgress,
    required this.resumeProgress,
    required this.interviewReadiness,
    required this.estimatedWeeks,
  });

  final double portfolioProgress;
  final double resumeProgress;
  final double interviewReadiness;
  final int estimatedWeeks;

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
                Icons.assessment_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Readiness Breakdown', style: theme.textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '~$estimatedWeeks weeks',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _ReadinessRow(
            label: 'Portfolio',
            value: portfolioProgress,
            icon: Icons.folder_outlined,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.md),
          _ReadinessRow(
            label: 'Resume',
            value: resumeProgress,
            icon: Icons.description_outlined,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.md),
          _ReadinessRow(
            label: 'Interview',
            value: interviewReadiness,
            icon: Icons.record_voice_over_outlined,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  final String label;
  final double value;
  final IconData icon;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              PhoenixProgressIndicator(value: value, minHeight: 6),
            ],
          ),
        ),
      ],
    );
  }
}
