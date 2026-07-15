import 'package:flutter/material.dart';

import '../../theme/spacing.dart';

/// A context-aware loading experience for the Phoenix Platform.
///
/// Replaces every generic `CircularProgressIndicator()` with meaningful
/// guidance that reassures the user Phoenix is actively preparing content.
///
/// Every loading state includes:
/// 1. Relevant icon/illustration
/// 2. Context-aware title (e.g. "Preparing your dashboard...")
/// 3. Optional subtitle with more detail
/// 4. Animated progress indicator
///
/// Dark mode compatible. Responsive layout.
class PhoenixLoadingWidget extends StatelessWidget {
  const PhoenixLoadingWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  /// The icon representing what's being loaded.
  final IconData icon;

  /// Context-aware loading message (e.g. "Preparing your dashboard…").
  final String title;

  /// Optional secondary loading message.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Pulsing icon (decorative)
            Semantics(
              excludeSemantics: true,
              child: _LoadingIcon(icon: icon, theme: theme),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 2. Context-aware title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // 3. Optional subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // 4. Animated progress indicator
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                color: theme.colorScheme.primary,
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An animated pulsing icon for the loading state.
class _LoadingIcon extends StatefulWidget {
  const _LoadingIcon({required this.icon, required this.theme});
  final IconData icon;
  final ThemeData theme;

  @override
  State<_LoadingIcon> createState() => _LoadingIconState();
}

class _LoadingIconState extends State<_LoadingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              size: 48,
              color: widget.theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}
