import 'package:flutter/material.dart';

import '../../services/sample_data_service.dart';
import '../../shared/widgets/phoenix_card.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/phoenix_progress_indicator.dart';
import '../mission_engine/mission_service.dart';
import '../../shared/widgets/phoenix_section_header.dart';
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
    final sampleData = const SampleDataService();
    final missionService = MissionService(seedSource: sampleData);
    final missionProgress = missionService.buildProgress();
    final featuredMission = missionProgress.featuredMission;
    final quickActions = sampleData.quickActions;
    final academies = sampleData.academySummaries;
    final dashboardSections = sampleData.dashboardSections;
    final knowledgeSummary =
        '${(missionProgress.completionPercentage * 100).toInt()}% of your mission engine is now active.';
    final quickActionsHeader = dashboardSections
        .firstWhere((section) => section.id == 'section-quick-actions')
        .label;
    final academiesHeader = dashboardSections
        .firstWhere((section) => section.id == 'section-academies')
        .label;

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
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.academy);
                },
                child: PhoenixCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              featuredMission.title,
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
                              'Priority Focus',
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
                        featuredMission.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PhoenixProgressIndicator(value: missionProgress.completionPercentage),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PhoenixSectionHeader(title: quickActionsHeader),
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
              PhoenixSectionHeader(title: academiesHeader),
              const SizedBox(height: AppSpacing.sm),
              ...academies.map(
                (academy) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AcademyTile(
                    title: academy.title,
                    subtitle: academy.description,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PhoenixCard(
                color: AppColors.darkBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Knowledge DNA',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.onDarkBackground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      knowledgeSummary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onDarkBackground.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PhoenixProgressIndicator(
                      value: missionProgress.completionPercentage,
                      minHeight: 10,
                      backgroundColor: AppColors.onDarkBackground.withValues(alpha: 0.2),
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
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
