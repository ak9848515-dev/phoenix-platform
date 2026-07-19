import 'package:flutter/material.dart';

import '../../core/design/theme/phoenix_colors.dart';
import '../../core/design/theme/phoenix_radius.dart';
import '../../core/design/theme/phoenix_spacing.dart';

/// A shimmer animation widget that wraps child skeleton placeholders.
///
/// Provides a subtle animated gradient that sweeps across the skeleton
/// to indicate content is loading. Uses the Phoenix Design System colors.
class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  /// The skeleton content to animate.
  final Widget child;

  /// Base color for the shimmer effect. Defaults to surfaceVariant.
  final Color? baseColor;

  /// Highlight color sweeping across. Defaults to surface.
  final Color? highlightColor;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? PhoenixColors.surfaceVariant;
    final highlightColor =
        widget.highlightColor ?? PhoenixColors.border.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                baseColor,
                highlightColor,
                baseColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value - 0.15,
                _controller.value,
                _controller.value + 0.15,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcOver,
          child: child,
        );
      },
    );
  }
}

/// A skeleton box placeholder with shimmer animation.
///
/// Mimics the shape of content that is loading. Use inside a [ShimmerLoader]
/// or standalone with shimmer enabled.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shimmer = true,
    this.baseColor,
    this.highlightColor,
  });

  /// Width of the skeleton. Null means fill available width.
  final double? width;

  /// Height of the skeleton.
  final double? height;

  /// Border radius for rounded corners. Defaults to [PhoenixRadius.sm].
  final BorderRadiusGeometry? borderRadius;

  /// Whether to apply shimmer animation.
  final bool shimmer;

  /// Base color override.
  final Color? baseColor;

  /// Highlight color override.
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final base = baseColor ?? PhoenixColors.surfaceVariant;

    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: borderRadius ?? PhoenixRadius.smRadius,
      ),
    );

    if (!shimmer) return box;

    return ShimmerLoader(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: box,
    );
  }
}

/// A skeleton card placeholder mimicking [PhoenixCard] shape.
///
/// Useful for dashboard or list loading states.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.height = 100,
    this.child,
  });

  /// Approximate height of the card.
  final double height;

  /// Optional custom skeleton content inside the card.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: PhoenixColors.surfaceVariant,
        borderRadius: PhoenixRadius.xlRadius,
      ),
      child: child ??
          Padding(
            padding: const EdgeInsets.all(PhoenixSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 120, height: 14),
                const SizedBox(height: PhoenixSpacing.sm),
                SkeletonBox(width: double.infinity, height: 12),
                const SizedBox(height: PhoenixSpacing.sm),
                SkeletonBox(width: 80, height: 10),
              ],
            ),
          ),
    );
  }
}

/// A skeleton row placeholder mimicking a list tile.
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({
    super.key,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.hasTrailing = false,
  });

  /// Whether to show a leading icon circle.
  final bool hasLeading;

  /// Whether to show a subtitle line.
  final bool hasSubtitle;

  /// Whether to show a trailing icon circle.
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PhoenixSpacing.lg,
        vertical: PhoenixSpacing.sm,
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            const SkeletonBox(width: 40, height: 40, borderRadius: PhoenixRadius.mdRadius),
            const SizedBox(width: PhoenixSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 14),
                if (hasSubtitle) ...[
                  const SizedBox(height: PhoenixSpacing.xs),
                  SkeletonBox(width: double.infinity, height: 10),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: PhoenixSpacing.md),
            const SkeletonBox(width: 24, height: 24, borderRadius: PhoenixRadius.smRadius),
          ],
        ],
      ),
    );
  }
}

/// Dashboard skeleton for the loading state of [CommandCenterScreen].
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Welcome skeleton (full screen height area)
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.all(PhoenixSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                SkeletonBox(width: 48, height: 48, borderRadius: PhoenixRadius.lgRadius),
                const SizedBox(height: PhoenixSpacing.xl),
                SkeletonBox(width: 240, height: 32, borderRadius: PhoenixRadius.smRadius),
                const SizedBox(height: PhoenixSpacing.sm),
                SkeletonBox(width: 180, height: 20, borderRadius: PhoenixRadius.smRadius),
                const Spacer(flex: 1),
                SkeletonCard(height: 120),
                const SizedBox(height: PhoenixSpacing.lg),
                SkeletonBox(width: double.infinity, height: 56, borderRadius: PhoenixRadius.lgRadius),
                const Spacer(flex: 2),
              ],
            ),
          ),
          // Section skeletons
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: PhoenixSpacing.lg),
            child: Column(
              children: [
                SkeletonCard(height: 90),
                SizedBox(height: PhoenixSpacing.lg),
                SkeletonCard(height: 110),
                SizedBox(height: PhoenixSpacing.lg),
                SkeletonCard(height: 80),
                SizedBox(height: PhoenixSpacing.lg),
                SkeletonCard(height: 100),
                SizedBox(height: PhoenixSpacing.lg),
                SkeletonCard(height: 90),
                SizedBox(height: PhoenixSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Academy search skeleton for Learn page loading state.
class AcademySkeleton extends StatelessWidget {
  const AcademySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Hero skeleton
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              PhoenixSpacing.xl,
              MediaQuery.of(context).padding.top + PhoenixSpacing.xxl,
              PhoenixSpacing.xl,
              PhoenixSpacing.xxl,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 280, height: 40),
                SizedBox(height: PhoenixSpacing.sm),
                SkeletonBox(width: 200, height: 18),
                SizedBox(height: PhoenixSpacing.xl),
                SkeletonBox(width: double.infinity, height: 56, borderRadius: PhoenixRadius.lgRadius),
                SizedBox(height: PhoenixSpacing.xl),
                SkeletonBox(width: 100, height: 14),
                SizedBox(height: PhoenixSpacing.md),
                Wrap(
                  spacing: PhoenixSpacing.sm,
                  runSpacing: PhoenixSpacing.sm,
                  children: [
                    SkeletonBox(width: 80, height: 32, borderRadius: PhoenixRadius.lgRadius),
                    SkeletonBox(width: 120, height: 32, borderRadius: PhoenixRadius.lgRadius),
                    SkeletonBox(width: 100, height: 32, borderRadius: PhoenixRadius.lgRadius),
                    SkeletonBox(width: 90, height: 32, borderRadius: PhoenixRadius.lgRadius),
                    SkeletonBox(width: 110, height: 32, borderRadius: PhoenixRadius.lgRadius),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings skeleton for loading state of settings screen.
class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(PhoenixSpacing.xl),
      child: const Column(
        children: [
          SkeletonBox(width: 140, height: 20),
          SizedBox(height: PhoenixSpacing.md),
          SkeletonBox(width: double.infinity, height: 56),
          SizedBox(height: PhoenixSpacing.xxl),
          SkeletonBox(width: 140, height: 20),
          SizedBox(height: PhoenixSpacing.md),
          SkeletonBox(width: double.infinity, height: 120),
          SizedBox(height: PhoenixSpacing.xxl),
          SkeletonBox(width: 140, height: 20),
          SizedBox(height: PhoenixSpacing.md),
          SkeletonBox(width: double.infinity, height: 80),
          SizedBox(height: PhoenixSpacing.xxl),
          SkeletonBox(width: 140, height: 20),
          SizedBox(height: PhoenixSpacing.md),
          SkeletonBox(width: double.infinity, height: 56),
        ],
      ),
    );
  }
}
