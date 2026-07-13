/// Immutable representation of interview feedback.
class InterviewFeedback {
  const InterviewFeedback({
    required this.id,
    required this.sessionId,
    this.technicalScore = 0.0,
    this.behavioralScore = 0.0,
    this.communicationScore = 0.0,
    this.overallScore = 0.0,
    this.strengths = const [],
    this.improvements = const [],
    this.summary = '',
  });

  /// Unique identifier.
  final String id;

  /// Session this feedback belongs to.
  final String sessionId;

  /// Technical performance score from 0.0 to 1.0.
  final double technicalScore;

  /// Behavioral performance score from 0.0 to 1.0.
  final double behavioralScore;

  /// Communication performance score from 0.0 to 1.0.
  final double communicationScore;

  /// Overall score from 0.0 to 1.0.
  final double overallScore;

  /// Strengths demonstrated during the interview.
  final List<String> strengths;

  /// Areas for improvement.
  final List<String> improvements;

  /// Short feedback summary.
  final String summary;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterviewFeedback && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'InterviewFeedback(id: $id, overall: $overallScore)';
}
