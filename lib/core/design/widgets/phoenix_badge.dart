import 'package:flutter/material.dart';

import '../theme/phoenix_colors.dart';
import '../theme/phoenix_spacing.dart';
import '../theme/phoenix_typography.dart';

/// A premium badge component for the Phoenix Design System.
///
/// Used for status indicators, achievement tags, category labels,
/// and similar compact annotations.
///
/// [variant] controls the color scheme:
/// - `default`: primary color
/// - `success`: emerald
/// - `warning`: gold (for achievements / premium)
/// - `error`: soft red
/// - `neutral`: grey
/// - `gold`: premium gold (achievements)
class PhoenixBadge extends StatelessWidget {
  const PhoenixBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = BadgeVariant.neutral,
    this.isSmall = false,
  });

  /// The badge text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Color variant.
  final BadgeVariant variant;

  /// Whether to use the small size variant.
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final colors = _variantColors(variant);

    return Container(
      padding: isSmall
          ? EdgeInsets.symmetric(
              horizontal: PhoenixSpacing.sm,
              vertical: 2,
            )
          : EdgeInsets.symmetric(
              horizontal: PhoenixSpacing.sm + 2,
              vertical: PhoenixSpacing.xs,
            ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 12 : 14,
              color: colors.foreground,
            ),
            SizedBox(width: PhoenixSpacing.xs),
          ],
          Text(
            label,
            style: (isSmall
                    ? PhoenixTypography.labelSmall
                    : PhoenixTypography.caption)
                .copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _variantColors(BadgeVariant v) {
    switch (v) {
      case BadgeVariant.primary:
        return _BadgeColors(
          background: PhoenixColors.primary.withValues(alpha: 0.1),
          foreground: PhoenixColors.primary,
          border: PhoenixColors.primary.withValues(alpha: 0.2),
        );
      case BadgeVariant.success:
        return _BadgeColors(
          background: PhoenixColors.success.withValues(alpha: 0.1),
          foreground: PhoenixColors.success,
          border: PhoenixColors.success.withValues(alpha: 0.2),
        );
      case BadgeVariant.warning:
        return _BadgeColors(
          background: PhoenixColors.warning.withValues(alpha: 0.1),
          foreground: PhoenixColors.warning,
          border: PhoenixColors.warning.withValues(alpha: 0.2),
        );
      case BadgeVariant.error:
        return _BadgeColors(
          background: PhoenixColors.error.withValues(alpha: 0.1),
          foreground: PhoenixColors.error,
          border: PhoenixColors.error.withValues(alpha: 0.2),
        );
      case BadgeVariant.neutral:
        return _BadgeColors(
          background: PhoenixColors.surfaceVariant,
          foreground: PhoenixColors.textSecondary,
          border: PhoenixColors.border,
        );
      case BadgeVariant.gold:
        return _BadgeColors(
          background: PhoenixColors.gold.withValues(alpha: 0.1),
          foreground: PhoenixColors.gold,
          border: PhoenixColors.gold.withValues(alpha: 0.2),
        );
    }
  }
}

/// Color variant for [PhoenixBadge].
enum BadgeVariant {
  primary,
  success,
  warning,
  error,
  neutral,
  gold,
}

class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
