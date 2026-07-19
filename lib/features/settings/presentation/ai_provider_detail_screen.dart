import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../ai/provider_config/models/provider_config.dart';
import '../../ai/provider_config/services/connection_test_service.dart';
import '../../ai/provider_config/services/health_monitor.dart';
import '../../ai/provider_config/services/provider_config_service.dart';

/// AI Provider Detail screen — full configuration for a single provider.
class AIProviderDetailScreen extends StatefulWidget {
  const AIProviderDetailScreen({super.key, required this.config});

  final ProviderConfiguration config;

  @override
  State<AIProviderDetailScreen> createState() =>
      _AIProviderDetailScreenState();
}

class _AIProviderDetailScreenState extends State<AIProviderDetailScreen> {
  ProviderConfigurationService? get _configService =>
      AppBootstrap.maybeProviderConfigService;
  HealthMonitor? get _healthMonitor => AppBootstrap.maybeHealthMonitor;
  ConnectionTestService? get _testService =>
      AppBootstrap.maybeConnectionTestService;

  late ProviderConfiguration _config;
  bool _hasApiKey = false;
  bool _testing = false;
  String? _testResult;
  bool _testSuccess = false; // ignore: unused_field

  @override
  void initState() {
    super.initState();
    _config = widget.config;
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final service = _configService;
    if (service == null) return;
    final has = await service.hasApiKey(_config.providerId);
    if (mounted) setState(() => _hasApiKey = has);
  }

  Future<void> _toggleEnabled() async {
    final service = _configService;
    if (service == null) return;
    if (_config.enabled) {
      await service.disableProvider(_config.providerId);
    } else {
      await service.enableProvider(_config.providerId);
    }
    await _reloadConfig();
  }

  Future<void> _setDefault() async {
    final service = _configService;
    if (service == null) return;
    await service.setDefaultProvider(_config.providerId);
    await _reloadConfig();
  }

  Future<void> _setOfflineMode(bool offline) async {
    final service = _configService;
    if (service == null) return;
    await service.setOfflineMode(_config.providerId, offline);
    await _reloadConfig();
  }

  Future<void> _setPreferredModel() async {
    final controller = TextEditingController(
      text: _config.preferredModel ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Preferred Model'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. gpt-4o, claude-3-opus',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _configService?.setPreferredModel(_config.providerId, result);
      await _reloadConfig();
    }
  }

  Future<void> _manageApiKey() async {
    final service = _configService;
    if (service == null) return;

    if (_hasApiKey) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('API Key'),
          content: const Text('An API key is currently stored.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(ctx).pop('replace'),
              icon: const Icon(Icons.key_rounded, size: 18),
              label: const Text('Replace Key'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.of(ctx).pop('remove'),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove Key'),
            ),
          ],
        ),
      );

      if (action == 'remove') {
        await service.deleteApiKey(_config.providerId);
        await _checkApiKey();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API key removed'),
                behavior: SnackBarBehavior.floating),
          );
        }
      } else if (action == 'replace') {
        await _enterApiKey();
      }
    } else {
      await _enterApiKey();
    }
  }

  Future<void> _enterApiKey() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_config.providerName} API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your API key',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _configService?.storeApiKey(_config.providerId, result);
      await _checkApiKey();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API key saved for ${_config.providerName}'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _testConnection() async {
    final service = _testService;
    if (service == null) return;

    setState(() {
      _testing = true;
      _testResult = null;
    });

    final apiKey = await _configService?.readApiKey(_config.providerId);
    final result = await service.testConnection(
      providerId: _config.providerId,
      apiKey: apiKey,
    );

    if (mounted) {
      setState(() {
        _testing = false;
        _testResult = result.isSuccess
            ? 'Connected (${result.latencyMs}ms)'
            : 'Failed: ${result.errorReason ?? "Unknown error"}';
        _testSuccess = result.isSuccess;
      });

      _healthMonitor?.reportHealth(
        providerId: _config.providerId,
        status: result.isSuccess
            ? ProviderHealthStatus.healthy
            : ProviderHealthStatus.unavailable,
      );
    }
  }

  Future<void> _refreshHealth() async {
    _healthMonitor?.reportHealth(
      providerId: _config.providerId,
      status: ProviderHealthStatus.healthy,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health status refreshed'),
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _reloadConfig() async {
    final service = _configService;
    if (service == null) return;
    final updated = await service.load(_config.providerId);
    if (updated != null && mounted) {
      setState(() => _config = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final healthStatus = _healthMonitor?.getHealth(_config.providerId) ??
        _config.healthStatus;
    final healthColor = _healthColor(healthStatus);
    final stats = _config.usageStatistics;
    final lastCheck = _healthMonitor?.lastCheckTime(_config.providerId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_config.providerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reloadConfig,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusBanner(
              config: _config,
              healthStatus: healthStatus,
              healthColor: healthColor,
              lastCheck: lastCheck,
            ),
            const SizedBox(height: AppSpacing.lg),

            // General
            _buildSection(context, 'General', Icons.info_outline, [
              _tile(Icons.label_outline, 'Provider Name', _config.providerName, AppColors.primary, hasDivider: true),
              _tile(Icons.fingerprint, 'Provider ID', _config.providerId, AppColors.primary, hasDivider: true),
              _switchTile(Icons.circle_rounded, 'Status', _config.enabled ? 'Enabled' : 'Disabled',
                  _config.enabled ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                  _config.enabled, _toggleEnabled),
            ]),

            // Authentication
            _buildSection(context, 'Authentication', Icons.lock_outline, [
              ListTile(
                leading: _iconBadge(
                  _hasApiKey ? Icons.key_rounded : Icons.key_off_outlined,
                  _hasApiKey ? AppColors.success : AppColors.warning,
                ),
                title: Text(_hasApiKey ? 'API Key Configured' : 'No API Key'),
                subtitle: Text(
                  _hasApiKey ? 'Stored securely' : 'Required for this provider',
                ),
                trailing: TextButton(
                  onPressed: _manageApiKey,
                  child: Text(_hasApiKey ? 'Manage' : 'Add Key'),
                ),
              ),
            ]),

            // Configuration
            _buildSection(context, 'Configuration', Icons.tune_outlined, [
              ListTile(
                leading: _iconBadge(Icons.model_training, AppColors.primary),
                title: const Text('Preferred Model'),
                subtitle: Text(
                  _config.preferredModel ?? 'Not set',
                  style: TextStyle(
                    color: _config.preferredModel == null
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                    fontStyle: _config.preferredModel == null
                        ? FontStyle.italic
                        : null,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _setPreferredModel,
                  child: const Text('Edit'),
                ),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                title: const Text('Default Provider'),
                subtitle: const Text('Route primary requests here'),
                value: _config.isDefault,
                secondary: Icon(Icons.star_rounded,
                    color: _config.isDefault
                        ? AppColors.warning
                        : theme.colorScheme.onSurfaceVariant),
                onChanged: _config.isDefault ? null : (_) => _setDefault(),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                title: const Text('Offline Mode'),
                subtitle: const Text('Operate without network'),
                value: _config.offlineMode,
                secondary: Icon(Icons.wifi_off_rounded,
                    color: _config.offlineMode
                        ? AppColors.warning
                        : theme.colorScheme.onSurfaceVariant),
                onChanged: _setOfflineMode,
              ),
            ]),

            // Reliability
            _buildSection(context, 'Reliability', Icons.monitor_heart_outlined, [
              _healthTile(theme, healthStatus, healthColor),
              if (_config.lastSuccessfulConnection != null)
                _infoTile(Icons.check_circle_outlined, 'Last Successful',
                    _formatDate(_config.lastSuccessfulConnection!), AppColors.success),
              if (_config.lastFailure != null)
                _infoTile(Icons.error_outline, 'Last Failure',
                    _formatDate(_config.lastFailure!), AppColors.error),
              if (stats != null && stats.averageResponseTimeMs > 0)
                _infoTile(Icons.speed_rounded, 'Avg Response Time',
                    '${stats.averageResponseTimeMs.toStringAsFixed(0)}ms', AppColors.primary),
              if (stats != null && stats.totalFailures > 0)
                _infoTile(Icons.error_outline, 'Failures',
                    '${stats.totalFailures}', AppColors.error),
            ]),

            // Operations
            _buildSection(context, 'Operations', Icons.play_circle_outline, [
              _testConnectionTile(theme),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: _iconBadge(Icons.refresh_rounded, AppColors.primary),
                title: const Text('Refresh Health'),
                subtitle: const Text('Update health status'),
                trailing: TextButton(
                  onPressed: _refreshHealth,
                  child: const Text('Refresh'),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: _iconBadge(Icons.cleaning_services_outlined, AppColors.warning),
                title: const Text('Clear Cache'),
                subtitle: const Text('Reset cached data for this provider'),
                trailing: TextButton(
                  onPressed: () {
                    _healthMonitor?.resetHealth(_config.providerId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared'),
                          behavior: SnackBarBehavior.floating),
                    );
                  },
                  child: const Text('Clear'),
                ),
              ),
            ]),

            // Statistics
            _buildSection(context, 'Statistics', Icons.bar_chart_outlined, [
              _statTile(Icons.send_rounded, 'Total Requests', '${stats?.totalRequests ?? 0}', AppColors.primary),
              if (stats != null && stats.totalTokens > 0)
                _statTile(Icons.token_rounded, 'Total Tokens', '${stats.totalTokens}', AppColors.primary, hasDivider: true),
              if (stats != null && stats.estimatedCost > 0)
                _statTile(Icons.attach_money_rounded, 'Estimated Cost',
                    '\$${stats.estimatedCost.toStringAsFixed(4)}', AppColors.warning, hasDivider: true),
              if (stats != null && stats.averageResponseTimeMs > 0)
                _statTile(Icons.speed_rounded, 'Avg Response Time',
                    '${stats.averageResponseTimeMs.toStringAsFixed(0)}ms', AppColors.primary, hasDivider: true),
              if (stats?.lastUsed != null)
                _statTile(Icons.access_time_rounded, 'Last Used', _formatDate(stats!.lastUsed!),
                    theme.colorScheme.onSurfaceVariant, hasDivider: true),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Builder helpers ──────────────────────────────────────────────

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(child: Column(children: children)),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, Color color, {bool hasDivider = false}) {
    return Column(
      children: [
        if (hasDivider && !identical(title, 'Provider Name')) const Divider(height: 1, indent: 56),
        ListTile(
          leading: _iconBadge(icon, color),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ],
    );
  }

  Widget _switchTile(IconData icon, String title, String subtitle, Color color,
      bool value, VoidCallback onToggle) {
    return Column(
      children: [
        const Divider(height: 1, indent: 56),
        ListTile(
          leading: _iconBadge(icon, color),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Switch(value: value, onChanged: (_) => onToggle()),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        const Divider(height: 1, indent: 56),
        ListTile(
          leading: _iconBadge(icon, color),
          title: Text(label),
          subtitle: Text(value),
        ),
      ],
    );
  }

  Widget _healthTile(ThemeData theme, ProviderHealthStatus status, Color color) {
    return ListTile(
      leading: _iconBadge(Icons.health_and_safety_rounded, color),
      title: const Text('Health Status'),
      subtitle: Text(status.displayName),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(status.displayName,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _testConnectionTile(ThemeData theme) {
    return ListTile(
      leading: _iconBadge(Icons.wifi_find_rounded, AppColors.primary),
      title: const Text('Test Connection'),
      subtitle: Text(
        _testing ? 'Testing...' : _testResult ?? 'Verify provider connectivity',
      ),
      trailing: _testing
          ? const SizedBox(width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2))
          : FilledButton.tonalIcon(
              onPressed: _testConnection,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Test'),
            ),
    );
  }

  Widget _statTile(IconData icon, String label, String value, Color color, {bool hasDivider = false}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (hasDivider) const Divider(height: 1, indent: 56),
        ListTile(
          leading: _iconBadge(icon, color),
          title: Text(label, style: theme.textTheme.bodyMedium),
          trailing: Text(value,
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: color)),
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

  Color _healthColor(ProviderHealthStatus status) {
    switch (status) {
      case ProviderHealthStatus.healthy:
        return AppColors.success;
      case ProviderHealthStatus.unavailable:
        return AppColors.error;
      case ProviderHealthStatus.authenticationFailed:
        return AppColors.warning;
      case ProviderHealthStatus.rateLimited:
        return AppColors.warning;
      case ProviderHealthStatus.offline:
        return PhoenixColors.textSecondary;
      case ProviderHealthStatus.unknown:
        return PhoenixColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.config,
    required this.healthStatus,
    required this.healthColor,
    required this.lastCheck,
  });

  final ProviderConfiguration config;
  final ProviderHealthStatus healthStatus;
  final Color healthColor;
  final DateTime? lastCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: healthColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: healthColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: healthColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cloud_done_rounded, color: healthColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.providerName,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${healthStatus.displayName}${config.offlineMode ? " • Offline Mode" : ""}',
                    style: theme.textTheme.bodySmall?.copyWith(color: healthColor)),
                if (lastCheck != null)
                  Text('Last check: ${_formatAgo(lastCheck!)}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(width: 12, height: 12,
              decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  String _formatAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
