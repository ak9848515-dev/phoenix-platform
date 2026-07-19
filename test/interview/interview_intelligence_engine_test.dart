import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/repository.dart';
import 'package:phoenix_platform/features/career/engine/career_engine.dart';
import 'package:phoenix_platform/features/career/engine/career_snapshot.dart';
import 'package:phoenix_platform/features/career/repository/career_repository_interface.dart';
import 'package:phoenix_platform/features/career/services/career_service.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_dimension.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_metrics.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/growth_index/repository/growth_repository_interface.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/models/identity_profile.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/identity/repository/identity_repository_interface.dart';
import 'package:phoenix_platform/features/interview/intelligence/engine/interview_intelligence_engine.dart';
import 'package:phoenix_platform/features/interview/intelligence/models/interview_enums.dart';
import 'package:phoenix_platform/features/interview/services/interview_service.dart';
import 'package:phoenix_platform/features/portfolio/engine/portfolio_engine.dart';
import 'package:phoenix_platform/features/portfolio/engine/portfolio_snapshot.dart';
import 'package:phoenix_platform/features/portfolio/repository/portfolio_repository_interface.dart';
import 'package:phoenix_platform/features/portfolio/services/portfolio_service.dart';
import 'package:phoenix_platform/features/resume_intelligence/engine/resume_intelligence_engine.dart';
import 'package:phoenix_platform/features/personal_knowledge/engine/knowledge_engine.dart';
import 'package:phoenix_platform/features/personal_knowledge/services/knowledge_service.dart';
import 'package:phoenix_platform/features/progress_engine/achievement_engine.dart';
import 'package:phoenix_platform/features/progress_engine/progress_service.dart';
import 'package:phoenix_platform/features/progress_engine/repository/achievement_repository_interface.dart';
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';
import 'package:phoenix_platform/features/ai/services/ai_mentor_service.dart';

/// Tests for InterviewIntelligenceEngine.
void main() {
  group('InterviewIntelligenceEngine', () {
    late InterviewIntelligenceEngine engine;

    setUp(() {
      engine = _createMinimalEngine();
    });

    test('init sets isInitialized to true', () async {
      await engine.init();
      expect(engine.isInitialized, isTrue);
    });

    test('snapshot is null before init', () {
      expect(engine.snapshot, isNull);
    });

    test('snapshot is not null after init', () async {
      await engine.init();
      expect(engine.snapshot, isNotNull);
    });

    test('createSession returns valid session', () async {
      await engine.init();
      final session = engine.createSession();
      expect(session.id, isNotEmpty);
      expect(session.title, isNotEmpty);
      expect(session.questions, isNotEmpty);
      expect(session.status, SessionStatus.inProgress);
    });

    test('createSession generates questions', () async {
      await engine.init();
      final session = engine.createSession();
      expect(session.questions.length, greaterThan(0));
    });

    test('createSession with custom title and difficulty', () async {
      await engine.init();
      final session = engine.createSession(
        title: 'Custom',
        difficulty: InterviewDifficulty.hard,
        durationMinutes: 30,
      );
      expect(session.title, 'Custom');
      expect(session.difficulty, InterviewDifficulty.hard);
      expect(session.durationMinutes, 30);
    });

    test('recordAnswer updates question', () async {
      await engine.init();
      final session = engine.createSession();
      final q = session.questions.first;
      final updated = engine.recordAnswer(
        sessionId: session.id,
        questionId: q.id,
        answer: 'Structured answer.',
        timeSpentSeconds: 30,
        score: 0.8,
      );
      expect(updated, isNotNull);
      expect(updated!.answeredCount, greaterThan(0));
    });

    test('recordAnswer with skipped question', () async {
      await engine.init();
      final session = engine.createSession();
      final q = session.questions.first;
      final updated = engine.recordAnswer(
        sessionId: session.id,
        questionId: q.id,
        skipped: true,
      );
      expect(updated, isNotNull);
      expect(updated!.skippedCount, greaterThan(0));
    });

    test('recordAnswer returns null for invalid session', () async {
      await engine.init();
      final result = engine.recordAnswer(
        sessionId: 'invalid',
        questionId: 'invalid',
        answer: 'test',
      );
      expect(result, isNull);
    });

    test('completeSession generates feedback', () async {
      await engine.init();
      final session = engine.createSession();
      for (final q in session.questions) {
        engine.recordAnswer(
          sessionId: session.id,
          questionId: q.id,
          answer: 'Strong structured answer.',
          timeSpentSeconds: 45,
          score: 0.8,
        );
      }
      final feedback = engine.completeSession(session.id);
      expect(feedback.sessionId, session.id);
      expect(feedback.strengths, isNotEmpty);
      expect(feedback.improvementPlan, isNotEmpty);
      expect(feedback.summary, isNotEmpty);
    });

    test('completeSession with no answers adds weak areas', () async {
      await engine.init();
      final session = engine.createSession();
      final feedback = engine.completeSession(session.id);
      expect(feedback.sessionId, session.id);
      expect(feedback.weakAreas, isNotEmpty);
    });

    test('snapshot has data after completion', () async {
      await engine.init();
      final session = engine.createSession();
      engine.completeSession(session.id);
      expect(engine.snapshot!.hasData, isTrue);
    });

    test('snapshot has recent sessions', () async {
      await engine.init();
      final session = engine.createSession();
      engine.completeSession(session.id);
      expect(engine.snapshot!.recentSessions, isNotEmpty);
    });

    test('progress tracks sessions', () async {
      await engine.init();
      final s1 = engine.createSession();
      final s2 = engine.createSession();
      engine.completeSession(s1.id);
      engine.completeSession(s2.id);
      expect(engine.snapshot!.progress.completedSessions, 2);
      expect(engine.snapshot!.progress.totalSessions, 2);
    });

    test('session history accessible', () async {
      await engine.init();
      engine.createSession();
      engine.createSession();
      expect(engine.sessionHistory.length, 2);
    });

    test('recommendations generated after session', () async {
      await engine.init();
      final session = engine.createSession();
      engine.completeSession(session.id);
      expect(engine.snapshot!.recommendations, isNotEmpty);
    });

    test('questions contain technical and behavioral categories', () async {
      await engine.init();
      final session = engine.createSession();
      final categories = session.questions.map((q) => q.category).toSet();
      expect(categories, contains(InterviewQuestionCategory.technical));
      expect(categories, contains(InterviewQuestionCategory.behavioral));
    });

    test('readiness scores in valid range', () async {
      await engine.init();
      final r = engine.snapshot!.readiness;
      expect(r.knowledgeScore, inInclusiveRange(0.0, 1.0));
      expect(r.projectScore, inInclusiveRange(0.0, 1.0));
      expect(r.confidenceScore, inInclusiveRange(0.0, 1.0));
    });
  });
}

// ── Helper: Minimal Engine Construction ─────────────────────────────

InterviewIntelligenceEngine _createMinimalEngine() {
  final userService = _createMinimalUserService();

  final careerEngine = _MockCareerEngine(
    repository: _MockCareerRepo(),
    careerService: CareerService(),
  );

  final identityEngine = _MockIdentityEngine(
    repository: _MockIdentityRepo(),
    userStateService: userService,
  );

  final growthEngine = _MockGrowthEngine(
    repository: _MockGrowthRepo(),
    userStateService: userService,
  );

  final portfolioEngine = _MockPortfolioEngine(
    repository: _MockPortfolioRepo(),
    portfolioService: PortfolioService(),
  );

  final resumeEngine = _createMinimalResumeEngine();

  return InterviewIntelligenceEngine(
    interviewService: InterviewService(),
    careerEngine: careerEngine,
    identityEngine: identityEngine,
    growthEngine: growthEngine,
    portfolioEngine: portfolioEngine,
    resumeEngine: resumeEngine,
  );
}

UserStateService _createMinimalUserService() {
  final repo = UserStateRepository();
  final engine = UserStateEngine(repository: repo);
  return UserStateService(engine: engine);
}

ResumeIntelligenceEngine _createMinimalResumeEngine() {
  final kService = KnowledgeService(
    userStateService: _createMinimalUserService(),
    aiMentorService: AIMentorService(repository: _MockRepo()),
  );
  return _MockResumeEngine(
    knowledgeEngine: KnowledgeEngine(knowledgeService: kService),
  );
}

// ── Mock Repository classes ─────────────────────────────────────────

class _MockCareerRepo implements CareerRepositoryInterface {
  @override
  Future<CareerSnapshot?> loadCachedSnapshot() async => null;
  @override
  Future<void> cacheSnapshot(CareerSnapshot snapshot) async {}
  @override
  Future<void> clear() async {}
}

class _MockIdentityRepo implements IdentityRepositoryInterface {
  @override
  Future<IdentityProfile?> loadProfile() async => null;
  @override
  Future<void> saveProfile(IdentityProfile profile) async {}
  @override
  Future<IdentitySnapshot?> loadCachedSnapshot() async => null;
  @override
  Future<void> cacheSnapshot(IdentitySnapshot snapshot) async {}
  @override
  Future<void> clear() async {}
}

class _MockGrowthRepo implements GrowthRepositoryInterface {
  @override
  Future<void> cacheSnapshot(GrowthSnapshot snapshot) async {}
  @override
  Future<GrowthSnapshot?> loadCachedSnapshot() async => null;
  @override
  Future<void> clear() async {}
}

class _MockPortfolioRepo implements PortfolioRepositoryInterface {
  @override
  Future<PortfolioSnapshot?> loadCachedSnapshot() async => null;
  @override
  Future<void> cacheSnapshot(PortfolioSnapshot snapshot) async {}
  @override
  Future<void> clear() async {}
}

class _MockRepo implements Repository {
  @override
  void noSuchMethod(Invocation invocation) {}
}

class _MockAchievementRepo implements AchievementRepositoryInterface {
  @override
  Future<void> clear() async {}
  @override
  Future<void> cacheSnapshot(_) async {}
  @override
  Future<Never?> loadCachedSnapshot() async => null;
}

// ── Mock Engine classes ─────────────────────────────────────────────

class _MockCareerEngine extends CareerEngine {
  _MockCareerEngine({
    required super.repository,
    required super.careerService,
  });

  @override
  CareerSnapshot? get snapshot => const CareerSnapshot(
    careerScore: 0.5,
    interviewReadiness: 0.4,
    strengths: ['Problem Solving'],
    skillGaps: ['Cloud Computing'],
    resumeProgress: 0.5,
    portfolioProgress: 0.3,
    estimatedWeeks: 12,
  );

  @override
  bool get isInitialized => true;
  @override
  Future<void> init() async {}
  @override
  Future<void> refresh() async {}
}

class _MockIdentityEngine extends IdentityEngine {
  _MockIdentityEngine({
    required super.repository,
    required super.userStateService,
  });

  @override
  IdentitySnapshot? get snapshot => IdentitySnapshot(
    profile: const IdentityProfile(
      id: 'test-id',
      title: 'Developer',
      description: 'Test developer',
      iconName: 'developer',
      category: 'engineering',
      currentLevel: 3,
      targetLevel: 5,
      careerGoal: 'Senior Developer',
      experienceLevel: 'Intermediate',
    ),
    currentIdentityTitle: 'Flutter Developer',
    targetIdentityTitle: 'Senior Developer',
    currentGoal: 'Become a senior engineer',
    experience: 'Intermediate',
    progress: 'Level 3',
    currentMissionTitle: '',
    currentLearningPathTitle: '',
    currentCareerPathTitle: '',
    growthIndex: 0.5,
    completionPercent: 40,
    lastUpdated: DateTime(2025, 1, 1),
  );

  @override
  bool get isInitialized => true;
  @override
  Future<void> init() async {}
}

class _MockGrowthEngine extends GrowthIndexEngine {
  _MockGrowthEngine({
    required super.repository,
    required super.userStateService,
  });

  @override
  GrowthSnapshot? get snapshot => GrowthSnapshot(
    overallScore: 0.6,
    knowledge: GrowthMetrics(
      dimension: GrowthDimension.knowledge, score: 0.6),
    skills: GrowthMetrics(
      dimension: GrowthDimension.skills, score: 0.5),
    projects: GrowthMetrics(
      dimension: GrowthDimension.projects, score: 0.5),
    career: GrowthMetrics(
      dimension: GrowthDimension.career, score: 0.5),
    habits: GrowthMetrics(
      dimension: GrowthDimension.habits, score: 0.7),
    interview: GrowthMetrics(
      dimension: GrowthDimension.interview, score: 0.3),
    mission: GrowthMetrics(
      dimension: GrowthDimension.mission, score: 0.4),
    portfolio: GrowthMetrics(
      dimension: GrowthDimension.portfolio, score: 0.4),
    learningConsistency: GrowthMetrics(
      dimension: GrowthDimension.learningConsistency, score: 0.5),
    currentLevel: 3,
    totalXp: 750,
    lastUpdated: DateTime(2025, 1, 1),
  );

  @override
  bool get isInitialized => true;
  @override
  Future<void> init() async {}
}

class _MockPortfolioEngine extends PortfolioEngine {
  _MockPortfolioEngine({
    required super.repository,
    required super.portfolioService,
  });

  @override
  PortfolioSnapshot? get snapshot => const PortfolioSnapshot(
    portfolioScore: 0.5,
    projectCount: 3,
    skillCount: 8,
    technologyCount: 5,
    achievementCount: 2,
    careerReadiness: 'Intermediate',
    strengthAreas: ['Mobile Development'],
    improvementAreas: ['Cloud'],
    technologies: ['Flutter', 'Dart'],
  );

  @override
  bool get isInitialized => true;
  @override
  Future<void> init() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> reset() async {}
}

class _MockResumeEngine extends ResumeIntelligenceEngine {
  _MockResumeEngine({
    required super.knowledgeEngine,
  }) : super(
    portfolioEngine: _createPortfolioEngine(),
    careerEngine: _createCareerEngine(),
    achievementEngine: _createAchievementEngine(),
  );

  @override
  bool get isInitialized => true;
  @override
  Future<void> init() async {}
  @override
  Future<void> refresh() async {}
}

PortfolioEngine _createPortfolioEngine() {
  return _MockPortfolioEngine(
    repository: _MockPortfolioRepo(),
    portfolioService: PortfolioService(),
  );
}

CareerEngine _createCareerEngine() {
  return _MockCareerEngine(
    repository: _MockCareerRepo(),
    careerService: CareerService(),
  );
}

AchievementEngine _createAchievementEngine() {
  return _MockAchievementEngine();
}

class _MockAchievementEngine extends AchievementEngine {
  _MockAchievementEngine() : super(
    repository: _MockAchievementRepo(),
    progressService: _MockProgressService(),
  );

  @override
  Future<void> init() async {}
}

class _MockProgressService extends ChangeNotifier implements ProgressService {
  @override
  void noSuchMethod(Invocation invocation) {}
}
