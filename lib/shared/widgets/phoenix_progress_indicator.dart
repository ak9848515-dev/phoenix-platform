import 'package:flutter/material.dart';

import '../../theme/radius.dart';

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
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.xl),
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          valueColor ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
