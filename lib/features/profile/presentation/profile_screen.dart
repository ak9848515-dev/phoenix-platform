import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../auth/services/authentication_service.dart';

/// Identity Hub — single source of truth for user identity.
///
/// PHX-087: Simplified minimal layout. Shows ONLY what matters:
/// • Profile identity card (compact)
/// • Account essentials
/// • Quick settings links
///
/// No redundant cards, no cluttered sections, maximum simplicity.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final theme = Theme.of(context);
    final identityEngine = AppBootstrap.maybeIdentityEngine;
    final identitySnap = identityEngine?.snapshot;
    final identityTitle = identitySnap?.currentIdentityTitle ?? 'Explorer';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Identity Card (compact) ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PhoenixSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PhoenixColors.primary.withValues(alpha: 0.08),
                  PhoenixColors.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: PhoenixColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: PhoenixColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: PhoenixSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        identityTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        identitySnap?.currentGoal.isNotEmpty == true
                            ? identitySnap!.currentGoal
                            : 'Begin your journey',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.xxl),

          // ── Quick Actions ─────────────────────────────────────────
          _buildSectionTitle(theme, 'Quick Actions'),
          const SizedBox(height: PhoenixSpacing.md),
          _ActionCard(
            icon: Icons.tune_rounded,
            label: 'Settings',
            subtitle: 'App preferences, theme, notifications',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
          const SizedBox(height: PhoenixSpacing.md),
          _ActionCard(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Providers',
            subtitle: 'Configure AI models and API keys',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.aiProviders),
          ),
          const SizedBox(height: PhoenixSpacing.md),
          _ActionCard(
            icon: Icons.security_rounded,
            label: 'Account',
            subtitle: 'Security, privacy, connected devices',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),

          const SizedBox(height: PhoenixSpacing.xxl),

          // ── About ─────────────────────────────────────────────────
          _buildSectionTitle(theme, 'About'),
          const SizedBox(height: PhoenixSpacing.md),
          _ActionCard(
            icon: Icons.info_outline_rounded,
            label: 'Phoenix OS',
            subtitle: 'AI Career Operating System · ${AppConfig.appVersion}',
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Minimal action card with icon, label, subtitle, and tap target.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PhoenixColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: PhoenixColors.primary),
            ),
            const SizedBox(width: PhoenixSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
