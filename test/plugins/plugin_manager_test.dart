import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/plugins/models/plugin_manifest.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin_manager.dart';
import 'package:phoenix_platform/core/plugins/runtime/plugin_registry.dart';

void main() {
  group('PluginManager', () {
    const manager = PluginManager();
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

    /// Helper to install and validate a plugin for use in lifecycle tests.
    PluginManagerResult installAndValidate(PluginRegistry registry) {
      var result = manager.install(
        registry: registry,
        manifest: validManifest,
        plugin: testPlugin,
      );
      expect(result.success, isTrue);

      result = manager.validate(
        registry: result.registry,
        pluginId: 'test_plugin',
      );
      expect(result.success, isTrue);

      return result;
    }

    // ─────────────────────────────────────────────────────────────────
    // installBuiltInPlugins
    // ─────────────────────────────────────────────────────────────────

    test('installBuiltInPlugins adds Software Engineer plugin', () {
      final result = manager.installBuiltInPlugins(empty);
      expect(result.success, isTrue);
      expect(result.registry.contains('software_engineer'), isTrue);
      expect(result.plugin, isNotNull);
    });

    test('installBuiltInPlugins returns registry with plugins', () {
      final result = manager.installBuiltInPlugins(empty);
      expect(result.registry.count, greaterThanOrEqualTo(1));
    });

    // ─────────────────────────────────────────────────────────────────
    // install
    // ─────────────────────────────────────────────────────────────────

    test('install adds a plugin to the registry', () {
      final result = manager.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      expect(result.success, isTrue);
      expect(result.registry.count, 1);
      expect(result.plugin?.state, PluginLifecycleState.installed);
    });

    test('install fails for duplicate plugin', () {
      final result1 = manager.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      final result2 = manager.install(
        registry: result1.registry,
        manifest: validManifest,
        plugin: testPlugin,
      );

      expect(result2.success, isFalse);
      expect(result2.error, contains('already installed'));
    });

    // ─────────────────────────────────────────────────────────────────
    // validate
    // ─────────────────────────────────────────────────────────────────

    test('validate succeeds for valid plugin', () {
      final installResult = manager.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      final result = manager.validate(
        registry: installResult.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.validated);
    });

    test('validate fails if plugin not found', () {
      final result = manager.validate(registry: empty, pluginId: 'nonexistent');

      expect(result.success, isFalse);
      expect(result.error, contains('not found'));
    });

    test('validate fails if plugin is not in installed state', () {
      final installResult = manager.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      // Validate once to move to validated state
      final validateResult = manager.validate(
        registry: installResult.registry,
        pluginId: 'test_plugin',
      );

      // Try validating again
      final secondResult = manager.validate(
        registry: validateResult.registry,
        pluginId: 'test_plugin',
      );

      expect(secondResult.success, isFalse);
      expect(secondResult.error, contains('Expected state'));
    });

    // ─────────────────────────────────────────────────────────────────
    // register
    // ─────────────────────────────────────────────────────────────────

    test('register transitions to registered state', () {
      final validated = installAndValidate(empty);

      final result = manager.register(
        registry: validated.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.registered);
    });

    test('register fails if plugin not validated', () {
      final installResult = manager.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      final result = manager.register(
        registry: installResult.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Expected state'));
    });

    // ─────────────────────────────────────────────────────────────────
    // load
    // ─────────────────────────────────────────────────────────────────

    test('load transitions to loaded state', () {
      var current = installAndValidate(empty);
      current = manager.register(
        registry: current.registry,
        pluginId: 'test_plugin',
      );

      final result = manager.load(
        registry: current.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.loaded);
    });

    test('load fails if plugin not registered', () {
      final validated = installAndValidate(empty);

      final result = manager.load(
        registry: validated.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Expected state'));
    });

    // ─────────────────────────────────────────────────────────────────
    // activate
    // ─────────────────────────────────────────────────────────────────

    test('activate transitions to active state', () {
      var current = installAndValidate(empty);
      current = manager.register(
        registry: current.registry,
        pluginId: 'test_plugin',
      );
      current = manager.load(
        registry: current.registry,
        pluginId: 'test_plugin',
      );

      final result = manager.activate(
        registry: current.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.active);
    });

    test('activate fails if plugin not loaded', () {
      final validated = installAndValidate(empty);

      final result = manager.activate(
        registry: validated.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Expected state'));
    });

    // ─────────────────────────────────────────────────────────────────
    // deactivate
    // ─────────────────────────────────────────────────────────────────

    test('deactivate transitions to deactivated state', () {
      // Run full lifecycle to active
      var current = installAndValidate(empty);
      current = manager.register(
        registry: current.registry,
        pluginId: 'test_plugin',
      );
      current = manager.load(
        registry: current.registry,
        pluginId: 'test_plugin',
      );
      current = manager.activate(
        registry: current.registry,
        pluginId: 'test_plugin',
      );

      final result = manager.deactivate(
        registry: current.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.deactivated);
    });

    test('deactivate fails if plugin not active or loaded', () {
      final validated = installAndValidate(empty);

      final result = manager.deactivate(
        registry: validated.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Expected state'));
    });

    // ─────────────────────────────────────────────────────────────────
    // remove
    // ─────────────────────────────────────────────────────────────────

    test('remove transitions to removed state and removes from registry', () {
      final installed = manager.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      final result = manager.remove(
        registry: installed.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.removed);
      expect(result.registry.contains('test_plugin'), isFalse);
    });

    test('remove fails if plugin not found', () {
      final result = manager.remove(registry: empty, pluginId: 'nonexistent');

      expect(result.success, isFalse);
      expect(result.error, contains('not found'));
    });

    // ─────────────────────────────────────────────────────────────────
    // fullLifecycle
    // ─────────────────────────────────────────────────────────────────

    test('fullLifecycle runs complete lifecycle successfully', () {
      final installed = manager.install(
        registry: empty,
        manifest: validManifest,
        plugin: testPlugin,
      );

      final result = manager.fullLifecycle(
        registry: installed.registry,
        pluginId: 'test_plugin',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.active);
    });

    test('fullLifecycle fails for missing plugin', () {
      final result = manager.fullLifecycle(
        registry: empty,
        pluginId: 'nonexistent',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('not found'));
    });

    // ─────────────────────────────────────────────────────────────────
    // fullLifecycle with built-in plugins
    // ─────────────────────────────────────────────────────────────────

    test('fullLifecycle activates Software Engineer plugin', () {
      final installResult = manager.installBuiltInPlugins(empty);

      final result = manager.fullLifecycle(
        registry: installResult.registry,
        pluginId: 'software_engineer',
      );

      expect(result.success, isTrue);
      expect(result.plugin?.state, PluginLifecycleState.active);
      expect(result.plugin?.manifest.id, 'software_engineer');
    });

    // ─────────────────────────────────────────────────────────────────
    // PluginManagerResult
    // ─────────────────────────────────────────────────────────────────

    test('PluginManagerResult has allErrors that combines errors', () {
      const result = PluginManagerResult(
        registry: PluginRegistry(),
        success: false,
        error: 'General error',
        validationErrors: ['Validation error 1'],
      );

      expect(result.allErrors.length, 2);
      expect(result.allErrors[0], 'General error');
      expect(result.allErrors[1], 'Validation error 1');
    });

    test('PluginManagerResult equality works', () {
      const result1 = PluginManagerResult(
        registry: PluginRegistry(),
        success: true,
      );
      const result2 = PluginManagerResult(
        registry: PluginRegistry(),
        success: true,
      );

      expect(result1, result2);

      const result3 = PluginManagerResult(
        registry: PluginRegistry(),
        success: false,
      );
      expect(result1, isNot(result3));
    });
  });
}
