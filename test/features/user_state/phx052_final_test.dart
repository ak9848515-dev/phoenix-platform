import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';
import 'package:phoenix_platform/features/identity/models/identity.dart';
import 'package:phoenix_platform/features/mission_engine/mission_engine.dart' as mission;
import 'package:phoenix_platform/features/mission_engine/models/mission_status.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_priority.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_difficulty.dart';
import 'package:phoenix_platform/features/mission_engine/repository/mission_repository.dart';
import 'package:phoenix_platform/features/mission_engine/engine/mission_engine.dart' as engine;
import 'package:phoenix_platform/features/mission_engine/engine/mission_generator.dart';
import 'package:phoenix_platform/features/mission_engine/engine/mission_prioritizer.dart';
import 'package:phoenix_platform/features/mission_engine/engine/mission_scheduler.dart';
import 'package:phoenix_platform/features/mission_engine/services/mission_service.dart' as mission_svc;
import 'package:phoenix_platform/features/progress_engine/progress_service.dart';
import 'package:phoenix_platform/features/knowledge_dna/knowledge_dna_service.dart';
import 'package:phoenix_platform/features/portfolio/services/portfolio_service.dart';
import 'package:phoenix_platform/features/resume/services/resume_service.dart';
import 'package:phoenix_platform/features/interview/services/interview_service.dart';
import 'package:phoenix_platform/features/opportunity/services/opportunity_service.dart';
import 'package:phoenix_platform/features/recommendation/services/recommendation_service.dart';
import 'package:phoenix_platform/core/sample_repository.dart';
import 'package:phoenix_platform/core/repository.dart';
import 'package:phoenix_platform/models/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late UserStateRepository userStateRepository;
  late UserStateEngine userStateEngine;
  late UserStateService userStateService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    userStateRepository = UserStateRepository();
    userStateEngine = UserStateEngine(repository: userStateRepository);
    userStateService = UserStateService(engine: userStateEngine);
    await userStateService.init();
  });

  // ═════════════════════════════════════════════════════════════════
  // 1. Migration Tests
  // ═════════════════════════════════════════════════════════════════

  group('Migration', () {
    test('engine migrates from version 0 to current version', () async {
      await userStateRepository.saveState(const UserState(
        version: 0,
        totalXp: 100,
        level: 2,
      ));

      final freshEngine = UserStateEngine(repository: userStateRepository);
      await freshEngine.load();

      expect(freshEngine.currentState.version, userStateVersion);
      expect(freshEngine.currentState.totalXp, 100);
      expect(freshEngine.currentState.level, 2);
    });

    test('backward compatibility: loads state without aiContext', () async {
      final oldMap = <String, dynamic>{
        'version': 1,
        'totalXp': 500,
        'level': 5,
        'missions': <dynamic>[],
        'opportunities': <dynamic>[],
        'achievements': <dynamic>[],
        'settings': const UserSettings().toMap(),
      };
      await userStateRepository.saveState(
        UserState.fromMap(oldMap),
      );

      final freshEngine = UserStateEngine(repository: userStateRepository);
      await freshEngine.load();

      expect(freshEngine.currentState.totalXp, 500);
      expect(freshEngine.currentState.aiContext, isNull);
      expect(freshEngine.currentState.version, userStateVersion);
    });

    test('invalid state recovery returns clean default', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phx_user_state', 'garbage data');

      final freshEngine = UserStateEngine(repository: userStateRepository);
      final loaded = await freshEngine.load();

      expect(loaded.totalXp, 0);
      expect(loaded.level, 1);
      expect(freshEngine.isLoaded, isTrue);
    });

    test('persisted state survives engine recreate round-trip', () async {
      await userStateService.setIdentity(Identity(
        id: 'dev', title: 'Flutter Engineer', description: 'desc',
        iconName: 'code', category: 'Tech', currentLevel: 1,
        targetLevel: 5, estimatedDuration: 100,
        requiredSkills: <String>[], roadmap: <String>[],
        status: IdentityStatus.active,
      ));
      await userStateService.addXp(1500);

      final freshEngine = UserStateEngine(repository: userStateRepository);
      await freshEngine.load();

      expect(freshEngine.currentState.totalXp, 1500);
      expect(freshEngine.currentState.identity?.title, 'Flutter Engineer');
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 2. Integration Tests — Mission → UserState
  // ═════════════════════════════════════════════════════════════════

  group('Integration: Mission Engine → UserState', () {
    test('MissionService.completeMission updates UserState XP', () async {
      final repository = const _TestRepository();
      final missionRepo = MissionRepository();
      final eng = _createMissionEngine(repository);
      final prioritizer = MissionPrioritizer();
      final scheduler = MissionScheduler();
      // Do NOT pass userStateService to ProgressService to avoid double-add.
      // The clean MissionService handles UserState updates directly.
      final progressService = ProgressService(repository: repository);
      final missionService = mission_svc.MissionService(
        engine: eng,
        repository: missionRepo,
        prioritizer: prioritizer,
        scheduler: scheduler,
        progressService: progressService,
        userStateService: userStateService,
        initialMissions: _sampleMissions(),
      );

      final missions = missionService.getActiveMissions();
      expect(missions, isNotEmpty);

      final xpBefore = userStateService.totalXp;

      await missionService.completeMission(missions.first.id);

      // UserState XP should have increased
      expect(userStateService.totalXp, greaterThan(xpBefore));
      expect(userStateService.level, greaterThanOrEqualTo(1));
      expect(userStateService.currentState.lastActivityAt, isNotNull);
    });

    test('MissionService.completeMission updates UserState missions list', () async {
      final repository = const _TestRepository();
      final missionRepo = MissionRepository();
      final eng = _createMissionEngine(repository);
      final prioritizer = MissionPrioritizer();
      final scheduler = MissionScheduler();
      final progressService = ProgressService(repository: repository);
      final missionService = mission_svc.MissionService(
        engine: eng,
        repository: missionRepo,
        prioritizer: prioritizer,
        scheduler: scheduler,
        progressService: progressService,
        userStateService: userStateService,
        initialMissions: _sampleMissions(),
      );

      final missions = missionService.getActiveMissions();
      await missionService.completeMission(missions.first.id);

      final userMissions = userStateService.missions;
      expect(userMissions, isNotEmpty);
      expect(userMissions.any((m) => m.isCompleted), isTrue);
    });

    test('MissionService.skipMission updates UserState missions list', () async {
      final repository = const _TestRepository();
      final missionRepo = MissionRepository();
      final eng = _createMissionEngine(repository);
      final prioritizer = MissionPrioritizer();
      final scheduler = MissionScheduler();
      final progressService = ProgressService(repository: repository);
      final missionService = mission_svc.MissionService(
        engine: eng,
        repository: missionRepo,
        prioritizer: prioritizer,
        scheduler: scheduler,
        progressService: progressService,
        userStateService: userStateService,
        initialMissions: _sampleMissions(),
      );

      final missions = missionService.getActiveMissions();
      await missionService.skipMission(missions.first.id);

      final userMissions = userStateService.missions;
      expect(userMissions, isNotEmpty);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 3. Integration Tests — Progress → UserState
  // ═════════════════════════════════════════════════════════════════

  group('Integration: Progress Engine → UserState', () {
    test('ProgressService.addXp updates UserState XP and level', () async {
      final progressService = ProgressService(
        repository: const _TestRepository(),
        userStateService: userStateService,
      );

      expect(userStateService.totalXp, 0);
      expect(userStateService.level, 1);

      progressService.addXp(100);

      expect(userStateService.totalXp, 100);
      expect(userStateService.level, greaterThanOrEqualTo(1));
    });

    test('ProgressService.addXp records last activity', () async {
      final progressService = ProgressService(
        repository: const _TestRepository(),
        userStateService: userStateService,
      );

      expect(userStateService.currentState.lastActivityAt, isNull);

      progressService.addXp(50);

      expect(userStateService.currentState.lastActivityAt, isNotNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 4. Integration Tests — UserState → Screen Data Flow
  // ═════════════════════════════════════════════════════════════════

  group('Integration: UserState → Screen Data', () {
    test('UserState provides identity data for screens', () async {
      final identity = Identity(
        id: 'test', title: 'Flutter Developer', description: 'desc',
        iconName: 'code', category: 'Tech', currentLevel: 1,
        targetLevel: 5, estimatedDuration: 100,
        requiredSkills: <String>[], roadmap: <String>[],
        status: IdentityStatus.active,
      );
      await userStateService.setIdentity(identity);

      expect(userStateService.identity?.title, 'Flutter Developer');
      expect(userStateService.hasIdentity, isTrue);
    });

    test('UserState provides journey data for screens', () async {
      await userStateService.update((s) => s.copyWith(
        currentFocus: 'Master Flutter',
      ));

      expect(userStateService.currentState.currentFocus, 'Master Flutter');
    });

    test('UserState provides aggregated state for dashboard', () async {
      await userStateService.addXp(500);
      await userStateService.update((s) => s.copyWith(
        currentFocus: 'Build Portfolio',
      ));

      expect(userStateService.totalXp, 500);
      expect(userStateService.currentState.currentFocus, 'Build Portfolio');
      expect(userStateService.isLoaded, isTrue);
    });

    test('UserState change notifies registered listeners', () async {
      var notified = false;
      final dispose = userStateService.addListener(() => notified = true);

      await userStateService.addXp(100);
      expect(notified, isTrue);

      notified = false;
      dispose();
      await userStateService.addXp(50);
      expect(notified, isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // 5. Widget Smoke Tests — UserState → Widget Rebuild
  // ═════════════════════════════════════════════════════════════════

  group('Widget smoke: UserState change triggers rebuild', () {
    testWidgets('StatefulWidget rebuilds when UserState changes via pumpAndSettle',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _UserStateTestWidget(
            userStateService: userStateService,
          ),
        ),
      );

      // Initial state: no identity, 0 XP
      expect(find.textContaining('Identity:'), findsOneWidget);
      expect(find.textContaining('XP: 0'), findsOneWidget);

      // Update identity — the listener calls setState, pumpAndSettle rebuilds
      await tester.runAsync(() async {
        await userStateService.setIdentity(Identity(
          id: 'dev', title: 'Flutter Ninja', description: 'desc',
          iconName: 'code', category: 'Tech', currentLevel: 1,
          targetLevel: 5, estimatedDuration: 100,
          requiredSkills: <String>[], roadmap: <String>[],
          status: IdentityStatus.active,
        ));
      });
      await tester.pump();
      await tester.pump();

      // Widget rebuilt with new identity
      expect(find.textContaining('Flutter Ninja'), findsOneWidget);

      // Update XP
      await tester.runAsync(() async {
        await userStateService.addXp(300);
      });
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('XP: 300'), findsOneWidget);
      expect(userStateService.level, 2);
    });

    testWidgets('UserState listener fires in widget tree',
        (tester) async {
      var listenerFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  userStateService.addListener(() {
                    listenerFired = true;
                  });
                },
                child: const Text('Register Listener'),
              );
            },
          ),
        ),
      );

      // Register listener via button tap
      await tester.tap(find.text('Register Listener'));
      await tester.pump();

      // Trigger state change
      await tester.runAsync(() async {
        await userStateService.setSettings(
          const UserSettings(themeMode: 'dark'),
        );
      });
      await tester.pump();

      expect(listenerFired, isTrue);
    });
  });
}

/// A [StatefulWidget] that listens to [UserStateService] changes and
/// rebuilds to reflect the latest state.
///
/// Simulates how production screens consume UserStateService with
/// a listener wired to setState. Properly disposes the listener.
class _UserStateTestWidget extends StatefulWidget {
  const _UserStateTestWidget({required this.userStateService});

  final UserStateService userStateService;

  @override
  State<_UserStateTestWidget> createState() => _UserStateTestWidgetState();
}

class _UserStateTestWidgetState extends State<_UserStateTestWidget> {
  VoidCallback? _disposeListener;

  @override
  void initState() {
    super.initState();
    _disposeListener = widget.userStateService.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _disposeListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = widget.userStateService;
    final name = svc.identity?.title ?? 'none';
    return Column(
      children: [
        Text('Identity: $name'),
        Text('XP: ${svc.totalXp}'),
      ],
    );
  }

}

// ═════════════════════════════════════════════════════════════════
// Test Helpers
// ═════════════════════════════════════════════════════════════════

class _TestRepository extends SampleRepository {
  const _TestRepository();
}

engine.MissionEngine _createMissionEngine(Repository repository) {
  final generator = MissionGenerator(
    knowledgeDnaService: KnowledgeDNAService(repository: repository),
    portfolioService: PortfolioService(repository: repository),
    resumeService: ResumeService(repository: repository),
    interviewService: InterviewService(repository: repository),
    opportunityService: OpportunityService(repository: repository),
    recommendationService: RecommendationService(repository: repository),
  );
  return engine.MissionEngine(
    generator: generator,
    prioritizer: MissionPrioritizer(),
    scheduler: MissionScheduler(),
  );
}

List<mission.Mission> _sampleMissions() {
  return [
    mission.Mission(
      id: 'm1',
      title: 'Complete Dart Basics',
      description: 'Master Dart fundamentals',
      category: MissionCategory.learning,
      priority: MissionPriority.high,
      difficulty: MissionDifficulty.beginner,
      estimatedDuration: 30,
      rewardXP: 100,
      progress: 0.0,
      status: MissionStatus.pending,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdDate: DateTime.now(),
      recurring: false,
    ),
    mission.Mission(
      id: 'm2',
      title: 'Build First App',
      description: 'Create a Flutter app',
      category: MissionCategory.build,
      priority: MissionPriority.medium,
      difficulty: MissionDifficulty.medium,
      estimatedDuration: 120,
      rewardXP: 250,
      progress: 0.0,
      status: MissionStatus.pending,
      dueDate: DateTime.now().add(const Duration(days: 14)),
      createdDate: DateTime.now(),
      recurring: false,
    ),
  ];
}
