import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/spacing.dart';

class MissionHeader extends StatelessWidget {
  const MissionHeader({
    super.key,
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.priority,
  });

  final String title;
  final String description;
  final String statusLabel;
  final String priority;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color priorityColor = switch (priority.toLowerCase()) {
      'high' => theme.colorScheme.error,
      'medium' => theme.colorScheme.tertiary,
      'low' => theme.colorScheme.secondary,
      _ => theme.colorScheme.primary,
    };

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.flag_outlined, size: 16, color: priorityColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Priority: $priority',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: priorityColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
