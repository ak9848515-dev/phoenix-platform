import 'conversation_context.dart' show ConversationContext;
import 'conversation_message.dart' show ConversationMessage;

/// State of a conversation session.
enum SessionState {
  active,
  waiting,
  completed,
}

/// A conversation session with the AI mentor.
///
/// Tracks the full conversation flow including messages, context,
/// and state transitions. Immutable — state changes produce a new session.
class ConversationSession {
  const ConversationSession({
    required this.id,
    this.messages = const [],
    this.context,
    this.state = SessionState.active,
    this.createdAt,
    this.lastActivityAt,
  });

  /// Unique session identifier.
  final String id;

  /// Ordered list of messages in this session.
  final List<ConversationMessage> messages;

  /// Current context snapshot.
  final ConversationContext? context;

  /// Current session state.
  final SessionState state;

  /// When this session was created.
  final DateTime? createdAt;

  /// When the last activity occurred.
  final DateTime? lastActivityAt;

  /// The last user message, if any.
  ConversationMessage? get lastUserMessage => messages.isEmpty
      ? null
      : messages.reversed.where((m) => m.role.isUser).firstOrNull;

  /// The last mentor response, if any.
  ConversationMessage? get lastMentorMessage => messages.isEmpty
      ? null
      : messages.reversed.where((m) => m.role.isMentor).firstOrNull;

  /// Number of messages in the session.
  int get messageCount => messages.length;

  /// Whether the session is active.
  bool get isActive => state == SessionState.active;

  /// Whether the session is waiting for a response.
  bool get isWaiting => state == SessionState.waiting;

  /// Returns messages for the context window (last N).
  List<ConversationMessage> contextWindow(int maxMessages) {
    if (messages.length <= maxMessages) return messages;
    return messages.sublist(messages.length - maxMessages);
  }

  /// Creates a copy with the given fields replaced.
  ConversationSession copyWith({
    String? id,
    List<ConversationMessage>? messages,
    ConversationContext? context,
    SessionState? state,
    DateTime? createdAt,
    DateTime? lastActivityAt,
  }) {
    return ConversationSession(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      context: context ?? this.context,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  ConversationSession addMessage(ConversationMessage message) {
    return copyWith(
      messages: [...messages, message],
      lastActivityAt: message.timestamp ?? DateTime.now(),
    );
  }

  ConversationSession withContext(ConversationContext newContext) {
    return copyWith(context: newContext);
  }

  ConversationSession withState(SessionState newState) {
    return copyWith(state: newState);
  }
}
