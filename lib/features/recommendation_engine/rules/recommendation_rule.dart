import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';

import '../models/recommendation_result.dart';

/// Abstract interface for recommendation rules.
///
/// Each rule evaluates the current state and optionally produces a
/// [RecommendationResult] if its conditions are met.
///
/// Rules are stateless — all state comes from input snapshots.
abstract class RecommendationRule {
  const RecommendationRule();

  /// Unique name for this rule.
  String get name;

  /// Evaluation priority (higher = evaluated first).
  int get priority => 1;

  /// Evaluates and returns a recommendation if conditions are met.
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  });
}
