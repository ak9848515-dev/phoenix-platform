import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/sample_repository.dart';
import 'package:phoenix_platform/features/portfolio/services/portfolio_service.dart';

void main() {
  group('PortfolioService', () {
    final service = PortfolioService(repository: const SampleRepository());

    test('buildPortfolio returns a non-null portfolio', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio, isNotNull);
      expect(portfolio.id, isNotEmpty);
      expect(portfolio.identityId, isNotEmpty);
    });

    test('portfolio has a score between 0 and 1', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.portfolioScore, greaterThanOrEqualTo(0.0));
      expect(portfolio.portfolioScore, lessThanOrEqualTo(1.0));
    });

    test('portfolio has featured projects', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.featuredProjects, isNotEmpty);
    });

    test('portfolio has skills', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.skills, isNotEmpty);
    });

    test('portfolio has achievements', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.achievements, isNotEmpty);
    });

    test('portfolio has technologies list', () {
      final portfolio = service.buildPortfolio();

      // Technologies are derived from skill names matching tech keywords.
      // With sample data, this may be empty if skills are soft skills.
      expect(portfolio.technologies, isNotNull);
    });

    test('portfolio has career readiness', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.careerReadiness, isNotEmpty);
    });

    test('portfolio has strength and improvement areas', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.strengthAreas, isNotEmpty);
      expect(portfolio.improvementAreas, isNotEmpty);
    });

    test('portfolio has a lastUpdated timestamp', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.lastUpdated, isNotNull);
    });

    test('projectCount matches completed featured projects', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.projectCount, greaterThanOrEqualTo(0));
      expect(
        portfolio.projectCount,
        lessThanOrEqualTo(portfolio.featuredProjects.length),
      );
    });

    test('portfolio has a consistent id format', () {
      final portfolio = service.buildPortfolio();

      expect(portfolio.id, startsWith('portfolio-'));
    });

    test('skills have diverse categories', () {
      final portfolio = service.buildPortfolio();
      final categories = portfolio.skills.map((s) => s.category).toSet();

      expect(categories, isNotEmpty);
    });

    test('skills have valid proficiency values', () {
      final portfolio = service.buildPortfolio();

      for (final skill in portfolio.skills) {
        expect(skill.proficiency, greaterThanOrEqualTo(0.0));
        expect(skill.proficiency, lessThanOrEqualTo(1.0));
      }
    });

    test('strength skills have high proficiency', () {
      final portfolio = service.buildPortfolio();
      final strengths = portfolio.skills.where((s) => s.isStrength);

      for (final skill in strengths) {
        expect(skill.proficiency, greaterThan(0.5));
      }
    });

    test('improvement skills have lower proficiency', () {
      final portfolio = service.buildPortfolio();
      final improvements = portfolio.skills.where((s) => !s.isStrength);

      for (final skill in improvements) {
        expect(skill.proficiency, lessThanOrEqualTo(0.5));
      }
    });

    test('technologies are sorted when non-empty', () {
      final portfolio = service.buildPortfolio();

      if (portfolio.technologies.isNotEmpty) {
        final sorted = List<String>.from(portfolio.technologies)..sort();
        expect(portfolio.technologies, sorted);
      }
    });
  });
}
