/// A single quiz question within a lesson.
///
/// Immutable. Supports multiple-choice questions with one correct answer.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.points = 10,
  });

  /// Unique identifier for this question.
  final String id;

  /// The question text displayed to the user.
  final String question;

  /// Available answer choices.
  final List<String> options;

  /// Index (0-based) of the correct answer in [options].
  final int correctAnswerIndex;

  /// Explanation shown after answering.
  final String explanation;

  /// Points awarded for a correct answer.
  final int points;

  /// Whether the given answer index is correct.
  bool isCorrect(int answerIndex) => answerIndex == correctAnswerIndex;

  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    int? points,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'points': points,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List),
      correctAnswerIndex: map['correctAnswerIndex'] as int,
      explanation: map['explanation'] as String,
      points: map['points'] as int? ?? 10,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestion && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'QuizQuestion(id: $id)';
}
