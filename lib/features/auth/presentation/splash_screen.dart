import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../services/auth_service.dart';

/// Splash Screen — checks authentication state on startup.
///
/// Flow:
/// 1. Show splash animation
/// 2. Check auth state via [AuthService]
/// 3. Navigate to Login or Dashboard
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
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Brief delay for splash visibility
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Check if onboarding has been completed
    final storage = AppBootstrap.maybeStorageService;
    if (storage != null) {
      final settings = storage.readUserSettings();
      if (!settings.onboardingComplete) {
        // First-time user — show onboarding flow
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        return;
      }
    }

    // Onboarding complete — check auth state
    final authService = AppBootstrap.maybeAuthService;
    if (authService == null) {
      // Auth service not initialized — go to dashboard
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      return;
    }

    if (authService.isAuthenticated) {
      // User is logged in — go to dashboard
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      // User is not logged in — go to login
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
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
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Phoenix',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Personal Growth OS',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
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