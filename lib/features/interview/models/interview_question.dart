/// Type of interview question.
enum QuestionType { technical, behavioral, hr, systemDesign, pluginSpecific }

/// Immutable representation of an interview question.
class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.question,
    this.questionType = QuestionType.technical,
    this.difficulty = 0.5,
    this.topics = const [],
    this.suggestedAnswer,
    this.tips = const [],
  });

  /// Unique identifier.
  final String id;

  /// The interview question text.
  final String question;

  /// Category of question.
  final QuestionType questionType;

  /// Difficulty level from 0.0 (easy) to 1.0 (hard).
  final double difficulty;

  /// Topics or skills this question covers.
  final List<String> topics;

  /// Optional suggested answer outline.
  final String? suggestedAnswer;

  /// Tips for answering this question.
  final List<String> tips;

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'question': question,
      'questionType': questionType.name,
      'difficulty': difficulty,
      'topics': topics,
      'suggestedAnswer': suggestedAnswer,
      'tips': tips,
    };
  }

  /// Creates from a JSON-compatible map.
  factory InterviewQuestion.fromMap(Map<String, dynamic> map) {
    return InterviewQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      questionType: QuestionType.values.firstWhere(
        (t) => t.name == map['questionType'],
        orElse: () => QuestionType.technical,
      ),
      difficulty: (map['difficulty'] as num?)?.toDouble() ?? 0.5,
      topics: map['topics'] != null
          ? List<String>.from(map['topics'] as List)
          : const [],
      suggestedAnswer: map['suggestedAnswer'] as String?,
      tips: map['tips'] != null
          ? List<String>.from(map['tips'] as List)
          : const [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterviewQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'InterviewQuestion(id: $id, type: ${questionType.name})';
}
