import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/identity/models/identity.dart';
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';
import 'package:phoenix_platform/models/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late UserStateRepository repository;
  late UserStateEngine engine;
  late UserStateService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = UserStateRepository();
    engine = UserStateEngine(repository: repository);
    service = UserStateService(engine: engine);
  });

  // ═════════════════════════════════════════════════════════════════
  // UserState Model
  // ═════════════════════════════════════════════════════════════════

  group('UserState model', () {
    test('creates default state with sensible defaults', () {
      const state = UserState();
      expect(state.version, 1);
      expect(state.missions, isEmpty);
      expect(state.opportunities, isEmpty);
      expect(state.achievements, isEmpty);
      expect(state.totalXp, 0);
      expect(state.level, 1);
      expect(state.onboardingComplete, false);
      expect(state.hasIdentity, false);
    });

    test('copyWith replaces specified fields', () {
      const state = UserState(totalXp: 100, level: 2);
      final updated = state.copyWith(totalXp: 200);
      expect(updated.totalXp, 200);
      expect(updated.level, 2); // unchanged
    });

    test('copyWith clearFlags set fields to null', () {
      final identity = Identity(
        id: 'test', title: 'Developer', description: 'desc',
        iconName: 'code', category: 'Tech', currentLevel: 1,
        targetLevel: 5, estimatedDuration: 100,
        requiredSkills: [], roadmap: [], status: IdentityStatus.active,
      );
      final state = UserState(identity: identity);
      expect(state.hasIdentity, true);

      final cleared = state.copyWith(clearIdentity: true);
      expect(cleared.hasIdentity, false);
      expect(cleared.identity, isNull);
    });

    test('toMap and fromMap round-trip correctly', () {
      const original = UserState(totalXp: 500, level: 5);
      final map = original.toMap();
      final restored = UserState.fromMap(map);
      expect(restored.totalXp, 500);
      expect(restored.level, 5);
      expect(restored.version, original.version);
    });

    test('toJson and fromJson round-trip correctly', () {
      const original = UserState(totalXp: 1000, level: 10);
      final json = original.toJson();
      final restored = UserState.fromJson(json);
      expect(restored.totalXp, 1000);
      expect(restored.level, 10);
    });

    test('settings defaults to UserSettings()', () {
      const state = UserState();
      expect(state.settings.themeMode, 'system');
      expect(state.settings.notificationsEnabled, true);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // UserStateRepository
  // ═════════════════════════════════════════════════════════════════

  group('UserStateRepository', () {
    test('loadState returns null when no state saved', () async {
      final state = await repository.loadState();
      expect(state, isNull);
    });

    test('saveState and loadState round-trip', () async {
      const state = UserState(totalXp: 300, level: 3);
      await repository.saveState(state);
      final loaded = await repository.loadState();
      expect(loaded, isNotNull);
      expect(loaded!.totalXp, 300);
      expect(loaded.level, 3);
    });

    test('hasState returns false initially', () async {
      expect(await repository.hasState(), isFalse);
    });

    test('hasState returns true after save', () async {
      await repository.saveState(const UserState());
      expect(await repository.hasState(), isTrue);
    });

    test('clearState removes persisted data', () async {
      await repository.saveState(const UserState(totalXp: 100));
      await repository.clearState();
      expect(await repository.hasState(), isFalse);
    });

    test('cacheState and loadCachedState round-trip', () async {
      await repository.cacheState(const UserState(totalXp: 50));
      final cached = await repository.loadCachedState();
      expect(cached, isNotNull);
      expect(cached!.totalXp, 50);
    });

    test('stateSizeBytes returns approximate size', () async {
      await repository.saveState(const UserState());
      final size = await repository.stateSizeBytes();
      expect(size, greaterThan(0));
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // UserStateEngine
  // ═════════════════════════════════════════════════════════════════

  group('UserStateEngine', () {
    test('currentState returns default when not loaded', () {
      expect(engine.isLoaded, isFalse);
      expect(engine.currentState.totalXp, 0);
    });

    test('load returns default state when no persisted data', () async {
      final state = await engine.load();
      expect(engine.isLoaded, isTrue);
      expect(state.totalXp, 0);
    });

    test('load returns persisted state', () async {
      await repository.saveState(const UserState(totalXp: 500));
      final state = await engine.load();
      expect(state.totalXp, 500);
    });

    test('replace overwrites current state', () async {
      const newState = UserState(totalXp: 999, level: 10);
      await engine.replace(newState);
      expect(engine.currentState.totalXp, 999);
      expect(engine.currentState.level, 10);
    });

    test('update merges changes via callback', () async {
      await engine.update((s) => s.copyWith(totalXp: 250));
      expect(engine.currentState.totalXp, 250);

      await engine.update((s) => s.copyWith(totalXp: s.totalXp + 100));
      expect(engine.currentState.totalXp, 350);
    });

    test('clear resets state', () async {
      await engine.replace(const UserState(totalXp: 500));
      await engine.clear();
      expect(engine.isLoaded, isFalse);
    });

    test('notifies listeners on state change', () async {
      var notified = false;
      engine.addListener(() => notified = true);

      await engine.replace(const UserState(totalXp: 100));
      expect(notified, isTrue);
    });

    test('listener dispose removes listener', () async {
      var callCount = 0;
      final dispose = engine.addListener(() => callCount++);

      await engine.replace(const UserState(totalXp: 1));
      expect(callCount, 1);

      dispose();
      await engine.replace(const UserState(totalXp: 2));
      expect(callCount, 1); // not called again
    });

    test('validate returns no issues for valid state', () {
      expect(engine.validate(), isEmpty);
    });

    test('validate reports negative XP', () async {
      await engine.replace(const UserState(totalXp: -1));
      final issues = engine.validate();
      expect(issues, isNotEmpty);
      expect(issues.first, contains('totalXp'));
    });

    test('diagnostics returns correct info', () async {
      await engine.replace(const UserState(totalXp: 750, level: 8));
      final diag = engine.diagnostics();
      expect(diag['loaded'], isTrue);
      expect(diag['totalXp'], 750);
      expect(diag['level'], 8);
    });

    test('persists state after update', () async {
      await engine.update((s) => s.copyWith(totalXp: 400));
      final loaded = await repository.loadState();
      expect(loaded!.totalXp, 400);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // UserStateService
  // ═════════════════════════════════════════════════════════════════

  group('UserStateService', () {
    test('init loads state and marks as loaded', () async {
      await service.init();
      expect(service.isLoaded, isTrue);
    });

    test('read convenience getters work', () async {
      await service.init();
      expect(service.totalXp, 0);
      expect(service.level, 1);
      expect(service.identity, isNull);
    });

    test('setIdentity updates state', () async {
      await service.init();
      final identity = Identity(
        id: 'test', title: 'Flutter Dev', description: 'desc',
        iconName: 'flutter_dash', category: 'Tech', currentLevel: 1,
        targetLevel: 5, estimatedDuration: 100,
        requiredSkills: [], roadmap: [], status: IdentityStatus.active,
      );
      await service.setIdentity(identity);
      expect(service.identity?.title, 'Flutter Dev');
      expect(service.hasIdentity, isTrue);
    });

    test('setSettings updates settings', () async {
      await service.init();
      final settings = const UserSettings(themeMode: 'dark');
      await service.setSettings(settings);
      expect(service.settings.themeMode, 'dark');
    });

    test('addXp increases total XP and recalculates level', () async {
      await service.init();
      await service.addXp(250);
      expect(service.totalXp, 250);
      expect(service.level, 2); // LevelCalculator: 1 + (250 ~/ 250) = 2
    });

    test('touch records lastActivityAt', () async {
      await service.init();
      await service.touch();
      expect(service.currentState.lastActivityAt, isNotNull);
    });

    test('update with custom callback works', () async {
      await service.init();
      await service.update((s) => s.copyWith(
        currentFocus: 'Build Portfolio',
      ));
      expect(service.currentState.currentFocus, 'Build Portfolio');
    });

    test('addListener and removeListener work', () async {
      await service.init();
      var notified = false;
      final dispose = service.addListener(() => notified = true);

      await service.setSettings(const UserSettings(themeMode: 'dark'));
      expect(notified, isTrue);

      notified = false;
      dispose();
      await service.setSettings(const UserSettings(themeMode: 'light'));
      expect(notified, isFalse);
    });

    test('replace overwrites entire state', () async {
      await service.init();
      const newState = UserState(totalXp: 5000, level: 50);
      await service.replace(newState);
      expect(service.totalXp, 5000);
      expect(service.level, 50);
    });

    test('clear removes all state', () async {
      await service.init();
      await service.setIdentity(Identity(
        id: 'test', title: 'T', description: 'd',
        iconName: 'star', category: 'C', currentLevel: 1,
        targetLevel: 5, estimatedDuration: 10,
        requiredSkills: [], roadmap: [], status: IdentityStatus.active,
      ));
      await service.clear();
      expect(service.isLoaded, isFalse);
    });

    test('diagnostics returns service state info', () async {
      await service.init();
      final diag = service.diagnostics();
      expect(diag['loaded'], isTrue);
      expect(diag['version'], 1);
    });

    test('validate returns empty for clean state', () async {
      await service.init();
      expect(service.validate(), isEmpty);
    });

    test('persists state across operations', () async {
      await service.init();
      await service.addXp(750);
      await service.setSettings(const UserSettings(
        themeMode: 'dark',
        notificationsEnabled: false,
      ));

      final loaded = await repository.loadState();
      expect(loaded, isNotNull);
      expect(loaded!.totalXp, 750);
      expect(loaded.settings.themeMode, 'dark');
    });
  });
}
