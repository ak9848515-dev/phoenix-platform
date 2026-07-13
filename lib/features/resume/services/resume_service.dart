import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../../career/services/career_service.dart';
import '../../decision/services/decision_service.dart';
import '../../portfolio/services/portfolio_service.dart';
import '../models/resume.dart';
import '../models/resume_project.dart';
import '../models/resume_skill.dart';

/// Builds the user's Living Resume from the Portfolio and Career Profile.
///
/// The resume is automatically generated — no manual editing, no AI,
/// no networking, no persistence, no duplicate storage. Always reflects
/// the latest Portfolio data.
///
/// Resume type is selected automatically from the active plugin(s).
///
/// Future capabilities (architecture placeholders only):
///   - ATS Score
///   - PDF Export
///   - LinkedIn Export
///   - Version History
class ResumeService {
  ResumeService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  // ── Internal service accessors ──────────────────────────────────────

  PortfolioService get _portfolioService =>
      PortfolioService(repository: repository);

  CareerService get _careerService => CareerService(repository: repository);

  DecisionService get _decisionService =>
      DecisionService(repository: repository);

  // ── Public API ──────────────────────────────────────────────────────

  /// Builds the full resume from portfolio, career, and plugin data.
  Resume buildResume() {
    final identity = repository.selectedIdentity;
    final portfolio = _portfolioService.buildPortfolio();
    final careerProfile = _careerService.buildProfile();
    final topDecision = _decisionService.getDecision();

    final resumeType = _deriveResumeType();
    final summary = _buildProfessionalSummary(
      identity.title,
      careerProfile.jobReadiness,
      topDecision.title,
    );
    final projects = _deriveProjects(portfolio);
    final skills = _deriveSkills(portfolio);
    final achievements = _deriveAchievements(portfolio);
    final highlights = _buildCareerHighlights(careerProfile);
    final resumeScore = _calculateResumeScore(careerProfile, portfolio);

    return Resume(
      id: 'resume-${identity.id}',
      identityId: identity.id,
      resumeType: resumeType,
      professionalSummary: summary,
      projects: projects,
      skills: skills,
      achievements: achievements,
      careerHighlights: highlights,
      technologyStack: List<String>.from(portfolio.technologies),
      careerReadiness: careerProfile.jobReadiness,
      resumeScore: resumeScore,
      generatedAt: DateTime.now(),
    );
  }

  // ── Resume type derivation ──────────────────────────────────────────

  /// Derives resume type from the user's selected identity.
  ///
  /// Maps the identity title to the corresponding [ResumeType].
  /// Falls back to [ResumeType.generic] if no matching type is found.
  ResumeType _deriveResumeType() {
    final identityTitle = repository.selectedIdentity.title;
    return ResumeType.fromIdentityTitle(identityTitle);
  }

  // ── Derivation helpers ──────────────────────────────────────────────

  /// Builds a professional summary from career profile data.
  String _buildProfessionalSummary(
    String identityTitle,
    String jobReadiness,
    String topDecision,
  ) {
    return 'Aspiring $identityTitle with a $jobReadiness career profile. '
        'Currently focused on: $topDecision. '
        'Demonstrating consistent growth through structured learning '
        'missions, knowledge development, and project execution.';
  }

  /// Derives resume projects from portfolio featured projects.
  List<ResumeProject> _deriveProjects(dynamic portfolio) {
    return portfolio.featuredProjects.map<ResumeProject>((project) {
      return ResumeProject(
        title: project.title,
        description: project.description,
        type: project.type,
        skills: List<String>.from(project.skills),
        highlights: project.isCompleted
            ? ['Successfully completed this ${project.type}.']
            : ['Currently working on this ${project.type}.'],
      );
    }).toList();
  }

  /// Derives resume skills from portfolio skills.
  List<ResumeSkill> _deriveSkills(dynamic portfolio) {
    return portfolio.skills.map<ResumeSkill>((skill) {
      return ResumeSkill(
        name: skill.name,
        proficiency: skill.proficiency,
        isStrength: skill.isStrength,
        category: skill.category,
      );
    }).toList();
  }

  /// Derives achievement descriptions from portfolio achievements.
  List<String> _deriveAchievements(dynamic portfolio) {
    final result = <String>[];
    for (final achievement in portfolio.achievements) {
      result.add(achievement.title as String);
    }
    return result;
  }

  /// Builds career highlight bullet points from the career profile.
  List<String> _buildCareerHighlights(dynamic careerProfile) {
    final highlights = <String>[];

    highlights.add(
      'Career readiness: ${careerProfile.jobReadiness} '
      '(score: ${(careerProfile.careerScore * 100).round()}%)',
    );

    if (careerProfile.strengths.isNotEmpty) {
      highlights.add(
        'Key strengths: ${careerProfile.strengths.take(3).join(', ')}',
      );
    }

    if (careerProfile.skillGaps.isNotEmpty) {
      highlights.add(
        'Actively developing: ${careerProfile.skillGaps.take(3).join(', ')}',
      );
    }

    highlights.add(
      'Next goal: ${careerProfile.nextGoal} '
      '(estimated ${careerProfile.estimatedWeeks} weeks)',
    );

    return highlights;
  }

  /// Calculates the resume score from career and portfolio data.
  double _calculateResumeScore(dynamic careerProfile, dynamic portfolio) {
    // Weighted combination: career score (50%) + portfolio score (50%)
    return (careerProfile.careerScore * 0.50 + portfolio.portfolioScore * 0.50)
        .clamp(0.0, 1.0);
  }
}
