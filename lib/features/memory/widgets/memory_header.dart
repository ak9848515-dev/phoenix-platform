import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';

/// Displays the header for the Memory Screen with a title and subtitle.
class MemoryHeader extends StatelessWidget {
  const MemoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.history_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Memory',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your journey, captured. Every milestone, decision, and '
          'reflection shapes who you are becoming.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
