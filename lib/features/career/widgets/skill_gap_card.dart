import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';
import '../services/career_service.dart';

class SkillGapCard extends StatelessWidget {
  const SkillGapCard({super.key, required this.gaps});

  final List<GapItem> gaps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (gaps.isEmpty) {
      return const SizedBox.shrink();
    }

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_graph_outlined,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Skill Gaps', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '${gaps.length} to address',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...gaps.map(
            (gap) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _GapRow(gap: gap, theme: theme),
            ),
          ),
        ],
      ),
    );
  }
}

class _GapRow extends StatelessWidget {
  const _GapRow({required this.gap, required this.theme});

  final GapItem gap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final Color priorityColor = switch (gap.priority) {
      'High' => theme.colorScheme.error,
      'Medium' => theme.colorScheme.tertiary,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.arrow_upward_rounded,
            size: 14,
            color: priorityColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gap.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (gap.isCurrentStage)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs + 2,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'current',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${gap.priority} priority',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: priorityColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
