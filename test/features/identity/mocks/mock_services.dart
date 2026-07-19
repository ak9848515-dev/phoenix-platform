import 'package:phoenix_platform/features/identity/models/identity.dart';
import 'package:phoenix_platform/features/journey/models/journey.dart';
import 'package:phoenix_platform/features/journey/models/journey_stage.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_difficulty.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_priority.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_status.dart';
import 'package:phoenix_platform/features/mission_engine/mission_engine.dart' as mission_engine;
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';
import 'package:phoenix_platform/models/user_settings.dart';

/// Provides controlled user state data for IdentityEngine tests.
///
/// Wraps a [UserStateService] backed by a mock engine that returns
/// the state built from configurable properties.
class MockUserStateProvider {
  int totalXp = 1000;
  int level = 1;
  int completedMissions = 0;
  int completedLessons = 0;
  int missionCount = 0;
  int lessonCount = 0;

  late final UserStateService userStateService;

  MockUserStateProvider() {
    userStateService = _TestUserStateService(this);
  }

  /// Builds a [UserState] with the current mock values.
  UserState buildState() {
    final identity = Identity(
      id: 'test-engineer',
      title: 'Software Engineer',
      description: 'Test description',
      iconName: 'code_outlined',
      category: 'Technology',
      currentLevel: 1,
      targetLevel: 8,
      estimatedDuration: 730,
      requiredSkills: ['Dart', 'Flutter'],
      roadmap: ['Learn Dart', 'Build apps'],
      status: IdentityStatus.active,
    );

    final journey = Journey(
      id: 'test-journey',
      identityId: 'test-engineer',
      title: 'Engineering Journey',
      description: 'Become a software engineer',
      stages: [
        JourneyStage(
          id: 'foundations',
          title: 'Foundations',
          description: 'Learn basics',
          order: 0,
          completion: 0.0,
        ),
        JourneyStage(
          id: 'intermediate',
          title: 'Intermediate',
          description: 'Build skills',
          order: 1,
          completion: 0.0,
        ),
      ],
      currentStage: 0,
      completion: 0.25,
    );

    final missions = <mission_engine.Mission>[];
    for (var i = 0; i < missionCount; i++) {
      final isCompleted = i < completedMissions;
      missions.add(mission_engine.Mission(
        id: 'mission-$i',
        title: 'Mission $i',
        description: 'Description $i',
        category: MissionCategory.learning,
        priority: MissionPriority.medium,
        difficulty: MissionDifficulty.beginner,
        estimatedDuration: 30,
        rewardXP: 50,
        status: isCompleted ? MissionStatus.completed : MissionStatus.pending,
        progress: isCompleted ? 1.0 : 0.0,
        completedDate: isCompleted ? DateTime(2025, 1, 1) : null,
      ));
    }

    return UserState(
      identity: identity,
      journey: journey,
      currentJourneyStage: journey.stages[0],
      missions: missions,
      totalXp: totalXp,
      level: level,
      settings: const UserSettings(onboardingComplete: true),
    );
  }
}

/// A minimal [UserStateService] subclass that returns mock data.
class _TestUserStateService extends UserStateService {
  _TestUserStateService(this._provider)
      : super(engine: _MockUserStateEngine());

  final MockUserStateProvider _provider;

  @override
  UserState get currentState => _provider.buildState();
}

/// A mock [UserStateEngine] that does nothing.
class _MockUserStateEngine extends UserStateEngine {
  _MockUserStateEngine() : super(repository: _MockUserStateRepo());

  @override
  UserState get currentState => const UserState();

  @override
  bool get isLoaded => true;
}

/// A mock repository that returns null.
class _MockUserStateRepo extends UserStateRepository {
  @override
  Future<UserState?> loadState() async => null;
}
