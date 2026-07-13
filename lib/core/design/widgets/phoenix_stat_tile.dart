import 'package:flutter/material.dart';

import '../theme/phoenix_colors.dart';
import '../theme/phoenix_radius.dart';
import '../theme/phoenix_spacing.dart';
import '../theme/phoenix_typography.dart';

/// A premium stat display tile for the Phoenix Design System.
///
/// Displays a labeled value with an icon in a compact, elegant layout.
/// Used for XP, level, streaks, achievements, and similar metrics.
class PhoenixStatTile extends StatelessWidget {
  const PhoenixStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.iconBackgroundColor,
    this.valueStyle,
    this.labelStyle,
    this.compact = false,
  });

  /// The icon displayed on the left.
  final IconData icon;

  /// The label text (e.g. "Total XP", "Current Streak").
  final String label;

  /// The value text (e.g. "1,234", "7 days").
  final String value;

  /// Accent color for the icon and value.
  final Color? color;

  /// Background color for the icon container.
  final Color? iconBackgroundColor;

  /// Custom style for the value text.
  final TextStyle? valueStyle;

  /// Custom style for the label text.
  final TextStyle? labelStyle;

  /// If true, uses a more compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? PhoenixColors.primary;
    final iconBg = iconBackgroundColor ??
        accentColor.withValues(alpha: 0.1);

    if (compact) {
      return _buildCompactRow(accentColor, iconBg);
    }

    return _buildStandardColumn(accentColor, iconBg);
  }

  Widget _buildStandardColumn(Color accentColor, Color iconBg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(PhoenixSpacing.sm),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: PhoenixRadius.smRadius,
          ),
          child: Icon(icon, size: 22, color: accentColor),
        ),
        SizedBox(height: PhoenixSpacing.sm),
        Text(
          value,
          style: valueStyle ??
              PhoenixTypography.statValue.copyWith(color: accentColor),
        ),
        SizedBox(height: PhoenixSpacing.xs),
        Text(
          label,
          style: labelStyle ??
              PhoenixTypography.statLabel.copyWith(
                color: PhoenixColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCompactRow(Color accentColor, Color iconBg) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(PhoenixSpacing.xs),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: PhoenixRadius.smRadius,
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        SizedBox(width: PhoenixSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: valueStyle ??
                  PhoenixTypography.label.copyWith(
                color: PhoenixColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: labelStyle ??
                  PhoenixTypography.caption.copyWith(
                    color: PhoenixColors.textSecondary,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
