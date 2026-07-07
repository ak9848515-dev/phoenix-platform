import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';

/// Presents the Mission Center experience as a reusable UI screen.
///
/// This screen is intentionally presentation-only and uses placeholder data
/// to define the layout structure for the feature.
class MissionCenterScreen extends StatelessWidget {
  const MissionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final quickActions = <_QuickActionData>[
      _QuickActionData('Daily Check-in', Icons.task_alt_outlined),
      _QuickActionData('Focus Session', Icons.bolt_outlined),
      _QuickActionData('Learning Sprint', Icons.school_outlined),
    ];

    final academies = <_AcademyData>[
      _AcademyData('Leadership Lab', 'Growth • 4 lessons'),
      _AcademyData('Product Thinking', 'Strategy • 6 lessons'),
      _AcademyData('Design Systems', 'Craft • 3 lessons'),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mission Center',
              style: theme.textTheme.titleLarge,
            ),
            Text(
              'Your daily momentum starts here',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingSection(
                name: 'Ava',
                subtitle: 'You are 2 steps away from your next milestone.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _MissionCard(
                title: 'Today\'s Mission',
                description:
                    'Complete the onboarding sprint and unlock the next level of your learning path.',
                badgeLabel: 'Priority Focus',
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: quickActions
                    .map(
                      (action) => _QuickActionChip(
                        label: action.label,
                        icon: action.icon,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Academies',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...academies.map(
                (academy) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AcademyTile(
                    title: academy.title,
                    subtitle: academy.subtitle,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _KnowledgeDnaCard(
                progress: 0.72,
                label: 'Knowledge DNA',
                summary: '72% of your curated learning map is now activated.',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.rocket_launch_outlined), label: 'Mission'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning, $name',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.title,
    required this.description,
    required this.badgeLabel,
  });

  final String title;
  final String description;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text(
                    badgeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: 0.45,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _AcademyTile extends StatelessWidget {
  const _AcademyTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      tileColor: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.success.withValues(alpha: 0.14),
        child: const Icon(Icons.auto_awesome_outlined, color: AppColors.success),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
    );
  }
}

class _KnowledgeDnaCard extends StatelessWidget {
  const _KnowledgeDnaCard({
    required this.progress,
    required this.label,
    required this.summary,
  });

  final double progress;
  final String label;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      color: AppColors.darkBackground,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.onDarkBackground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onDarkBackground.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.onDarkBackground.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _AcademyData {
  const _AcademyData(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
