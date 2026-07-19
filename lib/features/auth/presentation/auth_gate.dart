import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../models/authentication_state.dart';
import '../services/authentication_service.dart';

/// AuthGate — root-level routing widget that determines the initial
/// screen based on authentication state.
///
/// **Flow:**
/// ```
/// Splash
///   ↓
/// AuthGate (authentication check)
///   ↓
/// If authenticated  →  Dashboard
/// If anonymous      →  Dashboard (guest mode)
/// If expired        →  Login (with message)
/// If unauthenticated → Login
/// If error          →  Login (with error)
/// ```
///
/// **Architecture:**
/// - Reads [AuthenticationService] state
/// - No business logic — presentation only
/// - Never accesses FirebaseAuth directly
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthenticationService? _authService;

  @override
  void initState() {
    super.initState();
    _authService = AppBootstrap.maybeAuthenticationService;
    _authService?.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService?.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authService = _authService;
    if (authService == null) {
      // Auth service not initialized — show splash
      return const _SplashPlaceholder();
    }

    switch (authService.state) {
      case AuthenticationState.initializing:
        return const _SplashPlaceholder();

      case AuthenticationState.authenticated:
      case AuthenticationState.anonymous:
        // Authenticated or guest — check if identity is set up
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final identityEngine = AppBootstrap.maybeIdentityEngine;
          final identitySnap = identityEngine?.snapshot;
          final hasIdentity = identitySnap != null &&
              identitySnap.profile.fullName.isNotEmpty;

          if (hasIdentity) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
          } else {
            // First login — mandatory Identity Setup
            Navigator.of(context).pushReplacementNamed(AppRoutes.identitySetup);
          }
        });
        return const _SplashPlaceholder();

      case AuthenticationState.expired:
        // Session expired — go to login with message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.login,
              arguments: {'expired': true},
            );
          }
        });
        return const _SplashPlaceholder();

      case AuthenticationState.offline:
        // Previously authenticated, now offline — go to dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
          }
        });
        return const _SplashPlaceholder();

      case AuthenticationState.error:
        // Error — go to login with error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.login,
              arguments: {
                'error': authService.lastErrorMessage ??
                    'Authentication error. Please sign in again.',
              },
            );
          }
        });
        return const _SplashPlaceholder();

      case AuthenticationState.unauthenticated:
        // Not authenticated — check onboarding first, then go to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
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

          // Onboarding complete — go to login
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        });
        return const _SplashPlaceholder();
    }
  }
}

/// Simple splash placeholder shown during auth check.
class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Phoenix',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personal Growth OS',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
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