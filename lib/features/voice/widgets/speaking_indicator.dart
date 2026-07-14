import 'package:flutter/material.dart';

import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/design/theme/phoenix_typography.dart';
import '../models/voice_state.dart';
import '../services/voice_service.dart';

/// A compact speaking indicator that shows when the system is speaking.
///
/// Displays the current transcript alongside a waveform animation
/// and a stop button. Minimal and accessible.
class SpeakingIndicator extends StatelessWidget {
  const SpeakingIndicator({
    super.key,
    required this.voiceService,
  });

  final VoiceService voiceService;

  @override
  Widget build(BuildContext context) {
    final state = voiceService.state;
    if (state != VoiceSessionState.speaking) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Voice is speaking',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PhoenixSpacing.md,
          vertical: PhoenixSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: PhoenixColors.primaryContainer(0.1),
          borderRadius: PhoenixRadius.xlRadius,
          border: Border.all(
            color: PhoenixColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.volume_up_rounded,
              size: 18,
              color: PhoenixColors.primary,
            ),
            SizedBox(width: PhoenixSpacing.sm),
            Text(
              'Speaking',
              style: PhoenixTypography.caption.copyWith(
                color: PhoenixColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: PhoenixSpacing.sm),
            GestureDetector(
              onTap: () => voiceService.stopSpeaking(),
              child: Container(
                padding: const EdgeInsets.all(PhoenixSpacing.xs),
                decoration: BoxDecoration(
                  color: PhoenixColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  Icons.stop_rounded,
                  size: 14,
                  color: PhoenixColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
