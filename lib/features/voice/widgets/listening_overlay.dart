import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design/animations/fade_animation.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../models/voice_state.dart';
import '../services/voice_service.dart';

/// An elegant listening overlay that appears when voice is active.
///
/// Displays:
/// - Current voice state
/// - Transcribed text (live)
/// - A visualiser animation
/// - Option to cancel
///
/// Designed to be minimal and unobtrusive while clearly indicating
/// voice state to the user.
class ListeningOverlay extends StatefulWidget {
  const ListeningOverlay({
    super.key,
    required this.voiceService,
  });

  final VoiceService voiceService;

  @override
  State<ListeningOverlay> createState() => _ListeningOverlayState();
}

class _ListeningOverlayState extends State<ListeningOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    widget.voiceService.addListener(_onStateChanged);
    _startDurationTimer();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.voiceService.isActive && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    widget.voiceService.removeListener(_onStateChanged);
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.voiceService.currentSession;
    if (!session.isActive && session.state != VoiceSessionState.error) {
      return const SizedBox.shrink();
    }

    final state = session.state;
    final seconds = (session.durationMs / 1000).round();
    final displayTime = _formatDuration(seconds);

    return FadeAnimation(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(PhoenixSpacing.lg),
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        decoration: BoxDecoration(
          color: PhoenixColors.surface,
          borderRadius: PhoenixRadius.xlRadius,
          boxShadow: [
            BoxShadow(
              color: PhoenixColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── State Header ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _stateIndicator(state),
                    SizedBox(width: PhoenixSpacing.sm),
                    Text(
                      _stateLabel(state),
                      style: PhoenixTypography.label.copyWith(
                        color: _stateColor(state),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  displayTime,
                  style: PhoenixTypography.caption.copyWith(
                    color: PhoenixColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: PhoenixSpacing.lg),

            // ── Visualiser ────────────────────────────────────────
            _VoiceVisualiser(state: state),

            // ── Transcript ─────────────────────────────────────────
            if (session.transcript != null &&
                session.transcript!.isNotEmpty) ...[
              SizedBox(height: PhoenixSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PhoenixSpacing.md),
                decoration: BoxDecoration(
                  color: PhoenixColors.surfaceVariant,
                  borderRadius: PhoenixRadius.smRadius,
                ),
                child: Text(
                  session.transcript!,
                  style: PhoenixTypography.bodySmall.copyWith(
                    color: PhoenixColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            // ── Error Message ─────────────────────────────────────
            if (state == VoiceSessionState.error &&
                session.errorMessage != null) ...[
              SizedBox(height: PhoenixSpacing.md),
              Text(
                session.errorMessage!,
                style: PhoenixTypography.caption.copyWith(
                  color: PhoenixColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // ── Cancel Button ─────────────────────────────────────
            SizedBox(height: PhoenixSpacing.md),
            TextButton(
              onPressed: () => widget.voiceService.cancel(),
              child: Text(
                'Cancel',
                style: PhoenixTypography.label.copyWith(
                  color: PhoenixColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateIndicator(VoiceSessionState state) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _stateColor(state),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _stateColor(VoiceSessionState state) {
    switch (state) {
      case VoiceSessionState.listening:
        return PhoenixColors.error;
      case VoiceSessionState.processing:
        return PhoenixColors.warning;
      case VoiceSessionState.speaking:
        return PhoenixColors.primary;
      case VoiceSessionState.error:
        return PhoenixColors.error;
      case VoiceSessionState.idle:
        return PhoenixColors.textDisabled;
    }
  }

  String _stateLabel(VoiceSessionState state) {
    switch (state) {
      case VoiceSessionState.listening:
        return 'Listening';
      case VoiceSessionState.processing:
        return 'Processing';
      case VoiceSessionState.speaking:
        return 'Speaking';
      case VoiceSessionState.error:
        return 'Error';
      case VoiceSessionState.idle:
        return 'Ready';
    }
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

/// A minimal animated visualiser for the listening overlay.
class _VoiceVisualiser extends StatefulWidget {
  const _VoiceVisualiser({required this.state});

  final VoiceSessionState state;

  @override
  State<_VoiceVisualiser> createState() => _VoiceVisualiserState();
}

class _VoiceVisualiserState extends State<_VoiceVisualiser>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barCount = 5;
    final active = widget.state != VoiceSessionState.idle;

    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(barCount, (index) {
          final delay = index * 0.1;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final height = active
                  ? 8.0 + (16.0 * (_controller.value + delay) % 1.0)
                  : 8.0;
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: PhoenixColors.primary
                      .withValues(alpha: active ? 0.8 : 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
