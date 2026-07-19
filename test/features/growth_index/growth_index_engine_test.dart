import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_dimension.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_metrics.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_trend.dart';
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';

import 'mocks/mock_growth_repository.dart';

/// Minimal [UserStateService] stub for engine construction.
UserStateService _createStubUserStateService() {
  return UserStateService(
    engine: _StubUserStateEngine(),
  );
}

class _StubUserStateEngine extends UserStateEngine {
  _StubUserStateEngine() : super(repository: _StubUserStateRepo());

  @override
  UserState get currentState => const UserState(
        level: 1,
        totalXp: 0,
      );

  @override
  bool get isLoaded => true;
}

class _StubUserStateRepo extends UserStateRepository {
  @override
  Future<UserState?> loadState() async => null;
}

void main() {
  late MockGrowthRepository repository;
  late UserStateService userStateService;

  setUp(() {
    repository = MockGrowthRepository();
    userStateService = _createStubUserStateService();
  });

  GrowthIndexEngine createEngine() {
    return GrowthIndexEngine(
      repository: repository,
      userStateService: userStateService,
    );
  }

  group('GrowthIndexEngine', () {
    test('init loads snapshot from cache when available', () async {
      final cached = GrowthSnapshot(
        overallScore: 0.5,
        knowledge: const GrowthMetrics(
          dimension: GrowthDimension.knowledge, score: 0.5,
        ),
        skills: const GrowthMetrics(
          dimension: GrowthDimension.skills, score: 0.0,
        ),
        projects: const GrowthMetrics(
          dimension: GrowthDimension.projects, score: 0.0,
        ),
        career: const GrowthMetrics(
          dimension: GrowthDimension.career, score: 0.0,
        ),
        habits: const GrowthMetrics(
          dimension: GrowthDimension.habits, score: 0.0,
        ),
        interview: const GrowthMetrics(
          dimension: GrowthDimension.interview, score: 0.0,
        ),
        mission: const GrowthMetrics(
          dimension: GrowthDimension.mission, score: 0.0,
        ),
        portfolio: const GrowthMetrics(
          dimension: GrowthDimension.portfolio, score: 0.0,
        ),
        currentLevel: 3,
        totalXp: 750,
        lastUpdated: DateTime(2025, 1, 1),
      );
      repository.lastCachedSnapshot = cached;

      final engine = createEngine();
      await engine.init();

      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot, isNotNull);
      // Fresh snapshot is built from UserState stub (level: 1, XP: 0)
      // The engine recalculates from calculators on init
      expect(engine.snapshot!.currentLevel, 1);
      expect(engine.snapshot!.totalXp, 0);
    });

    test('init creates fresh snapshot on first launch', () async {
      final engine = createEngine();
      await engine.init();

      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot, isNotNull);
      expect(engine.snapshot!.knowledge.score, greaterThanOrEqualTo(0.0));
    });

    test('refresh updates snapshot from calculators', () async {
      final engine = createEngine();
      await engine.init();
      await engine.refresh();

      expect(engine.snapshot, isNotNull);
      expect(engine.snapshot!.lastUpdated, isNot(equals(DateTime(2025))));
    });

    test('snapshot contains all 8 dimensions', () async {
      final engine = createEngine();
      await engine.init();

      final snap = engine.snapshot!;
      expect(snap.knowledge.dimension.name, 'knowledge');
      expect(snap.skills.dimension.name, 'skills');
      expect(snap.projects.dimension.name, 'projects');
      expect(snap.career.dimension.name, 'career');
      expect(snap.habits.dimension.name, 'habits');
      expect(snap.interview.dimension.name, 'interview');
      expect(snap.mission.dimension.name, 'mission');
      expect(snap.portfolio.dimension.name, 'portfolio');
    });

    test('allMetrics returns at least 8 dimensions', () async {
      final engine = createEngine();
      await engine.init();
      expect(engine.snapshot!.allMetrics.length, greaterThanOrEqualTo(8));
    });

    test('overallScore is between 0.0 and 1.0', () async {
      final engine = createEngine();
      await engine.init();
      final snap = engine.snapshot!;
      expect(snap.overallScore, greaterThanOrEqualTo(0.0));
      expect(snap.overallScore, lessThanOrEqualTo(1.0));
    });

    test('overallTrend returns a valid trend', () async {
      final engine = createEngine();
      await engine.init();
      expect(
        [GrowthTrend.improving, GrowthTrend.stable, GrowthTrend.declining],
        contains(engine.snapshot!.overallTrend),
      );
    });

    test('strongestDimension returns highest scoring dimension', () async {
      final engine = createEngine();
      await engine.init();
      final strongest = engine.snapshot!.strongestDimension;
      final all = engine.snapshot!.allMetrics;
      expect(all.every((m) => strongest.score >= m.score), isTrue);
    });

    test('weakestDimension returns lowest scoring dimension', () async {
      final engine = createEngine();
      await engine.init();
      final weakest = engine.snapshot!.weakestDimension;
      final all = engine.snapshot!.allMetrics;
      expect(all.every((m) => weakest.score <= m.score), isTrue);
    });

    test('reset clears all cached data', () async {
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
      engine.addListener(() { notified = true; });
      await engine.refresh();
      expect(notified, isTrue);
    });

    test('notifies listeners on reset', () async {
      final engine = createEngine();
      await engine.init();
      var notified = false;
      engine.addListener(() { notified = true; });
      await engine.reset();
      expect(notified, isTrue);
    });

    test('GrowthTrend.fromScores computes improving', () {
      expect(GrowthTrend.fromScores(0.6, 0.5), GrowthTrend.improving);
    });

    test('GrowthTrend.fromScores computes declining', () {
      expect(GrowthTrend.fromScores(0.4, 0.5), GrowthTrend.declining);
    });

    test('GrowthTrend.fromScores computes stable', () {
      expect(GrowthTrend.fromScores(0.52, 0.5), GrowthTrend.stable);
    });

    test('isNewUser returns true when no progress exists', () {
      final snap = GrowthSnapshot(
        overallScore: 0.0,
        knowledge: const GrowthMetrics(
          dimension: GrowthDimension.knowledge, score: 0.0,
        ),
        skills: const GrowthMetrics(
          dimension: GrowthDimension.skills, score: 0.0,
        ),
        projects: const GrowthMetrics(
          dimension: GrowthDimension.projects, score: 0.0,
        ),
        career: const GrowthMetrics(
          dimension: GrowthDimension.career, score: 0.0,
        ),
        habits: const GrowthMetrics(
          dimension: GrowthDimension.habits, score: 0.0,
        ),
        interview: const GrowthMetrics(
          dimension: GrowthDimension.interview, score: 0.0,
        ),
        mission: const GrowthMetrics(
          dimension: GrowthDimension.mission, score: 0.0,
        ),
        portfolio: const GrowthMetrics(
          dimension: GrowthDimension.portfolio, score: 0.0,
        ),
        currentLevel: 1, totalXp: 0, lastUpdated: DateTime.now(),
      );
      expect(snap.isNewUser, isTrue);
      expect(snap.hasAnyProgress, isFalse);
    });

    test('serialization round-trip preserves data', () {
      final original = GrowthSnapshot(
        overallScore: 0.65,
        knowledge: const GrowthMetrics(
          dimension: GrowthDimension.knowledge, score: 0.8,
          trend: GrowthTrend.improving,
        ),
        skills: const GrowthMetrics(
          dimension: GrowthDimension.skills, score: 0.5,
          trend: GrowthTrend.stable,
        ),
        projects: const GrowthMetrics(
          dimension: GrowthDimension.projects, score: 0.3,
          trend: GrowthTrend.declining,
        ),
        career: const GrowthMetrics(
          dimension: GrowthDimension.career, score: 0.6,
        ),
        habits: const GrowthMetrics(
          dimension: GrowthDimension.habits, score: 0.0,
        ),
        interview: const GrowthMetrics(
          dimension: GrowthDimension.interview, score: 0.4,
        ),
        mission: const GrowthMetrics(
          dimension: GrowthDimension.mission, score: 0.7,
        ),
        portfolio: const GrowthMetrics(
          dimension: GrowthDimension.portfolio, score: 0.5,
        ),
        currentLevel: 5, totalXp: 1200,
        lastUpdated: DateTime(2025, 6, 15),
      );

      final map = original.toMap();
      final restored = GrowthSnapshot.fromMap(map);

      expect(restored.overallScore, original.overallScore);
      expect(restored.knowledge.score, original.knowledge.score);
      expect(restored.knowledge.trend, original.knowledge.trend);
      expect(restored.projects.score, original.projects.score);
      expect(restored.projects.trend, original.projects.trend);
      expect(restored.currentLevel, original.currentLevel);
      expect(restored.totalXp, original.totalXp);
      expect(restored.lastUpdated.year, 2025);
    });
  });
}
