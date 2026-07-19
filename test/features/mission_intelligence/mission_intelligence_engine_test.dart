import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_metrics.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_trend.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_dimension.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/models/identity_profile.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_state.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_difficulty.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_priority.dart';
import 'package:phoenix_platform/features/mission_intelligence/engine/mission_intelligence_engine.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_evaluation.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_history.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_impact.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_recommendation.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_score.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/repository/mission_intelligence_repository_interface.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';

/// Minimal stub that provides a fixed UserState.
class _StubUserStateService extends UserStateService {
  _StubUserStateService()
      : super(
          engine: _StubUserStateEngine(),
        );

  @override
  UserState get currentState => UserState(level: 1, totalXp: 0);
}

class _StubUserStateEngine extends UserStateEngine {
  _StubUserStateEngine() : super(repository: _StubRepo());
}

class _StubRepo extends UserStateRepository {
  @override
  Future<void> saveState(UserState state) async {}
}

// ── Mock Repository ─────────────────────────────────────────────────────────

class _MockMissionRepo implements MissionIntelligenceRepositoryInterface {
  MissionSnapshot? _cached;

  @override
  Future<MissionSnapshot?> loadCachedSnapshot() async => _cached;

  @override
  Future<void> cacheSnapshot(MissionSnapshot snapshot) async {
    _cached = snapshot;
  }

  @override
  Future<MissionHistory> loadHistory() async =>
      const MissionHistory();

  @override
  Future<void> saveHistory(MissionHistory history) async {}

  @override
  Future<void> clear() async {
    _cached = null;
  }
}

/// Public accessor for test assertions on private _cached field.
extension _MissionRepoAccess on _MockMissionRepo {
  MissionSnapshot? get cached => _cached;
}

// ── Mock Identity Engine ────────────────────────────────────────────────────

class _MockIdentityEngine extends ChangeNotifier
    implements IdentityEngine {
  _MockIdentityEngine({this.snapshotOverride});

  IdentitySnapshot? snapshotOverride;

  @override
  IdentitySnapshot? get snapshot => snapshotOverride;

  @override
  IdentityState get identityState => snapshotOverride != null
      ? IdentityState.ready
      : IdentityState.uninitialized;

  @override
  bool get isInitialized => snapshotOverride != null;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

// ── Mock Growth Engine ──────────────────────────────────────────────────────

class _MockGrowthEngine extends ChangeNotifier
    implements GrowthIndexEngine {
  _MockGrowthEngine({this.snapshotOverride});

  GrowthSnapshot? snapshotOverride;

  @override
  GrowthSnapshot? get snapshot => snapshotOverride;

  @override
  bool get isInitialized => snapshotOverride != null;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

// ── Test Data Builders ──────────────────────────────────────────────────────

IdentitySnapshot _identitySnapshot() => IdentitySnapshot(
      profile: const IdentityProfile(
        id: 'test',
        title: 'Flutter Developer',
        description: 'A Flutter developer',
        iconName: 'code',
        category: 'Tech',
        currentLevel: 3,
        targetLevel: 7,
        careerGoal: 'Build a portfolio project',
        experienceLevel: 'intermediate',
      ),
      currentIdentityTitle: 'Flutter Developer',
      targetIdentityTitle: 'Senior Developer',
      currentGoal: 'Build a portfolio project',
      experience: 'Intermediate',
      progress: 'Level 3 of 7',
      currentMissionTitle: 'Build Portfolio App',
      currentLearningPathTitle: '',
      currentCareerPathTitle: 'Senior Developer',
      growthIndex: 0.5,
      completionPercent: 40,
      lastUpdated: DateTime.now(),
      missionCount: 10,
      completedMissions: 5,
      lessonCount: 20,
      completedLessons: 12,
      totalXp: 1500,
      level: 3,
      activeHabitCount: 2,
      knowledgeNodeCount: 15,
      hasActiveMission: true,
      hasActiveLearning: true,
    );

GrowthSnapshot _lowGrowth() => GrowthSnapshot(
      overallScore: 0.25,
      knowledge:
          _metric(GrowthDimension.knowledge, 0.2, GrowthTrend.stable),
      skills:
          _metric(GrowthDimension.skills, 0.3, GrowthTrend.stable),
      projects:
          _metric(GrowthDimension.projects, 0.15, GrowthTrend.stable),
      career:
          _metric(GrowthDimension.career, 0.1, GrowthTrend.declining),
      habits:
          _metric(GrowthDimension.habits, 0.3, GrowthTrend.stable),
      interview: _metric(
          GrowthDimension.interview, 0.15, GrowthTrend.stable),
      mission:
          _metric(GrowthDimension.mission, 0.4, GrowthTrend.stable),
      portfolio: _metric(
          GrowthDimension.portfolio, 0.05, GrowthTrend.declining),
      learningConsistency: _metric(GrowthDimension.learningConsistency,
          0.25, GrowthTrend.declining),
      currentLevel: 1,
      totalXp: 200,
      lastUpdated: DateTime.now(),
    );

GrowthSnapshot _highGrowth() => GrowthSnapshot(
      overallScore: 0.75,
      knowledge: _metric(
          GrowthDimension.knowledge, 0.7, GrowthTrend.improving),
      skills:
          _metric(GrowthDimension.skills, 0.75, GrowthTrend.improving),
      projects:
          _metric(GrowthDimension.projects, 0.6, GrowthTrend.stable),
      career:
          _metric(GrowthDimension.career, 0.65, GrowthTrend.improving),
      habits:
          _metric(GrowthDimension.habits, 0.7, GrowthTrend.stable),
      interview:
          _metric(GrowthDimension.interview, 0.6, GrowthTrend.stable),
      mission:
          _metric(GrowthDimension.mission, 0.8, GrowthTrend.improving),
      portfolio:
          _metric(GrowthDimension.portfolio, 0.5, GrowthTrend.stable),
      learningConsistency: _metric(GrowthDimension.learningConsistency,
          0.7, GrowthTrend.improving),
      currentLevel: 5,
      totalXp: 3500,
      lastUpdated: DateTime.now(),
    );

GrowthMetrics _metric(
        GrowthDimension dim, double score, GrowthTrend trend) =>
    GrowthMetrics(
        dimension: dim, score: score, trend: trend, label: dim.displayName);

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late _MockMissionRepo repository;
  late MissionIntelligenceEngine engine;

  group('MissionIntelligenceEngine', () {
    group('initialization', () {
      test('init with engines ready builds fresh snapshot', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _highGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        expect(engine.isInitialized, isTrue);
        expect(engine.snapshot, isNotNull);
        expect(engine.snapshot!.lastEvaluation, isNotNull);
      });

      test('init caches snapshot after evaluation', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _highGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        expect(repository.cached, isNotNull);
      });

      test('empty snapshot when engines not ready', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine:
              _MockIdentityEngine(snapshotOverride: null),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: null),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        expect(engine.snapshot, isNotNull);
        expect(engine.snapshot!.hasAnyRecommendation, isFalse);
        expect(engine.snapshot!.reason, contains('not yet initialized'));
      });

      test('reset clears all cached data', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _highGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();
        expect(engine.isInitialized, isTrue);

        await engine.reset();
        expect(engine.isInitialized, isFalse);
        expect(engine.snapshot, isNull);
      });
    });

    group('rule evaluation', () {
      test('low scores trigger multiple recommendations', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _lowGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        final snap = engine.snapshot!;
        expect(snap.hasActiveRecommendation, isTrue);
        expect(snap.currentMission, isNotNull);
        expect(snap.currentMission!.reason, isNotEmpty);
        expect(snap.alternatives.length, greaterThanOrEqualTo(1));
      });

      test('high scores produce no active recommendation', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _highGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        expect(engine.snapshot!.currentMission, isNull);
      });

      test('top mission ranked by weighted score', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _lowGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        final snap = engine.snapshot!;
        expect(snap.currentMission, isNotNull);
        final topScore = snap.currentMission!.score.weightedScore;
        for (final alt in snap.alternatives) {
          expect(topScore, greaterThanOrEqualTo(alt.score.weightedScore));
        }
      });

      test('evaluation includes rule counts', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _lowGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        expect(engine.snapshot!.evaluation, isNotNull);
        expect(engine.snapshot!.evaluation!.totalRules, equals(5));
        expect(engine.snapshot!.evaluation!.evaluationTime, isNotNull);
      });

      test('rejected rules listed with reasons', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _highGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        final snap = engine.snapshot!;
        expect(snap.rejectedRules.length, greaterThanOrEqualTo(3));
        for (final reason in snap.rejectedRules) {
          expect(reason, contains('Conditions not met'));
        }
      });
    });

    group('mission lifecycle', () {
      test('acceptMission records acceptance', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _lowGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        await engine.acceptMission('rec-1', 'mission-1', 'Test Mission');

        expect(engine.history.totalAccepted, equals(1));
        final entry = engine.history.entries.first;
        expect(entry.missionId, equals('mission-1'));
        expect(entry.isAccepted, isTrue);
      });

      test('completeMission records completion with XP', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _lowGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        await engine.acceptMission('rec-1', 'm1', 'Mission 1');
        await engine.completeMission('rec-1', 50, 30);

        expect(engine.history.totalCompleted, equals(1));
        expect(engine.history.totalAccepted, equals(1));
        expect(engine.history.completionRate, equals(1.0));
        expect(engine.history.averageCompletionTimeMinutes, equals(30.0));
      });

      test('rejectMission records rejection', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _lowGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        await engine.acceptMission('rec-1', 'm1', 'Mission 1');
        await engine.rejectMission('rec-1');

        expect(engine.history.totalRejected, equals(1));
        expect(engine.history.totalAccepted, equals(0));
      });

      test('re-evaluates after rejectMission', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _lowGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        expect(engine.snapshot!.hasActiveRecommendation, isTrue);
        await engine.rejectMission(
            engine.snapshot!.currentMission!.id);
        expect(engine.snapshot!.hasActiveRecommendation, isTrue);
      });
    });

    group('history tracking', () {
      test('acceptance and completion rates computed', () async {
        repository = _MockMissionRepo();
        engine = MissionIntelligenceEngine(
          repository: repository,
          identityEngine: _MockIdentityEngine(
              snapshotOverride: _identitySnapshot()),
          growthEngine:
              _MockGrowthEngine(snapshotOverride: _lowGrowth()),
          userStateService: _StubUserStateService(),
        );
        await engine.init();

        await engine.acceptMission('rec-1', 'm1', 'Mission 1');
        await engine.acceptMission('rec-2', 'm2', 'Mission 2');
        await engine.acceptMission('rec-3', 'm3', 'Mission 3');
        await engine.completeMission('rec-1', 50, 30);
        await engine.completeMission('rec-2', 75, 45);

        expect(engine.history.totalAccepted, equals(3));
        expect(engine.history.totalCompleted, equals(2));
        expect(engine.history.acceptanceRate, equals(1.0));
        expect(engine.history.completionRate, equals(2.0 / 3.0));
        expect(engine.history.averageCompletionTimeMinutes, equals(37.5));
      });
    });

    group('recommendation models', () {
      test('MissionScore weightedScore computed correctly', () {
        final score = MissionScore(
          score: 0.8, weight: 3, confidence: 0.9,
        );
        expect(score.weightedScore, closeTo(0.8 * 3 * 0.9, 0.001));
      });

      test('toMission preserves recommendation fields', () {
        final rec = MissionRecommendation(
          id: 'test-rec',
          title: 'Test Mission',
          description: 'A test mission description',
          category: MissionCategory.learning,
          priority: MissionPriority.high,
          difficulty: MissionDifficulty.beginner,
          estimatedDuration: 30,
          rewardXP: 50,
          reason: 'Test reason',
          score: MissionScore(score: 0.8, weight: 3, confidence: 0.9),
          impact: const MissionImpact(knowledgeGain: 0.4),
        );
        final mission = rec.toMission();

        expect(mission.id, equals('test-rec'));
        expect(mission.title, equals('Test Mission'));
        expect(mission.category, equals(MissionCategory.learning));
        expect(mission.sourceService, equals('mission_intelligence'));
        expect(mission.recommendationReason, equals('Test reason'));
      });

      test('MissionEvaluation hasRecommendations', () {
        final rec = MissionRecommendation(
          id: 'test',
          title: 'Test',
          description: 'desc',
          category: MissionCategory.learning,
          priority: MissionPriority.high,
          difficulty: MissionDifficulty.beginner,
          estimatedDuration: 0,
          rewardXP: 0,
          reason: 'reason',
          score: MissionScore(score: 0.5, weight: 1, confidence: 0.5),
          impact: const MissionImpact(),
        );
        final eval = MissionEvaluation(
          topMission: rec,
          evaluationTime: DateTime.now(),
          ruleCount: 1,
          totalRules: 5,
        );
        expect(eval.hasRecommendations, isTrue);
        expect(eval.hasData, isTrue);
      });
    });
  });
}
