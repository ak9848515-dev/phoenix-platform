import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';

/// Displays improvement areas and recommended topics for interview prep.
class ImprovementCard extends StatelessWidget {
  const ImprovementCard({
    super.key,
    required this.improvementAreas,
    required this.recommendedTopics,
  });

  final List<String> improvementAreas;
  final List<String> recommendedTopics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (improvementAreas.isEmpty && recommendedTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_outlined,
                size: 20,
                color: Colors.orange.shade600,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Focus Areas', style: theme.textTheme.titleMedium),
            ],
          ),
          if (improvementAreas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Areas to Improve',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...improvementAreas
                .take(4)
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(a, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          if (recommendedTopics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Recommended Topics',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: recommendedTopics.take(6).map((topic) {
                return Chip(
                  label: Text(
                    topic,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
