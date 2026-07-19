import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';

import '../models/recommendation_category.dart';
import '../models/recommendation_reason.dart';
import '../models/recommendation_result.dart';
import '../models/recommendation_score.dart';
import '../models/recommendation_urgency.dart';
import 'recommendation_rule.dart';

/// If learning consistency is weak, suggest a shorter mission to build momentum.
class WeakLearningRule extends RecommendationRule {
  const WeakLearningRule();

  @override
  String get name => 'WeakLearning';

  @override
  int get priority => 3;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    final lc = growthSnapshot.learningConsistency;
    final lcScore = lc?.score ?? 0.5;
    if (lcScore >= 0.5) return null;

    return RecommendationResult(
      id: 'rec-weak-learning',
      title: 'Short Learning Session',
      description:
          'Your learning consistency is ${(lcScore * 100).round()}%. '
          'A short 15-minute session builds momentum without overwhelming you.',
      category: RecommendationCategory.learning,
      score: RecommendationScore(
        priority: 7,
        urgency: const RecommendationUrgency(
          score: 0.7,
          reason: 'Weak learning consistency needs immediate attention.',
          isTimeSensitive: true,
        ),
        confidence: 0.75,
        estimatedBenefit: 0.3,
      ),
      reason: const RecommendationReason(
        why: 'Learning consistency is below target.',
        whyNow: 'Short sessions are more sustainable for rebuilding momentum.',
        improvement: 'Daily practice improves habit strength and retention.',
        unlock: 'Consistency streaks and habit rewards.',
        template: 'WeakLearning',
      ),
      estimatedDuration: 15,
      learningImpact: 0.3,
      growthImpact: 0.2,
      ruleName: name,
    );
  }
}
