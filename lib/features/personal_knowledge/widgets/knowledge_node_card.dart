import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/knowledge_domain.dart';
import '../models/knowledge_node.dart';

/// A card displaying a knowledge node with domain icon,
/// label, proficiency bar, and importance indicator.
class KnowledgeNodeCard extends StatelessWidget {
  const KnowledgeNodeCard({
    super.key,
    required this.node,
    this.isSelected = false,
    this.onTap,
    this.showProficiency = true,
  });

  final KnowledgeNode node;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showProficiency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final domainColor = _domainColor(node.domain);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? domainColor.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? domainColor.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: domainColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                node.domain.icon,
                size: 18,
                color: domainColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (node.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        node.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (showProficiency && node.proficiency > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: node.proficiency,
                                backgroundColor:
                                    domainColor.withValues(alpha: 0.1),
                                color: domainColor,
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(node.proficiency * 100).round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (node.importance > 0.5)
              Icon(Icons.star_rounded,
                  size: 14,
                  color: AppColors.warning.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  Color _domainColor(KnowledgeDomain domain) {
    switch (domain) {
      case KnowledgeDomain.skills:
        return AppColors.primary;
      case KnowledgeDomain.goals:
        return AppColors.warning;
      case KnowledgeDomain.learning:
        return const Color(0xFF7C4DFF);
      case KnowledgeDomain.career:
        return const Color(0xFF00BCD4);
      case KnowledgeDomain.projects:
        return const Color(0xFFFF6F00);
      case KnowledgeDomain.portfolio:
        return const Color(0xFF2E7D32);
      case KnowledgeDomain.resume:
        return const Color(0xFF1565C0);
      case KnowledgeDomain.missions:
        return const Color(0xFFD32F2F);
      case KnowledgeDomain.habits:
        return const Color(0xFF6A1B9A);
      case KnowledgeDomain.decisions:
        return const Color(0xFF00838F);
      case KnowledgeDomain.timeline:
        return const Color(0xFF4E342E);
      case KnowledgeDomain.aiConversations:
        return const Color(0xFF37474F);
      case KnowledgeDomain.custom:
        return Colors.grey;
    }
  }
}
