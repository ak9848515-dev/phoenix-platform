import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';

/// Displays the user's technology stack as labeled chips.
class TechnologyStackCard extends StatelessWidget {
  const TechnologyStackCard({super.key, required this.technologies});

  final List<String> technologies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (technologies.isEmpty) {
      return const SizedBox.shrink();
    }

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Technology Stack', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '${technologies.length} tools',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: technologies.map((tech) {
              return Chip(
                label: Text(
                  tech,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: theme.colorScheme.secondaryContainer,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
