/// A single message in an AI Mentor conversation.
///
/// Persisted through the existing SharedPreferences storage.
/// No business logic — pure data.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  /// Unique message identifier.
  final String id;

  /// Who sent this message: 'user' or 'assistant'.
  final String role;

  /// The message text content.
  final String content;

  /// When this message was created.
  final DateTime timestamp;

  /// Whether this message is from the user.
  bool get isUser => role == 'user';

  /// Whether this message is from the AI mentor.
  bool get isAssistant => role == 'assistant';

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates from a JSON-compatible map.
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ChatMessage(role: $role, content: ${content.length} chars)';
}
