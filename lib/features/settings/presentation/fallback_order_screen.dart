import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../ai/provider_config/models/provider_config.dart';
import '../../ai/provider_config/services/provider_config_service.dart';

/// Fallback Order screen — manage provider priority chain.
///
/// Allows reordering providers via Move Up/Move Down buttons.
/// The first provider in the list is tried first, then the next,
/// and so on down to the last provider.
class FallbackOrderScreen extends StatefulWidget {
  const FallbackOrderScreen({super.key});

  @override
  State<FallbackOrderScreen> createState() => _FallbackOrderScreenState();
}

class _FallbackOrderScreenState extends State<FallbackOrderScreen> {
  ProviderConfigurationService? get _configService =>
      AppBootstrap.maybeProviderConfigService;

  List<ProviderConfiguration> _configs = [];
  bool _loading = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    final service = _configService;
    if (service == null) return;

    try {
      var configs = await service.loadAll();
      configs.sort((a, b) => a.fallbackPriority.compareTo(b.fallbackPriority));

      if (mounted) {
        setState(() {
          _configs = configs;
          _loading = false;
          _dirty = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load providers'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _moveUp(int index) {
    if (index <= 0) return;
    final configs = List<ProviderConfiguration>.from(_configs);
    final temp = configs[index];
    configs[index] = configs[index - 1];
    configs[index - 1] = temp;
    setState(() {
      _configs = configs;
      _dirty = true;
    });
  }

  void _moveDown(int index) {
    if (index >= _configs.length - 1) return;
    final configs = List<ProviderConfiguration>.from(_configs);
    final temp = configs[index];
    configs[index] = configs[index + 1];
    configs[index + 1] = temp;
    setState(() {
      _configs = configs;
      _dirty = true;
    });
  }

  Future<void> _saveOrder() async {
    final service = _configService;
    if (service == null) return;

    final ids = _configs.map((c) => c.providerId).toList();
    await service.setFallbackOrder(ids);

    if (mounted) {
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fallback order saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fallback Order'),
        actions: [
          if (_dirty)
            TextButton.icon(
              onPressed: _saveOrder,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save'),
            ),
        ],
      ),
      body: _loading
          ? const PhoenixLoadingWidget(
              icon: Icons.swap_vert_rounded,
              title: 'Loading fallback order…',
              subtitle: 'Preparing provider priority list',
            )
          : _configs.isEmpty
              ? const PhoenixEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'No providers available',
                  message: 'Configure AI providers in Settings first to set a fallback order.',
                  primaryAction: null,
                )
              : Column(
                  children: [
                    // Info banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Providers at the top are tried first. '
                              'Move up/down to change priority.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Provider list
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _configs.length,
                        onReorderItem: (oldIndex, newIndex) {
                          setState(() {
                            final item = _configs.removeAt(oldIndex);
                            _configs.insert(newIndex, item);
                            _dirty = true;
                          });
                        },
                        itemBuilder: (context, index) {
                          final config = _configs[index];
                          return _FallbackTile(
                            key: ValueKey(config.providerId),
                            config: config,
                            index: index,
                            total: _configs.length,
                            onMoveUp: () => _moveUp(index),
                            onMoveDown: () => _moveDown(index),
                          );
                        },
                      ),
                    ),

                    // Save banner if dirty
                    if (_dirty)
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _saveOrder,
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('Save Fallback Order'),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _FallbackTile extends StatelessWidget {
  const _FallbackTile({
    super.key,
    required this.config,
    required this.index,
    required this.total,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final ProviderConfiguration config;
  final int index;
  final int total;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: config.isDefault
              ? AppColors.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(Icons.drag_handle_rounded,
                color: theme.colorScheme.onSurfaceVariant, size: 24),

            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: index == 0
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: index == 0
                        ? AppColors.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

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
                        ),
                      ),
                      if (config.isDefault) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Default',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (config.preferredModel != null)
                    Text(
                      config.preferredModel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: index > 0 ? onMoveUp : null,
                  icon: Icon(Icons.keyboard_arrow_up_rounded,
                      color: index > 0
                          ? AppColors.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Move Up',
                ),
                IconButton(
                  onPressed: index < total - 1 ? onMoveDown : null,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: index < total - 1
                          ? AppColors.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Move Down',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
