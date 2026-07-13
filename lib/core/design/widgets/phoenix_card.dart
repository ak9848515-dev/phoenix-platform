import 'package:flutter/material.dart';

import '../theme/phoenix_colors.dart';
import '../theme/phoenix_radius.dart';
import '../theme/phoenix_shadow.dart';
import '../theme/phoenix_spacing.dart';
import '../theme/phoenix_typography.dart';

/// A premium card surface for the Phoenix Design System.
///
/// Every card uses:
/// - 20px border radius ([PhoenixRadius.xl])
/// - Soft shadow ([PhoenixShadow.cardRest])
/// - Consistent padding
/// - Optional [header]
/// - Optional [action] (e.g. a "See all" button)
///
/// Use [PhoenixCard] everywhere instead of raw Material [Card].
/// Do not create custom card shapes in features.
class PhoenixCard extends StatelessWidget {
  const PhoenixCard({
    super.key,
    required this.child,
    this.header,
    this.action,
    this.padding = const EdgeInsets.all(PhoenixSpacing.xl),
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The primary content of the card.
  final Widget child;

  /// Optional header text displayed above the child.
  final String? header;

  /// Optional trailing widget (e.g. a text button, icon button) placed
  /// beside or after the [header].
  final Widget? action;

  /// Padding around the card content (including header area).
  final EdgeInsetsGeometry padding;

  /// Margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Background color. Defaults to [PhoenixColors.surface].
  final Color? color;

  /// Custom border radius. Defaults to [PhoenixRadius.xl].
  final BorderRadiusGeometry? borderRadius;

  /// Custom elevation. Defaults to [PhoenixShadow.none] (uses soft shadow).
  final double? elevation;

  /// Clip behavior. Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  bool get _hasHeader => header != null || action != null;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? PhoenixColors.surface;
    final cardRadius = borderRadius ?? PhoenixRadius.xlRadius;
    final cardElevation = elevation ?? PhoenixShadow.none;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: cardRadius,
        boxShadow: cardElevation == 0
            ? PhoenixShadow.cardRest
            : [
                BoxShadow(
                  color: PhoenixColors.shadow,
                  blurRadius: cardElevation * 2,
                  offset: Offset(0, cardElevation),
                ),
              ],
      ),
      clipBehavior: clipBehavior,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (_hasHeader) ...[
              _buildHeader(context),
              SizedBox(height: PhoenixSpacing.lg),
            ],
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (header != null && action != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              header!,
              style: PhoenixTypography.h3.copyWith(
                color: PhoenixColors.textPrimary,
              ),
            ),
          ),
          if (action != null) ...[
            SizedBox(width: PhoenixSpacing.sm),
            action!,
          ],
        ],
      );
    }

    if (header != null) {
      return Text(
        header!,
        style: PhoenixTypography.h3.copyWith(
          color: PhoenixColors.textPrimary,
        ),
      );
    }

    // Only action exists.
    if (action != null) {
      return Align(alignment: Alignment.centerRight, child: action);
    }

    return const SizedBox.shrink();
  }
}
