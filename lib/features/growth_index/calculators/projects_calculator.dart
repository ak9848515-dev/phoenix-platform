import '../../../core/sample_repository.dart';
import '../../portfolio/services/portfolio_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates project completion growth from Portfolio data.
///
/// Derived from the ratio of completed projects to total projects
/// in the user's living portfolio.
class ProjectsCalculator implements GrowthCalculator {
  ProjectsCalculator({
    PortfolioService? portfolioService,
  }) : _portfolioService = portfolioService ??
            PortfolioService(repository: const SampleRepository());

  final PortfolioService _portfolioService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    final portfolio = _portfolioService.buildPortfolio();
    final projects = portfolio.featuredProjects;
    final completed = projects.where((p) => p.isCompleted).length;
    final total = projects.length;
    final score = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.projects,
      score: score,
      trend: trend,
      previousScore: previous?.score,
      label: '$completed/$total completed',
      detail: '${total > 0 ? (score * 100).round() : 0}% project completion',
    );

    return _previous!;
  }

  @override
  GrowthMetrics? get previousMetrics => _previous;
}
