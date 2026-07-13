import 'package:flutter/material.dart';

/// A fade-in animation widget for the Phoenix Design System.
///
/// Wraps [child] with a [FadeTransition] that fades from transparent
/// to opaque over [duration] with an optional [delay].
///
/// Allowed animation: fade (not bounce, shake, flash, or neon).
class FadeAnimation extends StatefulWidget {
  const FadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  /// The widget to animate in.
  final Widget child;

  /// Duration of the fade animation.
  final Duration duration;

  /// Delay before the animation begins.
  final Duration delay;

  /// The animation curve.
  final Curve curve;

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, _controller.forward);
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
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
      opacity: _animation,
      child: widget.child,
    );
  }
}
