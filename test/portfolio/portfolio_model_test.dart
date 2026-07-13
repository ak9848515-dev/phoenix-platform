import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/portfolio/models/portfolio.dart';
import 'package:phoenix_platform/features/portfolio/models/portfolio_achievement.dart';
import 'package:phoenix_platform/features/portfolio/models/portfolio_project.dart';
import 'package:phoenix_platform/features/portfolio/models/portfolio_skill.dart';

void main() {
  group('PortfolioProject', () {
    const project = PortfolioProject(
      id: 'proj-1',
      title: 'Build REST API',
      description: 'Created a REST API with Flutter',
      type: 'mission',
      skills: ['Dart', 'Flutter'],
      technologies: ['Dart', 'Postman'],
    );

    test('creates with default values', () {
      const minimal = PortfolioProject(
        id: 'minimal',
        title: 'Minimal',
        description: 'Desc',
      );
      expect(minimal.type, 'mission');
      expect(minimal.isCompleted, isFalse);
      expect(minimal.skills, isEmpty);
      expect(minimal.technologies, isEmpty);
    });

    test('isCompleted returns true when completedDate is set', () {
      final completed = project.copyWith(completedDate: DateTime(2026, 1, 1));
      expect(completed.isCompleted, isTrue);
    });

    test('isCompleted returns false when completedDate is null', () {
      expect(project.isCompleted, isFalse);
    });

    test('copyWith replaces fields', () {
      final copy = project.copyWith(title: 'Updated');
      expect(copy.title, 'Updated');
      expect(copy.id, 'proj-1');
    });

    test('equality works', () {
      const same = PortfolioProject(
        id: 'proj-1',
        title: 'Build REST API',
        description: 'Created a REST API with Flutter',
        type: 'mission',
        skills: ['Dart', 'Flutter'],
        technologies: ['Dart', 'Postman'],
      );
      expect(project, same);

      const different = PortfolioProject(
        id: 'other',
        title: 'Other',
        description: 'Desc',
      );
      expect(project, isNot(different));
    });
  });

  group('PortfolioSkill', () {
    const skill = PortfolioSkill(
      id: 'skill-1',
      name: 'Dart',
      proficiency: 0.85,
      category: 'Language',
      isStrength: true,
    );

    test('creates with default values', () {
      const minimal = PortfolioSkill(id: 's1', name: 'Test');
      expect(minimal.proficiency, 0.0);
      expect(minimal.category, 'General');
      expect(minimal.isStrength, isFalse);
    });

    test('copyWith replaces fields', () {
      final copy = skill.copyWith(proficiency: 0.95);
      expect(copy.proficiency, 0.95);
      expect(copy.name, 'Dart');
    });

    test('equality works', () {
      const same = PortfolioSkill(
        id: 'skill-1',
        name: 'Dart',
        proficiency: 0.85,
        category: 'Language',
        isStrength: true,
      );
      expect(skill, same);
    });
  });

  group('PortfolioAchievement', () {
    final achievement = PortfolioAchievement(
      id: 'ach-1',
      title: 'First Mission',
      description: 'Completed first mission',
      icon: Icons.stars,
      date: DateTime(2026, 1, 1),
      type: 'achievement',
    );

    test('creates with default values', () {
      const minimal = PortfolioAchievement(id: 'a1', title: 'Test');
      expect(minimal.type, 'achievement');
      expect(minimal.isBadge, isFalse);
      expect(minimal.isMilestone, isFalse);
    });

    test('isBadge returns true for badge type', () {
      const badge = PortfolioAchievement(
        id: 'b1',
        title: 'Badge',
        type: 'badge',
      );
      expect(badge.isBadge, isTrue);
      expect(badge.isMilestone, isFalse);
    });

    test('copyWith replaces fields', () {
      final copy = achievement.copyWith(title: 'Updated');
      expect(copy.title, 'Updated');
      expect(copy.id, 'ach-1');
    });

    test('equality works', () {
      final same = PortfolioAchievement(
        id: 'ach-1',
        title: 'First Mission',
        description: 'Completed first mission',
        icon: Icons.stars,
        date: DateTime(2026, 1, 1),
        type: 'achievement',
      );
      expect(achievement, same);
    });
  });

  group('Portfolio', () {
    const portfolio = Portfolio(
      id: 'portfolio-1',
      identityId: 'identity-1',
      portfolioScore: 0.75,
      careerReadiness: 'Building',
    );

    test('creates with default values', () {
      expect(portfolio.projectCount, 0);
      expect(portfolio.achievementCount, 0);
      expect(portfolio.technologyCount, 0);
      expect(portfolio.strengthAreas, isEmpty);
      expect(portfolio.improvementAreas, isEmpty);
    });

    test('projectCount counts only completed projects', () {
      final withProjects = portfolio.copyWith(
        featuredProjects: [
          PortfolioProject(
            id: 'p1',
            title: 'Completed',
            description: 'Desc',
            completedDate: DateTime(2026, 1, 1),
          ),
          const PortfolioProject(
            id: 'p2',
            title: 'In Progress',
            description: 'Desc',
          ),
        ],
      );
      expect(withProjects.projectCount, 1);
    });

    test('achievementCount returns correct count', () {
      final withAchievements = portfolio.copyWith(
        achievements: [
          const PortfolioAchievement(id: 'a1', title: 'A1'),
          const PortfolioAchievement(id: 'a2', title: 'A2'),
        ],
      );
      expect(withAchievements.achievementCount, 2);
    });

    test('technologyCount returns correct count', () {
      final withTech = portfolio.copyWith(technologies: ['Dart', 'Flutter']);
      expect(withTech.technologyCount, 2);
    });

    test('copyWith replaces fields', () {
      final copy = portfolio.copyWith(portfolioScore: 0.9);
      expect(copy.portfolioScore, 0.9);
      expect(copy.id, 'portfolio-1');
    });

    test('equality works', () {
      const same = Portfolio(
        id: 'portfolio-1',
        identityId: 'identity-1',
        portfolioScore: 0.75,
        careerReadiness: 'Building',
      );
      expect(portfolio, same);
    });
  });
}
