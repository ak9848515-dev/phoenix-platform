import 'package:flutter/material.dart';

import '../theme/phoenix_colors.dart';
import '../theme/phoenix_spacing.dart';
import '../theme/phoenix_typography.dart';

/// A premium progress bar for the Phoenix Design System.
///
/// Supports all progress contexts:
/// - XP / Level
/// - Knowledge DNA
/// - Mission progress
/// - Career readiness
/// - Interview readiness
/// - General progress
///
/// Features:
/// - Smooth animated fill (progress fill is an allowed animation)
/// - Optional label + percentage display
/// - Context-aware accent color
class PhoenixProgressBar extends StatelessWidget {
  const PhoenixProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  /// Progress value from 0.0 to 1.0.
  final double value;

  /// Minimum height of the bar track.
  final double minHeight;

  /// Background track color.
  final Color? backgroundColor;

  /// The filled progress color. Context-aware defaults:
  /// - XP / Level: [PhoenixColors.primary]
  /// - Knowledge: [PhoenixColors.primary]
  /// - Mission: [PhoenixColors.primary]
  /// - Career: [PhoenixColors.primary]
  /// - Interview: [PhoenixColors.primary]
  /// - General: [PhoenixColors.primary]
  final Color? progressColor;

  /// Custom border radius. Defaults to fully rounded (pill shape).
  final BorderRadiusGeometry? borderRadius;

  /// Optional label displayed above the bar.
  final String? label;

  /// Whether to show the percentage value to the right of the label.
  final bool showPercentage;

  /// Whether the progress fill animates.
  final bool animated;

  /// Duration of the fill animation.
  final Duration animationDuration;

  double get _clampedValue => value.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: PhoenixTypography.caption.copyWith(
                    color: PhoenixColors.textSecondary,
                  ),
                ),
              if (showPercentage)
                Text(
                  '${(_clampedValue * 100).round()}%',
                  style: PhoenixTypography.caption.copyWith(
                    color: PhoenixColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          SizedBox(height: PhoenixSpacing.xs),
        ],
        ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(100),
          child: animated
              ? TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _clampedValue),
                  duration: animationDuration,
                  curve: Curves.easeOut,
                  builder: (context, value, _) => _buildTrack(value),
                )
              : _buildTrack(_clampedValue),
        ),
      ],
    );
  }

  Widget _buildTrack(double progress) {
    return Container(
      height: minHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? PhoenixColors.surfaceVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(100),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor ?? PhoenixColors.primary,
            borderRadius: borderRadius ?? BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
