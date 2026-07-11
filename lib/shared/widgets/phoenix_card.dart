import 'package:flutter/material.dart';

import '../../theme/radius.dart';
import '../../theme/spacing.dart';

class PhoenixCard extends StatelessWidget {
  const PhoenixCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
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
    final theme = Theme.of(context);

    return Card(
      margin: margin,
      elevation: elevation,
      color: color ?? theme.colorScheme.surfaceContainerHighest,
      clipBehavior: clipBehavior,
      shape:
          shape ??
          RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
          ),
      child: Padding(padding: padding, child: child),
    );
  }
}
