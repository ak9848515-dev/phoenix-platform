import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/plugins/models/plugin_manifest.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin_registry.dart';

void main() {
  group('PluginRegistry', () {
    const manifestA = PluginManifest(
      id: 'plugin_a',
      name: 'Plugin A',
      version: '1.0.0',
      description: 'First test plugin.',
      minPhoenixVersion: '1.0.0',
      pluginApiVersion: '1.0.0',
      requiredCapabilities: ['identity'],
    );

    const manifestB = PluginManifest(
      id: 'plugin_b',
      name: 'Plugin B',
      version: '1.0.0',
      description: 'Second test plugin.',
      minPhoenixVersion: '1.0.0',
      pluginApiVersion: '1.0.0',
      requiredCapabilities: ['journey'],
    );

    const manifestC = PluginManifest(
      id: 'plugin_c',
      name: 'Plugin C',
      version: '1.0.0',
      description: 'Third test plugin.',
      minPhoenixVersion: '1.0.0',
      pluginApiVersion: '1.0.0',
      requiredCapabilities: ['missions'],
    );

    const pluginA = Plugin(manifest: manifestA);
    const pluginB = Plugin(manifest: manifestB);

    final activePluginA = Plugin(
      manifest: manifestA,
      state: PluginLifecycleState.active,
    );

    final activePluginC = Plugin(
      manifest: manifestC,
      state: PluginLifecycleState.active,
    );

    final loadedPlugin = Plugin(
      manifest: manifestB,
      state: PluginLifecycleState.loaded,
    );

    const empty = PluginRegistry();

    test('starts empty', () {
      expect(empty.count, 0);
      expect(empty.all, isEmpty);
    });

    test('adds a plugin', () {
      final registry = empty.add(pluginA);

      expect(registry.count, 1);
      expect(registry.contains('plugin_a'), isTrue);
      expect(registry.contains('plugin_b'), isFalse);
    });

    test('add returns new instance without modifying original', () {
      final updated = empty.add(pluginA);
      expect(updated.count, 1);
      expect(empty.count, 0);
    });

    test('replaces existing plugin with same id on add', () {
      final withA = empty.add(pluginA);
      final replaced = withA.add(activePluginA);

      expect(replaced.count, 1);
      expect(replaced.getById('plugin_a')?.state, PluginLifecycleState.active);
    });

    test('adds multiple plugins', () {
      final registry = empty.add(pluginA).add(pluginB);
      expect(registry.count, 2);
      expect(registry.contains('plugin_a'), isTrue);
      expect(registry.contains('plugin_b'), isTrue);
    });

    test('removes a plugin', () {
      final registry = empty.add(pluginA).add(pluginB);
      final removed = registry.remove('plugin_a');

      expect(removed.count, 1);
      expect(removed.contains('plugin_a'), isFalse);
      expect(removed.contains('plugin_b'), isTrue);
    });

    test('remove returns same instance if plugin not found', () {
      final result = empty.remove('nonexistent');
      expect(identical(result, empty), isTrue);
    });

    test('clears all plugins', () {
      final registry = empty.add(pluginA).add(pluginB);
      final cleared = registry.clear();

      expect(cleared.count, 0);
      expect(cleared.all, isEmpty);
    });

    test('getById returns correct plugin', () {
      final registry = empty.add(pluginA).add(pluginB);
      final found = registry.getById('plugin_a');

      expect(found, isNotNull);
      expect(found?.manifest.id, 'plugin_a');
    });

    test('getById returns null for missing plugin', () {
      expect(empty.getById('nonexistent'), isNull);
    });

    test('all returns unmodifiable list', () {
      final registry = empty.add(pluginA);
      expect(() => registry.all.clear(), throwsUnsupportedError);
    });

    test('getByState returns plugins in given state', () {
      final registry = empty.add(pluginA).add(activePluginC);
      final installed = registry.getByState(PluginLifecycleState.installed);

      expect(installed.length, 1);
      expect(installed.first.manifest.id, 'plugin_a');

      final active = registry.getByState(PluginLifecycleState.active);
      expect(active.length, 1);
      expect(active.first.manifest.id, 'plugin_c');
    });

    test('active returns only active plugins', () {
      final registry = empty.add(pluginA).add(activePluginC);
      expect(registry.active.length, 1);
      expect(registry.active.first.manifest.id, 'plugin_c');
    });

    test('usable returns loaded and active plugins', () {
      final registry = empty.add(pluginA).add(activePluginC).add(loadedPlugin);

      expect(registry.usable.length, 2);
      expect(registry.usable.every((p) => p.isUsable), isTrue);
    });

    test('equality works', () {
      final reg1 = empty.add(pluginA);
      final reg2 = empty.add(pluginA);
      final reg3 = empty.add(pluginB);

      expect(reg1, reg2);
      expect(reg1, isNot(reg3));
    });

    test('toString returns readable representation', () {
      final registry = empty.add(pluginA);
      expect(registry.toString(), contains('count: 1'));
    });
  });
}
