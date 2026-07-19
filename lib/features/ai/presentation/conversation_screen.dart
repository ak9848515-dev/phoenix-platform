import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_error_state.dart';
import '../models/conversation_message.dart' show ConversationMessage;
import '../models/conversation_session.dart' show ConversationSession;
import '../services/conversation_service.dart' show ConversationService;

/// Full-screen conversation with the AI mentor.
///
/// Displays chat history, typing indicator, suggested prompts,
/// and input field. All data comes from [ConversationService].
/// No business logic in UI.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.conversationService});

  final ConversationService conversationService;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    widget.conversationService.addListener(_onConversationChanged);
    if (!widget.conversationService.hasActiveSession) {
      widget.conversationService.startSession();
    }
  }

  @override
  void dispose() {
    widget.conversationService.removeListener(_onConversationChanged);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onConversationChanged() {
    if (mounted) setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isProcessing) return;

    setState(() => _isProcessing = true);
    _inputController.clear();

    try {
      await widget.conversationService.processMessage(text.trim());
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isProcessing = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  void _onSuggestionTapped(String suggestion) {
    _sendMessage(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.conversationService.currentSession;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, size: 20),
            SizedBox(width: 8),
            Text('AI Mentor'),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (session != null && session.messageCount > 1)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'New conversation',
              onPressed: () {
                widget.conversationService.clearSession();
                widget.conversationService.startSession();
                setState(() => _hasError = false);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Chat area
          Expanded(
            child: _hasError
                ? PhoenixErrorState(
                    category: PhoenixErrorCategory.unexpected,
                    message: 'We couldn\'t process your message right now. '
                        'Please try again.',
                    onAction: () {
                      setState(() => _hasError = false);
                    },
                  )
                : session == null || session.messages.isEmpty
                    ? _EmptyState(onSuggestionTapped: _onSuggestionTapped)
                    : _ChatArea(
                        session: session,
                        isProcessing: _isProcessing,
                        scrollController: _scrollController,
                      ),
          ),
          // Input area
          _MessageInput(
            controller: _inputController,
            onSend: _sendMessage,
            enabled: !_isProcessing,
            lastMentorMessage: session?.lastMentorMessage,
            onSuggestionTapped: _onSuggestionTapped,
          ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestionTapped});
  final void Function(String) onSuggestionTapped;

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'How am I doing?',
      'What should I focus on today?',
      'Any recommendations for me?',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: Colors.deepPurple.shade200),
            const SizedBox(height: 16),
            Text(
              'Hi, I\'m your AI Mentor',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about your progress, recommendations,\nlearning, habits, and more.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ...suggestions.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ActionChip(
                    label: Text(s),
                    onPressed: () => onSuggestionTapped(s),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Chat Area ──────────────────────────────────────────────────────────

class _ChatArea extends StatelessWidget {
  const _ChatArea({
    required this.session,
    required this.isProcessing,
    required this.scrollController,
  });

  final ConversationSession session;
  final bool isProcessing;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: session.messages.length + (isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == session.messages.length && isProcessing) {
          return const _TypingIndicator();
        }
        final message = session.messages[index];
        return _ChatBubble(message: message);
      },
    );
  }
}

// ── Chat Bubble ────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ConversationMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role.isUser;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
      bottomRight: isUser ? Radius.zero : const Radius.circular(16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.auto_awesome, size: 16, color: Colors.deepPurple),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.deepPurple.shade100
                    : Colors.grey.shade100,
                borderRadius: borderRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.deepPurple.shade900 : Colors.black87,
                    ),
                  ),
                  if (message.suggestions.isNotEmpty && !isUser) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: message.suggestions.take(3).map((s) =>
                        InkWell(
                          onTap: () {
                            // Handled by parent via callback
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.deepPurple.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.deepPurple.shade700)),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                  if (message.sourceServices.isNotEmpty && !isUser) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Sources: ${message.sourceServices.join(", ")}',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Typing Indicator ───────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.deepPurple.shade100,
            child:
                const Icon(Icons.auto_awesome, size: 14, color: Colors.deepPurple),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final tween = Tween<double>(begin: 0.3, end: 1.0);
                      final delayedValue = (_controller.value + delay) % 1.0;
                      return Opacity(
                        opacity: tween.transform(delayedValue),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Input ──────────────────────────────────────────────────────

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.enabled,
    this.lastMentorMessage,
    this.onSuggestionTapped,
  });

  final TextEditingController controller;
  final void Function(String) onSend;
  final bool enabled;
  final ConversationMessage? lastMentorMessage;
  final void Function(String)? onSuggestionTapped;

  @override
  Widget build(BuildContext context) {
    final hasSuggestions =
        lastMentorMessage != null && lastMentorMessage!.suggestions.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Suggestions row
            if (hasSuggestions)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: lastMentorMessage!.suggestions
                      .take(3)
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(s, style: const TextStyle(fontSize: 12)),
                              onPressed: enabled
                                  ? () => onSend(s)
                                  : null,
                              visualDensity: VisualDensity.compact,
                            ),
                          ))
                      .toList(),
                ),
              ),
            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    decoration: InputDecoration(
                      hintText: 'Ask your mentor...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: enabled ? (v) => onSend(v) : null,
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: enabled
                        ? const Icon(Icons.send, color: Colors.white)
                        : const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                    tooltip: 'Send message',
                    onPressed:
                        enabled ? () => onSend(controller.text) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
