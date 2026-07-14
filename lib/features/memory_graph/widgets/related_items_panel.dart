import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../models/memory_context.dart';
import '../models/memory_entity.dart';
import 'entity_card.dart';
import 'relation_badge.dart';

/// A panel showing entities related to a focal entity, grouped by relation type.
class RelatedItemsPanel extends StatelessWidget {
  const RelatedItemsPanel({
    super.key,
    required this.memoryContext,
    this.onEntityTap,
  });

  final MemoryContext memoryContext;
  final void Function(MemoryEntity entity)? onEntityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mc = memoryContext;
    final grouped = mc.groupedByRelation;

    if (grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No related entities found.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RelationBadge(
                    type: mc.relations
                        .firstWhere(
                          (r) => r.type.label == entry.key,
                          orElse: () => mc.relations.first,
                        )
                        .type,
                    showArrow: true,
                    size: BadgeSize.medium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${entry.value.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...entry.value.map((entity) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: EntityCard(
                  entity: entity,
                  onTap: onEntityTap != null
                      ? () => onEntityTap!(entity)
                      : null,
                ),
              )),
            ],
          ),
        );
      }).toList(),
    );
  }
}
