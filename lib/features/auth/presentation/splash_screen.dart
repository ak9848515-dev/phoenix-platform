import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';

/// Splash Screen — shows a branded splash animation then delegates to
/// [AuthGate] for authentication routing.
///
/// AuthGate is the single source of truth for all auth-based routing.
/// SplashScreen only displays the animation and forwards to AuthGate.
///
/// No business logic. Presentation only.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirectToAuthGate();
  }

  Future<void> _redirectToAuthGate() async {
    // Brief delay for splash visibility
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Delegate all auth routing to AuthGate
    Navigator.of(context).pushReplacementNamed(AppRoutes.authGate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phoenix logo
            Container(
              padding: const EdgeInsets.all(PhoenixSpacing.xl),
              decoration: BoxDecoration(
                color: PhoenixColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 64,
                color: PhoenixColors.primary,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.lg),
            Text(
              'Phoenix',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: PhoenixColors.primary,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.sm),
            Text(
              'AI Career Operating System',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.xxl),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}