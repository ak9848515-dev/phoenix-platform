import '../../user_state/services/user_state_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates mission completion growth from UserState data.
///
/// Derived from the ratio of completed missions to total missions
/// in the current UserState.
class MissionCalculator implements GrowthCalculator {
  MissionCalculator({
    this._userStateService,
  });

  final UserStateService? _userStateService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    final service = _userStateService;
    double score;
    String label;
    String detail;

    if (service != null) {
      final missions = service.currentState.missions;
      final total = missions.length;
      final completed = missions.where((m) => m.isCompleted).length;
      score = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
      label = '$completed/$total completed';
      detail = '${(score * 100).round()}% mission completion';
    } else {
      score = 0.0;
      label = 'No user state';
      detail = 'UserState not available';
    }

    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.mission,
      score: score,
      trend: trend,
      previousScore: previous?.score,
      label: label,
      detail: detail,
    );

    return _previous!;
  }

  @override
  GrowthMetrics? get previousMetrics => _previous;
}
