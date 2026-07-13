import 'package:flutter/material.dart';

import '../../../core/sample_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../services/marketplace_service.dart';
import '../widgets/available_plugins_card.dart';
import '../widgets/installed_plugins_card.dart';
import '../widgets/marketplace_actions_card.dart';
import '../widgets/marketplace_header.dart';
import '../widgets/marketplace_statistics_card.dart';
import '../widgets/plugin_capabilities_card.dart';
import '../widgets/plugin_details_card.dart';

/// The Marketplace screen for managing Phoenix plugins.
///
/// This is NOT an online store. It is the local plugin management layer.
/// No networking, no purchases, no authentication, no AI, no persistence.
///
/// Presentation only. StatelessWidget.
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final marketplaceService = MarketplaceService(repository: repository);

    final installedPlugins = marketplaceService.getInstalledPlugins();
    final availablePlugins = marketplaceService.getAvailablePlugins();
    final allPlugins = marketplaceService.getAllPlugins();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarketplaceHeader(
            identityTitle: repository.selectedIdentity.title,
            installedCount: installedPlugins.length,
            availableCount: availablePlugins.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          MarketplaceStatisticsCard(
            totalPlugins: allPlugins.length,
            activeCount: marketplaceService.activeCount,
            availableCount: availablePlugins.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          InstalledPluginsCard(plugins: installedPlugins),
          const SizedBox(height: AppSpacing.lg),
          AvailablePluginsCard(plugins: availablePlugins),
          const SizedBox(height: AppSpacing.lg),
          if (installedPlugins.isNotEmpty)
            PluginDetailsCard(plugin: installedPlugins.first),
          if (installedPlugins.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            PluginCapabilitiesCard(plugin: installedPlugins.first),
            const SizedBox(height: AppSpacing.lg),
          ],
          MarketplaceActionsCard(
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onIdentity: () =>
                Navigator.of(context).pushNamed(AppRoutes.identity),
            onJourney: () => Navigator.of(context).pushNamed(AppRoutes.journey),
            onCareer: () => Navigator.of(context).pushNamed(AppRoutes.career),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
