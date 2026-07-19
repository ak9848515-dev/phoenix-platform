import '../../../core/sample_repository.dart';
import '../../portfolio/services/portfolio_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates portfolio development growth from PortfolioService.
///
/// Delegates to [PortfolioService.buildPortfolio] which computes the
/// portfolio score from career score, knowledge DNA, mission completion,
/// level progress, and achievement count.
class PortfolioCalculator implements GrowthCalculator {
  PortfolioCalculator({
    PortfolioService? portfolioService,
  }) : _portfolioService = portfolioService ??
            PortfolioService(repository: const SampleRepository());

  final PortfolioService _portfolioService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    final portfolio = _portfolioService.buildPortfolio();
    final score = portfolio.portfolioScore.clamp(0.0, 1.0);
    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.portfolio,
      score: score,
      trend: trend,
      previousScore: previous?.score,
      label: '${portfolio.featuredProjects.length} projects',
      detail: '${portfolio.achievements.length} achievements',
    );

    return _previous!;
  }

  @override
  GrowthMetrics? get previousMetrics => _previous;
}
