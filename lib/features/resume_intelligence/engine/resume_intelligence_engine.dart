import 'package:flutter/foundation.dart';

import '../../../shared/infrastructure/cache/cache_service.dart';
import '../../../shared/infrastructure/logging/phoenix_logger.dart';
import '../../career/engine/career_engine.dart';
import '../../career/engine/career_snapshot.dart';
import '../../personal_knowledge/engine/knowledge_engine.dart';
import '../../portfolio/engine/portfolio_engine.dart';
import '../../portfolio/engine/portfolio_snapshot.dart';
import '../../progress_engine/achievement_engine.dart';
import '../../progress_engine/achievement_snapshot.dart';
import '../models/resume_gap.dart';
import '../models/resume_intelligence_snapshot.dart';
import '../models/resume_recommendation.dart';
import '../models/resume_score_category.dart';
import '../models/resume_section_score.dart';
import '../models/resume_strength.dart';

/// Resume Intelligence Engine — continuously evaluates resume quality.
///
/// **Architecture:**
/// ```text
/// KnowledgeEngine + PortfolioEngine + CareerEngine + AchievementEngine
///   ↓
/// ResumeIntelligenceEngine
///   ↓
/// ResumeIntelligenceSnapshot
///   ↓
/// CareerScreen | Dashboard | Profile | PhoenixAssistant
/// ```
///
/// **Rules:**
/// - Fully deterministic — no AI, no randomness
/// - All scores are reproducible given the same inputs
/// - Widgets read [snapshot] only
class ResumeIntelligenceEngine extends ChangeNotifier {
  ResumeIntelligenceEngine({
    required this._knowledgeEngine,
    required this._portfolioEngine,
    required this._careerEngine,
    required this._achievementEngine,
    this._cacheService,
  });

  final KnowledgeEngine _knowledgeEngine;
  final PortfolioEngine _portfolioEngine;
  final CareerEngine _careerEngine;
  final AchievementEngine _achievementEngine;
  final CacheService? _cacheService;
  static const String _cacheKey = 'resume_intel:snapshot';
  final PhoenixLogger _logger = PhoenixLogger.shared;

  bool _isInitialized = false;
  ResumeIntelligenceSnapshot? _cachedSnapshot;

  // ── Accessors ─────────────────────────────────────────────────────

  /// The current resume intelligence snapshot (may be cached).
  ResumeIntelligenceSnapshot? get snapshot => _cachedSnapshot;

  /// Whether the engine has been initialized.
  bool get isInitialized => _isInitialized;

  // ── Lifecycle ─────────────────────────────────────────────────────

  /// Initializes the engine and builds an initial snapshot.
  Future<void> init() async {
    _cachedSnapshot = _cacheService?.get<ResumeIntelligenceSnapshot>(_cacheKey);
    if (_cachedSnapshot == null) {
      _buildSnapshot();
      if (_cachedSnapshot != null) {
        _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.review);
      }
    }
    _isInitialized = true;
    _logger.info('ResumeIntelligenceEngine initialized',
        category: LogCategory.engine, source: 'ResumeIntelligenceEngine');
    notifyListeners();
  }

  /// Refreshes the snapshot from current engine states.
  Future<void> refresh() async {
    _buildSnapshot();
    if (_cachedSnapshot != null) {
      _cacheService?.cache(_cacheKey, _cachedSnapshot!, CacheDomain.review);
    }
    _logger.info('ResumeIntelligenceEngine refreshed',
        category: LogCategory.engine, source: 'ResumeIntelligenceEngine');
    notifyListeners();
  }

  // ── Snapshot Builder ──────────────────────────────────────────────

  void _buildSnapshot() {
    final portfolio = _portfolioEngine.snapshot ?? const PortfolioSnapshot();
    final career = _careerEngine.snapshot ?? const CareerSnapshot();
    final achievement = _achievementEngine.snapshot ?? const AchievementSnapshot();
    final nodeCount = _knowledgeEngine.snapshot.nodeCount;

    final scores = _calculateScores(nodeCount, portfolio, career, achievement);
    final sections = _evaluateSections(nodeCount, portfolio, career);
    final gaps = _findGaps(nodeCount, portfolio, career, achievement);
    final recs = _generateRecommendations(gaps, scores, portfolio, career, nodeCount);
    final strengths = _findStrengths(nodeCount, portfolio, career, achievement);

    final overallScore = scores[ResumeScoreCategory.overall] ?? 0.0;
    final atsScore = scores[ResumeScoreCategory.ats] ?? 0.0;
    final technicalScore = scores[ResumeScoreCategory.technical] ?? 0.0;
    final projectScore = scores[ResumeScoreCategory.project] ?? 0.0;
    final experienceScore = scores[ResumeScoreCategory.experience] ?? 0.0;
    final portfolioScore = scores[ResumeScoreCategory.portfolio] ?? 0.0;
    final keywordCoverage = scores[ResumeScoreCategory.keywordCoverage] ?? 0.0;
    final recruiterReadiness = scores[ResumeScoreCategory.recruiterReadiness] ?? 0.0;

    final completeness = _calculateCompleteness(sections);
    final atsCompleteness = _calculateATSCompleteness(sections, gaps);

    // Sort gaps and recommendations by severity/priority
    gaps.sort((a, b) => b.impact.compareTo(a.impact));
    recs.sort((a, b) => b.estimatedImprovement.compareTo(a.estimatedImprovement));
    strengths.sort((a, b) => b.confidence.compareTo(a.confidence));

    _cachedSnapshot = ResumeIntelligenceSnapshot(
      overallScore: overallScore,
      atsScore: atsScore,
      technicalScore: technicalScore,
      projectScore: projectScore,
      experienceScore: experienceScore,
      portfolioScore: portfolioScore,
      keywordCoverage: keywordCoverage,
      recruiterReadiness: recruiterReadiness,
      scores: scores,
      gaps: gaps,
      recommendations: recs,
      strengths: strengths,
      sectionScores: sections,
      completeness: completeness,
      atsCompleteness: atsCompleteness,
      strengthCount: strengths.length,
      gapCount: gaps.length,
      topGap: gaps.isNotEmpty ? gaps.first : null,
      topRecommendation: recs.isNotEmpty ? recs.first : null,
      topStrength: strengths.isNotEmpty ? strengths.first : null,
      hasData: overallScore > 0,
      lastUpdated: DateTime.now(),
    );
  }

  // ── Scoring ───────────────────────────────────────────────────────

  Map<ResumeScoreCategory, double> _calculateScores(
    int nodeCount,
    PortfolioSnapshot portfolio,
    CareerSnapshot career,
    AchievementSnapshot achievement,
  ) {
    final scores = <ResumeScoreCategory, double>{};
    final techCount = portfolio.technologyCount;
    final skillCount = portfolio.skillCount;

    // Technical Score
    final technicalScore = _clampScore(
      (nodeCount.clamp(0, 50) / 50.0 * 40) +
      (techCount.clamp(0, 20) / 20.0 * 30) +
      (skillCount.clamp(0, 20) / 20.0 * 30)
    );

    // Project Score
    final projectScore = _clampScore(
      (portfolio.projectCount.clamp(0, 10) / 10.0 * 50) +
      (career.portfolioProgress * 50)
    );

    // Experience Score
    final expRaw = career.estimatedWeeks > 0
        ? (52 - career.estimatedWeeks).clamp(0, 52) / 52.0
        : 0.1;
    final experienceScore = _clampScore(
      (career.careerScore * 100 * 0.5) +
      (career.interviewReadiness * 100 * 0.3) +
      (expRaw * 100 * 0.2)
    );

    // Portfolio Score
    final portfolioScore = _clampScore(
      (portfolio.portfolioScore * 100 * 0.5) +
      (achievement.totalAchievements.clamp(0, 20) / 20.0 * 100 * 0.3) +
      (portfolio.achievementCount.clamp(0, 15) / 15.0 * 100 * 0.2)
    );

    // Keyword Coverage
    final keywordCoverage = _clampScore(
      (portfolio.technologies.length.clamp(0, 15) / 15.0 * 50) +
      (skillCount.clamp(0, 20) / 20.0 * 25) +
      (career.strengths.length.clamp(0, 10) / 10.0 * 25)
    );

    // ATS Score
    final atsScore = _clampScore(
      (portfolioScore * 0.3) +
      (keywordCoverage * 0.3) +
      (experienceScore * 0.2) +
      (projectScore * 0.2)
    );

    // Recruiter Readiness
    final recruiterReadiness = _clampScore(
      (atsScore * 0.4) +
      (career.careerScore * 100 * 0.3) +
      (experienceScore * 0.3)
    );

    // Overall Score: weighted composite
    final overallScore = _clampScore(
      technicalScore * ResumeScoreCategory.technical.weight +
      projectScore * ResumeScoreCategory.project.weight +
      experienceScore * ResumeScoreCategory.experience.weight +
      portfolioScore * ResumeScoreCategory.portfolio.weight +
      keywordCoverage * ResumeScoreCategory.keywordCoverage.weight +
      recruiterReadiness * ResumeScoreCategory.recruiterReadiness.weight +
      atsScore * ResumeScoreCategory.ats.weight
    );

    scores[ResumeScoreCategory.overall] = overallScore;
    scores[ResumeScoreCategory.ats] = atsScore;
    scores[ResumeScoreCategory.technical] = technicalScore;
    scores[ResumeScoreCategory.project] = projectScore;
    scores[ResumeScoreCategory.experience] = experienceScore;
    scores[ResumeScoreCategory.portfolio] = portfolioScore;
    scores[ResumeScoreCategory.keywordCoverage] = keywordCoverage;
    scores[ResumeScoreCategory.recruiterReadiness] = recruiterReadiness;

    return scores;
  }

  // ── Section Evaluation ────────────────────────────────────────────

  List<ResumeSectionScore> _evaluateSections(
    int nodeCount,
    PortfolioSnapshot portfolio,
    CareerSnapshot career,
  ) {
    return [
      ResumeSectionScore(
        sectionName: 'Professional Summary',
        completeness: career.careerScore > 0 ? 0.6 : 0.0,
        quality: career.strengths.isNotEmpty ? 0.5 : 0.0,
        alignment: career.careerScore,
        notes: career.strengths.isNotEmpty
            ? 'Strengths identified: ${career.strengths.take(3).join(", ")}'
            : 'No career strengths defined yet.',
      ),
      ResumeSectionScore(
        sectionName: 'Skills',
        completeness: (portfolio.skillCount / 20.0).clamp(0.0, 1.0),
        quality: (portfolio.skillCount / 15.0).clamp(0.0, 1.0),
        alignment: career.careerScore,
        notes: '${portfolio.skillCount} skills tracked '
            'across ${portfolio.technologyCount} technologies.',
      ),
      ResumeSectionScore(
        sectionName: 'Projects',
        completeness: (portfolio.projectCount / 10.0).clamp(0.0, 1.0),
        quality: portfolio.portfolioScore,
        alignment: career.portfolioProgress,
        notes: '${portfolio.projectCount} completed projects.',
      ),
      ResumeSectionScore(
        sectionName: 'Technologies',
        completeness: (portfolio.technologyCount / 15.0).clamp(0.0, 1.0),
        quality: (portfolio.technologyCount / 10.0).clamp(0.0, 1.0),
        alignment: 0.5,
        notes: portfolio.technologies.isNotEmpty
            ? 'Stack: ${portfolio.technologies.take(5).join(", ")}${portfolio.technologies.length > 5 ? "..." : ""}'
            : 'No technologies tracked yet.',
      ),
      ResumeSectionScore(
        sectionName: 'Achievements & Certifications',
        completeness: portfolio.achievementCount > 0 ? 0.5 : 0.0,
        quality: (portfolio.achievementCount / 10.0).clamp(0.0, 1.0),
        alignment: 0.5,
        notes: '${portfolio.achievementCount} achievements, '
            '${portfolio.strengthAreas.length} strength areas identified.',
      ),
      ResumeSectionScore(
        sectionName: 'Education & Background',
        completeness: nodeCount > 5 ? 0.4 : 0.1,
        quality: nodeCount > 10 ? 0.5 : 0.2,
        alignment: 0.3,
        notes: nodeCount > 0
            ? '$nodeCount knowledge areas covered.'
            : 'Knowledge graph not yet built.',
      ),
    ];
  }

  // ── Gap Analysis ──────────────────────────────────────────────────

  List<ResumeGap> _findGaps(
    int nodeCount,
    PortfolioSnapshot portfolio,
    CareerSnapshot career,
    AchievementSnapshot achievement,
  ) {
    final gaps = <ResumeGap>[];

    // 1. Missing Technologies
    if (portfolio.technologyCount < 3) {
      gaps.add(ResumeGap(
        category: 'technologies',
        description: 'Too few technologies in portfolio.',
        severity: GapSeverity.critical,
        suggestion: 'Add at least 3-5 distinct technologies to your portfolio.',
        impact: 0.15,
      ));
    }

    // 2. Missing Projects
    if (portfolio.projectCount < 2) {
      gaps.add(ResumeGap(
        category: 'projects',
        description: 'Not enough completed projects.',
        severity: GapSeverity.critical,
        suggestion: 'Complete at least 2-3 projects to demonstrate skills.',
        impact: 0.20,
      ));
    }

    // 3. Low Career Readiness
    if (career.careerScore < 0.3) {
      gaps.add(ResumeGap(
        category: 'career',
        description: 'Career readiness is very low.',
        severity: GapSeverity.critical,
        suggestion: 'Define your career goal and start working on foundational skills.',
        impact: 0.15,
      ));
    }

    // 4. Missing Certifications / Achievements
    if (achievement.totalAchievements == 0) {
      gaps.add(ResumeGap(
        category: 'achievements',
        description: 'No achievements or certifications earned.',
        severity: GapSeverity.moderate,
        suggestion: 'Complete missions that earn badges or certifications.',
        impact: 0.10,
      ));
    }

    // 5. Weak Portfolio Evidence
    if (portfolio.portfolioScore < 0.4) {
      gaps.add(ResumeGap(
        category: 'portfolio',
        description: 'Portfolio evidence is insufficient.',
        severity: GapSeverity.moderate,
        suggestion: 'Improve project descriptions and add measurable outcomes.',
        impact: 0.10,
      ));
    }

    // 6. Skill Gaps (from career)
    if (career.skillGaps.length >= 3) {
      final topGaps = career.skillGaps.take(3).join(", ");
      gaps.add(ResumeGap(
        category: 'skills',
        description: '${career.skillGaps.length} skill gaps identified ($topGaps).',
        severity: GapSeverity.moderate,
        suggestion: 'Focus on closing top 3 skill gaps through targeted learning.',
        impact: 0.08,
      ));
    }

    // 7. Low Interview Readiness
    if (career.interviewReadiness < 0.3) {
      gaps.add(ResumeGap(
        category: 'interview',
        description: 'Interview readiness is low.',
        severity: GapSeverity.moderate,
        suggestion: 'Practice interviews and prepare for common questions.',
        impact: 0.08,
      ));
    }

    // 8. Weak Knowledge Foundation
    if (nodeCount < 5) {
      gaps.add(ResumeGap(
        category: 'knowledge',
        description: 'Knowledge graph is sparse.',
        severity: GapSeverity.minor,
        suggestion: 'Explore more topics and complete learning paths.',
        impact: 0.05,
      ));
    }

    // 9. Missing Measurable Achievements
    if (portfolio.achievementCount < 3 && portfolio.projectCount > 0) {
      gaps.add(ResumeGap(
        category: 'metrics',
        description: 'Project descriptions lack measurable outcomes.',
        severity: GapSeverity.minor,
        suggestion: 'Add metrics like performance improvements, user numbers, and completion rates.',
        impact: 0.04,
      ));
    }

    // 10. No Resume Generated Recently
    if (career.resumeProgress < 0.3) {
      gaps.add(ResumeGap(
        category: 'resume',
        description: 'Resume not yet built or very incomplete.',
        severity: GapSeverity.minor,
        suggestion: 'Generate your resume from your portfolio data.',
        impact: 0.05,
      ));
    }

    return gaps;
  }

  // ── Recommendations ──────────────────────────────────────────────

  List<ResumeRecommendation> _generateRecommendations(
    List<ResumeGap> gaps,
    Map<ResumeScoreCategory, double> scores,
    PortfolioSnapshot portfolio,
    CareerSnapshot career,
    int nodeCount,
  ) {
    final recs = <ResumeRecommendation>[];

    // Map gaps to recommendations
    for (final gap in gaps) {
      final priority = gap.severity == GapSeverity.critical
          ? RecommendationPriority.high
          : gap.severity == GapSeverity.moderate
              ? RecommendationPriority.medium
              : RecommendationPriority.low;

      recs.add(ResumeRecommendation(
        category: gap.category,
        description: gap.suggestion.isNotEmpty
            ? gap.suggestion
            : gap.description,
        priority: priority,
        estimatedImprovement: gap.impact,
        action: _buildAction(gap.category, portfolio, career),
      ));
    }

    // Additional proactive recommendations
    if (portfolio.projectCount >= 3 && portfolio.achievementCount < portfolio.projectCount) {
      recs.add(ResumeRecommendation(
        category: 'projects',
        description: 'Add measurable achievements to completed projects.',
        priority: RecommendationPriority.medium,
        estimatedImprovement: 0.05,
        action: 'Describe project outcomes with specific metrics.',
      ));
    }

    if (nodeCount > 10 && portfolio.skillCount < 10) {
      recs.add(ResumeRecommendation(
        category: 'skills',
        description: 'Register more skills from your knowledge base.',
        priority: RecommendationPriority.medium,
        estimatedImprovement: 0.04,
        action: 'Map knowledge nodes to formal skills in your portfolio.',
      ));
    }

    return recs;
  }

  /// Builds a specific actionable step for a gap category.
  String _buildAction(
    String category,
    PortfolioSnapshot portfolio,
    CareerSnapshot career,
  ) {
    switch (category) {
      case 'technologies':
        return 'Start a learning path or project using a new technology.';
      case 'projects':
        return portfolio.projectCount < 3
            ? 'Complete 2 more projects to reach 3 total.'
            : 'Complete one more significant project.';
      case 'career':
        return 'Define your career goal and start foundational missions.';
      case 'achievements':
        return 'Complete missions that reward badges or certifications.';
      case 'portfolio':
        return 'Review and enhance project descriptions with outcomes.';
      case 'skills':
        final topGap = career.skillGaps.isNotEmpty
            ? career.skillGaps.first
            : 'top skill gap';
        return 'Focus on closing "$topGap" through targeted study.';
      case 'interview':
        return 'Start interview practice sessions in the Career section.';
      case 'knowledge':
        return 'Explore new topics through academy learning paths.';
      case 'metrics':
        return 'Add measurable outcomes to each project description.';
      case 'resume':
        return 'Generate your resume from the Portfolio section.';
      default:
        return 'Review and address this area to improve resume quality.';
    }
  }

  // ── Strength Identification ───────────────────────────────────────

  List<ResumeStrength> _findStrengths(
    int nodeCount,
    PortfolioSnapshot portfolio,
    CareerSnapshot career,
    AchievementSnapshot achievement,
  ) {
    final strengths = <ResumeStrength>[];

    // Career Strengths
    for (final s in career.strengths) {
      strengths.add(ResumeStrength(
        name: s,
        category: 'Career',
        confidence: (career.careerScore * 0.9 + 0.1).clamp(0.0, 1.0),
        evidence: 'Identified as a career strength.',
      ));
    }

    // Technology Diversity
    if (portfolio.technologies.length >= 3) {
      final topTech = portfolio.technologies.take(5).join(", ");
      strengths.add(ResumeStrength(
        name: 'Technology Stack',
        category: 'Technical',
        confidence: (portfolio.technologies.length / 15.0).clamp(0.0, 1.0),
        evidence: 'Proficient in $topTech.',
      ));
    }

    // Project Portfolio
    if (portfolio.projectCount >= 2) {
      strengths.add(ResumeStrength(
        name: 'Project Portfolio',
        category: 'Portfolio',
        confidence: (portfolio.projectCount / 10.0).clamp(0.0, 1.0),
        evidence: 'Completed ${portfolio.projectCount} projects.',
      ));
    }

    // Knowledge Depth
    if (nodeCount >= 10) {
      strengths.add(ResumeStrength(
        name: 'Knowledge Depth',
        category: 'Knowledge',
        confidence: (nodeCount / 50.0).clamp(0.0, 1.0),
        evidence: '$nodeCount knowledge areas covered.',
      ));
    }

    // Achievements
    if (achievement.totalAchievements >= 3) {
      strengths.add(ResumeStrength(
        name: 'Achievements & Recognition',
        category: 'Achievements',
        confidence: (achievement.totalAchievements / 15.0).clamp(0.0, 1.0),
        evidence: 'Earned ${achievement.totalAchievements} badges and milestones.',
      ));
    }

    // Portfolio Quality
    if (portfolio.portfolioScore >= 0.6) {
      strengths.add(ResumeStrength(
        name: 'Portfolio Quality',
        category: 'Portfolio',
        confidence: portfolio.portfolioScore,
        evidence: 'Portfolio score of ${(portfolio.portfolioScore * 100).round()}%.',
      ));
    }

    return strengths;
  }

  // ── Completeness Calculations ─────────────────────────────────────

  double _calculateCompleteness(List<ResumeSectionScore> sections) {
    if (sections.isEmpty) return 0.0;
    final avg = sections.fold(0.0, (sum, s) => sum + s.completeness) / sections.length;
    return avg.clamp(0.0, 1.0);
  }

  double _calculateATSCompleteness(
    List<ResumeSectionScore> sections,
    List<ResumeGap> gaps,
  ) {
    final baseComplete = _calculateCompleteness(sections);
    final penalty = gaps
        .where((g) => g.severity == GapSeverity.critical)
        .length * 0.1;
    return (baseComplete - penalty).clamp(0.0, 1.0);
  }

  // ── Helpers ───────────────────────────────────────────────────────

  double _clampScore(double value) => value.clamp(0.0, 100.0);
}
