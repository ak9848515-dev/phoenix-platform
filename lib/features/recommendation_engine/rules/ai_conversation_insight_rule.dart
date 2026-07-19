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

/// Recommends actions based on AI conversation patterns and
/// learning velocity signals.
///
/// Consumed signals:
/// - [UserState.aiContext] — conversation topics and themes
/// - [GrowthSnapshot.knowledge] — learning velocity and knowledge gaps
/// - [GrowthSnapshot.learningConsistency] — consistency patterns
/// - [UserState.lastActivityAt] — engagement recency
///
/// Bridges AI interactions with actionable learning recommendations.
class AiConversationInsightRule extends RecommendationRule {
  const AiConversationInsightRule();

  @override
  String get name => 'AiConversationInsight';

  @override
  int get priority => 2;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    // 1. Assess learning velocity
    final knowledgeScore = growthSnapshot.knowledge.score;
    final learningConsistency = growthSnapshot.learningConsistency?.score ?? 0.5;

    // 2. Check for AI conversation activity
    final hasAiContext = userState.aiContext != null &&
        userState.aiContext!.isNotEmpty;

    // 3. Check for knowledge gaps
    final hasKnowledgeGap = knowledgeScore < 0.5;

    // If user has been engaging with AI and has knowledge gaps,
    // recommend consolidating learning
    if (hasAiContext && hasKnowledgeGap) {
      return RecommendationResult(
        id: 'rec-ai-insight-consolidate',
        title: 'Consolidate Your Learning',
        description:
            'You\'ve been exploring concepts with AI. Take time to consolidate '
            'what you\'ve learned into notes, projects, or revision.',
        category: RecommendationCategory.learning,
        score: RecommendationScore(
          priority: 7,
          urgency: RecommendationUrgency(
            score: 0.6 * (1.0 - knowledgeScore),
            reason: 'Knowledge retention improves with active consolidation.',
            isTimeSensitive: true,
          ),
          confidence: (0.6 + learningConsistency * 0.3).clamp(0.0, 0.9),
          estimatedBenefit: 0.4 * (1.0 - knowledgeScore),
          priorityWeight: 1.1,
        ),
        reason: const RecommendationReason(
          why: 'AI conversations generate insights that need consolidation.',
          whyNow: 'Fresh knowledge is easier to retain with active recall.',
          improvement: 'Knowledge retention and practical application improve.',
          unlock: 'Deeper understanding, project application, skill mastery.',
          template: 'AiConsolidation',
        ),
        estimatedDuration: 15,
        learningImpact: 0.5,
        growthImpact: 0.2,
        careerImpact: 0.2,
        ruleName: name,
      );
    }

    // If learning consistency is low, recommend setting a rhythm
    if (learningConsistency < 0.4) {
      return RecommendationResult(
        id: 'rec-ai-insight-rhythm',
        title: 'Set a Learning Rhythm',
        description:
            'Your learning consistency is ${(learningConsistency * 100).round()}%. '
            'Setting a regular learning schedule dramatically improves outcomes.',
        category: RecommendationCategory.habit,
        score: RecommendationScore(
          priority: 8,
          urgency: const RecommendationUrgency(
            score: 0.7,
            reason: 'Consistency is the #1 predictor of learning success.',
            isTimeSensitive: true,
          ),
          confidence: 0.75,
          estimatedBenefit: 0.5,
          priorityWeight: 1.3,
        ),
        reason: const RecommendationReason(
          why: 'Learning consistency is the strongest growth predictor.',
          whyNow: 'Building a habit now prevents motivation decay.',
          improvement: 'All growth dimensions benefit from regular engagement.',
          unlock: 'Streak rewards, habit bonuses, accelerated learning paths.',
          template: 'LearningRhythm',
        ),
        estimatedDuration: 10,
        learningImpact: 0.4,
        growthImpact: 0.3,
        careerImpact: 0.2,
        ruleName: name,
      );
    }

    // If knowledge is decent and consistency is good, but user has
    // career goals, recommend practical application
    if (knowledgeScore >= 0.5 &&
        learningConsistency >= 0.5 &&
        identitySnapshot.currentGoal.isNotEmpty) {
      return RecommendationResult(
        id: 'rec-ai-insight-apply',
        title: 'Apply Knowledge Practically',
        description:
            'You have a solid knowledge foundation. Apply it by building '
            'something real — a project, portfolio piece, or proof of concept.',
        category: RecommendationCategory.portfolio,
        score: RecommendationScore(
          priority: 8,
          urgency: const RecommendationUrgency(
            score: 0.6,
            reason: 'Knowledge without application has limited impact.',
          ),
          confidence: 0.8,
          estimatedBenefit: 0.5,
          priorityWeight: 1.2,
        ),
        reason: const RecommendationReason(
          why: 'Practical application transforms knowledge into skill.',
          whyNow: 'Your foundation is ready for real-world application.',
          improvement: 'Career readiness and portfolio depth improve.',
          unlock: 'Project portfolio, practical experience, job readiness.',
          template: 'ApplyKnowledge',
        ),
        estimatedDuration: 30,
        learningImpact: 0.3,
        growthImpact: 0.4,
        careerImpact: 0.5,
        ruleName: name,
      );
    }

    return null;
  }
}
