import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';

/// Displays the "Who do you want to become?" header for the identity
/// selection screen.
class IdentityHeader extends StatelessWidget {
  const IdentityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.face_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Who do you want to become?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Choose an identity to define your growth path. '
          'This shapes your missions, learning, and progress.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}