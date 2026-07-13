import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';

/// Header for the Marketplace screen showing the identity title and
/// description of the plugin management section.
class MarketplaceHeader extends StatelessWidget {
  const MarketplaceHeader({
    super.key,
    required this.identityTitle,
    this.installedCount = 0,
    this.availableCount = 0,
  });

  /// The user's selected identity title.
  final String identityTitle;

  /// Number of currently installed/active plugins.
  final int installedCount;

  /// Number of available plugins.
  final int availableCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.store_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Plugin Marketplace',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Manage your Phoenix plugins — installed and available.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Identity: $identityTitle',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            _StatBadge(
              icon: Icons.check_circle_outlined,
              label: '$installedCount installed',
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            _StatBadge(
              icon: Icons.add_circle_outlined,
              label: '$availableCount available',
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
