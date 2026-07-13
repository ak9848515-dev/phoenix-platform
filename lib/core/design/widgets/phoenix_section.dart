import 'package:flutter/material.dart';

import '../theme/phoenix_colors.dart';
import '../theme/phoenix_spacing.dart';
import '../theme/phoenix_typography.dart';

/// A reusable section layout for the Phoenix Design System.
///
/// Provides a consistent title / subtitle / action header with
/// content below. Replaces ad-hoc section header patterns.
class PhoenixSection extends StatelessWidget {
  const PhoenixSection({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
    this.contentPadding,
    required this.child,
  });

  /// Section title (displayed as H3).
  final String title;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// Optional trailing widget (e.g. "See all" button).
  final Widget? action;

  /// Padding around the entire section. Defaults to [PhoenixSpacing.lg]
  /// on the sides and zero on top/bottom.
  final EdgeInsetsGeometry? padding;

  /// Padding applied specifically to the child content area.
  final EdgeInsetsGeometry? contentPadding;

  /// The section content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(horizontal: PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          SizedBox(height: PhoenixSpacing.lg),
          if (contentPadding != null)
            Padding(padding: contentPadding!, child: child)
          else
            child,
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (subtitle != null && action != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(title, style: PhoenixTypography.h3)),
              if (action != null) ...[
                SizedBox(width: PhoenixSpacing.sm),
                action!,
              ],
            ],
          ),
          SizedBox(height: PhoenixSpacing.xs),
          Text(
            subtitle!,
            style: PhoenixTypography.bodySmall.copyWith(
              color: PhoenixColors.textSecondary,
            ),
          ),
        ],
      );
    }

    if (action != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(title, style: PhoenixTypography.h3)),
          SizedBox(width: PhoenixSpacing.sm),
          action!,
        ],
      );
    }

    if (subtitle != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PhoenixTypography.h3),
          SizedBox(height: PhoenixSpacing.xs),
          Text(
            subtitle!,
            style: PhoenixTypography.bodySmall.copyWith(
              color: PhoenixColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Text(title, style: PhoenixTypography.h3);
  }
}
