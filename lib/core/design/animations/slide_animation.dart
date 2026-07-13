import 'package:flutter/material.dart';

/// A slide-in animation widget for the Phoenix Design System.
///
/// Wraps [child] with a [SlideTransition] that slides from [offsetBegin]
/// to [offsetEnd] over [duration] with an optional [delay].
///
/// Allowed animation types: slide (not bounce, shake, flash, or neon).
class SlideAnimation extends StatefulWidget {
  const SlideAnimation({
    super.key,
    required this.child,
    this.offsetBegin = const Offset(0, 0.1),
    this.offsetEnd = Offset.zero,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  /// The widget to slide in.
  final Widget child;

  /// Starting offset (default: 10% below final position).
  final Offset offsetBegin;

  /// Ending offset (default: Identity / final position).
  final Offset offsetEnd;

  /// Duration of the slide animation.
  final Duration duration;

  /// Delay before the animation begins.
  final Duration delay;

  /// The animation curve.
  final Curve curve;

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<Offset>(
      begin: widget.offsetBegin,
      end: widget.offsetEnd,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
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
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
