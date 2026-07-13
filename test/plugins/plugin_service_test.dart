import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/plugins/models/plugin_manifest.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin_registry.dart';
import 'package:phoenix_platform/core/plugins/services/plugin_service.dart';

void main() {
  group('PluginService', () {
    const service = PluginService();
    const empty = PluginRegistry();

    const validManifest = PluginManifest(
      id: 'test_plugin',
      name: 'Test Plugin',
      version: '1.0.0',
      description: 'A test plugin.',
      minPhoenixVersion: '1.0.0',
      pluginApiVersion: '1.0.0',
      requiredCapabilities: ['identity'],
    );

    const testPlugin = Plugin(manifest: validManifest);

    // ─────────────────────────────────────────────────────────────────
    // installBuiltInPlugins
    // ─────────────────────────────────────────────────────────────────

    test('installBuiltInPlugins adds all built-in plugins', () {
      final result = service.installBuiltInPlugins(empty);

      expect(result.success, isTrue);
      expect(result.registry.count, greaterThanOrEqualTo(1));
      expect(result.registry.contains('software_engineer'), isTrue);
    });

    // ─────────────────────────────────────────────────────────────────
    // installAndActivateBuiltIns
    // ─────────────────────────────────────────────────────────────────

    test('installAndActivateBuiltIns fully activates all built-in plugins', () {
      final result = service.installAndActivateBuiltIns(empty);

      expect(result.success, isTrue);
      expect(result.registry.count, greaterThanOrEqualTo(1));

      // All plugins should be active
      for (final plugin in result.registry.all) {
        expect(
          plugin.state,
          PluginLifecycleState.active,
          reason: 'Plugin "${plugin.manifest.id}" should be active',
        );
      }
    });

    // ─────────────────────────────────────────────────────────────────
    // Single plugin lifecycle
    // ─────────────────────────────────────────────────────────────────

    test('install adds a plugin', () {
      final result = service.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      expect(result.success, isTrue);
      expect(service.getAll(result.registry).length, 1);
    });

    test('validate validates a plugin', () {
      final installResult = service.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      final result = service.validate(
        registry: installResult.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
    });

    test('runFullLifecycle activates a plugin', () {
      final installResult = service.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      final result = service.runFullLifecycle(
        registry: installResult.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.active);
    });

    test('deactivate and remove a plugin', () {
      // Install and activate
      final installResult = service.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );
      final lifecycleResult = service.runFullLifecycle(
        registry: installResult.registry,
        pluginId: 'test_plugin',
      );

      // Deactivate
      final deactivateResult = service.deactivate(
        registry: lifecycleResult.registry,
        pluginId: 'test_plugin',
      );
      expect(deactivateResult.success, isTrue);
      expect(deactivateResult.plugin?.state, PluginLifecycleState.deactivated);

      // Remove
      final removeResult = service.remove(
        registry: deactivateResult.registry,
        pluginId: 'test_plugin',
      );
      expect(removeResult.success, isTrue);
      expect(removeResult.registry.contains('test_plugin'), isFalse);
    });

    // ─────────────────────────────────────────────────────────────────
    // Query operations
    // ─────────────────────────────────────────────────────────────────

    test('getAll returns all plugins', () {
      final result = service.installBuiltInPlugins(empty);
      final plugins = service.getAll(result.registry);

      expect(plugins, isNotEmpty);
    });

    test('getById finds a plugin', () {
      final result = service.installBuiltInPlugins(empty);
      final plugin = service.getById(result.registry, 'software_engineer');

      expect(plugin, isNotNull);
      expect(plugin?.manifest.name, 'Software Engineer');
    });

    test('getById returns null for missing plugin', () {
      expect(service.getById(empty, 'nonexistent'), isNull);
    });

    test('getActive returns only active plugins', () {
      // Install but don't activate
      final result = service.installBuiltInPlugins(empty);
      final active = service.getActive(result.registry);

      expect(active, isEmpty);
    });

    test('getUsable returns loaded and active plugins', () {
      final result = service.installAndActivateBuiltIns(empty);
      final usable = service.getUsable(result.registry);

      expect(usable, isNotEmpty);
      expect(usable.every((p) => p.isUsable), isTrue);
    });
  });
}
