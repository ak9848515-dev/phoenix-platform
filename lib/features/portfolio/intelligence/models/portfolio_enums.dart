/// Priority level for action items.
enum ActionPriority {
  critical,
  high,
  medium,
  low;

  int get weight {
    switch (this) {
      case ActionPriority.critical:
        return 100;
      case ActionPriority.high:
        return 75;
      case ActionPriority.medium:
        return 50;
      case ActionPriority.low:
        return 25;
    }
  }

  String get displayName {
    switch (this) {
      case ActionPriority.critical:
        return 'Critical';
      case ActionPriority.high:
        return 'High';
      case ActionPriority.medium:
        return 'Medium';
      case ActionPriority.low:
        return 'Low';
    }
  }
}

/// Severity level for skill gaps.
enum GapSeverity {
  critical,
  major,
  moderate,
  minor;

  int get weight {
    switch (this) {
      case GapSeverity.critical:
        return 100;
      case GapSeverity.major:
        return 75;
      case GapSeverity.moderate:
        return 50;
      case GapSeverity.minor:
        return 25;
    }
  }

  String get displayName {
    switch (this) {
      case GapSeverity.critical:
        return 'Critical';
      case GapSeverity.major:
        return 'Major';
      case GapSeverity.moderate:
        return 'Moderate';
      case GapSeverity.minor:
        return 'Minor';
    }
  }
}

/// Priority level for project recommendations.
enum RecommendationPriority {
  high,
  medium,
  low;

  int get weight {
    switch (this) {
      case RecommendationPriority.high:
        return 100;
      case RecommendationPriority.medium:
        return 60;
      case RecommendationPriority.low:
        return 30;
    }
  }

  String get displayName {
    switch (this) {
      case RecommendationPriority.high:
        return 'High';
      case RecommendationPriority.medium:
        return 'Medium';
      case RecommendationPriority.low:
        return 'Low';
    }
  }
}
