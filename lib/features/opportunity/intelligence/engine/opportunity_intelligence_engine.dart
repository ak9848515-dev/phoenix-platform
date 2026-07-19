import 'package:flutter/foundation.dart';

import '../../../../shared/infrastructure/cache/cache_service.dart';
import '../../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../../career/engine/career_engine.dart';
import '../../../career/engine/career_snapshot.dart';
import '../../../growth_index/engine/growth_index_engine.dart';
import '../../../identity/engine/identity_engine.dart';
import '../../../portfolio/engine/portfolio_engine.dart';
import '../../../resume_intelligence/engine/resume_intelligence_engine.dart';
import '../../models/opportunity.dart';
import '../../models/opportunity_gap.dart';
import '../../models/opportunity_match.dart';
import '../../models/opportunity_requirement.dart';
import '../../services/opportunity_service.dart';
import '../models/opportunity_analytics.dart';
import '../models/opportunity_application.dart';
import '../models/opportunity_application_status.dart';
import '../models/opportunity_company_profile.dart';
import '../models/opportunity_insight.dart';
import '../models/opportunity_intelligence_snapshot.dart';
import '../repository/opportunity_intelligence_repository_interface.dart';

/// Opportunity Intelligence Engine — PHX-076.
///
/// Intelligently identifies, scores, prioritizes and recommends career
/// opportunities based on the user's profile and readiness.
///
/// **Architecture:**
/// ```text
/// OpportunityService + CareerEngine + PortfolioEngine + ResumeEngine
///   + InterviewEngine + IdentityEngine + GrowthEngine
///   ↓
/// OpportunityIntelligenceEngine (ChangeNotifier)
///   ↓
/// OpportunityIntelligenceSnapshot
///   ↓
/// OpportunityScreen | Dashboard | NotificationEngine
/// ```
///
/// **Rules:**
/// - Fully deterministic — no AI, no randomness
/// - All scores are reproducible given the same inputs
/// - Widgets read [snapshot] only
class OpportunityIntelligenceEngine extends ChangeNotifier {
  OpportunityIntelligenceEngine({
    required this.opportunityService,
    required this.careerEngine,
    required this.portfolioEngine,
    required this.resumeEngine,
    required this.identityEngine,
    required this.growthEngine,
    this.repository,
    this._cacheService,
  })  : _logger = PhoenixLogger.shared;

  final OpportunityService opportunityService;
  final CareerEngine careerEngine;
  final PortfolioEngine portfolioEngine;
  final ResumeIntelligenceEngine resumeEngine;
  final IdentityEngine identityEngine;
  final GrowthIndexEngine growthEngine;
  final OpportunityIntelligenceRepositoryInterface? repository;
  final CacheService? _cacheService;
  final PhoenixLogger _logger;

  bool _isInitialized = false;
  OpportunityIntelligenceSnapshot? _cachedSnapshot;
  bool _isBuilding = false;

  // ── Runtime tracking ──────────────────────────────────────────────
  final List<OpportunityApplication> _applications = [];
  final List<OpportunityMatch> _matches = [];
  final List<OpportunityCompanyProfile> _companies = [];
  // ── Accessors ─────────────────────────────────────────────────────

  /// The current opportunity intelligence snapshot.
  OpportunityIntelligenceSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  /// All tracked applications.
  List<OpportunityApplication> get applications =>
      List.unmodifiable(_applications);

  /// All match analyses.
  List<OpportunityMatch> get matches => List.unmodifiable(_matches);

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine and builds the first snapshot.
  Future<void> init() async {
    // Load persisted data from repository
    if (repository != null) {
      try {
        final repo = repository!;
        _applications.addAll(await repo.loadApplications());
        _matches.addAll(await repo.loadMatches());
        _companies.addAll(await repo.loadCompanies());
      } catch (e) {
        _logger.warning('OpportunityIntelligenceEngine: load failed: $e',
            category: LogCategory.engine,
            source: 'OpportunityIntelligenceEngine');
      }
    }

    _buildSnapshot();
    _isInitialized = true;

    careerEngine.addListener(_onEngineChanged);
    portfolioEngine.addListener(_onEngineChanged);
    resumeEngine.addListener(_onEngineChanged);
    identityEngine.addListener(_onEngineChanged);
    growthEngine.addListener(_onEngineChanged);

    _logger.info('OpportunityIntelligenceEngine initialized',
        category: LogCategory.engine,
        source: 'OpportunityIntelligenceEngine');
    notifyListeners();
  }

  /// Refreshes the snapshot from current engine states.
  Future<void> refresh() async {
    _buildSnapshot();
    _cacheService?.cache('opportunity_intel:snapshot', _cachedSnapshot, CacheDomain.opportunity);
    _logger.debug('OpportunityIntelligenceEngine refreshed',
        category: LogCategory.engine,
        source: 'OpportunityIntelligenceEngine');
    notifyListeners();
  }

  @override
  void dispose() {
    careerEngine.removeListener(_onEngineChanged);
    portfolioEngine.removeListener(_onEngineChanged);
    resumeEngine.removeListener(_onEngineChanged);
    identityEngine.removeListener(_onEngineChanged);
    growthEngine.removeListener(_onEngineChanged);
    super.dispose();
  }

  void _onEngineChanged() {
    if (!_isInitialized || _isBuilding) return;
    _isBuilding = true;
    _buildSnapshot();
    _isBuilding = false;
    notifyListeners();
  }

  // ── Application Management ───────────────────────────────────────

  /// Adds a new application entry.
  void addApplication(OpportunityApplication application) {
    _applications.add(application);
    _persistApplications();
    _buildSnapshot();
    notifyListeners();
  }

  /// Updates an existing application's status.
  void updateApplicationStatus(String id, ApplicationStatus status) {
    final idx = _applications.indexWhere((a) => a.id == id);
    if (idx < 0) return;
    final now = DateTime.now();
    final current = _applications[idx];
    _applications[idx] = current.copyWith(
      status: status,
      appliedAt: status == ApplicationStatus.applied
          ? (current.appliedAt ?? now)
          : null,
      interviewAt: status == ApplicationStatus.interviewScheduled
          ? now
          : null,
      offerAt: status == ApplicationStatus.offerReceived ? now : null,
      rejectedAt: status == ApplicationStatus.rejected ? now : null,
      acceptedAt: status == ApplicationStatus.accepted ? now : null,
    );
    _persistApplications();
    _buildSnapshot();
    notifyListeners();
  }

  /// Removes an application.
  void removeApplication(String id) {
    _applications.removeWhere((a) => a.id == id);
    _persistApplications();
    _buildSnapshot();
    notifyListeners();
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  void _buildSnapshot() {
    final career = careerEngine.snapshot ?? const CareerSnapshot();

    // 1. Discover opportunities from service
    final serviceOpps = opportunityService.getRecommendedOpportunities();

    // 2. Match each opportunity using engine scoring
    final allOpportunities = _enrichOpportunities(serviceOpps, career);
    final allMatches = _computeMatches(allOpportunities, career);

    // 3. Company profiles
    final companies = _computeCompanyProfiles(allOpportunities);

    // 4. Analytics
    final analytics = _computeAnalytics(allOpportunities, career);

    // 5. AI Advisor insight
    final insight = _generateInsight(allOpportunities, analytics);

    // 6. Action items
    final actionItems = _generateActionItems(analytics, allOpportunities);

    // 7. Top match and opportunity
    final sorted = [...allOpportunities]..sort(
        (a, b) => b.matchScore.compareTo(a.matchScore));

    _cachedSnapshot = OpportunityIntelligenceSnapshot(
      opportunities: sorted,
      matches: allMatches,
      applications: List.from(_applications),
      companies: companies,
      insight: insight,
      analytics: analytics,
      topMatch: allMatches.isNotEmpty ? allMatches.first : const OpportunityMatch(opportunityId: ''),
      topOpportunity: sorted.isNotEmpty ? sorted.first : null,
      actionItems: actionItems,
      hasData: sorted.isNotEmpty || _applications.isNotEmpty,
      lastUpdated: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. OPPORTUNITY ENRICHMENT & SCORING
  // ═══════════════════════════════════════════════════════════════════

  List<Opportunity> _enrichOpportunities(
    List<Opportunity> opportunities,
    CareerSnapshot career,
  ) {
    return opportunities.map((opp) {
      // Recalculate match score with full engine context
      final enrichedScore = _computeOpportunityScore(opp, career);
      return Opportunity(
        id: opp.id,
        title: opp.title,
        type: opp.type,
        matchScore: enrichedScore,
        requiredSkills: opp.requiredSkills,
        matchedSkills: opp.matchedSkills,
        missingSkills: opp.missingSkills,
        estimatedReadiness: _computeReadiness(career),
        recommendedActions: opp.recommendedActions,
        estimatedTimeline: opp.estimatedTimeline,
        description: opp.description,
      );
    }).toList();
  }

  double _computeOpportunityScore(Opportunity opportunity, CareerSnapshot career) {
    final careerScore = career.careerScore;
    final interviewReadiness = career.interviewReadiness;
    final resumeProgress = career.resumeProgress;
    final portfolioProgress = career.portfolioProgress;
    final skillMatch = opportunity.requiredSkills.isEmpty
        ? 0.5
        : opportunity.matchedSkills.length / opportunity.requiredSkills.length;

    return (
      careerScore * 0.25 +
      interviewReadiness * 0.20 +
      resumeProgress * 0.15 +
      portfolioProgress * 0.15 +
      skillMatch * 0.25
    ).clamp(0.0, 1.0);
  }

  String _computeReadiness(CareerSnapshot career) {
    final score = career.careerScore;
    if (score >= 0.8) return 'Highly Ready';
    if (score >= 0.6) return 'Nearly Ready';
    if (score >= 0.4) return 'Building';
    return 'Developing';
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2. MATCH COMPUTATION
  // ═══════════════════════════════════════════════════════════════════

  List<OpportunityMatch> _computeMatches(
    List<Opportunity> opportunities,
    CareerSnapshot career,
  ) {
    return opportunities.map((opp) {
      final requirements = opp.requiredSkills.map((skill) {
        final matched = opp.matchedSkills
            .any((s) => s.toLowerCase().contains(skill.toLowerCase()));
        return OpportunityRequirement(
          skill: skill,
          isRequired: true,
          isMatched: matched,
        );
      }).toList();

      final gaps = opp.missingSkills.map((skill) {
        return OpportunityGap(
          skill: skill,
          severity: 0.7,
          action: 'Study and practice $skill through targeted learning.',
        );
      }).toList();

      return OpportunityMatch(
        opportunityId: opp.id,
        matchScore: opp.matchScore,
        requirements: requirements,
        gaps: gaps,
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. COMPANY PROFILES
  // ═══════════════════════════════════════════════════════════════════

  List<OpportunityCompanyProfile> _computeCompanyProfiles(
    List<Opportunity> opportunities,
  ) {
    // Generate profiles from opportunity metadata
    return opportunities.map((opp) {
      final hasMissing = opp.missingSkills.isNotEmpty;
      return OpportunityCompanyProfile(
        id: 'company_${opp.id}',
        name: opp.title.contains('—')
            ? opp.title.split('—').first.trim()
            : opp.title,
        industry: opp.type.label,
        overview: opp.description,
        requiredSkills: opp.requiredSkills,
        preferredSkills: [],
        interviewDifficulty: hasMissing ? 0.7 : 0.4,
        culture: 'Collaborative, growth-oriented environment.',
        growthPotential: hasMissing ? 0.5 : 0.8,
        technologyStack: opp.requiredSkills.take(5).toList(),
        careerFitScore: opp.matchScore,
        location: '',
        size: '',
        fundingStage: '',
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 4. ANALYTICS
  // ═══════════════════════════════════════════════════════════════════

  OpportunityAnalytics _computeAnalytics(
    List<Opportunity> opportunities,
    CareerSnapshot career,
  ) {
    final totalApps = _applications.length;
    final activeApps = _applications.where((a) => a.isActive).length;
    final totalOpps = opportunities.length;

    // Calculate rates from application history
    final withResponses = _applications.where(
        (a) => a.status != ApplicationStatus.wishlist).length;
    final responseRate = totalApps > 0 ? withResponses / totalApps : 0.0;

    final withInterviews = _applications.where(
        (a) => a.status == ApplicationStatus.interviewScheduled ||
                a.status == ApplicationStatus.offerReceived ||
                a.status == ApplicationStatus.accepted).length;
    final interviewRate = totalApps > 0 ? withInterviews / totalApps : 0.0;

    final offers = _applications.where((a) => a.hasOffer).length;
    final offerRate = withInterviews > 0 ? offers / withInterviews : 0.0;

    // Success trend
    final success = (responseRate + interviewRate + offerRate) / 3.0;

    // Top skill gaps
    final skillGaps = <String, int>{};
    for (final opp in opportunities) {
      for (final skill in opp.missingSkills) {
        skillGaps.update(skill, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final sortedGaps = skillGaps.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topGaps = sortedGaps.take(5).map((e) => e.key).toList();

    // Average match score
    final avgMatch = totalOpps > 0
        ? opportunities.fold(0.0, (double s, o) => s + o.matchScore) / totalOpps
        : 0.0;

    // Opportunity readiness
    final readiness = (
      career.careerScore * 0.35 +
      career.interviewReadiness * 0.25 +
      career.resumeProgress * 0.20 +
      career.portfolioProgress * 0.20
    ).clamp(0.0, 1.0);

    return OpportunityAnalytics(
      totalOpportunities: totalOpps,
      totalApplications: totalApps,
      activeApplications: activeApps,
      responseRate: responseRate,
      interviewRate: interviewRate,
      offerRate: offerRate,
      successTrend: success,
      opportunityReadiness: readiness,
      topSkillGaps: topGaps,
      averageMatchScore: avgMatch,
      lastUpdated: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 5. AI OPPORTUNITY ADVISOR
  // ═══════════════════════════════════════════════════════════════════

  OpportunityInsight _generateInsight(
    List<Opportunity> opportunities,
    OpportunityAnalytics analytics,
  ) {
    if (opportunities.isEmpty) {
      return const OpportunityInsight(
        recommendationReason: 'Complete your profile to discover matching opportunities.',
        preparationPlan: ['Build your portfolio.', 'Complete career profile.'],
      );
    }

    final top = opportunities.first;
    final allMissing = <String>{};
    for (final opp in opportunities) {
      allMissing.addAll(opp.missingSkills);
    }

    return OpportunityInsight(
      bestOpportunityTitle: top.title,
      recommendationReason: 'Best match based on your skills, career goals, and readiness.',
      missingSkills: allMissing.toList(),
      preparationPlan: [
        if (top.missingSkills.isNotEmpty)
          'Address skill gaps: ${top.missingSkills.take(2).join(", ")}',
        if (analytics.opportunityReadiness < 0.6)
          'Improve overall readiness to ${(analytics.opportunityReadiness * 100).round()}%.',
        'Tailor your resume for ${top.title}.',
        'Build a portfolio project aligned with this role.',
      ],
      resumeImprovements: [
        'Highlight matched skills prominently.',
        if (allMissing.isNotEmpty)
          'Add projects demonstrating ${allMissing.take(2).join(" and ")}.',
        'Quantify achievements with metrics.',
      ],
      portfolioImprovements: [
        'Add a project that solves problems in ${top.type.label} domain.',
        if (top.matchedSkills.isNotEmpty)
          'Showcase ${top.matchedSkills.first} expertise.',
      ],
      interviewFocusAreas: [
        'Prepare for questions about ${top.requiredSkills.take(2).join(" and ")}.',
        'Practice behavioral questions using STAR method.',
      ],
      confidenceScore: top.matchScore,
      estimatedTimeline: analytics.opportunityReadiness >= 0.6
          ? 'Ready to apply now'
          : '${((1.0 - analytics.opportunityReadiness) * 12).round()} weeks of preparation',
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 6. ACTION ITEMS
  // ═══════════════════════════════════════════════════════════════════

  List<String> _generateActionItems(
    OpportunityAnalytics analytics,
    List<Opportunity> opportunities,
  ) {
    final items = <String>[];

    if (opportunities.isNotEmpty && analytics.opportunityReadiness >= 0.6) {
      items.add('Apply for ${opportunities.first.title}');
    }

    if (analytics.topSkillGaps.isNotEmpty) {
      items.add('Learn ${analytics.topSkillGaps.first}');
    }

    if (analytics.opportunityReadiness < 0.6) {
      items.add('Improve opportunity readiness');
    }

    items.add('Review and update resume');
    items.add('Build portfolio project');

    return items;
  }

  // ═══════════════════════════════════════════════════════════════════
  // 7. PERSISTENCE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _persistApplications() async {
    if (repository == null) return;
    try {
      final repo = repository!;
      for (final app in _applications) {
        await repo.saveApplication(app);
      }
    } catch (e) {
      _logger.warning('OpportunityIntelligenceEngine: persist failed: $e',
          category: LogCategory.engine,
          source: 'OpportunityIntelligenceEngine');
    }
  }
}
