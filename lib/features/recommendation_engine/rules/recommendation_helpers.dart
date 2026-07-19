import 'package:phoenix_platform/features/mission_engine/models/mission_category.dart';

import '../models/recommendation_category.dart';

/// Maps MissionCategory to RecommendationCategory.
RecommendationCategory mapMissionCategory(MissionCategory cat) {
  switch (cat) {
    case MissionCategory.learning:
    case MissionCategory.practice:
    case MissionCategory.reflection:
      return RecommendationCategory.learning;
    case MissionCategory.career:
      return RecommendationCategory.career;
    case MissionCategory.build:
    case MissionCategory.portfolio:
      return RecommendationCategory.portfolio;
    case MissionCategory.interview:
      return RecommendationCategory.interview;
    case MissionCategory.habit:
      return RecommendationCategory.habit;
    case MissionCategory.resume:
      return RecommendationCategory.career;
    case MissionCategory.daily:
    case MissionCategory.weekly:
      return RecommendationCategory.review;
    case MissionCategory.custom:
      return RecommendationCategory.learning;
  }
}
