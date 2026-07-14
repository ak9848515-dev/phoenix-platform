import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_icons.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../shared/widgets/phoenix_card.dart';

/// A grid of quick-action buttons for navigating to core Phoenix features.
///
/// Current targets:
/// - Portfolio → Portfolio Screen
/// - Resume → Resume Screen
/// - Interview → Interview Screen
/// - Opportunities → Opportunity Screen
/// - Marketplace → Marketplace Screen
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({
    super.key,
    required this.onPortfolio,
    required this.onResume,
    required this.onInterview,
    required this.onOpportunities,
    required this.onMarketplace,
  });

  /// Navigate to Portfolio.
  final VoidCallback onPortfolio;

  /// Navigate to Resume.
  final VoidCallback onResume;

  /// Navigate to Interview Prep.
  final VoidCallback onInterview;

  /// Navigate to Opportunities.
  final VoidCallback onOpportunities;

  /// Navigate to Marketplace.
  final VoidCallback onMarketplace;

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions();

    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 300),
      child: PhoenixCard(
        header: 'Quick Actions',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useThreeColumns = constraints.maxWidth >= 500;

            if (useThreeColumns) {
              return Column(
                children: [
                  Row(
                    children: actions.take(3).toList(),
                  ),
                  SizedBox(height: PhoenixSpacing.sm),
                  Row(
                    children: actions.skip(3).toList(),
                  ),
                ],
              );
            }

            if (constraints.maxWidth >= 320) {
              return Wrap(
                spacing: PhoenixSpacing.sm,
                runSpacing: PhoenixSpacing.sm,
                children: actions,
              );
            }

            return Column(
              children: actions
                  .map((action) => Padding(
                        padding: EdgeInsets.only(bottom: PhoenixSpacing.sm),
                        child: SizedBox(width: double.infinity, child: action),
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      _ActionButton(
        icon: PhoenixIcons.profile,
        label: 'Portfolio',
        color: PhoenixColors.primary,
        onTap: onPortfolio,
      ),
      _ActionButton(
        icon: Icons.description_outlined,
        label: 'Resume',
        color: PhoenixColors.primary,
        onTap: onResume,
      ),
      _ActionButton(
        icon: PhoenixIcons.interview,
        label: 'Interview',
        color: PhoenixColors.primary,
        onTap: onInterview,
      ),
      _ActionButton(
        icon: PhoenixIcons.target,
        label: 'Opportunities',
        color: PhoenixColors.warning,
        onTap: onOpportunities,
      ),
      _ActionButton(
        icon: Icons.store_outlined,
        label: 'Marketplace',
        color: PhoenixColors.primary,
        onTap: onMarketplace,
      ),
    ];
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: PhoenixRadius.mdRadius,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: PhoenixSpacing.md,
              horizontal: PhoenixSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: PhoenixRadius.mdRadius,
              border: Border.all(
                color: color.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                SizedBox(height: PhoenixSpacing.xs),
                Text(
                  label,
                  style: PhoenixTypography.labelSmall.copyWith(
                    color: PhoenixColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
