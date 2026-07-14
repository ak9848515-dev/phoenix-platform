import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/entity_type.dart';
import '../models/memory_cluster.dart';
import '../models/memory_entity.dart';
import 'entity_card.dart';

/// A card displaying a cluster of related entities.
class EntityClusterCard extends StatelessWidget {
  const EntityClusterCard({
    super.key,
    required this.cluster,
    this.onEntityTap,
  });

  final MemoryCluster cluster;
  final void Function(MemoryEntity entity)? onEntityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dominant = cluster.dominantType;
    final color = dominant != null ? _colorForType(dominant) : AppColors.primary;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.group_work_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cluster.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${cluster.entityCount} entities',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${cluster.relationCount} connections',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (cluster.score > 0.5)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(cluster.score * 100).round()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (cluster.entities.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ...cluster.entities.take(5).map((entity) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: EntityCard(
                  entity: entity,
                  onTap: onEntityTap != null
                      ? () => onEntityTap!(entity)
                      : null,
                ),
              )),
              if (cluster.entities.length > 5)
                Text(
                  '+${cluster.entities.length - 5} more',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _colorForType(EntityType type) => _iconColor(type);

  Color _iconColor(EntityType type) {
    switch (type) {
      case EntityType.skill:
        return const Color(0xFF7C3AED);
      case EntityType.habit:
        return Colors.orange;
      case EntityType.mission:
        return AppColors.primary;
      case EntityType.lesson:
        return Colors.indigo;
      case EntityType.decision:
        return const Color(0xFF0891B2);
      case EntityType.portfolio:
        return Colors.teal;
      case EntityType.resume:
        return Colors.blueGrey;
      default:
        return AppColors.primary;
    }
  }
}
