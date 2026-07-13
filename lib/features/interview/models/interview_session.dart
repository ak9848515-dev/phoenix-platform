import 'interview_question.dart';

/// Type of interview session.
enum InterviewType { technical, behavioral, hr, systemDesign, pluginSpecific }

/// Immutable representation of an interview session.
class InterviewSession {
  const InterviewSession({
    required this.id,
    required this.identityId,
    this.interviewType = InterviewType.technical,
    this.questions = const [],
    this.durationMinutes = 45,
    this.difficulty = 0.5,
    this.score = 0.0,
    this.completed = false,
  });

  /// Unique identifier.
  final String id;

  /// Identity this session belongs to.
  final String identityId;

  /// Type of interview.
  final InterviewType interviewType;

  /// Questions in this session.
  final List<InterviewQuestion> questions;

  /// Duration in minutes.
  final int durationMinutes;

  /// Difficulty level from 0.0 to 1.0.
  final double difficulty;

  /// Score from 0.0 to 1.0 if completed.
  final double score;

  /// Whether this session has been completed.
  final bool completed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterviewSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InterviewSession(id: $id, type: ${interviewType.name}, '
      'questions: ${questions.length})';
}
