import 'package:flutter/widgets.dart';

import '../models/voice_command.dart';

/// Recognises voice commands from transcribed text and routes them
/// to the appropriate navigation action.
///
/// Command recognition is keyword-based. No business logic.
/// The router only navigates — never checks permissions, state, or AI.
class VoiceCommandRouter {
  /// Parses transcribed text into a [VoiceCommand].
  ///
  /// Matching is case-insensitive. Returns [VoiceCommandType.unknown]
  /// when no command is recognised.
  VoiceCommand parse(String transcript) {
    final lower = transcript.toLowerCase();

    if (_matchesAny(lower, ['open dashboard', 'go to dashboard', 'home'])) {
      return VoiceCommand(
        type: VoiceCommandType.openDashboard,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, ['open profile', 'my profile', 'go to profile'])) {
      return VoiceCommand(
        type: VoiceCommandType.openProfile,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, [
      'continue mission',
      'my missions',
      'open mission',
      'show missions',
    ])) {
      return VoiceCommand(
        type: VoiceCommandType.continueMission,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, ['improve resume', 'my resume', 'edit resume'])) {
      return VoiceCommand(
        type: VoiceCommandType.improveResume,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, [
      'practice interview',
      'interview prep',
      'mock interview',
    ])) {
      return VoiceCommand(
        type: VoiceCommandType.practiceInterview,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, ['show portfolio', 'my portfolio', 'portfolio'])) {
      return VoiceCommand(
        type: VoiceCommandType.showPortfolio,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, [
      'open ai mentor',
      'ai mentor',
      'open ai',
      'talk to ai',
    ])) {
      return VoiceCommand(
        type: VoiceCommandType.openAiMentor,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, [
      'explore opportunities',
      'show opportunities',
      'opportunities',
    ])) {
      return VoiceCommand(
        type: VoiceCommandType.exploreOpportunities,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, ['open academy', 'go to academy', 'learning'])) {
      return VoiceCommand(
        type: VoiceCommandType.openAcademy,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, ['open marketplace', 'marketplace', 'plugins'])) {
      return VoiceCommand(
        type: VoiceCommandType.openMarketplace,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, ['show progress', 'my progress', 'progress'])) {
      return VoiceCommand(
        type: VoiceCommandType.showProgress,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, [
      'open knowledge dna',
      'knowledge dna',
      'my knowledge',
    ])) {
      return VoiceCommand(
        type: VoiceCommandType.openKnowledgeDna,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, ['open career', 'career readiness', 'career'])) {
      return VoiceCommand(
        type: VoiceCommandType.openCareer,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, ['open journey', 'my journey', 'journey'])) {
      return VoiceCommand(
        type: VoiceCommandType.openJourney,
        transcript: transcript,
      );
    }
    if (_matchesAny(lower, [
      'show recommendations',
      'recommendations',
      'what should I do',
    ])) {
      return VoiceCommand(
        type: VoiceCommandType.showRecommendations,
        transcript: transcript,
      );
    }

    return VoiceCommand(
      type: VoiceCommandType.unknown,
      transcript: transcript,
    );
  }

  /// Executes a voice command by navigating to the associated route.
  ///
  /// Returns `true` if a valid route was navigated to.
  /// Returns `false` if the command is unknown or has no associated route.
  bool execute(VoiceCommand command, NavigatorState navigator) {
    if (!command.isValid || command.route == null) return false;
    navigator.pushNamed(command.route!);
    return true;
  }

  bool _matchesAny(String lower, List<String> patterns) {
    return patterns.any((pattern) => lower.contains(pattern));
  }
}
