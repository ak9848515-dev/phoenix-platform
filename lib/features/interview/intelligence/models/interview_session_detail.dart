import 'interview_enums.dart';
import 'interview_question_detail.dart';

/// Enhanced interview session with full lifecycle tracking.
///
/// Supports practice sessions with timing, answer recording,
/// per-question evaluation, and summary feedback.
class InterviewSessionDetail {
  const InterviewSessionDetail({
    required this.id,
    required this.title,
    this.status = SessionStatus.notStarted,
    this.questions = const [],
    this.durationMinutes = 45,
    this.difficulty = InterviewDifficulty.medium,
    this.focusTopics = const [],
    this.score = 0.0,
    this.questionAccuracy = 0.0,
    this.averageTimePerQuestion = 0,
    this.strengths = const [],
    this.weaknesses = const [],
    this.feedback,
    this.startedAt,
    this.completedAt,
    this.lastUpdated,
  });

  /// Unique session identifier.
  final String id;

  /// Human-readable session title (e.g., "Technical Screening Prep").
  final String title;

  /// Current status of this session.
  final SessionStatus status;

  /// Questions in this session.
  final List<InterviewQuestionDetail> questions;

  /// Target duration in minutes.
  final int durationMinutes;

  /// Difficulty level of this session.
  final InterviewDifficulty difficulty;

  /// Topics this session focuses on.
  final List<String> focusTopics;

  /// Overall session score (0.0 – 1.0).
  final double score;

  /// Question accuracy rate (0.0 – 1.0).
  final double questionAccuracy;

  /// Average time spent per question in seconds.
  final int averageTimePerQuestion;

  /// Strengths identified during this session.
  final List<String> strengths;

  /// Weaknesses identified during this session.
  final List<String> weaknesses;

  /// Overall session feedback text.
  final String? feedback;

  /// When the session was started.
  final DateTime? startedAt;

  /// When the session was completed.
  final DateTime? completedAt;

  /// When the session was last updated.
  final DateTime? lastUpdated;

  /// Number of questions answered (including skipped).
  int get answeredCount => questions.where((q) => q.isAnswered).length;

  /// Number of questions not yet answered.
  int get unansweredCount => questions.length - answeredCount;

  /// Number of skipped questions.
  int get skippedCount => questions.where((q) => q.skipped).length;

  /// Number of questions answered well (score >= 0.7).
  int get wellAnsweredCount => questions.where((q) => q.answeredWell).length;

  /// Whether the session is completed.
  bool get isCompleted => status == SessionStatus.completed || status == SessionStatus.evaluated;

  /// Whether the session is in progress.
  bool get isInProgress => status == SessionStatus.inProgress;

  /// Session duration in seconds (real elapsed time).
  int get elapsedSeconds {
    if (startedAt == null) return 0;
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt!).inSeconds;
  }

  /// Creates a copy with the given fields replaced.
  InterviewSessionDetail copyWith({
    String? id,
    String? title,
    SessionStatus? status,
    List<InterviewQuestionDetail>? questions,
    int? durationMinutes,
    InterviewDifficulty? difficulty,
    List<String>? focusTopics,
    double? score,
    double? questionAccuracy,
    int? averageTimePerQuestion,
    List<String>? strengths,
    List<String>? weaknesses,
    String? feedback,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastUpdated,
  }) {
    return InterviewSessionDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      questions: questions ?? this.questions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      focusTopics: focusTopics ?? this.focusTopics,
      score: score ?? this.score,
      questionAccuracy: questionAccuracy ?? this.questionAccuracy,
      averageTimePerQuestion: averageTimePerQuestion ?? this.averageTimePerQuestion,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      feedback: feedback ?? this.feedback,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InterviewSessionDetail && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InterviewSessionDetail(id: $id, status: ${status.name}, score: $score, answered: $answeredCount/${questions.length})';
}
