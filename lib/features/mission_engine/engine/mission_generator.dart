import '../models/mission_category.dart';
import '../models/mission_difficulty.dart';
import '../models/mission_priority.dart';
import '../models/mission_status.dart';
import '../mission_engine.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../../portfolio/services/portfolio_service.dart';
import '../../resume/services/resume_service.dart';
import '../../interview/services/interview_service.dart';
import '../../opportunity/services/opportunity_service.dart';
import '../../recommendation/services/recommendation_service.dart';

/// Generates missions by reading existing platform intelligence.
///
/// The generator does NOT duplicate business logic — it reads from
/// existing services (KnowledgeDNA, Portfolio, Resume, Interview,
/// Opportunity, Recommendation) and maps their output to mission
/// structures.
///
/// No service logic is reimplemented here.
class MissionGenerator {
  MissionGenerator({
    required this._knowledgeDnaService,
    required this._portfolioService,
    required this._resumeService,
    required this._interviewService,
    required this._opportunityService,
    required this._recommendationService,
  });

  final KnowledgeDNAService _knowledgeDnaService;
  final PortfolioService _portfolioService;
  final ResumeService _resumeService;
  final InterviewService _interviewService;
  final OpportunityService _opportunityService;
  final RecommendationService _recommendationService;

  // ── Public API ────────────────────────────────────────────────────

  /// Generates personalised missions from all platform services.
  List<Mission> generateAll({
    required List<Mission> currentMissions,
    int maxMissions = 12,
  }) {
    final missions = <Mission>[
      ..._generateKnowledgeMissions(),
      ..._generatePortfolioMissions(),
      ..._generateResumeMissions(),
      ..._generateInterviewMissions(),
      ..._generateOpportunityMissions(),
      ..._generateRecommendationMissions(),
      ..._generateDailyMaintenance(),
    ];

    // Avoid duplicates with existing missions
    final existingIds = currentMissions.map((m) => m.id).toSet();
    final newMissions = missions.where((m) => !existingIds.contains(m.id));

    return newMissions.take(maxMissions).toList();
  }

  // ── Knowledge DNA Missions ────────────────────────────────────────

  List<Mission> _generateKnowledgeMissions() {
    final analysis = _knowledgeDnaService.buildAnalysis();
    final missions = <Mission>[];

    // Generate missions for weak areas
    for (var i = 0; i < analysis.skillWeaknesses.length; i++) {
      final weakness = analysis.skillWeaknesses[i];
      missions.add(Mission(
        id: 'gen-kd-$i',
        title: 'Strengthen $weakness',
        description:
            'Focus on improving your $weakness skills through targeted '
            'learning and practice.',
        category: MissionCategory.learning,
        priority: MissionPriority.high,
        difficulty: MissionDifficulty.medium,
        estimatedDuration: 25,
        rewardXP: 100,
        status: MissionStatus.pending,
        createdDate: DateTime.now(),
        recommendationReason:
            'Knowledge DNA indicates $weakness is an area for growth.',
        sourceService: 'KnowledgeDNAService',
      ));
    }

    return missions;
  }

  // ── Portfolio Missions ────────────────────────────────────────────

  List<Mission> _generatePortfolioMissions() {
    final portfolio = _portfolioService.buildPortfolio();
    final missions = <Mission>[];

    if (portfolio.portfolioScore < 0.8) {
      missions.add(Mission(
        id: 'gen-portfolio-1',
        title: 'Complete a Portfolio Project',
        description:
            'Build a new project to strengthen your portfolio. '
            'Current score: ${(portfolio.portfolioScore * 100).round()}%.',
        category: MissionCategory.portfolio,
        priority: MissionPriority.medium,
        difficulty: MissionDifficulty.medium,
        estimatedDuration: 60,
        rewardXP: 200,
        status: MissionStatus.pending,
        createdDate: DateTime.now(),
        recommendationReason:
            'A stronger portfolio increases your career readiness.',
        sourceService: 'PortfolioService',
      ));
    }

    return missions;
  }

  // ── Resume Missions ───────────────────────────────────────────────

  List<Mission> _generateResumeMissions() {
    final resume = _resumeService.buildResume();
    final missions = <Mission>[];

    if (resume.resumeScore < 0.8) {
      missions.add(Mission(
        id: 'gen-resume-1',
        title: 'Improve Your Resume',
        description:
            'Enhance your resume to better showcase your skills. '
            'Current score: ${(resume.resumeScore * 100).round()}%.',
        category: MissionCategory.resume,
        priority: MissionPriority.high,
        difficulty: MissionDifficulty.easy,
        estimatedDuration: 30,
        rewardXP: 150,
        status: MissionStatus.pending,
        createdDate: DateTime.now(),
        recommendationReason:
            'A polished resume is essential for career opportunities.',
        sourceService: 'ResumeService',
      ));
    }

    return missions;
  }

  // ── Interview Missions ────────────────────────────────────────────

  List<Mission> _generateInterviewMissions() {
    final interview = _interviewService.buildProfile();
    final missions = <Mission>[];

    if (interview.interviewReadiness < 0.7) {
      missions.add(Mission(
        id: 'gen-interview-1',
        title: 'Practice Interview Skills',
        description:
            'Improve your interview readiness through practice sessions. '
            'Current readiness: ${(interview.interviewReadiness * 100).round()}%.',
        category: MissionCategory.interview,
        priority: MissionPriority.medium,
        difficulty: MissionDifficulty.medium,
        estimatedDuration: 45,
        rewardXP: 180,
        status: MissionStatus.pending,
        createdDate: DateTime.now(),
        recommendationReason:
            'Strong interview skills boost your career confidence.',
        sourceService: 'InterviewService',
      ));
    }

    return missions;
  }

  // ── Opportunity Missions ──────────────────────────────────────────

  List<Mission> _generateOpportunityMissions() {
    final opportunities = _opportunityService.getRecommendedOpportunities();
    final missions = <Mission>[];

    for (var i = 0; i < opportunities.length && i < 2; i++) {
      final opp = opportunities[i];
      missions.add(Mission(
        id: 'gen-opp-$i',
        title: 'Explore: ${opp.title}',
        description:
            'This opportunity aligns with your career goals. '
            'Match score: ${(opp.matchScore * 100).round()}%.',
        category: MissionCategory.career,
        priority: MissionPriority.medium,
        difficulty: MissionDifficulty.medium,
        estimatedDuration: 20,
        rewardXP: 120,
        status: MissionStatus.pending,
        createdDate: DateTime.now(),
        recommendationReason:
            'Exploring this opportunity could advance your career.',
        sourceService: 'OpportunityService',
      ));
    }

    return missions;
  }

  // ── Recommendation Missions ───────────────────────────────────────

  List<Mission> _generateRecommendationMissions() {
    final today = _recommendationService.getTodaysFocus();
    if (today == null) return [];

    return [
      Mission(
        id: 'gen-rec-1',
        title: today.title,
        description: today.description,
        category: MissionCategory.learning,
        priority: MissionPriority.high,
        difficulty: MissionDifficulty.medium,
        estimatedDuration: today.estimatedDuration,
        rewardXP: today.estimatedDuration * 5,
        status: MissionStatus.pending,
        createdDate: DateTime.now(),
        recommendationReason: today.reason,
        sourceService: 'RecommendationService',
      ),
    ];
  }

  // ── Daily Maintenance ─────────────────────────────────────────────

  List<Mission> _generateDailyMaintenance() {
    return [
      Mission(
        id: 'gen-daily-checkin',
        title: 'Daily Check-in',
        description:
            'Log your daily progress and reflect on what you learned today.',
        category: MissionCategory.daily,
        priority: MissionPriority.medium,
        difficulty: MissionDifficulty.beginner,
        estimatedDuration: 5,
        rewardXP: 30,
        status: MissionStatus.pending,
        createdDate: DateTime.now(),
        sourceService: 'MissionEngine',
      ),
      Mission(
        id: 'gen-daily-review',
        title: 'Review Today\'s Progress',
        description:
            'Review what you accomplished today and plan tomorrow\'s focus.',
        category: MissionCategory.reflection,
        priority: MissionPriority.low,
        difficulty: MissionDifficulty.beginner,
        estimatedDuration: 10,
        rewardXP: 50,
        status: MissionStatus.pending,
        createdDate: DateTime.now(),
        sourceService: 'MissionEngine',
      ),
    ];
  }
}
