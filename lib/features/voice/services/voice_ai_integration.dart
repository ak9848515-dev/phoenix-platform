import '../../ai/services/ai_mentor_service.dart';
import '../models/voice_command.dart';
import 'voice_service.dart';

/// Integrates AI Mentor responses with the Voice Framework.
///
/// Allows AI responses to be spoken aloud. Uses the existing
/// [AIMentorService] — does NOT duplicate AI logic.
///
/// Two modes:
/// 1. `respondToCommand` — sends a transcribed command to the AI,
///    then speaks the AI's response.
/// 2. `speakText` — speaks any arbitrary text (e.g. greeting, status).
class VoiceAIIntegration {
  VoiceAIIntegration({
    required this._aiService,
    required this._voiceService,
  });

  final AIMentorService _aiService;
  final VoiceService _voiceService;

  /// Sends a voice command's transcript to the AI mentor and speaks
  /// the response.
  ///
  /// Returns `true` if the response was spoken successfully.
  Future<bool> respondToCommand(VoiceCommand command) async {
    if (!_voiceService.isAvailable) return false;
    if (command.transcript.isEmpty) return false;

    // Don't respond to navigation commands — those should navigate
    if (command.route != null) return true;

    // Get AI mentor response
    try {
      final response = await _aiService.chat(command.transcript);
      if (response.content.isEmpty) return false;

      // Speak the AI response
      await _voiceService.speak(response.content);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Speaks an AI mentor response for a given user message.
  ///
  /// This is the integration point between the AI chat and voice.
  /// After the AI produces a response, pass it here to be spoken.
  Future<bool> speakAiResponse(String userMessage) async {
    if (!_voiceService.isAvailable) return false;

    try {
      final response = await _aiService.chat(userMessage);
      if (response.content.isEmpty) return false;
      await _voiceService.speak(response.content);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Speaks a greeting message.
  Future<bool> speakGreeting() async {
    if (!_voiceService.isAvailable) return false;

    final greeting = _aiService.getGreeting();
    final motivation = _aiService.getMotivation();
    final message = '$greeting. $motivation';

    return _speakSafe(message);
  }

  /// Speaks a daily focus summary.
  Future<bool> speakDailyFocus() async {
    if (!_voiceService.isAvailable) return false;

    final focus = _aiService.getDailyFocus();
    final guidance = _aiService.buildGuidance();
    final message =
        'Your daily focus is: $focus. '
        'You are level ${guidance.level} with ${guidance.totalXp} XP. '
        '${guidance.missionSummary}';

    return _speakSafe(message);
  }

  Future<bool> _speakSafe(String text) async {
    if (text.isEmpty) return false;
    try {
      await _voiceService.speak(text);
      return true;
    } catch (_) {
      return false;
    }
  }
}
