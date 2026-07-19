import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';

/// A context-aware loading experience for the Phoenix Platform.
///
/// Replaces every generic `CircularProgressIndicator()` with meaningful
/// guidance that reassures the user Phoenix is actively preparing content.
///
/// Every loading state includes:
/// 1. Relevant icon/illustration with animated glow
/// 2. Context-aware title
/// 3. Optional subtitle with more detail
/// 4. Animated progress indicator
///
/// Uses the Phoenix Design System tokens for premium, consistent styling.
class PhoenixLoadingWidget extends StatelessWidget {
  const PhoenixLoadingWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  /// The icon representing what's being loaded.
  final IconData icon;

  /// Context-aware loading message.
  final String title;

  /// Optional secondary loading message.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Pulsing icon (decorative)
            Semantics(
              excludeSemantics: true,
              child: _LoadingIcon(icon: icon, theme: theme),
            ),
            const SizedBox(height: PhoenixSpacing.xl),

            // 2. Context-aware title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),

            // 3. Optional subtitle
            if (subtitle != null) ...[
              const SizedBox(height: PhoenixSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: PhoenixSpacing.xxl),

            // 4. Animated progress indicator with premium styling
            SizedBox(
              width: 160,
              child: ClipRRect(
                borderRadius: PhoenixRadius.smRadius,
                child: LinearProgressIndicator(
                  backgroundColor: PhoenixColors.primary.withValues(alpha: 0.08),
                  color: PhoenixColors.primary,
                  minHeight: 4,
                ),
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
            padding: const EdgeInsets.all(PhoenixSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PhoenixColors.primary.withValues(alpha: 0.12),
                  PhoenixColors.primary.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: PhoenixRadius.xlRadius,
            ),
            child: Icon(
              widget.icon,
              size: 48,
              color: PhoenixColors.primary,
            ),
          ),
        );
      },
    );
  }
}
