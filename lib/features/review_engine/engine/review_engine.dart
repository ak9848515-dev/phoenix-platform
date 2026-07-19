import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../career/engine/career_engine.dart';
import '../../career/engine/career_snapshot.dart';
import '../../growth_index/engine/growth_index_engine.dart';
import '../../growth_index/models/growth_snapshot.dart';
import '../../interview/intelligence/engine/interview_intelligence_engine.dart';
import '../../interview/intelligence/models/interview_intelligence_snapshot.dart';
import '../../opportunity/intelligence/engine/opportunity_intelligence_engine.dart';
import '../../opportunity/intelligence/models/opportunity_intelligence_snapshot.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../../portfolio/engine/portfolio_snapshot.dart';
import '../../resume_intelligence/engine/resume_intelligence_engine.dart';
import '../../resume_intelligence/models/resume_intelligence_snapshot.dart';
import '../models/review_snapshot.dart';
import '../repository/review_repository.dart';

/// The Phoenix Review Engine.
///
/// Generates daily, weekly, monthly, and domain-specific reviews by
/// consuming snapshots from all intelligence engines.
///
/// **Architecture Rules:**
/// - Deterministic — no AI, no LLM
/// - Consumes engine snapshots, never modifies them
/// - Produces immutable ReviewSnapshots for widget consumption
/// - Integrates with CacheService for fast restart
class ReviewEngine extends ChangeNotifier {
  ReviewEngine({
    required this.repository,
    required this._growthEngine,
    required this._careerEngine,
    required this._portfolioEngine,
    required this._resumeEngine,
    required this._interviewEngine,
    required this._opportunityEngine,
    this._cacheService,
  });

  final ReviewRepositoryInterface repository;
  final GrowthIndexEngine _growthEngine;
  final CareerEngine _careerEngine;
  final PortfolioEngine _portfolioEngine;
  final ResumeIntelligenceEngine _resumeEngine;
  final InterviewIntelligenceEngine _interviewEngine;
  final OpportunityIntelligenceEngine _opportunityEngine;
  final CacheService? _cacheService;

  static const String _cachePrefix = 'review:snapshot:';

  ReviewSnapshot? _cachedSnapshot;
  final PhoenixLogger _logger = PhoenixLogger.shared;
  bool _isInitialized = false;

  // ── Accessors ─────────────────────────────────────────────────────

  ReviewSnapshot? get snapshot => _cachedSnapshot;
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  Future<void> init() async {
    _cachedSnapshot = await repository.loadLatest();
    _isInitialized = true;
    _logger.info('ReviewEngine initialized',
        category: LogCategory.engine, source: 'ReviewEngine');
    notifyListeners();
  }

  /// Generates a review of the specified type.
  Future<ReviewSnapshot> generateReview(ReviewType type) async {
    final snapshot = _buildReview(type);
    _cachedSnapshot = snapshot;
    await repository.save(snapshot);
    _cacheService?.cache(
      '$_cachePrefix${type.name}',
      snapshot,
      CacheDomain.review,
    );
    _logger.info('ReviewEngine: generated ${type.displayName}',
        category: LogCategory.engine, source: 'ReviewEngine',
        metadata: {'score': snapshot.overallScore});
    notifyListeners();
    return snapshot;
  }

  Future<ReviewSnapshot> dailyReview() => generateReview(ReviewType.daily);
  Future<ReviewSnapshot> weeklyReview() => generateReview(ReviewType.weekly);
  Future<ReviewSnapshot> monthlyReview() => generateReview(ReviewType.monthly);
  Future<ReviewSnapshot> careerReview() => generateReview(ReviewType.career);
  Future<ReviewSnapshot> growthReview() => generateReview(ReviewType.growth);
  Future<ReviewSnapshot> learningReview() => generateReview(ReviewType.learning);
  Future<ReviewSnapshot> interviewReview() => generateReview(ReviewType.interview);
  Future<ReviewSnapshot> portfolioReview() => generateReview(ReviewType.portfolio);
  Future<ReviewSnapshot> opportunityReview() => generateReview(ReviewType.opportunity);

  /// Clears all cached review data.
  Future<void> reset() async {
    _cachedSnapshot = null;
    _cacheService?.invalidate(CacheDomain.review);
    await repository.clear();
    _logger.info('ReviewEngine reset',
        category: LogCategory.engine, source: 'ReviewEngine');
    notifyListeners();
  }


  // ── Review Builder ────────────────────────────────────────────────

  ReviewSnapshot _buildReview(ReviewType type) {
    final growthSnap = _growthEngine.snapshot;
    final careerSnap = _careerEngine.snapshot;
    final portfolioSnap = _portfolioEngine.snapshot;
    final resumeSnap = _resumeEngine.snapshot;
    final interviewSnap = _interviewEngine.snapshot;
    final opportunitySnap = _opportunityEngine.snapshot;

    final items = <ReviewItem>[];

    switch (type) {
      case ReviewType.daily:
        items.addAll(_buildDailyItems(growthSnap));
        break;
      case ReviewType.weekly:
        items.addAll(_buildWeeklyItems(growthSnap));
        break;
      case ReviewType.monthly:
        items.addAll(_buildMonthlyItems(
            growthSnap, careerSnap, portfolioSnap, resumeSnap,
            interviewSnap, opportunitySnap));
        break;
      case ReviewType.career:
        items.addAll(_buildCareerItems(careerSnap, resumeSnap));
        break;
      case ReviewType.growth:
        items.addAll(_buildGrowthItems(growthSnap));
        break;
      case ReviewType.learning:
        items.addAll(_buildLearningItems(growthSnap));
        break;
      case ReviewType.interview:
        items.addAll(_buildInterviewItems(interviewSnap));
        break;
      case ReviewType.portfolio:
        items.addAll(_buildPortfolioItems(portfolioSnap));
        break;
      case ReviewType.opportunity:
        items.addAll(_buildOpportunityItems(opportunitySnap));
        break;
    }

    final now = DateTime.now();
    final date = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
    final overallScore = items.isEmpty
        ? 0.0
        : items.map((i) => i.score).reduce((a, b) => a + b) / items.length;

    return ReviewSnapshot(
      reviewType: type,
      title: type.displayName,
      overallScore: overallScore,
      items: items,
      date: date,
      periodLabel: _periodLabel(type, now),
      overallSummary: _buildSummary(type, overallScore),
      topRecommendation: _buildTopRecommendation(items),
    );
  }

  // ── Item Builders ─────────────────────────────────────────────────

  List<ReviewItem> _buildDailyItems(GrowthSnapshot? growthSnap) {
    if (growthSnap == null) return [];
    return [
      ReviewItem(
        category: 'Today\'s Progress',
        score: growthSnap.overallScore,
        summary: growthSnap.totalXp > 0
            ? 'Level ${growthSnap.currentLevel} | ${growthSnap.totalXp} XP'
            : 'No activity recorded today',
        recommendations: growthSnap.overallScore < 0.3
            ? ['Try to complete at least one learning task today']
            : [],
      ),
    ];
  }

  List<ReviewItem> _buildWeeklyItems(GrowthSnapshot? growthSnap) {
    final items = <ReviewItem>[];
    if (growthSnap != null) {
      items.add(ReviewItem(
        category: 'Weekly Growth',
        score: growthSnap.overallScore,
        summary: 'Overall growth: ${(growthSnap.overallScore * 100).round()}%',
        recommendations: growthSnap.overallScore < 0.3
            ? ['Increase learning consistency this week']
            : [],
      ));
    }
    return items;
  }

  List<ReviewItem> _buildMonthlyItems(
    GrowthSnapshot? growthSnap,
    CareerSnapshot? careerSnap,
    PortfolioSnapshot? portfolioSnap,
    ResumeIntelligenceSnapshot? resumeSnap,
    InterviewIntelligenceSnapshot? interviewSnap,
    OpportunityIntelligenceSnapshot? opportunitySnap,
  ) {
    final items = <ReviewItem>[];
    if (growthSnap != null) {
      items.add(ReviewItem(
        category: 'Monthly Growth',
        score: growthSnap.overallScore,
        summary: 'Growth across ${growthSnap.allMetrics.length} dimensions',
        strengths: [growthSnap.strongestDimension.dimension.displayName],
        weaknesses: [growthSnap.weakestDimension.dimension.displayName],
      ));
    }
    return items;
  }

  List<ReviewItem> _buildCareerItems(
    CareerSnapshot? careerSnap,
    ResumeIntelligenceSnapshot? resumeSnap,
  ) {
    final items = <ReviewItem>[];
    if (careerSnap != null && careerSnap.hasData) {
      items.add(ReviewItem(
        category: 'Career Readiness',
        score: careerSnap.careerScore,
        summary: 'Career readiness: ${(careerSnap.careerScore * 100).round()}%',
        strengths: careerSnap.strengths,
        weaknesses: careerSnap.skillGaps,
        recommendations: careerSnap.nextGoal.isNotEmpty
            ? [careerSnap.nextGoal]
            : [],
      ));
    }
    if (resumeSnap != null && resumeSnap.hasData) {
      items.add(ReviewItem(
        category: 'Resume Quality',
        score: resumeSnap.overallScore / 100.0,
        summary: 'Resume score: ${resumeSnap.overallScore.round()}/100',
        recommendations: resumeSnap.topRecommendation != null
            ? [resumeSnap.topRecommendation!.description]
            : [],
        strengths: resumeSnap.strengths.map((s) => s.name).toList(),
        weaknesses: resumeSnap.gaps.map((g) => g.description).toList(),
      ));
    }
    return items;
  }

  List<ReviewItem> _buildGrowthItems(GrowthSnapshot? growthSnap) {
    if (growthSnap == null) return [];
    return growthSnap.allMetrics.map((m) => ReviewItem(
      category: m.dimension.displayName,
      score: m.score,
      summary: '${m.dimension.displayName}: ${(m.score * 100).round()}%',
      strengths: m.score >= 0.7 ? ['Strong area'] : [],
      weaknesses: m.score < 0.3 ? ['Needs improvement'] : [],
    )).toList();
  }

  List<ReviewItem> _buildLearningItems(GrowthSnapshot? growthSnap) {
    if (growthSnap == null) return [];
    final consistency = growthSnap.learningConsistency;
    return [
      ReviewItem(
        category: 'Learning Consistency',
        score: consistency?.score ?? 0.0,
        summary: consistency != null
            ? 'Consistency: ${(consistency.score * 100).round()}%'
            : 'Not enough learning data',
      ),
    ];
  }

  List<ReviewItem> _buildInterviewItems(
    InterviewIntelligenceSnapshot? interviewSnap,
  ) {
    if (interviewSnap == null || !interviewSnap.hasData) return [];
    return [
      ReviewItem(
        category: 'Interview Readiness',
        score: interviewSnap.readiness.overall,
        summary: 'Readiness: ${(interviewSnap.readiness.overall * 100).round()}%',
        strengths: interviewSnap.readiness.overall >= 0.5
            ? ['Overall readiness above 50%']
            : [],
        weaknesses: interviewSnap.weakTopics.map((w) => w.subject).toList(),
        recommendations: interviewSnap.recommendations
            .map((r) => r.description)
            .toList(),
      ),
    ];
  }

  List<ReviewItem> _buildPortfolioItems(PortfolioSnapshot? portfolioSnap) {
    if (portfolioSnap == null || !portfolioSnap.hasData) return [];
    return [
      ReviewItem(
        category: 'Portfolio',
        score: portfolioSnap.portfolioScore,
        summary: '${portfolioSnap.projectCount} projects, '
            'score: ${(portfolioSnap.portfolioScore * 100).round()}%',
      ),
    ];
  }

  List<ReviewItem> _buildOpportunityItems(
    OpportunityIntelligenceSnapshot? opportunitySnap,
  ) {
    if (opportunitySnap == null || !opportunitySnap.hasData) return [];
    return [
      ReviewItem(
        category: 'Opportunity Readiness',
        score: opportunitySnap.overallReadiness,
        summary: 'Readiness: '
            '${(opportunitySnap.overallReadiness * 100).round()}%',
      ),
    ];
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String _periodLabel(ReviewType type, DateTime now) {
    switch (type) {
      case ReviewType.daily:
        return 'Today';
      case ReviewType.weekly:
        return 'Week of ${now.month}/${now.day}';
      case ReviewType.monthly:
        return _monthName(now.month);
      default:
        return '';
    }
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  String _buildSummary(ReviewType type, double overallScore) {
    final pct = (overallScore * 100).round();
    return '$pct% overall ${type.displayName.toLowerCase()} score';
  }

  String _buildTopRecommendation(List<ReviewItem> items) {
    if (items.isEmpty) return '';
    final lowest = items.reduce(
      (a, b) => a.score < b.score ? a : b,
    );
    if (lowest.recommendations.isEmpty) return '';
    return lowest.recommendations.first;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
