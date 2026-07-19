import '../../../core/sample_repository.dart';
import '../../career/services/career_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates career readiness growth from CareerService.
///
/// Delegates to [CareerService.buildProfile] which computes a weighted
/// career score from journey completion, mission progress, knowledge DNA,
/// and progress level.
class CareerCalculator implements GrowthCalculator {
  CareerCalculator({
    CareerService? careerService,
  }) : _careerService = careerService ??
            CareerService(repository: const SampleRepository());

  final CareerService _careerService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    final profile = _careerService.buildProfile();
    final score = profile.careerScore.clamp(0.0, 1.0);
    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.career,
      score: score,
      trend: trend,
      previousScore: previous?.score,
      label: '${profile.jobReadiness} — ${profile.estimatedWeeks} weeks',
      detail: '${(score * 100).round()}% career readiness',
    );

    return _previous!;
  }

  @override
  GrowthMetrics? get previousMetrics => _previous;
}
