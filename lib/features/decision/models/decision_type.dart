/// Types of decisions the Decision Intelligence Engine can evaluate.
///
/// Architecture allows additional types to be added without breaking
/// existing code — just add a new enum value.
enum DecisionType {
  /// Career path or job transition decisions.
  career,

  /// Learning path or course selection decisions.
  learning,

  /// Job offer evaluation decisions.
  jobOffer,

  /// Interview preparation strategy decisions.
  interview,

  /// Financial planning or budgeting decisions.
  financial,

  /// Business strategy or startup decisions.
  business,

  /// Technology stack or tool selection decisions.
  technology,

  /// Project planning or methodology decisions.
  project,

  /// Personal growth or lifestyle decisions.
  personal,

  /// Health and wellness decisions.
  health,

  /// Investment or portfolio allocation decisions.
  investment,

  /// Custom user-defined decisions.
  custom;

  /// Human-readable label for the decision type.
  String get label {
    switch (this) {
      case DecisionType.career:
        return 'Career';
      case DecisionType.learning:
        return 'Learning';
      case DecisionType.jobOffer:
        return 'Job Offer';
      case DecisionType.interview:
        return 'Interview';
      case DecisionType.financial:
        return 'Financial';
      case DecisionType.business:
        return 'Business';
      case DecisionType.technology:
        return 'Technology';
      case DecisionType.project:
        return 'Project';
      case DecisionType.personal:
        return 'Personal';
      case DecisionType.health:
        return 'Health';
      case DecisionType.investment:
        return 'Investment';
      case DecisionType.custom:
        return 'Custom';
    }
  }

  /// Parses from a string (for serialization).
  static DecisionType fromString(String value) {
    return DecisionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => DecisionType.custom,
    );
  }
}
