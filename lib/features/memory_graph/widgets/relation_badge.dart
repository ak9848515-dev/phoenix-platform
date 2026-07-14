import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../models/relation_type.dart';

/// A badge displaying a relationship type with color and optional arrow.
class RelationBadge extends StatelessWidget {
  const RelationBadge({
    super.key,
    required this.type,
    this.showArrow = false,
    this.size = BadgeSize.small,
  });

  final RelationType type;
  final bool showArrow;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(type);
    final fontSize = size == BadgeSize.small ? 10.0 : 12.0;
    final padding = size == BadgeSize.small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showArrow && type.isDirected) ...[
            Icon(
              type == RelationType.parent ||
                      type == RelationType.createdBy ||
                      type == RelationType.completedBy
                  ? Icons.arrow_back_rounded
                  : Icons.arrow_forward_rounded,
              size: 10,
              color: color,
            ),
            const SizedBox(width: 2),
          ],
          if (showArrow && !type.isDirected)
            Icon(Icons.remove_rounded, size: 10, color: color),
          Text(
            type.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForType(RelationType type) {
    switch (type) {
      case RelationType.dependsOn:
        return Colors.red;
      case RelationType.relatedTo:
        return AppColors.primary;
      case RelationType.createdBy:
        return Colors.green;
      case RelationType.completedBy:
        return Colors.teal;
      case RelationType.learnedFrom:
        return Colors.indigo;
      case RelationType.leadsTo:
        return Colors.orange;
      case RelationType.blocks:
        return Colors.red;
      case RelationType.strengthens:
        return AppColors.success;
      case RelationType.weakens:
        return Colors.orange;
      case RelationType.references:
        return Colors.blueGrey;
      case RelationType.parent:
        return const Color(0xFF7C3AED);
      case RelationType.child:
        return Colors.purple;
      case RelationType.similar:
        return Colors.cyan;
      case RelationType.associated:
        return Colors.grey;
      case RelationType.custom:
        return Colors.amber;
    }
  }
}

enum BadgeSize { small, medium }
