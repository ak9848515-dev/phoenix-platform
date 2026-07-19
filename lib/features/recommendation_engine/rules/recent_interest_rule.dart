import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';

import '../models/recommendation_category.dart';
import '../models/recommendation_reason.dart';
import '../models/recommendation_result.dart';
import '../models/recommendation_score.dart';
import '../models/recommendation_urgency.dart';
import 'recommendation_rules.dart';

/// Recommends topics based on the user's recent interests, searches,
/// and AI conversation history.
///
/// Consumed signals:
/// - [UserState.aiContext] — recent AI conversation context
/// - [UserState.currentFocus] — user's stated focus
/// - [UserState.lastActivityAt] — recency signal
/// - [IdentitySnapshot.currentGoal] — stated primary goal
/// - [GrowthSnapshot.knowledge] — weak skills needing attention
///
/// Produces recommendations for topics the user has shown interest in
/// but hasn't yet mastered.
class RecentInterestRule extends RecommendationRule {
  const RecentInterestRule();

  @override
  String get name => 'RecentInterest';

  @override
  int get priority => 3;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    // Gather interest signals
    final signals = <String>[];

    // 1. From AI context (conversation history keywords)
    final aiContext = userState.aiContext;
    if (aiContext != null && aiContext.isNotEmpty) {
      // Extract first meaningful line as interest signal
      final lines = aiContext.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('system:')) {
          signals.add(trimmed);
          break;
        }
      }
    }

    // 2. From current focus
    if (userState.currentFocus != null && userState.currentFocus!.isNotEmpty) {
      signals.add(userState.currentFocus!);
    }

    // 3. From identity goals
    if (identitySnapshot.currentGoal.isNotEmpty) {
      signals.add(identitySnapshot.currentGoal);
    }

    // 4. From weak skills — the user likely needs to study these
    if (growthSnapshot.knowledge.score < 0.4) {
      signals.add('knowledge foundation');
    }
    if (growthSnapshot.skills.score < 0.4) {
      signals.add('skill development');
    }

    // If no signals detected, don't produce a recommendation
    if (signals.isEmpty) return null;

    // Compute recency boost (more recent = higher urgency)
    final hoursSinceActivity = userState.lastActivityAt != null
        ? DateTime.now().difference(userState.lastActivityAt!).inHours
        : 48;
    final recencyScore = (24.0 / (hoursSinceActivity + 1)).clamp(0.1, 1.0);

    // Confidence based on signal strength
    final confidence = (signals.length * 0.25).clamp(0.3, 0.95).toDouble();

    // Top interest area
    final topInterest = signals.first;

    return RecommendationResult(
      id: 'rec-recent-interest',
      title: 'Explore: $topInterest',
      description: signals.length > 1
          ? 'Based on your recent interest in "${signals.take(3).join('", "')}". '
              'Deepen your knowledge in this area.'
          : 'You showed interest in "$topInterest". '
              'Continue exploring to build expertise.',
      category: RecommendationCategory.learning,
      score: RecommendationScore(
        priority: (signals.length * 2).clamp(4, 9),
        urgency: RecommendationUrgency(
          score: recencyScore * confidence,
          reason: 'Recent interest detected — strike while curiosity is fresh.',
          isTimeSensitive: hoursSinceActivity < 24,
        ),
        confidence: confidence,
        estimatedBenefit: 0.3 * recencyScore,
        priorityWeight: 1.2,
      ),
      reason: RecommendationReason(
        why: 'You recently engaged with content related to "$topInterest".',
        whyNow: hoursSinceActivity < 24
            ? 'Your curiosity is fresh — great time to explore deeper.'
            : 'Revisit this topic while it\'s still top of mind.',
        improvement: 'Strengthening this area builds expertise and confidence.',
        unlock: 'Advanced topics and related skill areas open up.',
        template: 'RecentInterest',
      ),
      estimatedDuration: 15,
      learningImpact: 0.4,
      growthImpact: 0.2,
      careerImpact: (growthSnapshot.career.score < 0.5) ? 0.2 : 0.1,
      ruleName: name,
    );
  }
}
