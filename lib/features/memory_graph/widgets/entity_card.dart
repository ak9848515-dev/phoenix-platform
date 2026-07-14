import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/entity_type.dart';
import '../models/memory_entity.dart';

/// A card displaying a memory graph entity.
class EntityCard extends StatelessWidget {
  const EntityCard({
    super.key,
    required this.entity,
    this.relationCount = 0,
    this.onTap,
    this.isSelected = false,
  });

  final MemoryEntity entity;
  final int relationCount;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(entity.type);

    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? color
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Semantics(
        label: '${entity.title}, ${entity.type.label}',
        hint: onTap != null ? 'Double-tap to view details' : null,
        button: onTap != null,
        enabled: onTap != null,
        child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForType(entity.type),
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entity.type.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        if (relationCount > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.link_rounded,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            '$relationCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (entity.importance > 0.7) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.auto_awesome_rounded,
                              size: 12, color: AppColors.warning),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Color _colorForType(EntityType type) {
    switch (type) {
      case EntityType.person:
        return Colors.teal;
      case EntityType.skill:
        return const Color(0xFF7C3AED);
      case EntityType.project:
        return Colors.blue;
      case EntityType.goal:
        return AppColors.warning;
      case EntityType.habit:
        return Colors.orange;
      case EntityType.mission:
        return AppColors.primary;
      case EntityType.lesson:
        return Colors.indigo;
      case EntityType.decision:
        return const Color(0xFF0891B2);
      case EntityType.career:
        return Colors.green;
      case EntityType.resume:
        return Colors.blueGrey;
      case EntityType.portfolio:
        return Colors.teal;
      case EntityType.interview:
        return Colors.purple;
      case EntityType.opportunity:
        return Colors.cyan;
      case EntityType.timelineEvent:
        return Colors.amber;
      case EntityType.aiConversation:
        return Colors.pink;
      case EntityType.document:
        return Colors.brown;
      case EntityType.custom:
        return Colors.grey;
    }
  }

  IconData _iconForType(EntityType type) {
    switch (type) {
      case EntityType.person:
        return Icons.person_rounded;
      case EntityType.skill:
        return Icons.psychology_rounded;
      case EntityType.project:
        return Icons.folder_rounded;
      case EntityType.goal:
        return Icons.flag_rounded;
      case EntityType.habit:
        return Icons.checklist_rounded;
      case EntityType.mission:
        return Icons.rocket_launch_rounded;
      case EntityType.lesson:
        return Icons.school_rounded;
      case EntityType.decision:
        return Icons.account_tree_rounded;
      case EntityType.career:
        return Icons.work_rounded;
      case EntityType.resume:
        return Icons.description_rounded;
      case EntityType.portfolio:
        return Icons.folder_special_rounded;
      case EntityType.interview:
        return Icons.record_voice_over_rounded;
      case EntityType.opportunity:
        return Icons.trending_up_rounded;
      case EntityType.timelineEvent:
        return Icons.timeline_rounded;
      case EntityType.aiConversation:
        return Icons.auto_awesome_rounded;
      case EntityType.document:
        return Icons.article_rounded;
      case EntityType.custom:
        return Icons.star_rounded;
    }
  }
}
