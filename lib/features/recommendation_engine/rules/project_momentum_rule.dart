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

/// Recommends continuing work on active projects based on momentum.
///
/// Consumed signals:
/// - [UserState.missions] — active missions for momentum
/// - [UserState.totalXp] — recent XP velocity
/// - [UserState.lastActivityAt] — engagement recency
/// - [GrowthSnapshot.projects] — project completion score
/// - [GrowthSnapshot.mission] — mission momentum
///
/// High momentum = high confidence. Low momentum = smaller, easier task.
class ProjectMomentumRule extends RecommendationRule {
  const ProjectMomentumRule();

  @override
  String get name => 'ProjectMomentum';

  @override
  int get priority => 4;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    // 1. Calculate momentum score
    final hoursSinceActivity = userState.lastActivityAt != null
        ? DateTime.now().difference(userState.lastActivityAt!).inHours
        : 72;

    final recencyScore = (48.0 / (hoursSinceActivity + 1)).clamp(0.0, 1.0);

    // XP velocity (how much XP earned recently — use totalXp as proxy)
    final xpVelocity = (userState.totalXp / 1000.0).clamp(0.0, 1.0);

    // Project progress
    final projectScore = growthSnapshot.projects.score;

    // Active missions signal
    final activeMissions =
        userState.missions.where((m) => m.isActionable).toList();
    final hasMomentum = activeMissions.any((m) => m.isActionable);
    final missionMomentum = hasMomentum ? 0.3 : 0.0;

    // 2. Composite momentum
    final momentumScore =
        (recencyScore * 0.4 + xpVelocity * 0.3 + projectScore * 0.3 +
            missionMomentum);

    // If momentum is very low, recommend a small task to restart
    if (momentumScore < 0.2) {
      return RecommendationResult(
        id: 'rec-restart-momentum',
        title: 'Quick Win: Small Task',
        description:
            'It\'s been a while since your last activity. A small 10-minute '
            'task is the best way to rebuild momentum.',
        category: RecommendationCategory.learning,
        score: RecommendationScore(
          priority: 8,
          urgency: const RecommendationUrgency(
            score: 0.8,
            reason: 'Building momentum now prevents longer gaps.',
            isTimeSensitive: true,
          ),
          confidence: 0.7,
          estimatedBenefit: 0.4,
          priorityWeight: 1.3,
        ),
        reason: const RecommendationReason(
          why: 'Activity streaks are powerful for habit formation.',
          whyNow: 'A small win today prevents a longer inactivity gap.',
          improvement: 'Consistency strengthens all growth dimensions.',
          unlock: 'Streak bonuses and momentum rewards.',
          template: 'RestartMomentum',
        ),
        estimatedDuration: 10,
        learningImpact: 0.2,
        growthImpact: 0.3,
        careerImpact: 0.1,
        ruleName: name,
      );
    }

    // If momentum is strong, recommend continuing current work
    if (momentumScore >= 0.5) {
      final activeMission = activeMissions.isNotEmpty
          ? activeMissions.first
          : null;

      if (activeMission != null) {
        return RecommendationResult(
          id: 'rec-continue-momentum',
          title: 'Continue: ${activeMission.title}',
          description:
              'You have strong momentum! Continue your active mission '
              'to maintain your streak and make progress.',
          category: RecommendationCategory.learning,
          score: RecommendationScore(
            priority: 9,
            urgency: RecommendationUrgency(
              score: 0.7 * momentumScore,
              reason: 'Strong momentum — keep going!',
              isTimeSensitive: false,
            ),
            confidence: 0.85,
            estimatedBenefit: 0.5,
            priorityWeight: 1.4,
          ),
          reason: const RecommendationReason(
            why: 'You have active momentum and should capitalize on it.',
            whyNow: 'Continuing now is easier than restarting later.',
            improvement: 'Steady progress compounds into significant growth.',
            unlock: 'Mission completion rewards and streak milestones.',
            template: 'ContinueMomentum',
          ),
          missionId: activeMission.id,
          estimatedDuration: 20,
          learningImpact: 0.3,
          growthImpact: 0.4,
          careerImpact: 0.2,
          ruleName: name,
        );
      }
    }

    // Moderate momentum — recommend a focused session
    return RecommendationResult(
      id: 'rec-focused-session',
      title: 'Focused Learning Session',
      description:
          'Build on your current engagement with a focused 25-minute '
          'learning session on your primary growth area.',
      category: RecommendationCategory.learning,
      score: RecommendationScore(
        priority: 6,
        urgency: RecommendationUrgency(
          score: 0.5 * momentumScore,
          reason: 'Moderate momentum — a focused session accelerates growth.',
          isTimeSensitive: false,
        ),
        confidence: 0.7,
        estimatedBenefit: 0.3,
        priorityWeight: 1.0,
      ),
      reason: const RecommendationReason(
        why: 'Focused sessions are highly effective for learning.',
        whyNow: 'Your engagement level is good for a productive session.',
        improvement: 'Deep focus improves retention and skill acquisition.',
        unlock: 'Advanced topics and project opportunities.',
        template: 'FocusedSession',
      ),
      estimatedDuration: 25,
      learningImpact: 0.4,
      growthImpact: 0.3,
      careerImpact: 0.2,
      ruleName: name,
    );
  }
}
