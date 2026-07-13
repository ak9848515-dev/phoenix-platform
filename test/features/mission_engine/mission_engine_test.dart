import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/sample_repository.dart';
import 'package:phoenix_platform/features/interview/services/interview_service.dart';
import 'package:phoenix_platform/features/knowledge_dna/knowledge_dna_service.dart';
import 'package:phoenix_platform/features/mission_engine/engine/mission_engine.dart';
import 'package:phoenix_platform/features/mission_engine/engine/mission_generator.dart';
import 'package:phoenix_platform/features/mission_engine/engine/mission_prioritizer.dart';
import 'package:phoenix_platform/features/mission_engine/engine/mission_scheduler.dart';
import 'package:phoenix_platform/features/mission_engine/mission_engine.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_difficulty.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_priority.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_status.dart';
import 'package:phoenix_platform/features/mission_engine/mission_service.dart';
import 'package:phoenix_platform/features/mission_engine/repository/mission_repository.dart';
import 'package:phoenix_platform/features/opportunity/services/opportunity_service.dart';
import 'package:phoenix_platform/features/portfolio/services/portfolio_service.dart';
import 'package:phoenix_platform/features/recommendation/services/recommendation_service.dart';
import 'package:phoenix_platform/features/resume/services/resume_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Sample Missions ──────────────────────────────────────────────────────

const _pendingMission = Mission(
  id: 'test-1',
  title: 'Learn Dart',
  description: 'Master Dart fundamentals.',
  category: MissionCategory.learning,
  priority: MissionPriority.high,
  difficulty: MissionDifficulty.beginner,
  estimatedDuration: 30,
  rewardXP: 100,
  status: MissionStatus.pending,
  createdDate: null,
);

const _completedMission = Mission(
  id: 'test-2',
  title: 'Completed Task',
  description: 'This mission is done.',
  category: MissionCategory.daily,
  priority: MissionPriority.medium,
  difficulty: MissionDifficulty.beginner,
  estimatedDuration: 15,
  rewardXP: 50,
  status: MissionStatus.completed,
  completedDate: null,
);

const _blockedMission = Mission(
  id: 'test-3',
  title: 'Advanced Dart',
  description: 'Requires Learn Dart first.',
  category: MissionCategory.learning,
  priority: MissionPriority.high,
  difficulty: MissionDifficulty.medium,
  estimatedDuration: 45,
  rewardXP: 200,
  status: MissionStatus.blocked,
  dependencyMissionId: 'test-1',
);

const _recurringMission = Mission(
  id: 'test-4',
  title: 'Daily Review',
  description: 'Review your progress daily.',
  category: MissionCategory.daily,
  priority: MissionPriority.low,
  difficulty: MissionDifficulty.beginner,
  estimatedDuration: 10,
  rewardXP: 30,
  status: MissionStatus.completed,
  recurring: true,
  recurrenceIntervalDays: 1,
  completedDate: null,
);

const _highPriorityMission = Mission(
  id: 'test-5',
  title: 'Critical Fix',
  description: 'Fix a critical issue.',
  category: MissionCategory.practice,
  priority: MissionPriority.critical,
  difficulty: MissionDifficulty.hard,
  estimatedDuration: 60,
  rewardXP: 500,
  status: MissionStatus.pending,
);

const _dailyTemplateMission = Mission(
  id: 'test-daily',
  title: 'Daily Task',
  description: 'Complete your daily task.',
  category: MissionCategory.daily,
  priority: MissionPriority.medium,
  difficulty: MissionDifficulty.beginner,
  estimatedDuration: 10,
  rewardXP: 30,
  status: MissionStatus.pending,
);

void main() {
  // ═════════════════════════════════════════════════════════════════
  // Mission Model
  // ═════════════════════════════════════════════════════════════════

  group('Mission model', () {
    test('creates mission with all required fields', () {
      expect(_pendingMission.id, 'test-1');
      expect(_pendingMission.title, 'Learn Dart');
      expect(_pendingMission.isActionable, isTrue);
      expect(_pendingMission.isCompleted, isFalse);
    });

    test('copyWith creates a modified copy', () {
      final modified = _pendingMission.copyWith(
        title: 'Learn Flutter',
        priority: MissionPriority.critical,
      );
      expect(modified.id, 'test-1');
      expect(modified.title, 'Learn Flutter');
      expect(modified.priority, MissionPriority.critical);
    });

    test('copyWith preserves unchanged fields', () {
      final modified = _pendingMission.copyWith(title: 'New Title');
      expect(modified.description, 'Master Dart fundamentals.');
      expect(modified.category, MissionCategory.learning);
      expect(modified.difficulty, MissionDifficulty.beginner);
    });

    test('isCompleted returns true only for completed status', () {
      expect(_completedMission.isCompleted, isTrue);
      expect(_pendingMission.isCompleted, isFalse);
      expect(_blockedMission.isCompleted, isFalse);
    });

    test('isActionable returns correct value for each status', () {
      Mission make(String id, MissionStatus s) => Mission(
        id: id, title: 't', description: 'd',
        category: MissionCategory.learning, priority: MissionPriority.medium,
        difficulty: MissionDifficulty.beginner, estimatedDuration: 10,
        rewardXP: 10, status: s,
      );

      expect(make('a', MissionStatus.pending).isActionable, isTrue);
      expect(make('b', MissionStatus.inProgress).isActionable, isTrue);
      expect(make('c', MissionStatus.available).isActionable, isTrue);
      expect(make('d', MissionStatus.completed).isActionable, isFalse);
      expect(make('e', MissionStatus.skipped).isActionable, isFalse);
      expect(make('f', MissionStatus.blocked).isActionable, isFalse);
    });

    test('toMap and fromMap round-trip correctly', () {
      final map = _pendingMission.toMap();
      final restored = Mission.fromMap(map);
      expect(restored.id, _pendingMission.id);
      expect(restored.title, _pendingMission.title);
      expect(restored.category, _pendingMission.category);
      expect(restored.priority, _pendingMission.priority);
      expect(restored.difficulty, _pendingMission.difficulty);
    });

    test('toJson and fromJson round-trip correctly', () {
      final json = _pendingMission.toJson();
      final restored = Mission.fromJson(json);
      expect(restored.id, _pendingMission.id);
      expect(restored.title, _pendingMission.title);
    });

    test('equality uses id only', () {
      final copy = _pendingMission.copyWith(title: 'Different Title');
      expect(_pendingMission == copy, isTrue);
      expect(_pendingMission.hashCode, copy.hashCode);
    });

    test('missions with different ids are not equal', () {
      expect(_pendingMission == _completedMission, isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // Mission Engine
  // ═════════════════════════════════════════════════════════════════

  group('MissionEngine', () {
    late MissionEngine engine;

    setUp(() {
      final repository = const SampleRepository();
      final knowledgeDna = KnowledgeDNAService(repository: repository);
      engine = _createTestEngine(knowledgeDna);
    });

    test('completeMission returns updated mission with XP', () {
      final (updated, xp) = engine.completeMission(_pendingMission);
      expect(updated.status, MissionStatus.completed);
      expect(updated.isCompleted, isTrue);
      expect(updated.progress, 1.0);
      expect(updated.completedDate, isNotNull);
      expect(xp, 100);
    });

    test('completeMission sets up next cycle for recurring missions', () {
      final (updated, _) = engine.completeMission(_recurringMission);
      expect(updated.status, MissionStatus.available);
      expect(updated.progress, 0.0);
      expect(updated.completedDate, isNotNull);
    });

    test('skipMission marks mission as skipped', () {
      final updated = engine.skipMission(_pendingMission);
      expect(updated.status, MissionStatus.skipped);
      expect(updated.progress, 0.0);
    });

    test('updateProgress changes status based on value', () {
      final partial = engine.updateProgress(_pendingMission, 0.5);
      expect(partial.status, MissionStatus.inProgress);
      expect(partial.progress, 0.5);

      final complete = engine.updateProgress(_pendingMission, 1.0);
      expect(complete.status, MissionStatus.completed);
      expect(complete.completedDate, isNotNull);
    });

    test('unblockDependents unblocks missions with matching dependency', () {
      final missions = [_pendingMission, _blockedMission];
      final updated = engine.unblockDependents(
        completedMissionId: 'test-1',
        allMissions: missions,
      );
      expect(updated[1].status, MissionStatus.pending);
    });

    test('validateMission returns null for valid mission', () {
      expect(engine.validateMission(_pendingMission), isNull);
    });

    test('validateMission returns error for empty title', () {
      final invalid = _pendingMission.copyWith(title: '');
      expect(engine.validateMission(invalid), isNotNull);
    });

    test('validateMission returns error for negative XP', () {
      final invalid = _pendingMission.copyWith(rewardXP: -1);
      expect(engine.validateMission(invalid), isNotNull);
    });

    test('prioritizeMissions returns highest priority first', () {
      final sorted = engine.prioritizeMissions([
        _pendingMission,
        _highPriorityMission,
      ]);
      expect(sorted.first.id, 'test-5');
    });

    test('findTopPriority returns highest priority actionable mission', () {
      final top = engine.findTopPriority([
        _completedMission,
        _highPriorityMission,
      ]);
      expect(top?.id, 'test-5');
    });

    test('findTopPriority returns null if no actionable missions', () {
      final top = engine.findTopPriority([_completedMission]);
      expect(top, isNull);
    });

    test('generateDailyBatch creates new daily missions from templates', () {
      final batch = engine.generateDailyBatch(
        existingMissions: [_completedMission],
        availableTemplates: [_dailyTemplateMission],
      );
      expect(batch, isNotEmpty);
      expect(batch.first.category, MissionCategory.daily);
    });

    test('refreshRecurring refreshes due recurring missions', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dueMission = _recurringMission.copyWith(
        completedDate: yesterday,
      );
      final refreshed = engine.refreshRecurring([dueMission]);
      expect(refreshed[0].status, MissionStatus.available);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // Mission Prioritizer
  // ═════════════════════════════════════════════════════════════════

  group('MissionPrioritizer', () {
    late MissionPrioritizer prioritizer;

    setUp(() {
      prioritizer = MissionPrioritizer();
    });

    test('prioritize returns missions sorted by priority', () {
      final sorted = prioritizer.prioritize([
        _pendingMission,       // high
        _highPriorityMission,  // critical
        _completedMission,     // medium
      ]);
      expect(sorted[0].id, 'test-5'); // critical first
      expect(sorted[1].id, 'test-1'); // high second
      expect(sorted[2].id, 'test-2'); // medium last
    });

    test('findTopPriority returns null for empty list', () {
      expect(prioritizer.findTopPriority([]), isNull);
    });

    test('calculatePriority returns mission priority level', () {
      expect(
        prioritizer.calculatePriority(_highPriorityMission),
        MissionPriority.critical,
      );
      expect(
        prioritizer.calculatePriority(_pendingMission),
        MissionPriority.high,
      );
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // Mission Scheduler
  // ═════════════════════════════════════════════════════════════════

  group('MissionScheduler', () {
    late MissionScheduler scheduler;

    setUp(() {
      scheduler = MissionScheduler();
    });

    test('getTodaysMissions includes actionable missions', () {
      final today = scheduler.getTodaysMissions([
        _pendingMission,
        _completedMission,
      ]);
      expect(today.length, 1);
      expect(today.first.id, 'test-1');
    });

    test('shouldRefresh returns true for due recurring missions', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dueMission = _recurringMission.copyWith(
        completedDate: yesterday,
      );
      expect(scheduler.shouldRefresh(dueMission), isTrue);
    });

    test('shouldRefresh returns false for non-recurring missions', () {
      expect(scheduler.shouldRefresh(_pendingMission), isFalse);
    });

    test('shouldRefresh returns false for not-yet-due missions', () {
      final notDue = _recurringMission.copyWith(
        completedDate: DateTime.now(),
      );
      expect(scheduler.shouldRefresh(notDue), isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // MissionRepository
  // ═════════════════════════════════════════════════════════════════

  group('MissionRepository', () {
    late MissionRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = MissionRepository();
    });

    test('loadMissions returns empty list initially', () async {
      final missions = await repository.loadMissions();
      expect(missions, isEmpty);
    });

    test('saveMissions and loadMissions round-trip', () async {
      await repository.saveMissions([_pendingMission, _completedMission]);
      final loaded = await repository.loadMissions();
      expect(loaded.length, 2);
      expect(loaded[0].id, 'test-1');
      expect(loaded[1].id, 'test-2');
    });

    test('updateMission adds new mission if not found', () async {
      await repository.updateMission(_pendingMission);
      final loaded = await repository.loadMissions();
      expect(loaded.length, 1);
      expect(loaded[0].id, 'test-1');
    });

    test('updateMission updates existing mission', () async {
      await repository.saveMissions([_pendingMission]);
      await repository.updateMission(
        _pendingMission.copyWith(title: 'Updated'),
      );
      final loaded = await repository.loadMissions();
      expect(loaded[0].title, 'Updated');
    });

    test('deleteMission removes mission', () async {
      await repository.saveMissions([_pendingMission, _completedMission]);
      await repository.deleteMission('test-1');
      final loaded = await repository.loadMissions();
      expect(loaded.length, 1);
      expect(loaded[0].id, 'test-2');
    });

    test('archiveToHistory and loadHistory paginate results', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await repository.archiveToHistory([
        _completedMission.copyWith(
          completedDate: DateTime.now(),
        ),
      ]);
      // Pending missions are filtered out of history
      await repository.archiveToHistory([
        _pendingMission.copyWith(
          completedDate: yesterday,
          status: MissionStatus.completed,
        ),
      ]);
      final history = await repository.loadHistory(limit: 10);
      expect(history, isNotEmpty);
    });

    test('cacheGeneratedMissions stores separately', () async {
      await repository.cacheGeneratedMissions([_pendingMission]);
      final cached = await repository.loadCachedMissions();
      expect(cached, isNotNull);
      expect(cached!.length, 1);
      expect(cached[0].id, 'test-1');
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // MissionService (backward-compatible facade)
  // ═════════════════════════════════════════════════════════════════

  group('MissionService (facade)', () {
    test('buildProgress returns valid progress from seeded missions', () {
      final service = MissionService(repository: const SampleRepository());
      final progress = service.buildProgress();

      expect(progress.dailyMissions, isNotEmpty);
      expect(progress.weeklyMissions, isNotEmpty);
      expect(progress.completedCount, 2);
      expect(progress.pendingCount, 4);
      expect(progress.completionPercentage, closeTo(2 / 6, 0.001));
      expect(progress.streak, 2);
    });

    test('buildStatistics returns valid statistics', () {
      final service = MissionService(repository: const SampleRepository());
      final stats = service.buildStatistics();

      expect(stats.totalMissions, 6);
      expect(stats.completedCount, 2);
    });

    test('featuredMission returns first active mission', () {
      final service = MissionService(repository: const SampleRepository());
      final featured = service.featuredMission;

      expect(featured, isNotNull);
      expect(featured.title, isNotEmpty);
    });

    test('dailyMissions returns seeded daily missions', () {
      final service = MissionService(repository: const SampleRepository());
      expect(service.dailyMissions.length, 3);
    });

    test('weeklyMissions returns seeded weekly missions', () {
      final service = MissionService(repository: const SampleRepository());
      expect(service.weeklyMissions.length, 3);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // Widget Integration Smoke Test
  // ═════════════════════════════════════════════════════════════════

  group('MissionCenterScreen widget', () {
    testWidgets('renders with MissionService facade without error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final service = MissionService(
                  repository: const SampleRepository(),
                );
                final progress = service.buildProgress();
                return Text(
                  progress.summary,
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('missions complete'), findsOneWidget);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // Mission Enums
  // ═════════════════════════════════════════════════════════════════

  group('Mission enums', () {
    test('MissionCategory.fromString parses valid values', () {
      expect(MissionCategory.fromString('learning'), MissionCategory.learning);
      expect(MissionCategory.fromString('Learning'), MissionCategory.learning);
    });

    test('MissionCategory.fromString defaults to custom for unknown', () {
      expect(
        MissionCategory.fromString('unknown'),
        MissionCategory.custom,
      );
    });

    test('MissionPriority.fromWeight returns correct priority', () {
      expect(MissionPriority.fromWeight(4), MissionPriority.critical);
      expect(MissionPriority.fromWeight(3), MissionPriority.high);
      expect(MissionPriority.fromWeight(2), MissionPriority.medium);
      expect(MissionPriority.fromWeight(1), MissionPriority.low);
    });

    test('MissionDifficulty.xpMultiplier scales correctly', () {
      expect(MissionDifficulty.beginner.xpMultiplier, 1.0);
      expect(MissionDifficulty.easy.xpMultiplier, 1.5);
      expect(MissionDifficulty.medium.xpMultiplier, 2.0);
      expect(MissionDifficulty.hard.xpMultiplier, 3.0);
      expect(MissionDifficulty.expert.xpMultiplier, 4.0);
    });

    test('MissionStatus enum has all required values', () {
      expect(MissionStatus.values.length, 6);
      expect(MissionStatus.values, contains(MissionStatus.pending));
      expect(MissionStatus.values, contains(MissionStatus.inProgress));
      expect(MissionStatus.values, contains(MissionStatus.completed));
      expect(MissionStatus.values, contains(MissionStatus.skipped));
      expect(MissionStatus.values, contains(MissionStatus.blocked));
      expect(MissionStatus.values, contains(MissionStatus.available));
    });
  });
}

// ── Test Helper ──────────────────────────────────────────────────────────

MissionEngine _createTestEngine(KnowledgeDNAService knowledgeDna) {
  return MissionEngine(
    generator: MissionGenerator(
      knowledgeDnaService: knowledgeDna,
      portfolioService: PortfolioService(
        repository: const SampleRepository(),
      ),
      resumeService: ResumeService(
        repository: const SampleRepository(),
      ),
      interviewService: InterviewService(
        repository: const SampleRepository(),
      ),
      opportunityService: OpportunityService(
        repository: const SampleRepository(),
      ),
      recommendationService: RecommendationService(
        repository: const SampleRepository(),
      ),
    ),
    prioritizer: MissionPrioritizer(),
    scheduler: MissionScheduler(),
  );
}
