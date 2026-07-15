import 'conversation_intent.dart' show ConversationIntent;

/// Role of a message sender in the conversation.
enum MessageRole {
  user,
  mentor;

  bool get isUser => this == MessageRole.user;
  bool get isMentor => this == MessageRole.mentor;
}

/// A single message in a conversation with the AI mentor.
///
/// Immutable. Contains the message text, role, detected intent,
/// confidence, and any structured data attached to the response.
class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    this.intent,
    this.confidence = 0.0,
    this.timestamp,
    this.suggestions = const [],
    this.explanationId,
    this.sourceServices = const [],
    this.actionable = false,
  });

  /// Unique message identifier.
  final String id;

  /// Whether this is from the user or the mentor.
  final MessageRole role;

  /// The message text content.
  final String content;

  /// Detected intent (mentor messages may not have user intent).
  final ConversationIntent? intent;

  /// Confidence score for the detected intent (0.0–1.0).
  final double confidence;

  /// When this message was created.
  final DateTime? timestamp;

  /// Suggested follow-up prompts (mentor messages only).
  final List<String> suggestions;

  /// ID of the explanation if this message explains a recommendation.
  final String? explanationId;

  /// Source services that informed this response.
  final List<String> sourceServices;

  /// Whether this message contains actionable content.
  final bool actionable;

  /// Creates a copy with the given fields replaced.
  ConversationMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    ConversationIntent? intent,
    double? confidence,
    DateTime? timestamp,
    List<String>? suggestions,
    String? explanationId,
    List<String>? sourceServices,
    bool? actionable,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      intent: intent ?? this.intent,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      suggestions: suggestions ?? this.suggestions,
      explanationId: explanationId ?? this.explanationId,
      sourceServices: sourceServices ?? this.sourceServices,
      actionable: actionable ?? this.actionable,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role.name,
        'content': content,
        'intent': intent?.name,
        'confidence': confidence,
        'timestamp': timestamp?.toIso8601String(),
        'suggestions': suggestions,
        'explanationId': explanationId,
        'sourceServices': sourceServices,
        'actionable': actionable,
      };

  factory ConversationMessage.fromMap(Map<String, dynamic> map) =>
      ConversationMessage(
        id: map['id'] as String,
        role: MessageRole.values.firstWhere(
            (r) => r.name == map['role'],
            orElse: () => MessageRole.user),
        content: map['content'] as String,
        intent: map['intent'] != null
            ? ConversationIntent.values.firstWhere(
                (i) => i.name == map['intent'],
                orElse: () => ConversationIntent.general)
            : null,
        confidence: map['confidence'] as double? ?? 0.0,
        timestamp: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'] as String)
            : null,
        suggestions: List<String>.from(map['suggestions'] as List? ?? []),
        explanationId: map['explanationId'] as String?,
        sourceServices: List<String>.from(map['sourceServices'] as List? ?? []),
        actionable: map['actionable'] as bool? ?? false,
      );
}
