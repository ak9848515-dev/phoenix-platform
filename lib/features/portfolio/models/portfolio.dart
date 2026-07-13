import 'portfolio_achievement.dart';
import 'portfolio_project.dart';
import 'portfolio_skill.dart';

/// Immutable representation of the user's complete Living Portfolio.
///
/// Automatically derived from Journey, Missions, Knowledge DNA, Progress,
/// Career Profile, and Decision modules. Not manually editable.
///
/// The portfolio is a read-only, auto-generated showcase of the user's
/// skills, projects, achievements, and career readiness.
class Portfolio {
  const Portfolio({
    required this.id,
    required this.identityId,
    this.portfolioScore = 0.0,
    this.featuredProjects = const [],
    this.skills = const [],
    this.technologies = const [],
    this.achievements = const [],
    this.careerReadiness = '',
    this.strengthAreas = const [],
    this.improvementAreas = const [],
    this.lastUpdated,
  });

  /// Unique identifier for this portfolio.
  final String id;

  /// Identity this portfolio belongs to.
  final String identityId;

  /// Overall portfolio score from 0.0 to 1.0.
  final double portfolioScore;

  /// Featured projects and completed missions.
  final List<PortfolioProject> featuredProjects;

  /// Skills with proficiency levels derived from Knowledge DNA.
  final List<PortfolioSkill> skills;

  /// Technology stack (languages, frameworks, tools).
  final List<String> technologies;

  /// Achievements, badges, and milestones earned.
  final List<PortfolioAchievement> achievements;

  /// Career readiness label (e.g. 'Building', 'Nearly Ready').
  final String careerReadiness;

  /// Areas identified as strengths by Knowledge DNA.
  final List<String> strengthAreas;

  /// Areas identified for improvement by Knowledge DNA.
  final List<String> improvementAreas;

  /// When this portfolio was last derived.
  final DateTime? lastUpdated;

  /// Number of completed projects.
  int get projectCount => featuredProjects.where((p) => p.isCompleted).length;

  /// Number of achievements and badges.
  int get achievementCount => achievements.length;

  /// Number of distinct technologies.
  int get technologyCount => technologies.length;

  /// Creates a copy with the given fields replaced.
  Portfolio copyWith({
    String? id,
    String? identityId,
    double? portfolioScore,
    List<PortfolioProject>? featuredProjects,
    List<PortfolioSkill>? skills,
    List<String>? technologies,
    List<PortfolioAchievement>? achievements,
    String? careerReadiness,
    List<String>? strengthAreas,
    List<String>? improvementAreas,
    DateTime? lastUpdated,
  }) {
    return Portfolio(
      id: id ?? this.id,
      identityId: identityId ?? this.identityId,
      portfolioScore: portfolioScore ?? this.portfolioScore,
      featuredProjects: featuredProjects ?? this.featuredProjects,
      skills: skills ?? this.skills,
      technologies: technologies ?? this.technologies,
      achievements: achievements ?? this.achievements,
      careerReadiness: careerReadiness ?? this.careerReadiness,
      strengthAreas: strengthAreas ?? this.strengthAreas,
      improvementAreas: improvementAreas ?? this.improvementAreas,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Portfolio &&
        other.id == id &&
        other.identityId == identityId &&
        other.portfolioScore == portfolioScore &&
        other.careerReadiness == careerReadiness &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => Object.hash(
    id,
    identityId,
    portfolioScore,
    careerReadiness,
    Object.hashAll(featuredProjects),
    Object.hashAll(skills),
    Object.hashAll(achievements),
  );

  @override
  String toString() =>
      'Portfolio(id: $id, score: $portfolioScore, '
      'projects: $projectCount, achievements: $achievementCount)';
}
