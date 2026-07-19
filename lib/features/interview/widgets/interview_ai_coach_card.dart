import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';

/// Displays the AI Interview Coach summary with readiness insights
/// and the next best action.
class InterviewAICoachCard extends StatelessWidget {
  const InterviewAICoachCard({
    super.key,
    required this.summary,
    required this.nextBestAction,
    required this.readinessScore,
    required this.onStartPractice,
  });

  final String summary;
  final String nextBestAction;
  final double readinessScore;
  final VoidCallback onStartPractice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady = readinessScore >= 0.7;
    final needsPrep = readinessScore < 0.4;
    final accentColor = isReady
        ? PhoenixColors.success
        : needsPrep
            ? PhoenixColors.warning
            : PhoenixColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withAlpha(25),
            accentColor.withAlpha(8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: PhoenixRadius.xlRadius,
        border: Border.all(
          color: accentColor.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isReady
                      ? Icons.auto_awesome_rounded
                      : Icons.tips_and_updates_rounded,
                  size: 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: PhoenixSpacing.sm),
              Text(
                'AI Interview Coach',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics_outlined,
                        size: 14, color: accentColor),
                    const SizedBox(width: 4),
                    Text(
                      '${(readinessScore * 100).round()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          Text(
            summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (nextBestAction.isNotEmpty) ...[
            const SizedBox(height: PhoenixSpacing.md),
            Container(
              padding: const EdgeInsets.all(PhoenixSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 16,
                    color: PhoenixColors.warning,
                  ),
                  const SizedBox(width: PhoenixSpacing.sm),
                  Expanded(
                    child: Text(
                      'Next: $nextBestAction',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: PhoenixSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartPractice,
              icon: Icon(
                isReady ? Icons.refresh_rounded : Icons.play_arrow_rounded,
                size: 18,
              ),
              label: Text(isReady ? 'Practice Again' : 'Start Practice'),
            ),
          ),
        ],
      ),
    );
  }
}
