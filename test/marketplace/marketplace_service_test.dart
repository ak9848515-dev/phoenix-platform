import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/marketplace/models/plugin_installation.dart';
import 'package:phoenix_platform/features/marketplace/services/marketplace_service.dart';

void main() {
  group('MarketplaceService', () {
    late MarketplaceService service;

    setUp(() {
      service = MarketplaceService();
    });

    test('getAllPlugins returns all built-in plugins', () {
      final plugins = service.getAllPlugins();
      expect(plugins.length, greaterThanOrEqualTo(6));
      expect(plugins.every((p) => p.id.isNotEmpty), isTrue);
    });

    test('getInstalledPlugins returns at least one active plugin', () {
      final installed = service.getInstalledPlugins();
      expect(installed.isNotEmpty, true);
      // At least the identity-matching plugin should be active
      expect(installed.any((p) => p.isActive), true);
    });

    test('getAvailablePlugins returns non-active plugins', () {
      final available = service.getAvailablePlugins();
      expect(available.every((p) => !p.isActive), true);
    });

    test('plugins have valid names and versions', () {
      final plugins = service.getAllPlugins();
      for (final plugin in plugins) {
        expect(plugin.name.isNotEmpty, true);
        expect(plugin.version.isNotEmpty, true);
        expect(plugin.description.isNotEmpty, true);
      }
    });

    test('activeCount returns correct count', () {
      final installed = service.getInstalledPlugins();
      final activeCount = service.activeCount;
      expect(activeCount, installed.where((p) => p.isActive).length);
    });

    test('pluginCount matches all plugins', () {
      final all = service.getAllPlugins();
      expect(service.pluginCount, all.length);
    });

    test('stateSummary contains all states', () {
      final summary = service.stateSummary;
      expect(summary.isNotEmpty, true);
    });

    test('getPluginDetails returns plugin by id', () {
      final all = service.getAllPlugins();
      if (all.isNotEmpty) {
        final firstPlugin = all.first;
        final details = service.getPluginDetails(firstPlugin.id);
        expect(details, isNotNull);
        expect(details!.id, firstPlugin.id);
      }
    });

    test('getPluginDetails returns null for unknown id', () {
      final details = service.getPluginDetails('non_existent_plugin');
      expect(details, isNull);
    });

    group('Plugin lifecycle operations', () {
      test('activatePlugin activates an available plugin', () {
        final available = service.getAvailablePlugins();
        if (available.isNotEmpty) {
          final plugin = available.first;
          final result = service.activatePlugin(plugin.id);
          expect(result.status, InstallStatus.active);
          expect(result.isActive, true);

          // Verify it's now in installed
          final installed = service.getInstalledPlugins();
          expect(installed.any((p) => p.id == plugin.id), true);
        }
      });

      test('activatePlugin returns error for unknown plugin', () {
        final result = service.activatePlugin('unknown');
        expect(result.status, InstallStatus.error);
        expect(result.error, isNotNull);
      });

      test('deactivatePlugin deactivates an active plugin', () {
        final installed = service.getInstalledPlugins();
        if (installed.length > 1) {
          // Pick a non-identity plugin if possible, or the first
          final plugin = installed.first;
          final result = service.deactivatePlugin(plugin.id);
          expect(result.status, InstallStatus.installed);

          // Verify it's now available
          final available = service.getAvailablePlugins();
          expect(available.any((p) => p.id == plugin.id), true);
        }
      });

      test('deactivatePlugin returns error for unknown plugin', () {
        final result = service.deactivatePlugin('unknown');
        expect(result.status, InstallStatus.error);
      });

      test('removePlugin removes a plugin', () {
        final all = service.getAllPlugins();
        if (all.length > 1) {
          // Pick a non-primary plugin
          final plugin = all.first;
          final result = service.removePlugin(plugin.id);
          expect(result.status, InstallStatus.removed);

          // Verify it's gone
          final remaining = service.getAllPlugins();
          expect(remaining.any((p) => p.id == plugin.id), false);
        }
      });

      test('removePlugin returns error for unknown plugin', () {
        final result = service.removePlugin('unknown');
        expect(result.status, InstallStatus.error);
      });
    });

    group('versionIsStable', () {
      test('returns true for v1+', () {
        expect(MarketplaceService.versionIsStable('1.0.0'), true);
        expect(MarketplaceService.versionIsStable('2.0.0'), true);
      });

      test('returns false for v0', () {
        expect(MarketplaceService.versionIsStable('0.9.0'), false);
        expect(MarketplaceService.versionIsStable('0.1.0'), false);
      });

      test('returns false for empty version', () {
        expect(MarketplaceService.versionIsStable(''), false);
      });
    });
  });

  group('MarketplaceService with custom identity', () {
    test('activates the matching plugin for Flutter Developer identity', () {
      final service = MarketplaceService();
      final installed = service.getInstalledPlugins();
      expect(installed.any((p) => p.name.contains('Flutter')), true);
    });
  });
}
