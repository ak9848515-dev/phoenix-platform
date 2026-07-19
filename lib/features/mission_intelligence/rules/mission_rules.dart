import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_difficulty.dart';
import 'package:phoenix_platform/features/mission_engine/models/mission_priority.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';

import '../models/mission_impact.dart';
import '../models/mission_recommendation.dart';
import '../models/mission_score.dart';

/// Abstract interface for a mission intelligence rule.
///
/// Each independent rule evaluates the user's current state and optionally
/// produces a [MissionRecommendation] if its conditions are met.
///
/// Rules are stateless — all state comes from the input snapshots.
abstract class MissionRule {
  const MissionRule();

  /// Unique name for this rule (used for identification and history).
  String get name;

  /// Evaluation priority (higher = evaluated first, higher ranking weight).
  int get priority => 1;

  /// Evaluates the rule and returns a recommendation if conditions are met.
  ///
  /// Returns `null` if the rule's conditions are not satisfied.
  MissionRecommendation? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required UserState userState,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Rule 1: Low Knowledge
// ─────────────────────────────────────────────────────────────────────────────

/// If knowledge score is low, recommend a learning mission.
class LowKnowledgeRule extends MissionRule {
  const LowKnowledgeRule();

  @override
  String get name => 'LowKnowledge';

  @override
  int get priority => 3;

  @override
  MissionRecommendation? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required UserState userState,
  }) {
    final knowledgeScore = growthSnapshot.knowledge.score;
    if (knowledgeScore >= 0.4) return null;

    final diff = (0.4 - knowledgeScore).clamp(0.0, 0.4);
    final confidence = 0.5 + (diff / 0.4) * 0.4;
    final priority = knowledgeScore < 0.2
        ? MissionPriority.critical
        : MissionPriority.high;

    return MissionRecommendation(
      id: 'rule-low-knowledge',
      title: 'Improve Your Knowledge',
      description:
          'Your knowledge score is ${(knowledgeScore * 100).round()}%. '
          'Strengthen your foundations with focused learning.',
      category: MissionCategory.learning,
      priority: priority,
      difficulty: MissionDifficulty.beginner,
      estimatedDuration: 30,
      rewardXP: 50,
      reason:
          'Low knowledge score (${(knowledgeScore * 100).round()}%) — '
          'learning will strengthen your weakest area.',
      score: MissionScore(
        score: 0.9,
        weight: 3,
        confidence: confidence,
      ),
      impact: const MissionImpact(
        knowledgeGain: 0.4,
        growthGain: 0.3,
      ),
      confidence: confidence,
      unlocks: const ['Advanced learning paths', 'Knowledge-based missions'],
      ruleName: name,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rule 2: Empty Portfolio
// ─────────────────────────────────────────────────────────────────────────────

/// If portfolio is empty or very low, recommend building a project.
class EmptyPortfolioRule extends MissionRule {
  const EmptyPortfolioRule();

  @override
  String get name => 'EmptyPortfolio';

  @override
  int get priority => 3;

  @override
  MissionRecommendation? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required UserState userState,
  }) {
    final portfolioScore = growthSnapshot.portfolio.score;
    if (portfolioScore >= 0.15) return null;

    return MissionRecommendation(
      id: 'rule-empty-portfolio',
      title: 'Build Your First Project',
      description:
          'Your portfolio is empty. Start building to showcase '
          'your skills and track your progress.',
      category: MissionCategory.build,
      priority: MissionPriority.high,
      difficulty: MissionDifficulty.beginner,
      estimatedDuration: 45,
      rewardXP: 75,
      reason:
          'Portfolio score is ${(portfolioScore * 100).round()}% — '
          'a project will demonstrate your capabilities.',
      score: MissionScore(
        score: 0.85,
        weight: 3,
        confidence: 0.8,
      ),
      impact: const MissionImpact(
        projectGain: 0.5,
        careerGain: 0.3,
        growthGain: 0.3,
      ),
      confidence: 0.8,
      unlocks: const ['Portfolio review', 'Project showcase'],
      ruleName: name,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rule 3: Career Undefined
// ─────────────────────────────────────────────────────────────────────────────

/// If career path is not defined, recommend career planning.
class CareerUndefinedRule extends MissionRule {
  const CareerUndefinedRule();

  @override
  String get name => 'CareerUndefined';

  @override
  int get priority => 2;

  @override
  MissionRecommendation? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required UserState userState,
  }) {
    final hasCareerGoal = identitySnapshot.currentGoal.isNotEmpty &&
        identitySnapshot.currentGoal != 'Begin your journey' &&
        identitySnapshot.currentGoal != 'Define your career goal';

    // If the identity snapshot already has a defined goal, no need to recommend
    if (hasCareerGoal) return null;

    return MissionRecommendation(
      id: 'rule-career-undefined',
      title: 'Define Your Career Path',
      description:
          'A clear career destination helps Phoenix guide your '
          'learning and growth more effectively.',
      category: MissionCategory.career,
      priority: MissionPriority.high,
      difficulty: MissionDifficulty.beginner,
      estimatedDuration: 15,
      rewardXP: 30,
      reason: 'Your career direction is not yet defined — setting a goal '
          'unlocks personalised recommendations.',
      score: MissionScore(
        score: 0.8,
        weight: 2,
        confidence: 0.75,
      ),
      impact: const MissionImpact(
        careerGain: 0.5,
        growthGain: 0.2,
      ),
      confidence: 0.75,
      unlocks: const ['Career missions', 'Targeted learning paths'],
      ruleName: name,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rule 4: Weak Learning Consistency
// ─────────────────────────────────────────────────────────────────────────────

/// If learning consistency is weak, recommend a daily learning habit.
class WeakLearningConsistencyRule extends MissionRule {
  const WeakLearningConsistencyRule();

  @override
  String get name => 'WeakLearningConsistency';

  @override
  int get priority => 2;

  @override
  MissionRecommendation? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required UserState userState,
  }) {
    final lc = growthSnapshot.learningConsistency;
    final consistencyScore = lc?.score ?? 0.5;
    if (consistencyScore >= 0.5) return null;

    return MissionRecommendation(
      id: 'rule-weak-consistency',
      title: 'Build a Daily Learning Habit',
      description:
          'Your learning consistency is ${(consistencyScore * 100).round()}%. '
          'A short daily session builds momentum.',
      category: MissionCategory.habit,
      priority: MissionPriority.medium,
      difficulty: MissionDifficulty.beginner,
      estimatedDuration: 15,
      rewardXP: 25,
      reason:
          'Learning consistency is ${(consistencyScore * 100).round()}% — '
          'daily practice builds lasting habits.',
      score: MissionScore(
        score: 0.7,
        weight: 2,
        confidence: 0.7,
      ),
      impact: const MissionImpact(
        habitGain: 0.4,
        growthGain: 0.2,
      ),
      confidence: 0.7,
      unlocks: const ['Streak tracking', 'Consistency rewards'],
      ruleName: name,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rule 5: Low Interview Readiness
// ─────────────────────────────────────────────────────────────────────────────

/// If interview readiness is below 50%, recommend interview practice.
class LowInterviewReadinessRule extends MissionRule {
  const LowInterviewReadinessRule();

  @override
  String get name => 'LowInterviewReadiness';

  @override
  int get priority => 2;

  @override
  MissionRecommendation? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required UserState userState,
  }) {
    final interviewScore = growthSnapshot.interview.score;
    if (interviewScore >= 0.5) return null;

    return MissionRecommendation(
      id: 'rule-interview-readiness',
      title: 'Practice Interview Questions',
      description:
          'Your interview readiness is ${(interviewScore * 100).round()}%. '
          'Regular practice builds confidence and improves performance.',
      category: MissionCategory.interview,
      priority: MissionPriority.medium,
      difficulty: MissionDifficulty.medium,
      estimatedDuration: 30,
      rewardXP: 40,
      reason:
          'Interview readiness is ${(interviewScore * 100).round()}% — '
          'practice will improve your confidence and performance.',
      score: MissionScore(
        score: 0.75,
        weight: 2,
        confidence: 0.7,
      ),
      impact: const MissionImpact(
        interviewGain: 0.4,
        careerGain: 0.3,
        growthGain: 0.2,
      ),
      confidence: 0.7,
      unlocks: const ['Mock interviews', 'Interview feedback'],
      ruleName: name,
    );
  }
}
