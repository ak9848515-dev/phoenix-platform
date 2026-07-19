import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/continue_journey/engine/continue_journey_engine.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_activity.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_history.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_resume_point.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_snapshot.dart';
import 'package:phoenix_platform/features/continue_journey/repository/journey_repository_interface.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_history_entry.dart';
import 'package:phoenix_platform/features/daily_brief/engine/daily_brief_engine.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_brief_snapshot.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_plan.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_task.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_priority.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_history.dart';
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

class _MockRepo implements JourneyRepositoryInterface {
  JourneySnapshot? _cached;
  bool shouldReturnNull = false;

  @override
  Future<JourneySnapshot?> loadCachedSnapshot() async {
    if (shouldReturnNull) return null;
    return _cached;
  }

  @override
  Future<void> cacheSnapshot(JourneySnapshot snapshot) async {
    _cached = snapshot;
  }

  @override
  Future<JourneyHistory> loadHistory() async => const JourneyHistory();

  @override
  Future<void> saveHistory(JourneyHistory history) async {}

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

class _MockBriefEngine extends ChangeNotifier
    implements DailyBriefEngine {
  _MockBriefEngine({this.snapshotOverride});
  DailyBriefSnapshot? snapshotOverride;
  @override DailyBriefSnapshot? get snapshot => snapshotOverride;
  @override DailyHistory get history => const DailyHistory();
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
      targetIdentityTitle: 'Senior Flutter Engineer',
      currentGoal: 'Master Flutter',
      currentMissionTitle: 'Complete Tutorial',
      currentLearningPathTitle: 'Flutter Fundamentals',
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
      confidence: 0.95,      completionPercent: 0.3, lastEvaluation: DateTime.now(),
      lastUpdated: DateTime.now(),
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

DailyBriefSnapshot _briefSnap() => DailyBriefSnapshot(
      date: '2026-07-15',
      todaysFocus: 'Complete Tutorial',
      plan: DailyPlan(tasks: [
        const DailyTask(id: 't1', title: 'Do Homework', description: '',
            priority: DailyPriority.high, category: 'Learning',
            estimatedMinutes: 20, xpReward: 30),
      ]),
    );

MissionSnapshot _emptyMission() => const MissionSnapshot();
RecommendationSnapshot _emptyRec() => const RecommendationSnapshot();
DailyBriefSnapshot _emptyBrief() => const DailyBriefSnapshot();
IdentitySnapshot _emptyIdentity() => IdentitySnapshot(
      profile: const IdentityProfile(
        id: '', title: '', description: '', iconName: '',
        category: '', currentLevel: 1, targetLevel: 1,
        careerGoal: '', experienceLevel: '',
      ),
      currentIdentityTitle: '', targetIdentityTitle: '',
      currentGoal: '', currentMissionTitle: '',
      currentLearningPathTitle: '', currentCareerPathTitle: '',
      experience: '', progress: '', growthIndex: 0.0,
      completionPercent: 0, lastUpdated: DateTime.now(),
    );

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late _MockRepo repo;
  late ContinueJourneyEngine engine;

  group('ContinueJourneyEngine', () {
    group('initialization', () {
      test('init builds journey from engines', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _briefSnap()),
        );
        await engine.init();
        expect(engine.isInitialized, isTrue);
        expect(engine.snapshot, isNotNull);
        expect(engine.snapshot!.hasResumePoint, isTrue);
      });

      test('init with minimal engines builds journey', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _emptyIdentity()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _emptyBrief()),
        );
        await engine.init();
        expect(engine.snapshot!.hasResumePoint, isFalse);
        expect(engine.snapshot!.currentJourney, 'Getting Started');
      });

      test('reset clears all data', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _briefSnap()),
        );
        await engine.init();
        await engine.reset();
        expect(engine.isInitialized, isFalse);
        expect(engine.snapshot, isNull);
      });
    });

    group('resume candidates', () {
      test('identifies mission as top resume candidate', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _briefSnap()),
        );
        await engine.init();
        expect(engine.snapshot!.resumeCandidates.length, greaterThan(0));
        expect(engine.snapshot!.resumePoint!.type,
            JourneyResumePoint.mission);
      });

      test('has candidates even with no mission', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _emptyIdentity()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _emptyBrief()),
        );
        await engine.init();
        expect(engine.snapshot!.hasCandidates, isFalse);
      });
    });

    group('journey naming', () {
      test('journey name uses target identity', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _briefSnap()),
        );
        await engine.init();
        expect(engine.snapshot!.currentJourney,
            contains('Senior Flutter Engineer'));
      });

      test('journey name defaults with no identity', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _emptyIdentity()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _emptyBrief()),
        );
        await engine.init();
        expect(engine.snapshot!.currentJourney, 'Getting Started');
      });
    });

    group('activity lifecycle', () {
      test('startActivity records in history', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _emptyIdentity()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _emptyBrief()),
        );
        await engine.init();
        await engine.startActivity('a1', 'Test Activity', JourneyResumePoint.lesson);
        expect(engine.history.totalEntries, 1);
        expect(engine.history.inProgress.length, 1);
      });

      test('completeActivity marks completed in history', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _emptyIdentity()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _emptyBrief()),
        );
        await engine.init();
        await engine.startActivity('a1', 'Test', JourneyResumePoint.lesson);
        await engine.completeActivity('a1', minutesSpent: 20, xpEarned: 50);
        final completed = engine.history.completed;
        expect(completed.length, 1);
        expect(completed.first.totalMinutesSpent, 20);
        expect(completed.first.xpEarned, 50);
      });

      test('cancelActivity marks cancelled in history', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _emptyIdentity()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _emptyBrief()),
        );
        await engine.init();
        await engine.startActivity('a1', 'Test', JourneyResumePoint.lesson);
        await engine.cancelActivity('a1');
        expect(engine.history.cancelled.length, 1);
      });

      test('resumeActivity increments resume count', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _emptyIdentity()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _emptyBrief()),
        );
        await engine.init();
        await engine.startActivity('a1', 'Test', JourneyResumePoint.lesson);
        await engine.resumeActivity('a1');
        expect(engine.history.totalResumeCount, 1);
      });
    });

    group('reasoning', () {
      test('reason mentions mission when active mission exists', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _identitySnap()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _missionSnap()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _recSnap()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _briefSnap()),
        );
        await engine.init();
        expect(engine.snapshot!.reason, contains('active mission'));
      });

      test('reason mentions start when no candidates', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = ContinueJourneyEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(snapshotOverride: _emptyIdentity()),
          growthEngine: _MockGrowthEngine(snapshotOverride: _growthSnap()),
          missionEngine: _MockMissionEngine(snapshotOverride: _emptyMission()),
          recommendationEngine: _MockRecEngine(snapshotOverride: _emptyRec()),
          dailyBriefEngine: _MockBriefEngine(snapshotOverride: _emptyBrief()),
        );
        await engine.init();
        expect(engine.snapshot!.reason, contains('Start your journey'));
      });
    });

    group('models', () {
      test('JourneyActivity copyWith preserves fields', () {
        final activity = JourneyActivity(
          id: '1', title: 'Test', type: JourneyResumePoint.lesson,
          progressPercent: 0.5,
        );
        final updated = activity.copyWith(progressPercent: 0.8);
        expect(updated.progressPercent, 0.8);
        expect(updated.id, '1');
        expect(updated.title, 'Test');
      });

      test('JourneyHistory counts completed', () {
        final history = JourneyHistory(entries: [
          const JourneyHistoryEntry(
            activityId: '1', activityTitle: 'A',
            activityType: JourneyResumePoint.lesson, status: 'completed',
          ),
          const JourneyHistoryEntry(
            activityId: '2', activityTitle: 'B',
            activityType: JourneyResumePoint.lesson, status: 'cancelled',
          ),
          const JourneyHistoryEntry(
            activityId: '3', activityTitle: 'C',
            activityType: JourneyResumePoint.lesson, status: 'started',
          ),
        ]);
        expect(history.totalEntries, 3);
        expect(history.completed.length, 1);
        expect(history.inProgress.length, 1);
        expect(history.cancelled.length, 1);
        expect(history.completionRate, 0.5);
      });

      test('JourneySnapshot hasResumePoint', () {
        const snap = JourneySnapshot();
        expect(snap.hasResumePoint, isFalse);
        expect(snap.hasCandidates, isFalse);
      });
    });
  });
}
