import 'interview_enums.dart';

/// Enhanced interview question with answer recording, scoring, and feedback.
///
/// Extends the concept of the existing [InterviewQuestion] with
/// session-specific runtime data (answer, time spent, score, feedback).
class InterviewQuestionDetail {
  const InterviewQuestionDetail({
    required this.id,
    required this.question,
    this.category = InterviewQuestionCategory.technical,
    this.difficulty = InterviewDifficulty.medium,
    this.topics = const [],
    this.suggestedAnswer,
    this.tips = const [],
    this.userAnswer,
    this.timeSpentSeconds = 0,
    this.score = 0.0,
    this.feedback,
    this.skipped = false,
  });

  /// Unique identifier.
  final String id;

  /// The question text.
  final String question;

  /// Category of question.
  final InterviewQuestionCategory category;

  /// Difficulty level.
  final InterviewDifficulty difficulty;

  /// Topics or skills covered.
  final List<String> topics;

  /// Optional suggested answer outline.
  final String? suggestedAnswer;

  /// Tips for answering.
  final List<String> tips;

  /// The user's recorded answer (free text or transcript).
  final String? userAnswer;

  /// Time spent answering in seconds.
  final int timeSpentSeconds;

  /// Score for this question (0.0 – 1.0).
  final double score;

  /// Optional per-question feedback text.
  final String? feedback;

  /// Whether the user skipped this question.
  final bool skipped;

  /// Whether the question has been answered (has user answer or skipped).
  bool get isAnswered => userAnswer != null || skipped;

  /// Whether the question was answered well (score >= 0.7).
  bool get answeredWell => score >= 0.7;

  /// Creates a copy with the given fields replaced.
  InterviewQuestionDetail copyWith({
    String? id,
    String? question,
    InterviewQuestionCategory? category,
    InterviewDifficulty? difficulty,
    List<String>? topics,
    String? suggestedAnswer,
    List<String>? tips,
    String? userAnswer,
    int? timeSpentSeconds,
    double? score,
    String? feedback,
    bool? skipped,
  }) {
    return InterviewQuestionDetail(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      topics: topics ?? this.topics,
      suggestedAnswer: suggestedAnswer ?? this.suggestedAnswer,
      tips: tips ?? this.tips,
      userAnswer: userAnswer ?? this.userAnswer,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
      skipped: skipped ?? this.skipped,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InterviewQuestionDetail && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InterviewQuestionDetail(id: $id, category: ${category.name}, score: $score)';
}
