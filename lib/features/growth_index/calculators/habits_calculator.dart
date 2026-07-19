import '../../habit/services/habit_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates habit consistency growth from HabitService.
///
/// Delegates to [HabitService] for active habits and today's completion.
///
/// Fallback: if [habitService] is not provided, returns a placeholder
/// score of 0.0.
class HabitsCalculator implements GrowthCalculator {
  HabitsCalculator({
    this._habitService,
  });

  final HabitService? _habitService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    final service = _habitService;
    double score;
    String label;
    String detail;

    if (service != null) {
      final activeHabits = service.activeHabits;
      if (activeHabits.isNotEmpty) {
        final total = activeHabits.length;
        final completedToday = activeHabits
            .where((h) => service.isCompletedToday(h.id))
            .length;
        score = (completedToday / total).clamp(0.0, 1.0);
        label = '$completedToday/$total done today';
        detail = '${(score * 100).round()}% habit completion';
      } else {
        score = 0.0;
        label = 'No habits yet';
        detail = 'Create habits to track consistency';
      }
    } else {
      score = 0.0;
      label = 'No habit service';
      detail = 'Connect habit tracking';
    }

    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.habits,
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
