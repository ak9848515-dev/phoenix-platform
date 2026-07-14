import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_card.dart';

/// Quick navigation shortcuts to core Phoenix features.
///
/// Navigation only — no business logic.
class SuggestedActions extends StatelessWidget {
  const SuggestedActions({
    super.key,
    required this.onContinueMission,
    required this.onImproveResume,
    required this.onPracticeInterview,
    required this.onBuildPortfolio,
    required this.onExploreOpportunities,
    required this.onContinueLearning,
  });

  final VoidCallback onContinueMission;
  final VoidCallback onImproveResume;
  final VoidCallback onPracticeInterview;
  final VoidCallback onBuildPortfolio;
  final VoidCallback onExploreOpportunities;
  final VoidCallback onContinueLearning;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 250),
      child: PhoenixCard(
        header: 'Suggested Actions',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useColumns = constraints.maxWidth >= 400;

            if (useColumns) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ActionChip(
                          icon: PhoenixIcons.mission,
                          label: 'Continue Mission',
                          onTap: onContinueMission,
                        ),
                      ),
                      SizedBox(width: PhoenixSpacing.sm),
                      Expanded(
                        child: _ActionChip(
                          icon: PhoenixIcons.profile,
                          label: 'Improve Resume',
                          onTap: onImproveResume,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: PhoenixSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionChip(
                          icon: PhoenixIcons.interview,
                          label: 'Practice Interview',
                          onTap: onPracticeInterview,
                        ),
                      ),
                      SizedBox(width: PhoenixSpacing.sm),
                      Expanded(
                        child: _ActionChip(
                          icon: PhoenixIcons.launch,
                          label: 'Build Portfolio',
                          onTap: onBuildPortfolio,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: PhoenixSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionChip(
                          icon: PhoenixIcons.target,
                          label: 'Explore Opportunities',
                          onTap: onExploreOpportunities,
                        ),
                      ),
                      SizedBox(width: PhoenixSpacing.sm),
                      Expanded(
                        child: _ActionChip(
                          icon: PhoenixIcons.lessons,
                          label: 'Continue Learning',
                          onTap: onContinueLearning,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Column(
              children: [
                _ActionChip(
                  icon: PhoenixIcons.mission,
                  label: 'Continue Mission',
                  onTap: onContinueMission,
                ),
                SizedBox(height: PhoenixSpacing.sm),
                _ActionChip(
                  icon: PhoenixIcons.profile,
                  label: 'Improve Resume',
                  onTap: onImproveResume,
                ),
                SizedBox(height: PhoenixSpacing.sm),
                _ActionChip(
                  icon: PhoenixIcons.interview,
                  label: 'Practice Interview',
                  onTap: onPracticeInterview,
                ),
                SizedBox(height: PhoenixSpacing.sm),
                _ActionChip(
                  icon: PhoenixIcons.launch,
                  label: 'Build Portfolio',
                  onTap: onBuildPortfolio,
                ),
                SizedBox(height: PhoenixSpacing.sm),
                _ActionChip(
                  icon: PhoenixIcons.target,
                  label: 'Explore Opportunities',
                  onTap: onExploreOpportunities,
                ),
                SizedBox(height: PhoenixSpacing.sm),
                _ActionChip(
                  icon: PhoenixIcons.lessons,
                  label: 'Continue Learning',
                  onTap: onContinueLearning,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: true,
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: PhoenixRadius.smRadius,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: PhoenixSpacing.md,
            horizontal: PhoenixSpacing.md,
          ),
          decoration: BoxDecoration(
            color: PhoenixColors.surfaceVariant,
            borderRadius: PhoenixRadius.smRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: PhoenixColors.primary),
              SizedBox(width: PhoenixSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  style: PhoenixTypography.bodySmall.copyWith(
                    color: PhoenixColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
