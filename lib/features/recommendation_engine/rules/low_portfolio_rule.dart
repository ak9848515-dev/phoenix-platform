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

/// If portfolio score is low, recommend building a project.
class LowPortfolioRule extends RecommendationRule {
  const LowPortfolioRule();

  @override
  String get name => 'LowPortfolio';

  @override
  int get priority => 3;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    final portfolioScore = growthSnapshot.portfolio.score;
    if (portfolioScore >= 0.4) return null;

    return RecommendationResult(
      id: 'rec-low-portfolio',
      title: 'Build Your Portfolio',
      description:
          'Your portfolio score is ${(portfolioScore * 100).round()}%. '
          'A new project will demonstrate your skills and attract opportunities.',
      category: RecommendationCategory.portfolio,
      score: RecommendationScore(
        priority: 8,
        urgency: const RecommendationUrgency(
          score: 0.6,
          reason: 'Portfolio is a key career asset.',
        ),
        confidence: 0.8,
        estimatedBenefit: 0.5,
      ),
      reason: const RecommendationReason(
        why: 'Portfolio is underdeveloped.',
        whyNow: 'Projects are the strongest signal of capability.',
        improvement: 'Career readiness and opportunity match scores improve.',
        unlock: 'Portfolio reviews, project showcases, career referrals.',
        template: 'LowPortfolio',
      ),
      estimatedDuration: 45,
      careerImpact: 0.4,
      growthImpact: 0.3,
      ruleName: name,
    );
  }
}
