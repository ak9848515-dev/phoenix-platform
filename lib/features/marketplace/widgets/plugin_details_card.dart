import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../models/marketplace_plugin.dart';

/// Displays detailed information about a specific plugin including
/// version, compatibility, dependencies, and description.
class PluginDetailsCard extends StatelessWidget {
  const PluginDetailsCard({super.key, required this.plugin});

  /// The plugin to display details for.
  final MarketplacePlugin plugin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.extension_outlined,
                  size: 22,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plugin.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'by ${plugin.author}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        plugin.formattedRating,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${plugin.formattedDownloads} downloads',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(plugin.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Version', value: plugin.version, theme: theme),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(label: 'Category', value: plugin.category, theme: theme),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            label: 'Min Phoenix Version',
            value: plugin.minPhoenixVersion,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            label: 'Plugin API Version',
            value: plugin.pluginApiVersion,
            theme: theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            label: 'Status',
            value: plugin.isActive ? 'Active' : 'Installed',
            theme: theme,
            valueColor: plugin.isActive ? Colors.green : null,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
