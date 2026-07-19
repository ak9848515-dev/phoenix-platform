import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/career/engine/career_engine.dart';
import 'package:phoenix_platform/features/career/engine/career_snapshot.dart';
import 'package:phoenix_platform/features/career/repository/career_repository_interface.dart';
import 'package:phoenix_platform/features/career/services/career_service.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/growth_index/repository/growth_repository_interface.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/repository/identity_repository_interface.dart';
import 'package:phoenix_platform/features/opportunity/intelligence/engine/opportunity_intelligence_engine.dart';
import 'package:phoenix_platform/features/opportunity/intelligence/models/opportunity_application.dart';
import 'package:phoenix_platform/features/opportunity/intelligence/models/opportunity_application_status.dart';
import 'package:phoenix_platform/features/opportunity/services/opportunity_service.dart';
import 'package:phoenix_platform/features/portfolio/engine/portfolio_engine.dart';
import 'package:phoenix_platform/features/portfolio/repository/portfolio_repository_interface.dart';
import 'package:phoenix_platform/features/portfolio/services/portfolio_service.dart';
import 'package:phoenix_platform/features/user_state/engine/user_state_engine.dart';
import 'package:phoenix_platform/features/user_state/repository/user_state_repository.dart';
import 'package:phoenix_platform/features/user_state/services/user_state_service.dart';
import 'package:phoenix_platform/features/resume_intelligence/engine/resume_intelligence_engine.dart';

/// Tests for OpportunityIntelligenceEngine.
void main() {
  group('OpportunityIntelligenceEngine', () {
    late OpportunityIntelligenceEngine engine;

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

    test('snapshot has opportunities after init', () async {
      await engine.init();
      final snap = engine.snapshot!;
      expect(snap.opportunities, isNotEmpty);
      expect(snap.hasData, isTrue);
    });

    test('snapshot has analytics after init', () async {
      await engine.init();
      expect(engine.snapshot!.analytics.totalOpportunities, greaterThan(0));
    });

    test('snapshot has matches after init', () async {
      await engine.init();
      expect(engine.snapshot!.matches, isNotEmpty);
    });

    test('topOpportunity is set for highest match', () async {
      await engine.init();
      expect(engine.snapshot!.topOpportunity, isNotNull);
      expect(engine.snapshot!.topMatch.matchScore, greaterThan(0));
    });

    test('applications are empty initially', () async {
      await engine.init();
      expect(engine.applications, isEmpty);
    });

    test('addApplication adds to list', () async {
      await engine.init();
      engine.addApplication(OpportunityApplication(
        id: 'app-1',
        opportunityId: 'opp-1',
        opportunityTitle: 'Test Role',
      ));
      expect(engine.applications.length, 1);
    });

    test('snapshot reflects applications after add', () async {
      await engine.init();
      engine.addApplication(OpportunityApplication(
        id: 'app-2',
        opportunityId: 'opp-2',
        opportunityTitle: 'Test Role',
      ));
      expect(engine.snapshot!.applications.length, 1);
    });

    test('updateApplicationStatus changes status', () async {
      await engine.init();
      engine.addApplication(OpportunityApplication(
        id: 'app-3',
        opportunityId: 'opp-3',
        opportunityTitle: 'Test Role',
      ));
      engine.updateApplicationStatus('app-3', ApplicationStatus.applied);
      final app = engine.applications.first;
      expect(app.status, ApplicationStatus.applied);
      expect(app.appliedAt, isNotNull);
    });

    test('updateApplicationStatus to interview sets interviewAt', () async {
      await engine.init();
      engine.addApplication(OpportunityApplication(
        id: 'app-4',
        opportunityId: 'opp-4',
        opportunityTitle: 'Test Role',
      ));
      engine.updateApplicationStatus('app-4', ApplicationStatus.interviewScheduled);
      final app = engine.applications.first;
      expect(app.status, ApplicationStatus.interviewScheduled);
      expect(app.interviewAt, isNotNull);
    });

    test('removeApplication removes from list', () async {
      await engine.init();
      engine.addApplication(OpportunityApplication(
        id: 'app-5',
        opportunityId: 'opp-5',
        opportunityTitle: 'Test Role',
      ));
      engine.removeApplication('app-5');
      expect(engine.applications, isEmpty);
    });

    test('snapshot has insight after init', () async {
      await engine.init();
      final insight = engine.snapshot!.insight;
      expect(insight.bestOpportunityTitle, isNotEmpty);
      expect(insight.preparationPlan, isNotEmpty);
    });

    test('snapshot has action items', () async {
      await engine.init();
      expect(engine.snapshot!.actionItems, isNotEmpty);
    });

    test('snapshot has companies', () async {
      await engine.init();
      expect(engine.snapshot!.companies, isNotEmpty);
    });

    test('active application count is correct', () async {
      await engine.init();
      engine.addApplication(OpportunityApplication(
        id: 'app-6',
        opportunityId: 'opp-6',
        opportunityTitle: 'Test Role',
        status: ApplicationStatus.applied,
      ));
      engine.addApplication(OpportunityApplication(
        id: 'app-7',
        opportunityId: 'opp-7',
        opportunityTitle: 'Test Role',
        status: ApplicationStatus.wishlist,
      ));
      expect(engine.snapshot!.activeApplicationCount, 1);
    });

    test('bestMatchScore is highest score', () async {
      await engine.init();
      final snap = engine.snapshot!;
      final highest = snap.opportunities
          .map((o) => o.matchScore)
          .reduce((a, b) => a > b ? a : b);
      expect(snap.bestMatchScore, highest);
    });

    test('overallReadiness is within valid range', () async {
      await engine.init();
      final r = engine.snapshot!.overallReadiness;
      expect(r, inInclusiveRange(0.0, 1.0));
    });
  });
}

/// Creates a minimal OpportunityIntelligenceEngine with mock dependencies.
OpportunityIntelligenceEngine _createMinimalEngine() {
  return OpportunityIntelligenceEngine(
    opportunityService: OpportunityService(),
    careerEngine: _MockCareerEngine(
      repository: _MockCareerRepo(),
      careerService: CareerService(),
    ),
    portfolioEngine: _MockPortfolioEngine(
      repository: _MockPortfolioRepo(),
      portfolioService: PortfolioService(),
    ),
    resumeEngine: _MockResumeEngine(),
    identityEngine: _MockIdentityEngine(),
    growthEngine: _MockGrowthEngine(),
  );
}

// ── Mock Repository Classes ────────────────────────────────────

class _MockCareerRepo implements CareerRepositoryInterface {
  @override
  Future<CareerSnapshot?> loadCachedSnapshot() async => null;
  @override
  Future<void> cacheSnapshot(CareerSnapshot snapshot) async {}
  @override
  Future<void> clear() async {}
}

class _MockPortfolioRepo implements PortfolioRepositoryInterface {
  @override
  Future<void> cacheSnapshot(_) async {}
  @override
  Future<Never?> loadCachedSnapshot() async => null;
  @override
  Future<void> clear() async {}
}

class _MockIdentityRepo implements IdentityRepositoryInterface {
  @override
  Future<void> cacheSnapshot(_) async {}
  @override
  Future<Never?> loadCachedSnapshot() async => null;
  @override
  Future<void> clear() async {}
  @override
  Future<Never?> loadProfile() async => null;
  @override
  Future<void> saveProfile(_) async {}
}

class _MockGrowthRepo implements GrowthRepositoryInterface {
  @override
  Future<void> cacheSnapshot(_) async {}
  @override
  Future<Never?> loadCachedSnapshot() async => null;
  @override
  Future<void> clear() async {}
}

// ── Mock Engine Classes ────────────────────────────────────────

class _MockCareerEngine extends CareerEngine {
  _MockCareerEngine({
    required super.repository,
    required super.careerService,
  });

  @override
  CareerSnapshot? get snapshot => const CareerSnapshot(
    careerScore: 0.5,
    interviewReadiness: 0.4,
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

class _MockPortfolioEngine extends PortfolioEngine {
  _MockPortfolioEngine({
    required super.repository,
    required super.portfolioService,
  });

  @override
  bool get isInitialized => true;
  @override
  Future<void> init() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> reset() async {}
}

class _MockIdentityEngine extends IdentityEngine {
  _MockIdentityEngine() : super(
    repository: _MockIdentityRepo(),
    userStateService: _createUserService(),
  );

  @override
  bool get isInitialized => true;
  @override
  Future<void> init() async {}
}

class _MockGrowthEngine extends GrowthIndexEngine {
  _MockGrowthEngine() : super(
    repository: _MockGrowthRepo(),
    userStateService: _createUserService(),
  );

  @override
  bool get isInitialized => true;
  @override
  Future<void> init() async {}
}

class _MockResumeEngine extends ChangeNotifier implements ResumeIntelligenceEngine {
  @override
  bool get isInitialized => true;
  @override
  void noSuchMethod(Invocation invocation) {}
}

/// Creates a real minimal UserStateService (same pattern as PHX-075 engine tests).
UserStateService _createUserService() {
  final repo = UserStateRepository();
  final engine = UserStateEngine(repository: repo);
  return UserStateService(engine: engine);
}
