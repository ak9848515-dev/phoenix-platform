import 'dart:math' as math;

/// Impact assessment for a mission recommendation.
///
/// Describes how completing this mission will improve each growth dimension.
/// All scores are 0.0–1.0 and computed from [GrowthSnapshot] data.
class MissionImpact {
  const MissionImpact({
    this.knowledgeGain = 0.0,
    this.careerGain = 0.0,
    this.projectGain = 0.0,
    this.interviewGain = 0.0,
    this.habitGain = 0.0,
    this.growthGain = 0.0,
  });

  /// Expected knowledge improvement (0.0–1.0).
  final double knowledgeGain;

  /// Expected career readiness improvement (0.0–1.0).
  final double careerGain;

  /// Expected project portfolio improvement (0.0–1.0).
  final double projectGain;

  /// Expected interview readiness improvement (0.0–1.0).
  final double interviewGain;

  /// Expected habit consistency improvement (0.0–1.0).
  final double habitGain;

  /// Expected overall growth score improvement (0.0–1.0).
  final double growthGain;

  /// Combined overall impact score (0.0–1.0).
  double get overallImpact {
    final gains = [
      knowledgeGain,
      careerGain,
      projectGain,
      interviewGain,
      habitGain,
      growthGain,
    ];
    final nonZero = gains.where((g) => g > 0.0).toList();
    if (nonZero.isEmpty) return 0.0;
    return nonZero.reduce((a, b) => a + b) / nonZero.length;
  }

  /// The highest individual gain dimension.
  double get maxGain => [knowledgeGain, careerGain, projectGain,
            interviewGain, habitGain, growthGain]
          .reduce(math.max);

  @override
  String toString() =>
      'MissionImpact(overall: ${(overallImpact * 100).round()}%, '
      'knowledge: ${(knowledgeGain * 100).round()}%, '
      'career: ${(careerGain * 100).round()}%)';
}
