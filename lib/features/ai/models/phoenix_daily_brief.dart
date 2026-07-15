import 'daily_recommendation.dart' show DailyRecommendation;

/// Immutable daily intelligence brief produced by [PhoenixAIService].
///
/// Generated once per day (or on demand) from all six Phoenix platform
/// services via the [DailyBriefEngine]. Contains no persistence — it is
/// computed from existing data.
///
/// Each field is a human-readable string designed for presentation in
/// the Phoenix Shell daily briefing screen.
class PhoenixDailyBrief {
  const PhoenixDailyBrief({
    required this.todaysFocus,
    required this.learningRecommendation,
    required this.habitInsight,
    required this.knowledgeInsight,
    required this.timelineReminder,
    required this.decisionFollowUp,
    required this.overallDailySummary,
    this.recommendations = const [],
    this.confidenceScore = 0.0,
    this.generatedAt,
  });

  /// The single most important action for today.
  ///
  /// Determined by [DailyBriefEngine.topFocus] from all collected
  /// recommendations.
  final String todaysFocus;

  /// A personalised learning suggestion.
  ///
  /// Drawn from [DailyBriefEngine] academy-scoped recommendations.
  final String learningRecommendation;

  /// A behavioural insight about the user's habits.
  ///
  /// Drawn from [DailyBriefEngine] habit-scoped recommendations.
  final String habitInsight;

  /// A knowledge-graph insight about the user's personal knowledge.
  ///
  /// Drawn from [DailyBriefEngine] knowledge-scoped recommendations.
  final String knowledgeInsight;

  /// A reminder from the user's timeline.
  ///
  /// Drawn from [DailyBriefEngine] timeline-scoped recommendations.
  final String timelineReminder;

  /// A follow-up prompt for a recent or pending decision.
  ///
  /// Drawn from [DailyBriefEngine] decision-scoped recommendations.
  final String decisionFollowUp;

  /// A holistic one-paragraph summary of the user's daily state.
  final String overallDailySummary;

  /// All scored and ranked recommendations from the [DailyBriefEngine].
  ///
  /// Ordered by priority score descending. Presentation layers can use
  /// this for richer UI (badges, progress bars, priority indicators).
  final List<DailyRecommendation> recommendations;

  /// Overall confidence in this brief (0.0–1.0).
  ///
  /// Computed as the average confidence of all recommendations.
  final double confidenceScore;

  /// When this brief was generated.
  final DateTime? generatedAt;

  /// Serializes to a JSON-compatible map (for diagnostics / display only).
  Map<String, dynamic> toMap() {
    return {
      'todaysFocus': todaysFocus,
      'learningRecommendation': learningRecommendation,
      'habitInsight': habitInsight,
      'knowledgeInsight': knowledgeInsight,
      'timelineReminder': timelineReminder,
      'decisionFollowUp': decisionFollowUp,
      'overallDailySummary': overallDailySummary,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'confidenceScore': confidenceScore,
      'generatedAt': generatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhoenixDailyBrief &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode => generatedAt.hashCode;

  @override
  String toString() =>
      'PhoenixDailyBrief(generatedAt: $generatedAt, '
      'focus: ${todaysFocus.length} chars, '
      'recommendations: ${recommendations.length})';
}
