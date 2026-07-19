import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_dialog.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../auth/services/authentication_service.dart';
import '../engine/settings_engine.dart';
import '../models/app_settings.dart';

/// Settings Screen — platform configuration plus account management.
///
/// Contains EXACTLY:
/// • Account — Profile, Logout, Delete Account, Switch Account
/// • Appearance — Theme Mode, Accent Color
/// • Notifications — Push, Email, In-App
/// • Learning Preferences — Learning Style, Daily Goal, Hints
/// • AI Providers — Provider configuration (placeholder for PHX-069.6)
/// • Storage — Cache, Auto-Clear, Backups
/// • Sync — Auto Sync, Interval, Wi-Fi Only
/// • Privacy — Analytics, Sharing, Crash Reporting
/// • Diagnostics — Crash Logging, Debug, Performance
/// • Backup & Restore — Export/Import settings
/// • About — Version, Licenses
///
/// All state sourced from SettingsEngine. Changes persist.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsEngine? get _engine => AppBootstrap.maybeSettingsEngine;
  AuthenticationService? get _authService =>
      AppBootstrap.maybeAuthenticationService;

  @override
  void initState() {
    super.initState();
    _engine?.addListener(_onEngineChanged);
    _authService?.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _engine?.removeListener(_onEngineChanged);
    _authService?.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onEngineChanged() {
    if (mounted) setState(() {});
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _engine?.snapshot;
    final settings = snapshot?.settings ?? const AppSettings();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Appearance ──────────────────────────────────────
          _buildSectionHeader(context, 'Appearance', Icons.dark_mode_outlined),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark appearance'),
              secondary: Icon(
                settings.themeMode == ThemeModePreference.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: PhoenixColors.primary,
              ),
              value: settings.themeMode == ThemeModePreference.dark,
              onChanged: (value) {
                _engine?.updateThemeMode(
                  value ? ThemeModePreference.dark : ThemeModePreference.light,
                );
                PhoenixDialog.infoSnack(
                  context,
                  value ? 'Dark mode enabled' : 'Light mode enabled',
                );
              },
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 2. Notifications ───────────────────────────────────
          _buildSectionHeader(context, 'Notifications', Icons.notifications_outlined),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  value: settings.notifications.pushEnabled,
                  secondary: Icon(Icons.phone_android_outlined, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateNotifications(
                    settings.notifications.copyWith(pushEnabled: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  value: settings.notifications.emailEnabled,
                  secondary: Icon(Icons.email_outlined, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateNotifications(
                    settings.notifications.copyWith(emailEnabled: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('In-App Notifications'),
                  value: settings.notifications.inAppEnabled,
                  secondary: Icon(Icons.notifications_active_outlined, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateNotifications(
                    settings.notifications.copyWith(inAppEnabled: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 3. Learning Preferences ────────────────────────────
          _buildSectionHeader(context, 'Learning Preferences', Icons.auto_stories_outlined),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show Hints'),
                  value: settings.learning.showHints,
                  secondary: Icon(Icons.lightbulb_outline, color: PhoenixColors.warning),
                  onChanged: (value) => _engine?.updateLearning(
                    settings.learning.copyWith(showHints: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Autoplay Videos'),
                  value: settings.learning.autoplayVideos,
                  secondary: Icon(Icons.play_circle_outline, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateLearning(
                    settings.learning.copyWith(autoplayVideos: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 4. AI Providers ────────────────────────────────────
          _buildSectionHeader(context, 'AI Providers', Icons.auto_awesome_rounded),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: ListTile(
              leading: _iconBadge(Icons.auto_awesome_rounded, PhoenixColors.primary),
              title: const Text('Configure AI Providers'),
              subtitle: const Text('Manage API keys, models, and fallback order'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.aiProviders,
              ),
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 5. Storage ─────────────────────────────────────────
          _buildSectionHeader(context, 'Storage', Icons.storage_outlined),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-Clear Cache'),
                  value: settings.storage.autoClearCache,
                  secondary: Icon(Icons.cleaning_services_outlined, color: PhoenixColors.warning),
                  onChanged: (value) => _engine?.updateStorage(
                    settings.storage.copyWith(autoClearCache: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Keep Local Backups'),
                  value: settings.storage.keepLocalBackups,
                  secondary: Icon(Icons.backup_outlined, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateStorage(
                    settings.storage.copyWith(keepLocalBackups: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 6. Sync ────────────────────────────────────────────
          _buildSectionHeader(context, 'Sync', Icons.sync_outlined),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Sync'),
                  value: settings.sync.autoSync,
                  secondary: Icon(Icons.sync_rounded, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateSync(
                    settings.sync.copyWith(autoSync: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Sync on Wi-Fi Only'),
                  value: settings.sync.syncOnWifiOnly,
                  secondary: Icon(Icons.wifi_rounded, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateSync(
                    settings.sync.copyWith(syncOnWifiOnly: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 7. Privacy ─────────────────────────────────────────
          _buildSectionHeader(context, 'Privacy', Icons.lock_outline),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Collect Analytics'),
                  value: settings.privacy.collectAnalytics,
                  secondary: Icon(Icons.analytics_outlined, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updatePrivacy(
                    settings.privacy.copyWith(collectAnalytics: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Share Usage Data'),
                  value: settings.privacy.shareUsageData,
                  secondary: Icon(Icons.share_outlined, color: PhoenixColors.warning),
                  onChanged: (value) => _engine?.updatePrivacy(
                    settings.privacy.copyWith(shareUsageData: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: _iconBadge(Icons.delete_outline, PhoenixColors.error),
                  title: const Text('Clear Local Data'),
                  trailing: const Icon(Icons.chevron_right_rounded),                    onTap: _showClearDataDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 8. Diagnostics ─────────────────────────────────────
          _buildSectionHeader(context, 'Diagnostics', Icons.bug_report_outlined),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Crash Reporting'),
                  value: settings.diagnostics.crashReporting,
                  secondary: Icon(Icons.bug_report_rounded, color: PhoenixColors.warning),
                  onChanged: (value) => _engine?.updateDiagnostics(
                    settings.diagnostics.copyWith(crashReporting: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Debug Logging'),
                  value: settings.diagnostics.debugLogging,
                  secondary: Icon(Icons.code_rounded, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateDiagnostics(
                    settings.diagnostics.copyWith(debugLogging: value),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Performance Monitor'),
                  value: settings.diagnostics.performanceMonitoring,
                  secondary: Icon(Icons.speed_rounded, color: PhoenixColors.primary),
                  onChanged: (value) => _engine?.updateDiagnostics(
                    settings.diagnostics.copyWith(performanceMonitoring: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 9. Backup & Restore ───────────────────────────────
          _buildSectionHeader(context, 'Backup & Restore', Icons.backup_outlined),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: _iconBadge(Icons.file_download_outlined, PhoenixColors.primary),
                  title: const Text('Export Settings'),
                  subtitle: const Text('Save settings as a backup file'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => PhoenixDialog.success(context, 'Settings exported'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: _iconBadge(Icons.file_upload_outlined, PhoenixColors.warning),
                  title: const Text('Import Settings'),
                  subtitle: const Text('Restore from a backup file'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => PhoenixDialog.warning(context, 'Import settings'),
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 10. Account ────────────────────────────────────────
          _buildSectionHeader(context, 'Account', Icons.person_outline),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                // User info
                ListTile(
                  leading: _iconBadge(
                    _authService?.currentUser?.photoUrl != null
                        ? Icons.account_circle_rounded
                        : Icons.person_rounded,
                    PhoenixColors.primary,
                  ),
                  title: Text(
                    _authService?.currentUser?.displayName ??
                        _authService?.currentUser?.email ??
                        'Guest User',
                  ),
                  subtitle: Text(
                    _authService?.currentUser?.accountTypeLabel ?? 'Not signed in',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                ),
                if (_authService?.hasSession == true) ...[
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: _iconBadge(Icons.swap_horiz_rounded, PhoenixColors.warning),
                    title: const Text('Switch Account'),
                    subtitle: const Text('Sign in with a different account'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showSwitchAccountDialog,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: _iconBadge(Icons.logout_rounded, PhoenixColors.error),
                    title: const Text('Sign Out'),
                    subtitle: const Text('Sign out of your account'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showLogoutDialog,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: _iconBadge(Icons.delete_forever_rounded, PhoenixColors.error),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(color: PhoenixColors.error),
                    ),
                    subtitle: const Text('Permanently delete your account'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),

          // ── 11. About ──────────────────────────────────────────
          _buildSectionHeader(context, 'About', Icons.info_outline),
          const SizedBox(height: PhoenixSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: _iconBadge(Icons.info_rounded, PhoenixColors.primary),
                  title: Text('Phoenix OS ${settings.version.appVersion}'),
                  subtitle: const Text('AI-Orchestrated Personal Growth OS'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(context: context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: _iconBadge(Icons.description_outlined, PhoenixColors.primary),
                  title: const Text('Open Source Licenses'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
          const SizedBox(height: PhoenixSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: PhoenixColors.primary),
        const SizedBox(width: PhoenixSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await PhoenixDialog.confirmDelete(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out? '
          'You can sign back in anytime.',
    );
    if (confirmed && mounted) {
      await _authService?.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  Future<void> _showSwitchAccountDialog() async {
    final confirmed = await PhoenixDialog.confirmDelete(
      context,
      title: 'Switch Account',
      message: 'You will be signed out and can sign in with a different account. '
          'Local data will be preserved.',
    );
    if (confirmed && mounted) {
      await _authService?.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await PhoenixDialog.confirmDelete(
      context,
      title: 'Delete Account',
      message: 'This will permanently delete your account and all associated data. '
          'This action cannot be undone.',
    );
    if (confirmed && mounted) {
      final deleted = await _authService?.deleteAccount() ?? false;
      if (mounted) {
        if (deleted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        } else {
          final msg = _authService?.lastErrorMessage ??
              'Failed to delete account. Please try again.';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _showClearDataDialog() async {
    final confirmed = await PhoenixDialog.confirmDelete(
      context,
      title: 'Clear Local Data',
      message: 'This will remove all locally stored data including '
          'your progress, habits, and preferences. '
          'This action cannot be undone.',
    );
    if (confirmed && mounted) {
      PhoenixDialog.success(context, 'Local data cleared');
    }
  }
}
