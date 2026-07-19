import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/continue_journey/engine/continue_journey_engine.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_history.dart';
import 'package:phoenix_platform/features/continue_journey/models/journey_snapshot.dart';
import 'package:phoenix_platform/features/continue_journey/repository/journey_repository_interface.dart';
import 'package:phoenix_platform/features/daily_brief/engine/daily_brief_engine.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_brief_snapshot.dart';
import 'package:phoenix_platform/features/daily_brief/models/daily_history.dart';
import 'package:phoenix_platform/features/daily_brief/repository/daily_brief_repository_interface.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/growth_index/repository/growth_repository_interface.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/models/identity_profile.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_state.dart';
import 'package:phoenix_platform/features/identity/repository/identity_repository_interface.dart';
import 'package:phoenix_platform/features/memory_engine/engine/memory_engine.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_category.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_entry.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_index.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_relationship.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_snapshot.dart';
import 'package:phoenix_platform/features/memory_engine/repository/memory_repository_interface.dart';
import 'package:phoenix_platform/features/mission_intelligence/engine/mission_intelligence_engine.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_history.dart';
import 'package:phoenix_platform/features/mission_intelligence/repository/mission_intelligence_repository_interface.dart';
import 'package:phoenix_platform/features/recommendation_engine/engine/recommendation_engine.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_snapshot.dart';
import 'package:phoenix_platform/features/recommendation_engine/models/recommendation_history.dart';
import 'package:phoenix_platform/features/recommendation_engine/repository/recommendation_repository_interface.dart';
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';

// ── First Launch Tests ───────────────────────────────────────────────────────

void main() {
  group('First Launch (All 8 Engines)', () {
    test('IdentityEngine initializes from empty state', () async {
      final repo = _IdRepo()..returnNull = true;
      final engine = IdentityEngine(repository: repo, userStateService: _Us());
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot, isNotNull);
      expect(engine.snapshot!.profile.id, isEmpty);
    });

    test('GrowthIndexEngine initializes from empty state', () async {
      final repo = _GrRepo()..returnNull = true;
      final engine = GrowthIndexEngine(repository: repo, userStateService: _Us());
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot, isNotNull);
    });

    test('MissionIntelligenceEngine initializes from empty state', () async {
      final repo = _MsRepo()..returnNull = true;
      final engine = MissionIntelligenceEngine(
        repository: repo, identityEngine: _StubId(),
        growthEngine: _StubGr(), userStateService: _Us(),
      );
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot!.currentMission, isNull);
    });

    test('RecommendationEngine initializes from empty state', () async {
      final repo = _RcRepo()..returnNull = true;
      final engine = RecommendationEngine(
        repository: repo, identityEngine: _StubId(),
        growthEngine: _StubGr(), missionEngine: _StubMs(),
        userStateService: _Us(),
      );
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot!.primary, isNull);
    });

    test('DailyBriefEngine initializes from empty state', () async {
      final repo = _BrRepo()..returnNull = true;
      final engine = DailyBriefEngine(
        repository: repo, identityEngine: _StubId(),
        growthEngine: _StubGr(), missionEngine: _StubMs(),
        recommendationEngine: _StubRc(),
      );
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot, isNotNull);
    });

    test('ContinueJourneyEngine initializes from empty state', () async {
      final repo = _JyRepo()..returnNull = true;
      final engine = ContinueJourneyEngine(
        repository: repo, identityEngine: _StubId(),
        growthEngine: _StubGr(), missionEngine: _StubMs(),
        recommendationEngine: _StubRc(), dailyBriefEngine: _StubBr(),
      );
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot!.hasResumePoint, isFalse);
    });

    test('MemoryEngine initializes from empty state', () async {
      final repo = _MemRepo()..returnNull = true;
      final engine = MemoryEngine(
        repository: repo, identityEngine: _StubId(),
        growthEngine: _StubGr(), missionEngine: _StubMs(),
      );
      await engine.init();
      expect(engine.isInitialized, isTrue);
      expect(engine.snapshot!.hasMemories, isFalse);
    });
  });

  // ── Snapshot Restoration ───────────────────────────────────────────

  group('Snapshot Restoration', () {
    test('DailyBriefEngine restores from cache when date matches', () async {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final repo = _BrRepo();
      repo.cachedFocus = 'Cached';
      repo.cachedDate = dateStr;
      final engine = DailyBriefEngine(
        repository: repo, identityEngine: _StubId(),
        growthEngine: _StubGr(), missionEngine: _StubMs(),
        recommendationEngine: _StubRc(),
      );
      await engine.init();
      expect(engine.snapshot!.todaysFocus, 'Cached');
    });

    test('MemoryEngine adds and retrieves entries', () async {
      final repo = _MemRepo()..returnNull = true;
      final engine = MemoryEngine(
        repository: repo, identityEngine: _StubId(),
        growthEngine: _StubGr(), missionEngine: _StubMs(),
      );
      await engine.init();
      await engine.addEntry(MemoryEntry(id: '1', title: 'Test', content: 'Content', category: MemoryCategory.learning));
      expect(engine.snapshot!.hasMemories, isTrue);
      expect(engine.getEntry('1'), isNotNull);
    });
  });

  // ── Offline Behavior ──────────────────────────────────────────────

  group('Offline Behavior', () {
    test('All engines init without network', () async {
      final id = IdentityEngine(repository: _IdRepo()..returnNull = true, userStateService: _Us());
      await id.init();
      expect(id.isInitialized, isTrue);

      final mem = MemoryEngine(repository: _MemRepo()..returnNull = true, identityEngine: _StubId(), growthEngine: _StubGr(), missionEngine: _StubMs());
      await mem.init();
      expect(mem.isInitialized, isTrue);
    });

    test('Memory search works offline', () async {
      final repo = _MemRepo()..returnNull = true;
      final engine = MemoryEngine(
        repository: repo, identityEngine: _StubId(),
        growthEngine: _StubGr(), missionEngine: _StubMs(),
      );
      await engine.init();
      await engine.addEntry(MemoryEntry(id: '1', title: 'Flutter', content: 'Widget framework', category: MemoryCategory.learning));
      final results = engine.searchKeywords('flutter');
      expect(results.length, 1);
    });
  });
}

// ── Stub Engines ────────────────────────────────────────────────────────────

class _StubId extends ChangeNotifier implements IdentityEngine {
  @override IdentitySnapshot? get snapshot => null;
  @override IdentityState get identityState => IdentityState.uninitialized;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StubGr extends ChangeNotifier implements GrowthIndexEngine {
  @override GrowthSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StubMs extends ChangeNotifier implements MissionIntelligenceEngine {
  @override MissionSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StubRc extends ChangeNotifier implements RecommendationEngine {
  @override RecommendationSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StubBr extends ChangeNotifier implements DailyBriefEngine {
  @override DailyBriefSnapshot? get snapshot => null;
  @override DailyHistory get history => DailyHistory();
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ── Stub Services ───────────────────────────────────────────────────────────

class _Us extends UserStateService {
  _Us() : super(engine: _UsE());
}

class _UsE extends UserStateEngine {
  _UsE() : super(repository: _UsR());
}

class _UsR extends UserStateRepository {
  @override Future<void> saveState(UserState s) async {}
}

// ── Mock Repositories ───────────────────────────────────────────────────────

class _IdRepo implements IdentityRepositoryInterface {
  bool returnNull = false;
  @override Future<IdentitySnapshot?> loadCachedSnapshot() async =>
      returnNull ? null : IdentitySnapshot(profile: const IdentityProfile(id: '', title: '', description: '', iconName: '', category: '', currentLevel: 1, targetLevel: 1, careerGoal: '', experienceLevel: ''), currentIdentityTitle: '', targetIdentityTitle: '', currentGoal: '', currentMissionTitle: '', currentLearningPathTitle: '', currentCareerPathTitle: '', experience: '', progress: '', growthIndex: 0.0, completionPercent: 0, lastUpdated: DateTime.now());
  @override Future<void> cacheSnapshot(IdentitySnapshot s) async {}
  @override Future<IdentityProfile> loadProfile() async => const IdentityProfile(id: '', title: '', description: '', iconName: '', category: '', currentLevel: 1, targetLevel: 1, careerGoal: '', experienceLevel: '');
  @override Future<void> saveProfile(IdentityProfile p) async {}
  @override Future<void> clear() async {}
}

class _GrRepo implements GrowthRepositoryInterface {
  bool returnNull = false;
  @override Future<GrowthSnapshot?> loadCachedSnapshot() async =>
      returnNull ? null : null;
  @override Future<void> cacheSnapshot(GrowthSnapshot s) async {}
  @override Future<void> clear() async {}
}

class _MsRepo implements MissionIntelligenceRepositoryInterface {
  bool returnNull = false;
  @override Future<MissionSnapshot?> loadCachedSnapshot() async =>
      returnNull ? null : null;
  @override Future<void> cacheSnapshot(MissionSnapshot s) async {}
  @override Future<MissionHistory> loadHistory() async => MissionHistory();
  @override Future<void> saveHistory(MissionHistory h) async {}
  @override Future<void> clear() async {}
}

class _RcRepo implements RecommendationRepositoryInterface {
  bool returnNull = false;
  @override Future<RecommendationSnapshot?> loadCachedSnapshot() async =>
      returnNull ? null : null;
  @override Future<void> cacheSnapshot(RecommendationSnapshot s) async {}
  @override Future<RecommendationHistory> loadHistory() async => RecommendationHistory();
  @override Future<void> saveHistory(RecommendationHistory h) async {}
  @override Future<void> clear() async {}
}

class _BrRepo implements DailyBriefRepositoryInterface {
  bool returnNull = false;
  String? cachedFocus;
  String? cachedDate;
  @override Future<DailyBriefSnapshot?> loadCachedSnapshot() async {
    if (returnNull) return null;
    if (cachedDate != null) return DailyBriefSnapshot(date: cachedDate!, todaysFocus: cachedFocus ?? '');
    return null;
  }
  @override Future<void> cacheSnapshot(DailyBriefSnapshot s) async {}
  @override Future<DailyHistory> loadHistory() async => DailyHistory();
  @override Future<void> saveHistory(DailyHistory h) async {}
  @override Future<void> clear() async {}
}

class _JyRepo implements JourneyRepositoryInterface {
  bool returnNull = false;
  @override Future<JourneySnapshot?> loadCachedSnapshot() async =>
      returnNull ? null : null;
  @override Future<void> cacheSnapshot(JourneySnapshot s) async {}
  @override Future<JourneyHistory> loadHistory() async => JourneyHistory();
  @override Future<void> saveHistory(JourneyHistory h) async {}
  @override Future<void> clear() async {}
}

class _MemRepo implements MemoryRepositoryInterface {
  bool returnNull = false;
  @override Future<List<MemoryEntry>> loadAllEntries() async => [];
  @override Future<void> saveAllEntries(List<MemoryEntry> e) async {}
  @override Future<List<MemoryRelationship>> loadAllRelationships() async => [];
  @override Future<void> saveAllRelationships(List<MemoryRelationship> r) async {}
  @override Future<MemorySnapshot?> loadCachedSnapshot() async =>
      returnNull ? null : null;
  @override Future<void> cacheSnapshot(MemorySnapshot s) async {}
  @override Future<MemoryIndex> loadIndex() async => MemoryIndex();
  @override Future<void> saveIndex(MemoryIndex i) async {}
  @override Future<void> clear() async {}
}
