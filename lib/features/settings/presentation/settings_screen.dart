import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';

/// Settings Screen — manage app preferences.
///
/// Sections:
/// 1. Theme — toggle light/dark mode, accent color
/// 2. Notifications — push, email, in-app preferences
/// 3. Sync Status — cloud sync configuration
/// 4. Privacy — data & permissions management
///
/// Presentation-only. No persistence, no state management, no business logic.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _inAppEnabled = true;
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Theme ──────────────────────────────────────────
          _buildSectionHeader(context, 'Theme', Icons.dark_mode_outlined),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark appearance'),
                  secondary: Icon(
                    _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.primary,
                  ),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Dark mode enabled' : 'Light mode enabled',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 2. Notifications ─────────────────────────────────
          _buildSectionHeader(context, 'Notifications', Icons.notifications_outlined),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive alerts on your device'),
                  secondary: Icon(Icons.phone_android_outlined, color: AppColors.primary),
                  value: _pushEnabled,
                  onChanged: (value) => setState(() => _pushEnabled = value),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive weekly progress summaries'),
                  secondary: Icon(Icons.email_outlined, color: AppColors.primary),
                  value: _emailEnabled,
                  onChanged: (value) => setState(() => _emailEnabled = value),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  title: const Text('In-App Notifications'),
                  subtitle: const Text('Show updates within the app'),
                  secondary: Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                  value: _inAppEnabled,
                  onChanged: (value) => setState(() => _inAppEnabled = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 3. Sync Status ───────────────────────────────────
          _buildSectionHeader(context, 'Sync Status', Icons.sync_outlined),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Sync'),
                  subtitle: const Text('Automatically sync data with cloud'),
                  secondary: Icon(Icons.sync_rounded, color: AppColors.primary),
                  value: _autoSync,
                  onChanged: (value) => setState(() => _autoSync = value),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                  ),
                  title: const Text('Last Synced'),
                  subtitle: const Text('Connected and up to date'),
                  trailing: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Syncing...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Sync Now'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 4. Privacy ───────────────────────────────────────
          _buildSectionHeader(context, 'Privacy', Icons.lock_outline),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.security_outlined, color: AppColors.primary, size: 20),
                  ),
                  title: const Text('Data & Permissions'),
                  subtitle: const Text('Manage what data is collected and stored'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showPrivacyInfo(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.warning, size: 20),
                  ),
                  title: const Text('Clear Local Data'),
                  subtitle: const Text('Remove all locally stored data'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── App Info ─────────────────────────────────────────
          Center(
            child: Text(
              'Phoenix OS v2.5.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Privacy & Data'),
          ],
        ),
        content: const Text(
          'Phoenix OS stores your data locally on your device. '
          'Cloud sync is optional and end-to-end encrypted.\n\n'
          '• Learning progress and analytics are stored locally\n'
          '• No personal data is shared with third parties\n'
          '• You can delete all local data at any time\n'
          '• Cloud sync uses encrypted connections',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Clear Local Data'),
          ],
        ),
        content: const Text(
          'This will remove all locally stored data including '
          'your progress, habits, and preferences. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Local data cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}
