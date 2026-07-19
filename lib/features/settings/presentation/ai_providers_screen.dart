import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../ai/provider_config/models/provider_config.dart';
import '../../ai/provider_config/services/health_monitor.dart';
import '../../ai/provider_config/services/provider_config_service.dart';
import 'ai_provider_detail_screen.dart';
import 'fallback_order_screen.dart';

/// AI Providers screen — implements the PHX-087 provider experience rules.
///
/// **Rules:**
/// - **0 Providers** → Show AI Configuration popup → Configure → Auto-resume
/// - **1 Provider** → Use automatically. NO provider selection shown.
/// - **2+ Providers** → AI Provider Intelligence chooses based on:
///   Capability, Health, Availability, User Preference, Context
///
/// Provider routing remains transparent to the user.
class AIProvidersScreen extends StatefulWidget {
  const AIProvidersScreen({super.key});

  @override
  State<AIProvidersScreen> createState() => _AIProvidersScreenState();
}

class _AIProvidersScreenState extends State<AIProvidersScreen> {
  ProviderConfigurationService? get _configService =>
      AppBootstrap.maybeProviderConfigService;
  HealthMonitor? get _healthMonitor => AppBootstrap.maybeHealthMonitor;

  List<ProviderConfiguration> _configs = [];
  bool _loading = true;
  bool _showConfigDialog = false;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    final service = _configService;
    if (service == null) return;

    try {
      final configs = await service.loadAll();
      final enabledConfigs = configs.where((c) => c.enabled).toList();

      if (mounted) {
        setState(() {
          _configs = configs;
          _loading = false;
          // 0 providers → show configuration popup
          _showConfigDialog = enabledConfigs
              .where((c) => c.providerId == 'gemini' || c.providerId == 'openAI')
              .isEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabledConfigs = _configs.where((c) => c.enabled).toList();

    // ── 0 Providers → Show Configuration Popup ──────────────────
    if (!_loading && _showConfigDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _showConfigDialog) {
          _showConfigurationDialog(context);
          setState(() => _showConfigDialog = false);
        }
      });
    }

    // ── 1 Provider → Use automatically, show minimal view ───────
    if (!_loading && enabledConfigs.length == 1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Provider'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PhoenixColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: PhoenixColors.success,
                ),
              ),
              const SizedBox(height: PhoenixSpacing.lg),
              Text(
                'AI Provider Active',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: PhoenixSpacing.sm),
              Text(
                'Using ${enabledConfigs.first.providerName} automatically',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: PhoenixSpacing.xl),
              Text(
                'No configuration needed — Phoenix AI handles everything.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── 2+ Providers → Full management view ─────────────────────
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Providers'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const FallbackOrderScreen(),
              ),
            ),
            icon: const Icon(Icons.swap_vert_rounded, size: 18),
            label: const Text('Fallback'),
          ),
        ],
      ),
      body: _loading
          ? const PhoenixLoadingWidget(
              icon: Icons.auto_awesome_rounded,
              title: 'Loading AI providers?',
              subtitle: 'Checking registered providers and health status',
            )
          : RefreshIndicator(
              onRefresh: _loadConfigs,
              child: _configs.isEmpty
                  ? ListView(
                      children: [
                        PhoenixEmptyState(
                          icon: Icons.cloud_off_rounded,
                          title: 'No providers configured',
                          message: 'AI providers will appear here once configured. '
                              'Add an API key to get started.',
                          primaryAction: FilledButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded, size: 18),
                            label: const Text('Back to Settings'),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(PhoenixSpacing.md),
                      itemCount: _configs.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding:                            const EdgeInsets.fromLTRB(
                                PhoenixSpacing.sm, 0, PhoenixSpacing.sm, PhoenixSpacing.md),
                            child: Text(
                              '${_configs.length} providers registered',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        final config = _configs[index - 1];
                        return _ProviderListTile(
                          config: config,
                          healthStatus:
                              _healthMonitor?.getHealth(config.providerId) ??
                                  ProviderHealthStatus.unknown,
                          onTap: () => _openDetail(config),
                        );
                      },
                    ),
            ),
    );
  }

  /// Configuration dialog for 0 providers.
  void _showConfigurationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PhoenixColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 32,
                color: PhoenixColors.primary,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.lg),
            Text(
              'AI Configuration Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PhoenixSpacing.sm),
            Text(
              'Configure an AI provider to unlock personalized learning, '
              'missions, and insights.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PhoenixSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Navigate to Gemini configuration
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ConfigProviderScreen(
                        providerId: 'gemini',
                        providerName: 'Gemini',
                        onConfigured: _loadConfigs,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text('Configure Gemini'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: PhoenixSpacing.sm),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed('/settings/ai-providers');
              },
              child: const Text('Advanced Setup'),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(ProviderConfiguration config) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIProviderDetailScreen(config: config),
      ),
    ).then((_) => _loadConfigs());
  }
}

/// Quick-configuration screen for a single provider.
class _ConfigProviderScreen extends StatefulWidget {
  const _ConfigProviderScreen({
    required this.providerId,
    required this.providerName,
    required this.onConfigured,
  });

  final String providerId;
  final String providerName;
  final VoidCallback onConfigured;

  @override
  State<_ConfigProviderScreen> createState() => _ConfigProviderScreenState();
}

class _ConfigProviderScreenState extends State<_ConfigProviderScreen> {
  final _apiKeyController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final configService = AppBootstrap.maybeProviderConfigService;
      if (configService != null) {
        await configService.storeApiKey(widget.providerId, key);
        await configService.enableProvider(widget.providerId);
        widget.onConfigured();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure ${widget.providerName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(PhoenixSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your API key',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.sm),
            Text(
              'Your API key is stored securely and never shared.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PhoenixSpacing.xl),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter your ${widget.providerName} API key',
                prefixIcon: const Icon(Icons.key_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: PhoenixSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isSaving ? 'Configuring...' : 'Save & Continue'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderListTile extends StatelessWidget {
  const _ProviderListTile({
    required this.config,
    required this.healthStatus,
    required this.onTap,
  });

  final ProviderConfiguration config;
  final ProviderHealthStatus healthStatus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final healthColor = _healthColor(healthStatus);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: config.isDefault
              ? PhoenixColors.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: config.isDefault ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(PhoenixSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: config.enabled
                      ? healthColor.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _providerIcon(config.providerId),
                  color: config.enabled ? healthColor : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: PhoenixSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          config.providerName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: config.enabled
                                ? null
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (config.isDefault) ...[
                          const SizedBox(width: PhoenixSpacing.sm),
                          Container(
                            padding:                          const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: PhoenixColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: PhoenixColors.primary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.enabled
                          ? healthStatus.displayName
                          : 'Disabled',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: config.enabled
                            ? healthColor
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (config.preferredModel != null)
                    Text(
                      config.preferredModel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!config.enabled)
                        Icon(Icons.visibility_off_outlined,
                            size: 14, color: theme.colorScheme.onSurfaceVariant),
                      if (config.offlineMode)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.wifi_off_rounded,
                              size: 14, color: PhoenixColors.warning),
                        ),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _providerIcon(String providerId) {
    switch (providerId) {
      case 'openAI':
        return Icons.psychology_rounded;
      case 'gemini':
        return Icons.auto_awesome_rounded;
      case 'claude':
        return Icons.analytics_outlined;
      case 'deepseek':
        return Icons.code_rounded;
      case 'openRouter':
        return Icons.hub_rounded;
      case 'ollama':
        return Icons.computer_rounded;
      default:
        return Icons.cloud_outlined;
    }
  }

  Color _healthColor(ProviderHealthStatus status) {
    switch (status) {
      case ProviderHealthStatus.healthy:
        return PhoenixColors.success;
      case ProviderHealthStatus.unavailable:
        return PhoenixColors.error;
      case ProviderHealthStatus.authenticationFailed:
        return PhoenixColors.warning;
      case ProviderHealthStatus.rateLimited:
        return PhoenixColors.warning;
      case ProviderHealthStatus.offline:
        return PhoenixColors.textSecondary;
      case ProviderHealthStatus.unknown:
        return PhoenixColors.textSecondary;
    }
  }
}
