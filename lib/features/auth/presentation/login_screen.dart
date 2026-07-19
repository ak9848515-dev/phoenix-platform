import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../services/authentication_service.dart';

/// Login Screen — Google Sign-In primary, Guest mode as limited experience.
///
/// Flow:
/// 1. Google Sign-In is the primary action (FilledButton)
/// 2. Guest mode available as "Limited Experience (Guest)"
/// 3. Email/password login removed for v1.0 production release
///
/// No business logic. Presentation only.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  AuthenticationService? _authService;

  @override
  void initState() {
    super.initState();
    _authService = AppBootstrap.maybeAuthenticationService;

    // Check for expired/error arguments passed from AuthGate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        String? message;
        if (args['expired'] == true) {
          message = 'Your session has expired. Please sign in again.';
        } else if (args['error'] != null) {
          message = args['error'] as String;
        }
        if (message != null && mounted) {
          final msg = message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final authService = _authService;
    if (authService == null) {
      setState(() => _isLoading = false);
      _showError('Authentication service not available.');
      return;
    }

    final success = await authService.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      setState(() => _isLoading = false);
      _showError(authService.lastErrorMessage ?? 'Google Sign-In failed.');
    }
  }

  Future<void> _handleAnonymousLogin() async {
    setState(() => _isLoading = true);

    final authService = _authService;
    if (authService == null) {
      setState(() => _isLoading = false);
      _showError('Authentication service not available.');
      return;
    }

    final success = await authService.signInAnonymously();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      setState(() => _isLoading = false);
      _showError(authService.lastErrorMessage ?? 'Sign-in failed.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PhoenixSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo ──────────────────────────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(PhoenixSpacing.lg),
                    decoration: BoxDecoration(
                      color: PhoenixColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 48,
                      color: PhoenixColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: PhoenixSpacing.lg),

                // ── Title ─────────────────────────────────────────────
                Text(
                  'Phoenix',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: PhoenixSpacing.sm),
                Text(
                  'AI Career Operating System',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: PhoenixSpacing.xxl),

                // ── Google Sign-In (PRIMARY) ──────────────────────────
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                    label: const Text('Continue with Google'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: PhoenixRadius.mdRadius,
                      ),
                      backgroundColor: PhoenixColors.primary,
                      foregroundColor: PhoenixColors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: PhoenixSpacing.xl),

                // ── Divider ───────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: PhoenixSpacing.md),
                      child: Text(
                        'guest',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: PhoenixSpacing.md),

                // ── Guest Login (Limited Experience) ──────────────
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleAnonymousLogin,
                    icon: const Icon(Icons.person_outline_rounded),
                    label: const Text('Limited Experience (Guest)'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: PhoenixSpacing.md),
                Text(
                  'Sign in with Google for the full experience. '
                  'Guest mode has limited functionality.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}