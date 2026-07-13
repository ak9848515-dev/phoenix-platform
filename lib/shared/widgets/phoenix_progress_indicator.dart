import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';

/// A progress indicator for the Phoenix Platform.
///
/// Uses the Phoenix Design System tokens for consistent styling.
class PhoenixProgressIndicator extends StatelessWidget {
  const PhoenixProgressIndicator({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.backgroundColor,
    this.valueColor,
    this.borderRadius,
  });

  final double value;
  final double minHeight;
  final Color? backgroundColor;
  final Color? valueColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
        backgroundColor: backgroundColor ?? PhoenixColors.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(
          valueColor ?? PhoenixColors.primary,
        ),
      ),
    );
  }
}
