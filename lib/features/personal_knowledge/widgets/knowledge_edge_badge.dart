import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../models/knowledge_edge.dart';

/// A small badge displaying a knowledge edge type with
/// color coding and direction arrow.
class KnowledgeEdgeBadge extends StatelessWidget {
  const KnowledgeEdgeBadge({
    super.key,
    required this.edge,
    this.size = KnowledgeEdgeBadgeSize.small,
  });

  final KnowledgeEdge edge;
  final KnowledgeEdgeBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _edgeColor(edge.type);
    final isSmall = size == KnowledgeEdgeBadgeSize.small;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (edge.type.isDirectional)
            Icon(
              edge.type == KnowledgeEdgeType.requires_ ||
                      edge.type == KnowledgeEdgeType.prerequisite
                  ? Icons.arrow_back_rounded
                  : Icons.arrow_forward_rounded,
              size: isSmall ? 10 : 12,
              color: color,
            ),
          if (edge.type.isDirectional)
            const SizedBox(width: 3),
          Text(
            edge.label ?? edge.type.label,
            style: (isSmall
                    ? theme.textTheme.labelSmall
                    : theme.textTheme.bodySmall)
                ?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: isSmall ? 9 : 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _edgeColor(KnowledgeEdgeType type) {
    switch (type) {
      case KnowledgeEdgeType.requires_:
        return AppColors.error;
      case KnowledgeEdgeType.buildsToward:
        return AppColors.success;
      case KnowledgeEdgeType.strengthens:
        return AppColors.success;
      case KnowledgeEdgeType.weakens:
        return AppColors.error;
      case KnowledgeEdgeType.relatedTo:
        return AppColors.primary;
      case KnowledgeEdgeType.similarTo:
        return const Color(0xFF7C4DFF);
      case KnowledgeEdgeType.prerequisite:
        return AppColors.warning;
      case KnowledgeEdgeType.outcome:
        return AppColors.success;
      case KnowledgeEdgeType.alternative:
        return const Color(0xFF00BCD4);
      case KnowledgeEdgeType.partOf:
        return const Color(0xFFFF6F00);
      case KnowledgeEdgeType.recommended:
        return AppColors.primary;
      case KnowledgeEdgeType.custom:
        return Colors.grey;
    }
  }
}

enum KnowledgeEdgeBadgeSize { small, medium }
