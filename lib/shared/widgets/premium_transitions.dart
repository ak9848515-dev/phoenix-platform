import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';

/// A premium page transition that wraps screen content with fade + slide
/// entrance animation.
///
/// Provides a consistent entrance animation for all Phoenix screens.
/// Subtle, never flashy. Uses ease-out curves for premium feel.
class PageTransition extends StatefulWidget {
  const PageTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.slideOffset = 20.0,
  });

  /// The screen content to animate in.
  final Widget child;

  /// Duration of the entrance animation.
  final Duration duration;

  /// Delay before the animation begins.
  final Duration delay;

  /// How far the content slides up (in pixels). Default 20.
  final double slideOffset;

  @override
  State<PageTransition> createState() => _PageTransitionState();
}

class _PageTransitionState extends State<PageTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, _controller.forward);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// An interactive card wrapper that adds subtle elevation on press.
///
/// Provides premium tap feedback with elevation change, color shift,
/// and a scale pop on release.
class PressableCard extends StatefulWidget {
  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius,
    this.elevation = 0.0,
    this.elevationDelta = 2.0,
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  /// Card content.
  final Widget child;

  /// Tap callback.
  final VoidCallback onTap;

  /// Custom border radius. Defaults to [PhoenixRadius.xl].
  final BorderRadiusGeometry? borderRadius;

  /// Base elevation.
  final double elevation;

  /// How much elevation increases on press (adds to base).
  final double elevationDelta;

  /// Background color. Defaults to surface.
  final Color? backgroundColor;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Outer margin.
  final EdgeInsetsGeometry? margin;

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _elevationAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _elevationAnim = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + widget.elevationDelta,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.borderRadius ?? PhoenixRadius.xlRadius;
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Card(
            margin: widget.margin ?? EdgeInsets.zero,
            elevation: _elevationAnim.value,
            color: _isPressed
                ? bgColor.withValues(alpha: 0.95)
                : bgColor,
            shadowColor: PhoenixColors.shadow,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: radius is BorderRadius
                  ? radius
                  : BorderRadius.circular(PhoenixRadius.xl),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: radius is BorderRadius
                  ? radius
                  : BorderRadius.circular(PhoenixRadius.xl),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(PhoenixSpacing.lg),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A section header with optional trailing action for premium screens.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// Section title.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Optional action button label (e.g. "View All").
  final String? actionLabel;

  /// Optional action tap.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: PhoenixSpacing.sm),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: PhoenixSpacing.md,
                vertical: PhoenixSpacing.sm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: PhoenixColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
