import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/daily_brief/engine/daily_brief_engine.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_brief_snapshot.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_history.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_plan.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_priority.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_task.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_insight.dart';
import 'package:phoenix_platform/features/daily_brief/repository/daily_brief_repository_interface.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_metrics.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_trend.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_dimension.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/models/identity_profile.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_state.dart';
import 'package:phoenix_platform/features/mission_intelligence/engine/mission_intelligence_engine.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_impact.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_recommendation.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_score.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_difficulty.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_priority.dart';
import 'package:phoenix_platform/features/recommendation_engine/engine/recommendation_engine.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_category.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_reason.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_result.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_score.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_snapshot.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_urgency.dart';

// ── Mock Repository ─────────────────────────────────────────────────────────

class _MockRepo implements DailyBriefRepositoryInterface {
  DailyBriefSnapshot? _cached;
  bool shouldReturnNull = false;

  @override
  Future<DailyBriefSnapshot?> loadCachedSnapshot() async {
    if (shouldReturnNull) return null;
    return _cached;
  }

  @override
  Future<void> cacheSnapshot(DailyBriefSnapshot snapshot) async {
    _cached = snapshot;
  }

  @override
  Future<DailyHistory> loadHistory() async => const DailyHistory();

  @override
  Future<void> saveHistory(DailyHistory history) async {}

  @override
  Future<void> clear() async {
    _cached = null;
  }
}

// ── Stub Engines ────────────────────────────────────────────────────────────

class _MockIdentityEngine extends ChangeNotifier
    implements IdentityEngine {
  _MockIdentityEngine({this.snapshotOverride});
  IdentitySnapshot? snapshotOverride;
  @override IdentitySnapshot? get snapshot => snapshotOverride;
  @override IdentityState get identityState =>
      snapshotOverride != null ? IdentityState.ready : IdentityState.uninitialized;
  @override bool get isInitialized => snapshotOverride != null;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockGrowthEngine extends ChangeNotifier
    implements GrowthIndexEngine {
  _MockGrowthEngine({this.snapshotOverride});
  GrowthSnapshot? snapshotOverride;
  @override GrowthSnapshot? get snapshot => snapshotOverride;
  @override bool get isInitialized => snapshotOverride != null;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockMissionEngine extends ChangeNotifier
    implements MissionIntelligenceEngine {
  _MockMissionEngine({this.snapshotOverride});
  MissionSnapshot? snapshotOverride;
  @override MissionSnapshot? get snapshot => snapshotOverride;
  @override bool get isInitialized => snapshotOverride != null;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockRecEngine extends ChangeNotifier
    implements RecommendationEngine {
  _MockRecEngine({this.snapshotOverride});
  RecommendationSnapshot? snapshotOverride;
  @override RecommendationSnapshot? get snapshot => snapshotOverride;
  @override bool get isInitialized => snapshotOverride != null;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ── Test Data ───────────────────────────────────────────────────────────────

IdentitySnapshot _identitySnap() => IdentitySnapshot(
      profile: const IdentityProfile(
        id: 't', title: 'Dev', description: 'd',
        iconName: 'code', category: 'Tech', currentLevel: 3,
        targetLevel: 7, careerGoal: 'Build', experienceLevel: 'intermediate',
      ),
      currentIdentityTitle: 'Developer',
      targetIdentityTitle: 'Senior',
      currentGoal: 'Complete projects',
      currentMissionTitle: 'Tutorial',
      currentLearningPathTitle: 'Flutter',
      currentCareerPathTitle: 'Software Engineer',
      experience: 'Intermediate',
      progress: 'Level 3 of 7', growthIndex: 0.5, completionPercent: 40,
      lastUpdated: DateTime.now(), missionCount: 5, completedMissions: 2,
      activeHabitCount: 2,
    );

GrowthSnapshot _growthSnap() => GrowthSnapshot(
      overallScore: 0.5,
      knowledge: _gm(GrowthDimension.knowledge, 0.6, GrowthTrend.stable),
      skills: _gm(GrowthDimension.skills, 0.5, GrowthTrend.stable),
      projects: _gm(GrowthDimension.projects, 0.4, GrowthTrend.stable),
      career: _gm(GrowthDimension.career, 0.3, GrowthTrend.declining),
      habits: _gm(GrowthDimension.habits, 0.7, GrowthTrend.improving),
      interview: _gm(GrowthDimension.interview, 0.4, GrowthTrend.stable),
      mission: _gm(GrowthDimension.mission, 0.6, GrowthTrend.stable),
      portfolio: _gm(GrowthDimension.portfolio, 0.3, GrowthTrend.stable),
      learningConsistency: _gm(GrowthDimension.learningConsistency, 0.6, GrowthTrend.improving),
      currentLevel: 3, totalXp: 1500, lastUpdated: DateTime.now(),
    );

GrowthMetrics _gm(GrowthDimension d, double s, GrowthTrend t) =>
    GrowthMetrics(dimension: d, score: s, trend: t, label: d.displayName);

MissionSnapshot _missionSnap() => MissionSnapshot(
      currentMission: MissionRecommendation(
        id: 'm1', title: 'Complete Tutorial',
        description: 'Learn Flutter', category: MissionCategory.learning,
        priority: MissionPriority.high, difficulty: MissionDifficulty.beginner,
        estimatedDuration: 30, rewardXP: 50, reason: 'Upskill',
        score: MissionScore(score: 0.9, weight: 3, confidence: 0.95),
        impact: const MissionImpact(knowledgeGain: 0.4, growthGain: 0.3),
        confidence: 0.95, unlocks: ['Advanced tutorials'], ruleName: 'LowKnowledge',
      ),
      confidence: 0.95, lastEvaluation: DateTime.now(), lastUpdated: DateTime.now(),
    );

RecommendationSnapshot _recSnap() => RecommendationSnapshot(
      primary: RecommendationResult(
        id: 'rec-1', title: 'Interview Prep',
        description: 'Practice', category: RecommendationCategory.interview,
        score: RecommendationScore(
          priority: 9, urgency: const RecommendationUrgency(score: 0.8),
          confidence: 0.9, estimatedBenefit: 0.5,
        ),
        reason: const RecommendationReason(
          why: 'Low readiness', whyNow: 'Improve', improvement: 'Better offers',
        ),
        estimatedDuration: 30, growthImpact: 0.4, ruleName: 'LowInterview',
      ),
      confidence: 0.9, lastUpdated: DateTime.now(),
    );

MissionSnapshot _emptyMission() => const MissionSnapshot();
RecommendationSnapshot _emptyRec() => const RecommendationSnapshot();

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late _MockRepo repo;
  late DailyBriefEngine engine;

  group('DailyBriefEngine', () {
    group('initialization', () {
      test('init builds fresh brief from engines', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        expect(engine.isInitialized, isTrue);
        expect(engine.snapshot, isNotNull);
        expect(engine.snapshot!.hasBrief, isTrue);
        expect(engine.snapshot!.hasTasks, isTrue);
      });

      test('init loads cache when date matches', () async {
        final today = DateTime.now();
        final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        repo = _MockRepo();
        await repo.cacheSnapshot(DailyBriefSnapshot(
          date: dateStr, todaysFocus: 'Cached focus',
        ));
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        expect(engine.snapshot!.todaysFocus, 'Cached focus');
      });

      test('reset clears all data', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        await engine.reset();
        expect(engine.isInitialized, isFalse);
        expect(engine.snapshot, isNull);
      });
    });

    group('daily plan', () {
      test('plan includes tasks from recommendation + mission + growth + habits', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        expect(engine.snapshot!.plan.total, greaterThanOrEqualTo(3));
      });

      test('high priority tasks scheduled for morning', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        expect(engine.snapshot!.plan.morning.length, greaterThanOrEqualTo(1));
      });

      test('no rec + no mission = fewer tasks', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
        );
        await engine.init();
        expect(engine.snapshot!.plan.total, greaterThan(0));
      });
    });

    group('insights', () {
      test('insights generated from engines', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        expect(engine.snapshot!.insights.length, greaterThanOrEqualTo(1));
      });

      test('insights have category and relevance', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        for (final insight in engine.snapshot!.insights) {
          expect(insight.category, isNotEmpty);
          expect(insight.relevance, greaterThan(0.0));
        }
      });
    });

    group('task lifecycle', () {
      test('completeTask marks task as completed', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        final taskId = engine.snapshot!.plan.tasks.first.id;
        await engine.completeTask(taskId);
        expect(engine.snapshot!.plan.completedCount, greaterThan(0));
      });

      test('finalizeDay records history', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = DailyBriefEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
        );
        await engine.init();
        final progress = await engine.finalizeDay(200, 0.05);
        expect(progress.xpEarned, 200);
        expect(progress.growthDelta, 0.05);
        expect(engine.history.totalDays, 1);
      });
    });

    group('models', () {
      test('DailyPlan computes totals', () {
        final plan = DailyPlan(tasks: [
          const DailyTask(id: '1', title: 'T1', description: 'D1',
              priority: DailyPriority.high, category: 'C', estimatedMinutes: 30, xpReward: 50),
          const DailyTask(id: '2', title: 'T2', description: 'D2',
              priority: DailyPriority.low, category: 'C', estimatedMinutes: 15, xpReward: 20),
        ]);
        expect(plan.total, 2);
        expect(plan.totalMinutes, 45);
        expect(plan.totalXp, 70);
      });

      test('DailyTask copyWith preserves fields', () {
        const task = DailyTask(id: '1', title: 'T', description: 'D',
            priority: DailyPriority.high, category: 'C');
        final updated = task.copyWith(completed: true);
        expect(updated.completed, isTrue);
        expect(updated.id, '1');
        expect(updated.title, 'T');
      });

      test('DailyInsight has message and relevance', () {
        const insight = DailyInsight(
          message: 'Keep going!', category: 'growth', relevance: 0.8,
        );
        expect(insight.message, 'Keep going!');
        expect(insight.relevance, 0.8);
      });
    });
  });
}
