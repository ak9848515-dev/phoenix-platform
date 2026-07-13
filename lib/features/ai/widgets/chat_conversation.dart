import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_shadow.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../../ai/models/chat_message.dart';

/// A production-quality conversation interface for the AI Mentor.
///
/// Supports:
/// - Conversation history
/// - User and AI message bubbles
/// - Typing indicator
/// - Loading state
/// - Error state with retry
/// - Auto-scroll on new messages
class ChatConversation extends StatefulWidget {
  const ChatConversation({
    super.key,
    required this.messages,
    required this.onSendMessage,
    required this.isLoading,
    this.error,
    this.onRetry,
  });

  /// The list of messages to display.
  final List<ChatMessage> messages;

  /// Called when the user sends a new message.
  final ValueChanged<String> onSendMessage;

  /// Whether the AI is currently generating a response.
  final bool isLoading;

  /// Optional error message to display.
  final String? error;

  /// Called when the user taps retry after an error.
  final VoidCallback? onRetry;

  @override
  State<ChatConversation> createState() => _ChatConversationState();
}

class _ChatConversationState extends State<ChatConversation> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(ChatConversation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      _scrollToBottom();
    }
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

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    _controller.clear();
    widget.onSendMessage(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a direct Container instead of PhoenixCard to avoid the nested
    // Column(mainAxisSize) issue. PhoenixCard wraps content in a Column
    // which causes unbounded constraints when its parent asks for intrinsic
    // sizes — this conflicts with the Expanded used for the messages area.
    return Container(
      decoration: BoxDecoration(
        color: PhoenixColors.surface,
        borderRadius: PhoenixRadius.xlRadius,
        boxShadow: PhoenixShadow.cardRest,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: PhoenixSpacing.xl,
              vertical: PhoenixSpacing.md,
            ),
            decoration: BoxDecoration(
              color: PhoenixColors.primaryContainer(0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(PhoenixRadius.xl),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: PhoenixColors.primary,
                ),
                SizedBox(width: PhoenixSpacing.sm),
                Text(
                  'AI Mentor Chat',
                  style: PhoenixTypography.h3.copyWith(
                    color: PhoenixColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Messages ──────────────────────────────────────────────
          Expanded(
            child: widget.messages.isEmpty && !widget.isLoading && widget.error == null
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(PhoenixSpacing.md),
                    itemCount: widget.messages.length +
                        (widget.isLoading ? 1 : 0) +
                        (widget.error != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Error banner
                      if (widget.error != null &&
                          index == widget.messages.length +
                              (widget.isLoading ? 1 : 0)) {
                        return _buildErrorBanner();
                      }

                      // Typing indicator
                      if (widget.isLoading &&
                          index == widget.messages.length) {
                        return _buildTypingIndicator();
                      }

                      final message = widget.messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // ── Input Bar ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(PhoenixSpacing.md),
            decoration: BoxDecoration(
              color: PhoenixColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(PhoenixRadius.xl),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: 'Ask your AI Mentor...',
                      hintStyle: PhoenixTypography.bodySmall.copyWith(
                        color: PhoenixColors.textDisabled,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: PhoenixRadius.mdRadius,
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: PhoenixColors.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: PhoenixSpacing.lg,
                        vertical: PhoenixSpacing.md,
                      ),
                      isDense: true,
                    ),
                    style: PhoenixTypography.bodySmall.copyWith(
                      color: PhoenixColors.textPrimary,
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                SizedBox(width: PhoenixSpacing.sm),
                Material(
                  color: widget.isLoading
                      ? PhoenixColors.textDisabled
                      : PhoenixColors.primary,
                  borderRadius: BorderRadius.circular(100),
                  child: InkWell(
                    onTap: widget.isLoading ? null : _handleSend,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                      PhoenixColors.onPrimary,
                                    ),
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              size: 20,
                              color: PhoenixColors.onPrimary,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: PhoenixSpacing.sm,
        left: isUser ? PhoenixSpacing.xl : 0,
        right: isUser ? 0 : PhoenixSpacing.xl,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: EdgeInsets.all(PhoenixSpacing.md),
          decoration: BoxDecoration(
            color: isUser
                ? PhoenixColors.primary
                : PhoenixColors.surfaceVariant,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(PhoenixSpacing.md),
              topRight: Radius.circular(PhoenixSpacing.md),
              bottomLeft: Radius.circular(
                isUser ? PhoenixSpacing.md : 0,
              ),
              bottomRight: Radius.circular(
                isUser ? 0 : PhoenixSpacing.md,
              ),
            ),
          ),
          child: Text(
            message.content,
            style: PhoenixTypography.bodySmall.copyWith(
              color: isUser
                  ? PhoenixColors.onPrimary
                  : PhoenixColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: PhoenixSpacing.sm),
        child: Container(
          padding: EdgeInsets.all(PhoenixSpacing.md),
          decoration: BoxDecoration(
            color: PhoenixColors.surfaceVariant,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(PhoenixSpacing.md),
              topRight: Radius.circular(PhoenixSpacing.md),
              bottomRight: Radius.circular(PhoenixSpacing.md),
              bottomLeft: Radius.zero,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(0),
              SizedBox(width: 4),
              _dot(200),
              SizedBox(width: 4),
              _dot(400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(int delay) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: PhoenixColors.textDisabled,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: EdgeInsets.all(PhoenixSpacing.md),
      child: Container(
        padding: EdgeInsets.all(PhoenixSpacing.md),
        decoration: BoxDecoration(
          color: PhoenixColors.errorContainer(0.1),
          borderRadius: PhoenixRadius.smRadius,
          border: Border.all(
            color: PhoenixColors.error.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 18,
              color: PhoenixColors.error,
            ),
            SizedBox(width: PhoenixSpacing.sm),
            Expanded(
              child: Text(
                widget.error ?? 'Something went wrong',
                style: PhoenixTypography.caption.copyWith(
                  color: PhoenixColors.error,
                ),
              ),
            ),
            if (widget.onRetry != null) ...[
              SizedBox(width: PhoenixSpacing.sm),
              TextButton(
                onPressed: widget.onRetry,
                child: Text(
                  'Retry',
                  style: PhoenixTypography.label.copyWith(
                    color: PhoenixColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeAnimation(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(PhoenixSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: PhoenixColors.textDisabled,
              ),
              SizedBox(height: PhoenixSpacing.lg),
              Text(
                'Ask me anything about your growth journey',
                style: PhoenixTypography.bodySmall.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: PhoenixSpacing.sm),
              Text(
                'I can help with progress, missions, skills, career, '
                'and more!',
                style: PhoenixTypography.caption.copyWith(
                  color: PhoenixColors.textDisabled,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
