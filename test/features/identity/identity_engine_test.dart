import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/models/identity_events.dart';
import 'package:phoenix_platform/features/identity/models/identity_profile.dart';

import 'mocks/mock_identity_repository.dart';
import 'mocks/mock_services.dart';

void main() {
  late MockIdentityRepository repository;
  late MockUserStateProvider userStateProvider;

  setUp(() {
    repository = MockIdentityRepository();
    userStateProvider = MockUserStateProvider();
  });

  /// Creates an IdentityEngine wired to mock repository and provider.
  IdentityEngine createEngine() {
    return IdentityEngine(
      repository: repository,
      userStateService: userStateProvider.userStateService,
    );
  }

  group('IdentityEngine', () {
    test('init loads from cache when available', () async {
      final engine = createEngine();
      await engine.init();

      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot, isNotNull);
      expect(engine.snapshot!.currentIdentityTitle, 'Software Engineer');
    });

    test('init creates default snapshot on first launch', () async {
      repository.shouldReturnNull = true;
      final freshEngine = createEngine();
      await freshEngine.init();

      expect(freshEngine.isInitialized, isTrue);
      expect(freshEngine.snapshot, isNotNull);
    });

    test('refresh updates snapshot from service data', () async {
      final engine = createEngine();
      await engine.init();
      final beforeXp = engine.snapshot!.totalXp;

      userStateProvider.totalXp = 1500;
      await engine.refresh();

      expect(engine.snapshot!.totalXp, 1500);
      expect(engine.snapshot!.totalXp, isNot(beforeXp));
    });

    test('handleEvent triggers refresh for mission completed', () async {
      final engine = createEngine();
      await engine.init();
      final before = engine.snapshot!.completedMissions;

      userStateProvider.completedMissions = 3;
      userStateProvider.missionCount = 5;
      await engine.handleEvent(
        IdentityEventData.missionCompleted(missionId: 'mission-1', xpAwarded: 50),
      );

      expect(engine.snapshot!.completedMissions, 3);
      expect(engine.snapshot!.completedMissions, isNot(before));
    });

    test('handleEvent triggers refresh for XP gained', () async {
      final engine = createEngine();
      await engine.init();

      userStateProvider.totalXp = 2500;
      await engine.handleEvent(
        IdentityEventData.xpGained(amount: 100, source: 'lesson'),
      );

      expect(engine.snapshot!.totalXp, 2500);
    });

    test('updateProfile saves and refreshes', () async {
      final engine = createEngine();
      await engine.init();

      final profile = IdentityProfile(
        id: 'test-id',
        title: 'Test Identity',
        description: 'Test description',
        iconName: 'code_outlined',
        category: 'Technology',
        currentLevel: 3,
        targetLevel: 7,
        careerGoal: 'Become an expert',
        experienceLevel: 'intermediate',
      );

      await engine.updateProfile(profile);

      expect(engine.snapshot!.profile.title, 'Test Identity');
      expect(engine.snapshot!.profile.currentLevel, 3);
    });

    test('reset clears all data', () async {
      final engine = createEngine();
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot, isNotNull);

      await engine.reset();

      expect(engine.isInitialized, isFalse);
      expect(engine.snapshot, isNull);
    });

    test('notifies listeners on refresh', () async {
      final engine = createEngine();
      await engine.init();
      var notified = false;

      engine.addListener(() {
        notified = true;
      });

      await engine.refresh();

      expect(notified, isTrue);
    });

    test('notifies listeners on reset', () async {
      final engine = createEngine();
      await engine.init();
      var notified = false;

      engine.addListener(() {
        notified = true;
      });

      await engine.reset();

      expect(notified, isTrue);
    });

    test('profile from engine matches identity data', () async {
      final engine = createEngine();
      await engine.init();
      final profile = engine.snapshot!.profile;
      expect(profile.title, 'Software Engineer');
      expect(profile.currentLevel, greaterThan(0));
      expect(profile.targetLevel, greaterThan(0));
    });
  });
}
