import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';

/// A premium card surface for the Phoenix Platform.
///
/// Uses the Phoenix Design System tokens for consistent styling.
class PhoenixCard extends StatelessWidget {
  const PhoenixCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PhoenixSpacing.xl),
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation = 0,
    this.shape,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final double elevation;
  final ShapeBorder? shape;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? PhoenixColors.surface;
    final cardRadius = borderRadius ?? PhoenixRadius.xlRadius;

    return Card(
      margin: margin,
      elevation: elevation,
      color: cardColor,
      shadowColor: PhoenixColors.shadow,
      clipBehavior: clipBehavior,
      surfaceTintColor: Colors.transparent,
      shape:
          shape ??
          RoundedRectangleBorder(
            borderRadius: cardRadius is BorderRadius
                ? cardRadius
                : BorderRadius.circular(PhoenixRadius.xl),
          ),
      child: Padding(padding: padding, child: child),
    );
  }
}
