import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../../career/services/career_service.dart';
import '../../decision/services/decision_service.dart';
import '../../journey/services/journey_service.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../../mission_engine/mission_service.dart';
import '../../progress_engine/progress_service.dart';
import '../models/portfolio.dart';
import '../models/portfolio_achievement.dart';
import '../models/portfolio_project.dart';
import '../models/portfolio_skill.dart';

/// Builds the user's Living Portfolio by aggregating data from all
/// existing Phoenix modules.
///
/// The portfolio is automatically derived — no manual editing, no AI,
/// no networking, no persistence, no duplicate business logic.
///
/// Each piece of data is sourced from an existing service to avoid
/// recalculating what other modules already compute.
class PortfolioService {
  PortfolioService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  // ── Internal service accessors ──────────────────────────────────────

  JourneyService get _journeyService => JourneyService(repository: repository);

  MissionService get _missionService => MissionService(repository: repository);

  KnowledgeDNAService get _knowledgeDnaService =>
      KnowledgeDNAService(repository: repository);

  ProgressService get _progressService =>
      ProgressService(repository: repository);

  CareerService get _careerService => CareerService(repository: repository);

  DecisionService get _decisionService =>
      DecisionService(repository: repository);

  // ── Public API ──────────────────────────────────────────────────────

  /// Builds the full portfolio from all module data.
  Portfolio buildPortfolio() {
    final identity = repository.selectedIdentity;
    final journey = _journeyService.getJourney();
    final missionProgress = _missionService.buildProgress();
    final knowledgeAnalysis = _knowledgeDnaService.buildAnalysis();
    final progressSummary = _progressService.buildSummary();
    final careerProfile = _careerService.buildProfile();
    final topDecision = _decisionService.getDecision();

    final projects = _deriveProjects(journey, missionProgress);
    final skills = _deriveSkills(knowledgeAnalysis);
    final technologies = _deriveTechnologies(knowledgeAnalysis, skills);
    final achievements = _deriveAchievements(progressSummary);
    final portfolioScore = _calculateScore(
      careerProfile.careerScore,
      knowledgeAnalysis.knowledgeScore,
      missionProgress.completionPercentage,
      progressSummary,
    );

    return Portfolio(
      id: 'portfolio-${identity.id}',
      identityId: identity.id,
      portfolioScore: portfolioScore,
      featuredProjects: projects,
      skills: skills,
      technologies: technologies,
      achievements: achievements,
      careerReadiness: '${careerProfile.jobReadiness} • ${topDecision.title}',
      strengthAreas: List<String>.from(knowledgeAnalysis.skillStrengths),
      improvementAreas: List<String>.from(knowledgeAnalysis.skillWeaknesses),
      lastUpdated: DateTime.now(),
    );
  }

  // ── Derivation helpers ──────────────────────────────────────────────

  /// Derives featured projects from journey stages and completed missions.
  List<PortfolioProject> _deriveProjects(
    dynamic journey,
    dynamic missionProgress,
  ) {
    final projects = <PortfolioProject>[];

    // Journey stages as milestones
    for (final stage in journey.stages) {
      final isCompleted = stage.status.toString().contains('completed');
      projects.add(
        PortfolioProject(
          id: 'project-stage-${stage.id}',
          title: stage.title,
          description: stage.description,
          type: 'milestone',
          completedDate: isCompleted ? DateTime.now() : null,
          skills: List<String>.from(stage.requiredSkills),
        ),
      );
    }

    // Completed missions as projects
    final allMissions = [
      ...missionProgress.dailyMissions,
      ...missionProgress.weeklyMissions,
    ];
    for (final mission in allMissions) {
      if (mission.completed) {
        projects.add(
          PortfolioProject(
            id: 'project-mission-${mission.id}',
            title: mission.title,
            description: mission.description,
            type: 'mission',
            completedDate: DateTime.now(),
          ),
        );
      }
    }

    return projects;
  }

  /// Derives skills from Knowledge DNA analysis.
  List<PortfolioSkill> _deriveSkills(dynamic knowledgeAnalysis) {
    final skills = <PortfolioSkill>[];

    // Strengths have high proficiency
    for (final strength in knowledgeAnalysis.skillStrengths) {
      skills.add(
        PortfolioSkill(
          id: 'skill-strength-${strength.toLowerCase().replaceAll(' ', '_')}',
          name: strength,
          proficiency: 0.85,
          category: _categorizeSkill(strength),
          isStrength: true,
        ),
      );
    }

    // Weaknesses have lower proficiency
    for (final weakness in knowledgeAnalysis.skillWeaknesses) {
      if (!skills.any((s) => s.name == weakness)) {
        skills.add(
          PortfolioSkill(
            id: 'skill-weakness-${weakness.toLowerCase().replaceAll(' ', '_')}',
            name: weakness,
            proficiency: 0.35,
            category: _categorizeSkill(weakness),
            isStrength: false,
          ),
        );
      }
    }

    return skills;
  }

  /// Derives technology stack from Knowledge DNA and skill names.
  List<String> _deriveTechnologies(
    dynamic knowledgeAnalysis,
    List<PortfolioSkill> skills,
  ) {
    final technologies = <String>{};

    // Extract technology-like names from skill strengths
    final techKeywords = <String>{
      'dart',
      'flutter',
      'python',
      'javascript',
      'typescript',
      'react',
      'angular',
      'vue',
      'node',
      'sql',
      'git',
      'docker',
      'aws',
      'firebase',
      'supabase',
      'graphql',
      'rest',
      'css',
      'html',
    };

    for (final skill in skills) {
      final lower = skill.name.toLowerCase();
      for (final keyword in techKeywords) {
        if (lower.contains(keyword)) {
          technologies.add(skill.name);
          break;
        }
      }
    }

    return technologies.toList()..sort();
  }

  /// Derives achievements from ProgressService achievements.
  List<PortfolioAchievement> _deriveAchievements(dynamic progressSummary) {
    return progressSummary.achievements.map<PortfolioAchievement>((
      achievement,
    ) {
      return PortfolioAchievement(
        id: 'achievement-${achievement.title.toLowerCase().replaceAll(' ', '_')}',
        title: achievement.title,
        date: DateTime.now(),
        type: 'achievement',
      );
    }).toList();
  }

  /// Calculates the portfolio score from multiple weighted inputs.
  double _calculateScore(
    double careerScore,
    double knowledgeScore,
    double missionCompletion,
    dynamic progressSummary,
  ) {
    // Weighted combination of key metrics
    // Career score: 30%, Knowledge DNA: 25%, Mission completion: 20%,
    // Level progress: 15%, Achievement count: 10%
    final levelProgress = (progressSummary.level / 10.0).clamp(0.0, 0.5);
    final achievementBonus = (progressSummary.achievements.length / 10.0).clamp(
      0.0,
      0.5,
    );

    return (careerScore * 0.30 +
            knowledgeScore * 0.25 +
            missionCompletion * 0.20 +
            levelProgress * 0.15 +
            achievementBonus * 0.10)
        .clamp(0.0, 1.0);
  }

  /// Categorizes a skill name into a general category.
  String _categorizeSkill(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dart') ||
        lower.contains('flutter') ||
        lower.contains('python') ||
        lower.contains('javascript') ||
        lower.contains('java') ||
        lower.contains('swift')) {
      return 'Language';
    }
    if (lower.contains('framework') ||
        lower.contains('react') ||
        lower.contains('angular') ||
        lower.contains('vue') ||
        lower.contains('node') ||
        lower.contains('flutter')) {
      return 'Framework';
    }
    if (lower.contains('design') ||
        lower.contains('architecture') ||
        lower.contains('system') ||
        lower.contains('pattern')) {
      return 'Architecture';
    }
    if (lower.contains('test') ||
        lower.contains('debug') ||
        lower.contains('deploy') ||
        lower.contains('devops') ||
        lower.contains('ci') ||
        lower.contains('cd')) {
      return 'Engineering';
    }
    if (lower.contains('sql') ||
        lower.contains('database') ||
        lower.contains('nosql') ||
        lower.contains('graphql') ||
        lower.contains('api')) {
      return 'Data & API';
    }
    if (lower.contains('communicat') ||
        lower.contains('leader') ||
        lower.contains('team') ||
        lower.contains('collaborat') ||
        lower.contains('present')) {
      return 'Soft Skill';
    }
    return 'General';
  }
}
