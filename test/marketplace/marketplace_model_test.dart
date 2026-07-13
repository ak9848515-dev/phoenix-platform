import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/marketplace/models/plugin_category.dart';
import 'package:phoenix_platform/features/marketplace/models/plugin_installation.dart';

void main() {
  group('PluginCategory', () {
    test('has 6 categories', () {
      expect(PluginCategory.values.length, 6);
    });

    test('technology has correct label', () {
      expect(PluginCategory.technology.label, 'Technology');
    });

    test('fromString returns matching category', () {
      expect(
        PluginCategory.fromString('Technology'),
        PluginCategory.technology,
      );
      expect(PluginCategory.fromString('Business'), PluginCategory.business);
      expect(PluginCategory.fromString('Creative'), PluginCategory.creative);
    });

    test('fromString defaults to technology for unknown', () {
      expect(PluginCategory.fromString('Unknown'), PluginCategory.technology);
    });

    test('fromManifestCategory works with valid category', () {
      final result = PluginCategory.fromManifestCategory('Technology');
      expect(result, PluginCategory.technology);
    });

    test('each category has a non-null icon', () {
      for (final category in PluginCategory.values) {
        expect(category.icon, isNotNull);
      }
    });
  });

  group('InstallStatus', () {
    test('has 6 statuses', () {
      expect(InstallStatus.values.length, 6);
    });

    test('notInstalled is first', () {
      expect(InstallStatus.values.first, InstallStatus.notInstalled);
    });

    test('removed is last', () {
      expect(InstallStatus.values.last, InstallStatus.removed);
    });
  });

  group('PluginInstallation', () {
    test('default status is notInstalled', () {
      final installation = PluginInstallation(
        pluginId: 'test',
        pluginName: 'Test Plugin',
      );
      expect(installation.status, InstallStatus.notInstalled);
      expect(installation.isInstalled, false);
      expect(installation.isActive, false);
    });

    test('active status has isInstalled and isActive', () {
      final installation = PluginInstallation(
        pluginId: 'test',
        pluginName: 'Test Plugin',
        status: InstallStatus.active,
      );
      expect(installation.isInstalled, true);
      expect(installation.isActive, true);
    });

    test('installed status has isInstalled but not isActive', () {
      final installation = PluginInstallation(
        pluginId: 'test',
        pluginName: 'Test Plugin',
        status: InstallStatus.installed,
      );
      expect(installation.isInstalled, true);
      expect(installation.isActive, false);
    });

    test('error status includes error message', () {
      final installation = PluginInstallation(
        pluginId: 'test',
        pluginName: 'Test Plugin',
        status: InstallStatus.error,
        error: 'Something went wrong',
      );
      expect(installation.error, 'Something went wrong');
    });

    test('copyWith preserves unchanged fields', () {
      final installation = PluginInstallation(
        pluginId: 'test',
        pluginName: 'Test Plugin',
        status: InstallStatus.installed,
        installedAt: DateTime(2025),
      );
      final copy = installation.copyWith(pluginName: 'Updated');

      expect(copy.pluginId, 'test');
      expect(copy.pluginName, 'Updated');
      expect(copy.status, InstallStatus.installed);
      expect(copy.installedAt, DateTime(2025));
    });

    test('equality works correctly', () {
      final a = PluginInstallation(
        pluginId: 'a',
        pluginName: 'A',
        status: InstallStatus.active,
      );
      final b = PluginInstallation(
        pluginId: 'a',
        pluginName: 'A',
        status: InstallStatus.active,
      );
      expect(a, b);
    });

    test('inequality works correctly', () {
      final a = PluginInstallation(pluginId: 'a', pluginName: 'A');
      final b = PluginInstallation(pluginId: 'b', pluginName: 'B');
      expect(a, isNot(b));
    });

    test('toString contains pluginId', () {
      final installation = PluginInstallation(
        pluginId: 'flutter_dev',
        pluginName: 'Flutter Developer',
      );
      expect(installation.toString(), contains('flutter_dev'));
    });
  });
}
