import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../models/voice_command.dart';
import '../models/voice_state.dart';
import '../services/voice_service.dart';

/// A premium voice activation button for Phoenix OS.
///
/// Displays a microphone icon that reflects the current voice session
/// state. Supports idle (default), listening (animated pulse),
/// processing (spinner), and speaking (waveform) states.
///
/// Large tap target for accessibility.
class VoiceButton extends StatefulWidget {
  const VoiceButton({
    super.key,
    required this.voiceService,
    this.onCommand,
    this.size = 56,
  });

  /// The voice service to control.
  final VoiceService voiceService;

  /// Called when a valid voice command is recognised.
  /// Receives the parsed [VoiceCommand] with type, route, and transcript.
  final ValueChanged<VoiceCommand>? onCommand;

  /// Button diameter. Defaults to 56dp (accessibility-friendly).
  final double size;

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() => setState(() {}));

    widget.voiceService.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voiceService != widget.voiceService) {
      oldWidget.voiceService.removeListener(_onStateChanged);
      widget.voiceService.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    widget.voiceService.removeListener(_onStateChanged);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.voiceService.state;
    final isActive = widget.voiceService.isActive;
    final isAvailable = widget.voiceService.isAvailable;

    // Manage pulse animation based on state
    if (state == VoiceSessionState.listening && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (state != VoiceSessionState.listening &&
        _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    return Semantics(
      label: isActive ? 'Voice active, tap to stop' : 'Voice command',
      hint: 'Double-tap to activate voice commands',
      button: true,
      child: GestureDetector(
        onTap: () => _handleTap(),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = state == VoiceSessionState.listening
                ? 1.0 + (_pulseController.value * 0.08)
                : 1.0;
            final opacity = state == VoiceSessionState.listening
                ? 1.0 - (_pulseController.value * 0.2)
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: _backgroundColor(state, isAvailable),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _backgroundColor(state, isAvailable)
                          .withValues(alpha: opacity * 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: _buildIcon(state, isAvailable),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(VoiceSessionState state, bool isAvailable) {
    if (!isAvailable) {
      return Icon(Icons.mic_off_rounded, size: 24, color: PhoenixColors.textDisabled);
    }

    switch (state) {
      case VoiceSessionState.listening:
        return Icon(Icons.mic_rounded, size: 24, color: PhoenixColors.onPrimary);
      case VoiceSessionState.processing:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(PhoenixColors.onPrimary),
          ),
        );
      case VoiceSessionState.speaking:
        return Icon(Icons.volume_up_rounded, size: 24, color: PhoenixColors.onPrimary);
      case VoiceSessionState.error:
        return Icon(Icons.error_outline, size: 24, color: PhoenixColors.onPrimary);
      case VoiceSessionState.idle:
        return Icon(Icons.mic_none_rounded, size: 24, color: PhoenixColors.onPrimary);
    }
  }

  Color _backgroundColor(VoiceSessionState state, bool isAvailable) {
    if (!isAvailable) return PhoenixColors.textDisabled;
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
        return PhoenixColors.primary;
    }
  }

  void _handleTap() {
    if (!widget.voiceService.isAvailable) return;

    if (widget.voiceService.isActive) {
      widget.voiceService.stopListening();
      widget.voiceService.stopSpeaking();
    } else {
      widget.voiceService.startListening(
        onCommand: (command) {
          widget.onCommand?.call(command);
        },
      );
    }
  }
}
