import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../models/opportunity_gap.dart';

/// Displays skill gaps and missing skills for opportunities.
class SkillGapCard extends StatelessWidget {
  const SkillGapCard({
    super.key,
    required this.missingSkills,
    required this.gaps,
  });

  final List<String> missingSkills;
  final List<OpportunityGap> gaps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (missingSkills.isEmpty && gaps.isEmpty) return const SizedBox.shrink();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.orange.shade600),
              const SizedBox(width: AppSpacing.sm),
              Text('Closing Gaps', style: theme.textTheme.titleMedium),
            ],
          ),
          if (missingSkills.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Skills to Develop',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...missingSkills
                .take(4)
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(s, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          if (gaps.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Recommended Actions',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...gaps
                .take(3)
                .map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.skill,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                g.action,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
