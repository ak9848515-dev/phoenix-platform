import '../../../core/sample_repository.dart';
import '../../interview/services/interview_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates interview readiness growth from InterviewService.
///
/// Delegates to [InterviewService.buildProfile] which derives readiness
/// from career profile, knowledge DNA, portfolio, and resume data.
class InterviewCalculator implements GrowthCalculator {
  InterviewCalculator({
    InterviewService? interviewService,
  }) : _interviewService = interviewService ??
            InterviewService(repository: const SampleRepository());

  final InterviewService _interviewService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    final profile = _interviewService.buildProfile();
    final score = profile.interviewReadiness.clamp(0.0, 1.0);
    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.interview,
      score: score,
      trend: trend,
      previousScore: previous?.score,
      label: '${profile.estimatedPreparationDays} days to go',
      detail: '${profile.recommendedTopics.length} topics to review',
    );

    return _previous!;
  }

  @override
  GrowthMetrics? get previousMetrics => _previous;
}
