import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';

import '../models/recommendation_reason.dart';
import '../models/recommendation_result.dart';
import '../models/recommendation_score.dart';
import '../models/recommendation_urgency.dart';
import 'recommendation_rule.dart';
import 'recommendation_helpers.dart';

/// If mission confidence > 90%, surface as very high priority.
class MissionConfidenceRule extends RecommendationRule {
  const MissionConfidenceRule();

  @override
  String get name => 'MissionConfidence';

  @override
  int get priority => 4;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    final mission = missionSnapshot.currentMission;
    if (mission == null || mission.confidence < 0.9) return null;

    return RecommendationResult(
      id: 'rec-mission-confidence',
      title: mission.title,
      description: mission.description,
      category: mapMissionCategory(mission.category),
      score: RecommendationScore(
        priority: 10,
        urgency: const RecommendationUrgency(
          score: 0.9,
          reason: 'High confidence mission — recommended with certainty.',
          isTimeSensitive: true,
        ),
        confidence: mission.confidence,
        estimatedBenefit: mission.impact.overallImpact,
        priorityWeight: 1.5,
      ),
      reason: RecommendationReason(
        why: mission.reason,
        whyNow: 'This mission has high confidence (${(mission.confidence * 100).round()}%).',
        improvement: 'Completing this will improve growth by ${(mission.impact.overallImpact * 100).round()}%.',
        unlock: mission.unlocks.isNotEmpty
            ? mission.unlocks.join(', ')
            : 'Next-level missions become available.',
        template: 'MissionConfidence',
      ),
      missionId: mission.id,
      estimatedDuration: mission.estimatedDuration,
      careerImpact: mission.impact.careerGain,
      learningImpact: mission.impact.knowledgeGain,
      growthImpact: mission.impact.growthGain,
      ruleName: name,
    );
  }
}
