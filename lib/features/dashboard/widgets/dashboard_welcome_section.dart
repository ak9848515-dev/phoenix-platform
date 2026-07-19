import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';

/// The first visible screen — calm, premium, motivational.
///
/// Contains ONLY:
/// • AI-generated Welcome message
/// • Subtle animated premium background (particles)
/// • Today's Focus (single highest priority)
/// • Continue button
///
/// No progress bars, mission counts, charts, cards, statistics, badges, or widgets.
class DashboardWelcomeSection extends StatefulWidget {
  const DashboardWelcomeSection({super.key});

  @override
  State<DashboardWelcomeSection> createState() =>
      _DashboardWelcomeSectionState();
}

class _DashboardWelcomeSectionState extends State<DashboardWelcomeSection>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _welcomeSlideAnimation;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _welcomeSlideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final scrollController = PrimaryScrollController.maybeOf(context);

    // Read identity for personalized welcome
    final identityEngine = AppBootstrap.maybeIdentityEngine;
    final identitySnap = identityEngine?.snapshot;
    final userName = identitySnap?.currentIdentityTitle ?? 'Explorer';

    // Read decision intelligence for Today's Focus
    final decisionEngine = AppBootstrap.maybeDecisionIntelligenceEngine;
    final decisionSnap = decisionEngine?.snapshot;
    final topDecision = decisionSnap?.top;
    final todaysFocusTitle = topDecision?.title ?? 'Begin your journey today';
    final todaysFocusDescription =
        topDecision?.description ?? 'Explore what Phoenix has prepared for you.';
    final todaysFocusReason = topDecision?.reason.why ?? '';

    // Time-based greeting
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return SizedBox(
      height: size.height * 0.85,
      child: Stack(
        children: [
          // ── Animated Premium Background ────────────────────────────
          _AnimatedParticleBackground(controller: _particleController),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _welcomeSlideAnimation.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PhoenixSpacing.lg,
                    vertical: PhoenixSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),

                      // ── Premium Logo ──────────────────────────
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              PhoenixColors.primary,
                                PhoenixColors.primary.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: PhoenixColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: PhoenixSpacing.xl),

                      // ── AI-Generated Welcome ──────────────────
                      Text(
                        '$greeting, $userName',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: PhoenixSpacing.sm),
                      Text(
                        'Your growth journey awaits.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── Today's Focus ─────────────────────────
                      Container(
                        padding: const EdgeInsets.all(PhoenixSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: PhoenixColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.today_rounded,
                                    size: 18,
                                    color: PhoenixColors.primary,
                                  ),
                                ),
                                const SizedBox(width: PhoenixSpacing.sm),
                                Text(
                                  "Today's Focus",
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: PhoenixColors.primary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: PhoenixSpacing.md),
                            Text(
                              todaysFocusTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                            if (todaysFocusDescription.isNotEmpty) ...[
                              const SizedBox(height: PhoenixSpacing.sm),
                              Text(
                                todaysFocusDescription,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                            if (todaysFocusReason.isNotEmpty) ...[
                              const SizedBox(height: PhoenixSpacing.sm),
                              Text(
                                todaysFocusReason,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: PhoenixSpacing.lg),

                      // ── Continue Button ───────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () {
                            // Scroll to reveal progressive dashboard sections
                            if (scrollController != null &&
                                scrollController.hasClients) {
                              scrollController.animateTo(
                                size.height * 0.75,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_downward_rounded,
                            size: 20,
                          ),
                          label: Text(
                            'Continue',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // ── Subtle AI indicator ───────────────────
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Intelligence by Phoenix AI',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: PhoenixSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle animated particle background for premium feel.
class _AnimatedParticleBackground extends StatelessWidget {
  const _AnimatedParticleBackground({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomPaint(
      painter: _ParticlePainter(
        controller: controller,
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : PhoenixColors.primary.withValues(alpha: 0.04),
      ),
      size: Size.infinite,
    );
  }
}

/// Custom painter for floating particle animation.
class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.controller,
    required this.color,
  }) : super(repaint: controller);

  final AnimationController controller;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = Random(42);
    final particleCount = 20;
    final progress = controller.value;

    for (int i = 0; i < particleCount; i++) {
      random.nextDouble(); // advance
      final seed = i * 100;
      final xBase = (seed * 1.3) % size.width;
      final yBase = (seed * 2.7) % size.height;
      final floatX = sin(progress * 2 * pi + i * 1.2) * 8;
      final floatY = cos(progress * 2 * pi + i * 1.7) * 6;

      final radius = 1.5 + (i % 3) * 1.0;
      canvas.drawCircle(
        Offset(xBase + floatX, yBase + floatY),
        radius,
        paint..color = color.withValues(alpha: 0.3 + (i % 5) * 0.08),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}