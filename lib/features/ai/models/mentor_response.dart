import 'mentor_suggestion.dart' show MentorSuggestion;
import 'mentor_topic.dart' show MentorTopic;

/// A complete structured response from the AI mentor.
///
/// Contains a natural-language message plus structured suggestions
/// for the user to act on. Immutable. No persistence.
class MentorResponse {
  const MentorResponse({
    required this.message,
    this.topic = MentorTopic.daily,
    this.suggestions = const [],
    this.confidence = 0.0,
    this.insightCount = 0,
  });

  /// Natural-language mentor message.
  final String message;

  /// The primary topic of this response.
  final MentorTopic topic;

  /// Actionable suggestions derived from intelligence.
  final List<MentorSuggestion> suggestions;

  /// Overall confidence in this response (0.0–1.0).
  final double confidence;

  /// Number of intelligence signals that informed this response.
  final int insightCount;

  /// Whether the response has any actionable suggestions.
  bool get hasSuggestions => suggestions.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentorResponse && other.message == message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() =>
      'MentorResponse(topic: $topic, suggestions: ${suggestions.length}, '
      'confidence: $confidence)';
}
