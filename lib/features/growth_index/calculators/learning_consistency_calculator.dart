import '../../academy/services/academy_service.dart';
import '../../user_state/services/user_state_service.dart';
import '../models/growth_dimension.dart';
import '../models/growth_metrics.dart';
import '../models/growth_trend.dart';
import 'growth_calculator.dart';

/// Calculates learning consistency from UserState and Academy data.
///
/// Measures:
/// - Streak of daily learning activity
/// - Ratio of active days to total days
/// - Lesson completion consistency
///
/// Fallback: returns 0.0 with explanatory label if neither service
/// is available.
class LearningConsistencyCalculator implements GrowthCalculator {
  LearningConsistencyCalculator({
    this._userStateService,
    this._academyService,
  });

  final UserStateService? _userStateService;
  final AcademyService? _academyService;

  GrowthMetrics? _previous;

  @override
  GrowthMetrics calculate() {
    double score;
    String label;
    String detail;

    final userState = _userStateService;
    final academy = _academyService;

    if (userState != null && academy != null) {
      // Factor 1: Streak from UserState activity
      final lastActivity = userState.currentState.lastActivityAt;
      final daysSinceActivity = lastActivity != null
          ? DateTime.now().difference(lastActivity).inDays
          : 999;
      final streakScore = _streakFactor(daysSinceActivity);

      // Factor 2: Lesson completion from Academy
      final allProgress = academy.allProgress;
      final completedPaths =
          allProgress.where((p) => p.completionPercentage >= 1.0).length;
      final totalPaths = allProgress.length;
      final lessonScore =
          totalPaths > 0 ? (completedPaths / totalPaths).clamp(0.0, 1.0) : 0.0;

      // Factor 3: Active path progress
      final activePaths = allProgress
          .where((p) => p.completionPercentage > 0.0 && p.completionPercentage < 1.0)
          .length;
      final activeScore = (activePaths / 3.0).clamp(0.0, 1.0); // Cap at 3 paths

      // Composite: streak (50%), lesson completion (30%), active paths (20%)
      score = (streakScore * 0.5 + lessonScore * 0.3 + activeScore * 0.2)
          .clamp(0.0, 1.0);

      label = daysSinceActivity <= 1
          ? 'Active today'
          : '$daysSinceActivity days since last activity';
      detail = '$completedPaths/$totalPaths paths completed';
    } else if (userState != null) {
      // Only UserState available (no Academy)
      final lastActivity = userState.currentState.lastActivityAt;
      final daysSinceActivity = lastActivity != null
          ? DateTime.now().difference(lastActivity).inDays
          : 999;
      score = _streakFactor(daysSinceActivity);
      label = daysSinceActivity <= 1
          ? 'Active today'
          : '$daysSinceActivity days since activity';
      detail = 'Limited data — connect Academy for full measurement';
    } else {
      score = 0.0;
      label = 'No user data';
      detail = 'Connect profile to track learning consistency';
    }

    final previous = _previous;
    final trend = previous != null
        ? GrowthTrend.fromScores(score, previous.score)
        : GrowthTrend.stable;

    _previous = GrowthMetrics(
      dimension: GrowthDimension.learningConsistency,
      score: score,
      trend: trend,
      previousScore: previous?.score,
      label: label,
      detail: detail,
    );

    return _previous!;
  }

  /// Computes a streak score (0.0–1.0) from days since last activity.
  double _streakFactor(int daysSinceActivity) {
    if (daysSinceActivity <= 0) return 1.0;
    if (daysSinceActivity <= 1) return 0.9;
    if (daysSinceActivity <= 3) return 0.6;
    if (daysSinceActivity <= 7) return 0.3;
    return 0.0;
  }

  @override
  GrowthMetrics? get previousMetrics => _previous;
}
