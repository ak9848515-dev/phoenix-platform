import 'interview_enums.dart';

/// A weak topic detected by the Interview Intelligence Engine.
///
/// Captures the subject, severity, patterns (repeated mistakes,
/// frequently missed questions, low confidence), and action recommendations.
class WeakTopic {
  const WeakTopic({
    required this.subject,
    this.severity = WeakTopicSeverity.medium,
    this.repeatedMistakes = const [],
    this.frequentlyMissedQuestions = const [],
    this.lowConfidenceAreas = const [],
    this.recommendedLearning = const [],
    this.recommendedPractice = const [],
    this.recommendedMissions = const [],
    this.missedCount = 0,
    this.accuracyRate = 0.0,
  });

  /// The subject or skill area (e.g., "System Design", "Data Structures").
  final String subject;

  /// How critical this weak topic is.
  final WeakTopicSeverity severity;

  /// Specific mistakes the user keeps making.
  final List<String> repeatedMistakes;

  /// Questions the user frequently misses.
  final List<String> frequentlyMissedQuestions;

  /// Topics where confidence is low.
  final List<String> lowConfidenceAreas;

  /// Recommended learning resources or courses.
  final List<String> recommendedLearning;

  /// Recommended practice exercises.
  final List<String> recommendedPractice;

  /// Recommended Phoenix missions to address this gap.
  final List<String> recommendedMissions;

  /// How many times this topic was missed across sessions.
  final int missedCount;

  /// Accuracy rate for this topic (0.0 – 1.0).
  final double accuracyRate;

  /// Creates a copy with the given fields replaced.
  WeakTopic copyWith({
    String? subject,
    WeakTopicSeverity? severity,
    List<String>? repeatedMistakes,
    List<String>? frequentlyMissedQuestions,
    List<String>? lowConfidenceAreas,
    List<String>? recommendedLearning,
    List<String>? recommendedPractice,
    List<String>? recommendedMissions,
    int? missedCount,
    double? accuracyRate,
  }) {
    return WeakTopic(
      subject: subject ?? this.subject,
      severity: severity ?? this.severity,
      repeatedMistakes: repeatedMistakes ?? this.repeatedMistakes,
      frequentlyMissedQuestions:
          frequentlyMissedQuestions ?? this.frequentlyMissedQuestions,
      lowConfidenceAreas: lowConfidenceAreas ?? this.lowConfidenceAreas,
      recommendedLearning: recommendedLearning ?? this.recommendedLearning,
      recommendedPractice: recommendedPractice ?? this.recommendedPractice,
      recommendedMissions: recommendedMissions ?? this.recommendedMissions,
      missedCount: missedCount ?? this.missedCount,
      accuracyRate: accuracyRate ?? this.accuracyRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeakTopic &&
          other.subject == subject &&
          other.severity == severity;

  @override
  int get hashCode => Object.hash(subject, severity);

  @override
  String toString() =>
      'WeakTopic(subject: $subject, severity: ${severity.name}, accuracy: $accuracyRate)';
}
