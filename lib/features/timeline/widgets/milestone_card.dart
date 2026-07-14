import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/milestone.dart';
import '../models/timeline_category.dart';

/// A card displaying a milestone with visual prominence.
class MilestoneCard extends StatelessWidget {
  const MilestoneCard({
    super.key,
    required this.milestone,
    this.onTap,
  });

  final Milestone milestone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForCategory(milestone.category);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          milestone.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      if (milestone.isPinned)
                        Icon(Icons.push_pin_rounded,
                            size: 14, color: AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    milestone.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(milestone.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForCategory(TimelineCategory category) {
    switch (category) {
      case TimelineCategory.learning:
        return AppColors.primary;
      case TimelineCategory.mission:
        return Colors.orange;
      case TimelineCategory.achievement:
        return AppColors.warning;
      case TimelineCategory.career:
        return const Color(0xFF7C3AED);
      case TimelineCategory.portfolio:
        return Colors.teal;
      case TimelineCategory.resume:
        return Colors.blue;
      case TimelineCategory.interview:
        return Colors.purple;
      case TimelineCategory.decision:
        return const Color(0xFF0891B2);
      case TimelineCategory.ai:
        return const Color(0xFFD97706);
      case TimelineCategory.voice:
        return Colors.indigo;
      case TimelineCategory.marketplace:
        return Colors.pink;
      case TimelineCategory.system:
        return Colors.grey;
      case TimelineCategory.custom:
        return Colors.amber;
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
