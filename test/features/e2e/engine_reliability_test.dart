import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/continue_journey/engine/continue_journey_engine.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_history.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_resume_point.dart';
import 'package:phoenix_platform/features/continue_journey/repository/journey_repository_interface.dart';
import 'package:phoenix_platform/features/daily_brief/engine/daily_brief_engine.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_history.dart';
import 'package:phoenix_platform/features/daily_brief/repository/daily_brief_repository_interface.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/models/identity_state.dart';
import 'package:phoenix_platform/features/memory_engine/engine/memory_engine.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_category.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_entry.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_index.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_relationship.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_snapshot.dart';
import 'package:phoenix_platform/features/memory_engine/repository/memory_repository_interface.dart';
import 'package:phoenix_platform/features/mission_intelligence/engine/mission_intelligence_engine.dart';
import 'package:phoenix_platform/features/recommendation_engine/engine/recommendation_engine.dart';
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';
import 'package:phoenix_platform/features/mission_intelligence/repository/mission_intelligence_repository_interface.dart';
import 'package:phoenix_platform/features/recommendation_engine/repository/recommendation_repository_interface.dart';
import 'package:phoenix_platform/features/identity/repository/identity_repository_interface.dart';
import 'package:phoenix_platform/features/identity/models/identity_profile.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_history.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_snapshot.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_history.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_brief_snapshot.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_snapshot.dart';

void main() {
  group('Reliability: Rapid App Restart', () {
    test('IdentityEngine re-initializes after reset', () async {
      final repo = _IdentityRepo()..returnNull = true;
      var engine = IdentityEngine(
        repository: repo,
        userStateService: _StubUserState(),
      );
      await engine.init();
      await engine.reset();

      engine = IdentityEngine(
        repository: repo,
        userStateService: _StubUserState(),
      );
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot, isNotNull);
    });

    test('MemoryEngine re-initializes after clear', () async {
      final repo = _MemRepo()..returnNull = true;
      var engine = MemoryEngine(
        repository: repo,
        identityEngine: StubId(),
        growthEngine: StubGr(),
        missionEngine: StubMs(),
      );
      await engine.init();
      await engine.clear();

      engine = MemoryEngine(
        repository: repo,
        identityEngine: StubId(),
        growthEngine: StubGr(),
        missionEngine: StubMs(),
      );
      await engine.init();
      expect(engine.isInitialized, isTrue);
    });
  });

  group('Reliability: Repeated Observer Events', () {
    test('DailyBriefEngine handles rapid rebuilds', () async {
      final repo = _BriefRepo()..returnNull = true;
      final engine = DailyBriefEngine(
        repository: repo,
        identityEngine: StubId(),
        growthEngine: StubGr(),
        missionEngine: StubMs(),
        recommendationEngine: StubRc(),
      );
      await engine.init();
      await Future.wait([engine.rebuild(), engine.rebuild(), engine.rebuild()]);
      expect(engine.snapshot, isNotNull);
    });

    test('ContinueJourneyEngine handles activity lifecycle', () async {
      final repo = _JourneyRepo()..returnNull = true;
      final engine = ContinueJourneyEngine(
        repository: repo,
        identityEngine: StubId(),
        growthEngine: StubGr(),
        missionEngine: StubMs(),
        recommendationEngine: StubRc(),
        dailyBriefEngine: StubBr(),
      );
      await engine.init();
      await engine.startActivity('a1', 'A1', JourneyResumePoint.lesson);
      await engine.startActivity('a2', 'A2', JourneyResumePoint.mission);
      await engine.resumeActivity('a1');
      await engine.completeActivity('a1', minutesSpent: 30, xpEarned: 50);
      await engine.cancelActivity('a2');
      expect(engine.history.totalEntries, 2);
      expect(engine.history.completed.length, 1);
      expect(engine.history.cancelled.length, 1);
    });
  });

  group('Reliability: Missing Snapshot', () {
    test('All engines init with null cached snapshot', () async {
      final id = IdentityEngine(repository: _IdentityRepo()..returnNull = true, userStateService: _StubUserState());
      await id.init();
      expect(id.isInitialized, isTrue);

      final ms = MissionIntelligenceEngine(repository: _MsRepo()..returnNull = true, identityEngine: StubId(), growthEngine: StubGr(), userStateService: _StubUserState());
      await ms.init();
      expect(ms.isInitialized, isTrue);

      final rc = RecommendationEngine(repository: _RcRepo()..returnNull = true, identityEngine: StubId(), growthEngine: StubGr(), missionEngine: StubMs(), userStateService: _StubUserState());
      await rc.init();
      expect(rc.isInitialized, isTrue);

      final br = DailyBriefEngine(repository: _BriefRepo()..returnNull = true, identityEngine: StubId(), growthEngine: StubGr(), missionEngine: StubMs(), recommendationEngine: StubRc());
      await br.init();
      expect(br.isInitialized, isTrue);
    });
  });

  group('Reliability: Large Dataset', () {
    test('MemoryEngine handles 5000 entries', () async {
      final entries = List.generate(5000, (i) => MemoryEntry(
        id: 'mem-$i', title: 'Memory $i',
        content: 'Content $i about Flutter development.',
        category: MemoryCategory.values[i % MemoryCategory.values.length],
        tags: ['tag-${i % 20}'], source: 'test',
      ));
      final repo = _MemRepo()..entries = entries;
      final engine = MemoryEngine(
        repository: repo, identityEngine: StubId(),
        growthEngine: StubGr(), missionEngine: StubMs(),
      );
      await engine.init();
      expect(engine.snapshot!.totalMemories, 5000);
      final results = engine.searchKeywords('Flutter');
      expect(results.length, greaterThan(0));
    });
  });

  group('Reliability: Cache Corruption', () {
    test('Memory engine handles empty entries gracefully', () async {
      final repo = _MemRepo()..returnNull = true;
      final engine = MemoryEngine(
        repository: repo, identityEngine: StubId(),
        growthEngine: StubGr(), missionEngine: StubMs(),
      );
      await engine.init();
      expect(engine.snapshot!.hasMemories, isFalse);
      expect(engine.entries, isEmpty);
    });

    test('Identity engine handles empty profile gracefully', () async {
      final repo = _IdentityRepo()..returnNull = true;
      final engine = IdentityEngine(
        repository: repo, userStateService: _StubUserState(),
      );
      await engine.init();
      expect(engine.snapshot!.profile.id, isEmpty);
    });
  });
}

// ── Stub Engines ────────────────────────────────────────────────────────────

class StubId extends ChangeNotifier implements IdentityEngine {
  @override IdentitySnapshot? get snapshot => null;
  @override IdentityState get identityState => IdentityState.uninitialized;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class StubGr extends ChangeNotifier implements GrowthIndexEngine {
  @override GrowthSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class StubMs extends ChangeNotifier implements MissionIntelligenceEngine {
  @override MissionSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class StubRc extends ChangeNotifier implements RecommendationEngine {
  @override RecommendationSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class StubBr extends ChangeNotifier implements DailyBriefEngine {
  @override DailyBriefSnapshot? get snapshot => null;
  @override DailyHistory get history => DailyHistory();
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ── Stub Services ───────────────────────────────────────────────────────────

class _StubUserState extends UserStateService {
  _StubUserState() : super(engine: _StubUsEngine());
}

class _StubUsEngine extends UserStateEngine {
  _StubUsEngine() : super(repository: _StubUsRepo());
}

class _StubUsRepo extends UserStateRepository {
  @override Future<void> saveState(UserState s) async {}
}

// ── Mock Repositories ───────────────────────────────────────────────────────

class _IdentityRepo implements IdentityRepositoryInterface {
  bool returnNull = false;
  @override Future<IdentitySnapshot?> loadCachedSnapshot() async =>
      returnNull ? null : IdentitySnapshot(profile: const IdentityProfile(id: '', title: '', description: '', iconName: '', category: '', currentLevel: 1, targetLevel: 1, careerGoal: '', experienceLevel: ''), currentIdentityTitle: '', targetIdentityTitle: '', currentGoal: '', currentMissionTitle: '', currentLearningPathTitle: '', currentCareerPathTitle: '', experience: '', progress: '', growthIndex: 0.0, completionPercent: 0, lastUpdated: DateTime.now());
  @override Future<void> cacheSnapshot(IdentitySnapshot s) async {}
  @override Future<IdentityProfile> loadProfile() async => const IdentityProfile(id: '', title: '', description: '', iconName: '', category: '', currentLevel: 1, targetLevel: 1, careerGoal: '', experienceLevel: '');
  @override Future<void> saveProfile(IdentityProfile p) async {}
  @override Future<void> clear() async {}
}

class _MemRepo implements MemoryRepositoryInterface {
  bool returnNull = false;
  List<MemoryEntry> entries = [];
  @override Future<List<MemoryEntry>> loadAllEntries() async => entries;
  @override Future<void> saveAllEntries(List<MemoryEntry> e) async { entries = e; }
  @override Future<List<MemoryRelationship>> loadAllRelationships() async => [];
  @override Future<void> saveAllRelationships(List<MemoryRelationship> r) async {}
  @override Future<MemorySnapshot?> loadCachedSnapshot() async => returnNull ? null : null;
  @override Future<void> cacheSnapshot(MemorySnapshot s) async {}
  @override Future<MemoryIndex> loadIndex() async => MemoryIndex();
  @override Future<void> saveIndex(MemoryIndex i) async {}
  @override Future<void> clear() async { entries = []; }
}

class _BriefRepo implements DailyBriefRepositoryInterface {
  bool returnNull = false;
  @override Future<DailyBriefSnapshot?> loadCachedSnapshot() async => returnNull ? null : null;
  @override Future<void> cacheSnapshot(DailyBriefSnapshot s) async {}
  @override Future<DailyHistory> loadHistory() async => DailyHistory();
  @override Future<void> saveHistory(DailyHistory h) async {}
  @override Future<void> clear() async {}
}

class _MsRepo implements MissionIntelligenceRepositoryInterface {
  bool returnNull = false;
  @override Future<MissionSnapshot?> loadCachedSnapshot() async => returnNull ? null : null;
  @override Future<void> cacheSnapshot(MissionSnapshot s) async {}
  @override Future<MissionHistory> loadHistory() async => MissionHistory();
  @override Future<void> saveHistory(MissionHistory h) async {}
  @override Future<void> clear() async {}
}

class _RcRepo implements RecommendationRepositoryInterface {
  bool returnNull = false;
  @override Future<RecommendationSnapshot?> loadCachedSnapshot() async => returnNull ? null : null;
  @override Future<void> cacheSnapshot(RecommendationSnapshot s) async {}
  @override Future<RecommendationHistory> loadHistory() async => RecommendationHistory();
  @override Future<void> saveHistory(RecommendationHistory h) async {}
  @override Future<void> clear() async {}
}

class _JourneyRepo implements JourneyRepositoryInterface {
  bool returnNull = false;
  @override Future<JourneySnapshot?> loadCachedSnapshot() async => returnNull ? null : null;
  @override Future<void> cacheSnapshot(JourneySnapshot s) async {}
  @override Future<JourneyHistory> loadHistory() async => JourneyHistory();
  @override Future<void> saveHistory(JourneyHistory h) async {}
  @override Future<void> clear() async {}
}


