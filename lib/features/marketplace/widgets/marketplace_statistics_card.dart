import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';

/// Displays summary statistics about the marketplace.
class MarketplaceStatisticsCard extends StatelessWidget {
  const MarketplaceStatisticsCard({
    super.key,
    required this.totalPlugins,
    required this.activeCount,
    required this.availableCount,
  });

  /// Total number of plugins in the marketplace.
  final int totalPlugins;

  /// Number of currently active plugins.
  final int activeCount;

  /// Number of available (non-active) plugins.
  final int availableCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adoptionRate = totalPlugins > 0 ? activeCount / totalPlugins : 0.0;

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.extension_outlined,
                  label: 'Total',
                  value: '$totalPlugins',
                  theme: theme,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle_outlined,
                  label: 'Active',
                  value: '$activeCount',
                  theme: theme,
                  color: Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              Expanded(
                child: _StatTile(
                  icon: Icons.add_circle_outlined,
                  label: 'Available',
                  value: '$availableCount',
                  theme: theme,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Adoption',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PhoenixProgressIndicator(
                  value: adoptionRate,
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${(adoptionRate * 100).round()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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
