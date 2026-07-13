import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../models/portfolio_project.dart';

/// Displays the user's featured portfolio projects and missions.
class FeaturedProjectsCard extends StatelessWidget {
  const FeaturedProjectsCard({super.key, required this.projects});

  final List<PortfolioProject> projects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = projects.where((p) => p.isCompleted).toList();
    final inProgress = projects.where((p) => !p.isCompleted).toList();

    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Featured Projects', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '${projects.length} total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (inProgress.isNotEmpty) ...[
            Text(
              'In Progress',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...inProgress.take(3).map((p) => _ProjectItem(project: p)),
            const SizedBox(height: AppSpacing.md),
          ],
          if (completed.isNotEmpty) ...[
            Text(
              'Completed',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...completed.take(3).map((p) => _ProjectItem(project: p)),
          ],
          if (projects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'Complete missions to build your portfolio.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectItem extends StatelessWidget {
  const _ProjectItem({required this.project});

  final PortfolioProject project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            project.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 18,
            color: project.isCompleted
                ? Colors.green
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (project.skills.isNotEmpty)
                  Text(
                    project.skills.join(', '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              project.type,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
