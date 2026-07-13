import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_progress_indicator.dart';
import '../models/opportunity.dart';

/// Displays recommended career opportunities with match scores.
class RecommendedOpportunitiesCard extends StatelessWidget {
  const RecommendedOpportunitiesCard({super.key, required this.opportunities});

  final List<Opportunity> opportunities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (opportunities.isEmpty) return const SizedBox.shrink();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Recommended Opportunities',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...opportunities.map(
            (opp) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          opp.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _typeColor(opp.type, theme).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _typeLabel(opp.type),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _typeColor(opp.type, theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PhoenixProgressIndicator(value: opp.matchScore, minHeight: 6),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Match: ${(opp.matchScore * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        opp.estimatedTimeline,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opp.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(OpportunityType type, ThemeData theme) {
    switch (type) {
      case OpportunityType.fullTimeJob:
        return theme.colorScheme.primary;
      case OpportunityType.internship:
        return theme.colorScheme.tertiary;
      case OpportunityType.freelance:
        return Colors.orange;
      case OpportunityType.openSource:
        return Colors.purple;
      case OpportunityType.certification:
        return Colors.green;
      case OpportunityType.startup:
        return Colors.blue;
      case OpportunityType.hackathon:
        return Colors.pink;
    }
  }

  String _typeLabel(OpportunityType type) {
    switch (type) {
      case OpportunityType.fullTimeJob:
        return 'Full-Time';
      case OpportunityType.internship:
        return 'Internship';
      case OpportunityType.freelance:
        return 'Freelance';
      case OpportunityType.openSource:
        return 'Open Source';
      case OpportunityType.certification:
        return 'Cert';
      case OpportunityType.startup:
        return 'Startup';
      case OpportunityType.hackathon:
        return 'Hackathon';
    }
  }
}
