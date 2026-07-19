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

/// If interview readiness is low, recommend preparation.
class LowInterviewRule extends RecommendationRule {
  const LowInterviewRule();

  @override
  String get name => 'LowInterview';

  @override
  int get priority => 3;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    final interviewScore = growthSnapshot.interview.score;
    if (interviewScore >= 0.5) return null;

    return RecommendationResult(
      id: 'rec-low-interview',
      title: 'Interview Preparation',
      description:
          'Your interview readiness is ${(interviewScore * 100).round()}%. '
          'Regular practice builds confidence and improves performance.',
      category: RecommendationCategory.interview,
      score: RecommendationScore(
        priority: 7,
        urgency: const RecommendationUrgency(
          score: 0.6,
          reason: 'Interview readiness affects career opportunities.',
        ),
        confidence: 0.75,
        estimatedBenefit: 0.4,
      ),
      reason: const RecommendationReason(
        why: 'Interview readiness is below target.',
        whyNow: 'Consistent practice dramatically improves performance.',
        improvement: 'Confidence, clarity, and offer rates improve.',
        unlock: 'Mock interviews, feedback sessions, real interviews.',
        template: 'LowInterview',
      ),
      estimatedDuration: 30,
      careerImpact: 0.4,
      learningImpact: 0.2,
      growthImpact: 0.3,
      ruleName: name,
    );
  }
}
