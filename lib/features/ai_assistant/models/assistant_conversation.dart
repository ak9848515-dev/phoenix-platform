import 'dart:convert';

import 'assistant_response.dart';

/// A single message in an assistant conversation.
///
/// Extends [ChatMessage] semantics but adds structured metadata
/// from the Phoenix Assistant pipeline.
class AssistantMessage {
  const AssistantMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.responseType,
    this.confidence,
    this.suggestions = const [],
    this.providerName,
    this.tokensUsed,
  });

  /// Unique message identifier.
  final String id;

  /// 'user' or 'assistant'.
  final String role;

  /// Message text content.
  final String content;

  /// When this message was created.
  final DateTime timestamp;

  /// Response type (assistant messages only).
  final AssistantResponseType? responseType;

  /// Confidence score (assistant messages only).
  final double? confidence;

  /// Action suggestions (assistant messages only).
  final List<AssistantSuggestion> suggestions;

  /// AI provider used (assistant messages only).
  final String? providerName;

  /// Token count for this message.
  final int? tokensUsed;

  /// Whether this message is from the user.
  bool get isUser => role == 'user';

  /// Whether this message is from the assistant.
  bool get isAssistant => role == 'assistant';

  // ── Serialization ─────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        if (responseType != null) 'responseType': responseType!.name,
        if (confidence != null) 'confidence': confidence,
        if (suggestions.isNotEmpty)
          'suggestions': suggestions.map((s) => s.toJson()).toList(),
        if (providerName != null) 'providerName': providerName,
        if (tokensUsed != null) 'tokensUsed': tokensUsed,
      };

  factory AssistantMessage.fromJson(Map<String, dynamic> json) =>
      AssistantMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        responseType: json['responseType'] != null
            ? AssistantResponseType.values.firstWhere(
                (t) => t.name == json['responseType'],
                orElse: () => AssistantResponseType.general,
              )
            : null,
        confidence: json['confidence'] as double?,
        suggestions: json['suggestions'] != null
            ? (json['suggestions'] as List)
                .map((s) => AssistantSuggestion.fromJson(s as Map<String, dynamic>))
                .toList()
            : const [],
        providerName: json['providerName'] as String?,
        tokensUsed: json['tokensUsed'] as int?,
      );

  /// Creates a user message.
  factory AssistantMessage.user({required String id, required String content}) =>
      AssistantMessage(
        id: id,
        role: 'user',
        content: content,
        timestamp: DateTime.now(),
      );

  /// Creates an assistant message from a [PhoenixAssistantResponse].
  factory AssistantMessage.fromResponse({
    required String id,
    required PhoenixAssistantResponse response,
  }) =>
      AssistantMessage(
        id: id,
        role: 'assistant',
        content: response.message,
        timestamp: response.generatedAt,
        responseType: response.responseType,
        confidence: response.confidence,
        suggestions: response.suggestions,
        providerName: response.providerName,
        tokensUsed: response.tokensUsed,
      );

  @override
  String toString() =>
      'AssistantMessage(role: $role, type: ${responseType?.displayName ?? "text"})';
}

/// A complete assistant conversation with metadata.
///
/// Stores messages, context version, provider info, and timestamps
/// for the entire conversation session.
class AssistantConversation {
  const AssistantConversation({
    required this.id,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.contextVersion,
    this.providerName,
    this.totalTokensUsed = 0,
  });

  /// Unique conversation identifier.
  final String id;

  /// Ordered list of messages in this conversation.
  final List<AssistantMessage> messages;

  /// When the conversation was started.
  final DateTime createdAt;

  /// When the conversation was last updated.
  final DateTime updatedAt;

  /// Context version used during generation.
  final int? contextVersion;

  /// AI provider used.
  final String? providerName;

  /// Total tokens consumed in this conversation.
  final int totalTokensUsed;

  /// Creates a new empty conversation.
  factory AssistantConversation.createNew() {
    final now = DateTime.now();
    return AssistantConversation(
      id: 'conv-${now.millisecondsSinceEpoch}',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Adds a message and returns a new [AssistantConversation]
  /// with the message appended and [updatedAt] refreshed.
  AssistantConversation withMessage(AssistantMessage message) {
    final newTokens = (message.tokensUsed ?? 0);
    return AssistantConversation(
      id: id,
      messages: [...messages, message],
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      contextVersion: contextVersion,
      providerName: message.providerName ?? providerName,
      totalTokensUsed: totalTokensUsed + newTokens,
    );
  }

  /// The latest assistant message, if any.
  AssistantMessage? get lastAssistantMessage {
    try {
      return messages.lastWhere((m) => m.isAssistant);
    } catch (_) {
      return null;
    }
  }

  /// The latest user message, if any.
  AssistantMessage? get lastUserMessage {
    try {
      return messages.lastWhere((m) => m.isUser);
    } catch (_) {
      return null;
    }
  }

  /// Whether the conversation is empty.
  bool get isEmpty => messages.isEmpty;

  /// Number of exchanged turns.
  int get turnCount => messages.length ~/ 2;

  // ── Serialization ─────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (contextVersion != null) 'contextVersion': contextVersion,
        if (providerName != null) 'providerName': providerName,
        'totalTokensUsed': totalTokensUsed,
      };

  factory AssistantConversation.fromJson(Map<String, dynamic> json) =>
      AssistantConversation(
        id: json['id'] as String,
        messages: (json['messages'] as List)
            .map((m) => AssistantMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        contextVersion: json['contextVersion'] as int?,
        providerName: json['providerName'] as String?,
        totalTokensUsed: json['totalTokensUsed'] as int? ?? 0,
      );

  /// Serializes the conversation to a JSON string for storage.
  String toJsonString() => json.encode(toJson());

  /// Deserializes a conversation from a JSON string.
  factory AssistantConversation.fromJsonString(String jsonString) =>
      AssistantConversation.fromJson(
          json.decode(jsonString) as Map<String, dynamic>);

  @override
  String toString() =>
      'AssistantConversation(id: ${id.substring(0, 12)}, '
      'messages: ${messages.length}, tokens: $totalTokensUsed)';
}
