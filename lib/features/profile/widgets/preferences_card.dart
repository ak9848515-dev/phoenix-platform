import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../../core/design/widgets/phoenix_card.dart';

/// Displays a list of preferences that the user can navigate to.
///
/// Navigation-only — no settings logic or toggles in this widget.
/// Rows with no [onTap] callback render as non-interactive.
class PreferencesCard extends StatelessWidget {
  const PreferencesCard({
    super.key,
    this.onTheme,
    this.onNotifications,
    this.onSync,
    this.onPrivacy,
  });

  final VoidCallback? onTheme;
  final VoidCallback? onNotifications;
  final VoidCallback? onSync;
  final VoidCallback? onPrivacy;

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 350),
      child: PhoenixCard(
        header: 'Preferences',
        child: Column(
          children: [
            _PreferenceRow(
              icon: Icons.dark_mode_outlined,
              label: 'Theme',
              subtitle: 'Light mode (dark ready)',
              onTap: onTheme,
            ),
            _divider(),
            _PreferenceRow(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              subtitle: 'Push, email, in-app',
              onTap: onNotifications,
            ),
            _divider(),
            _PreferenceRow(
              icon: Icons.sync_outlined,
              label: 'Sync Status',
              subtitle: 'Last synced moments ago',
              onTap: onSync,
            ),
            _divider(),
            _PreferenceRow(
              icon: Icons.lock_outline,
              label: 'Privacy',
              subtitle: 'Data & permissions',
              onTap: onPrivacy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: PhoenixColors.border,
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasAction = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: hasAction ? PhoenixRadius.smRadius : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: PhoenixSpacing.md,
            horizontal: PhoenixSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: PhoenixColors.textSecondary),
              SizedBox(width: PhoenixSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: PhoenixTypography.bodySmall.copyWith(
                        color: PhoenixColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: PhoenixTypography.caption.copyWith(
                        color: PhoenixColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: hasAction
                    ? PhoenixColors.textDisabled
                    : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
