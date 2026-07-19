/// Enhanced interview feedback with per-question detail and AI coach output.
///
/// Contains strengths, weak areas, communication tips, technical feedback,
/// behavioral feedback, confidence score, recommended improvements,
/// and a next practice plan.
class InterviewFeedbackDetail {
  const InterviewFeedbackDetail({
    required this.sessionId,
    this.technicalScore = 0.0,
    this.behavioralScore = 0.0,
    this.communicationScore = 0.0,
    this.confidenceScore = 0.0,
    this.preparationScore = 0.0,
    this.overallScore = 0.0,
    this.strengths = const [],
    this.weakAreas = const [],
    this.communicationTips = const [],
    this.technicalFeedback = const [],
    this.behavioralFeedback = const [],
    this.questionFeedback = const {},
    this.improvementPlan = const [],
    this.nextPracticeFocus = '',
    this.summary = '',
  });

  /// Session this feedback belongs to.
  final String sessionId;

  /// Technical performance score (0.0 – 1.0).
  final double technicalScore;

  /// Behavioral performance score (0.0 – 1.0).
  final double behavioralScore;

  /// Communication ability score (0.0 – 1.0).
  final double communicationScore;

  /// Confidence level score (0.0 – 1.0).
  final double confidenceScore;

  /// Preparation level score (0.0 – 1.0).
  final double preparationScore;

  /// Overall score (0.0 – 1.0).
  final double overallScore;

  /// Key strengths demonstrated.
  final List<String> strengths;

  /// Areas needing improvement.
  final List<String> weakAreas;

  /// Communication-specific tips.
  final List<String> communicationTips;

  /// Technical-specific feedback items.
  final List<String> technicalFeedback;

  /// Behavioral-specific feedback items.
  final List<String> behavioralFeedback;

  /// Per-question feedback keyed by question ID.
  final Map<String, String> questionFeedback;

  /// Ordered improvement steps.
  final List<String> improvementPlan;

  /// What to focus on in the next practice session.
  final String nextPracticeFocus;

  /// Short feedback summary.
  final String summary;

  /// Whether the session was good (overall >= 0.7).
  bool get isGoodSession => overallScore >= 0.7;

  /// Whether the session needs significant improvement (overall < 0.4).
  bool get needsImprovement => overallScore < 0.4;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewFeedbackDetail && other.sessionId == sessionId;

  @override
  int get hashCode => sessionId.hashCode;

  @override
  String toString() =>
      'InterviewFeedbackDetail(sessionId: $sessionId, overall: $overallScore, good: $isGoodSession)';
}
