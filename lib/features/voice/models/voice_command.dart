import '../../../routes/app_routes.dart';

/// Recognised voice command types.
///
/// Each command maps to a navigation route or action.
/// No business logic — routing only.
enum VoiceCommandType {
  openDashboard,
  openProfile,
  continueMission,
  improveResume,
  practiceInterview,
  showPortfolio,
  openAiMentor,
  exploreOpportunities,
  openAcademy,
  openMarketplace,
  showProgress,
  openKnowledgeDna,
  openCareer,
  openJourney,
  showRecommendations,
  unknown,
}

/// A recognised voice command with its type and original transcript.
///
/// [VoiceCommandRouter] parses transcribed text and creates instances
/// of this class. Consumers use the [type] to determine the action.
class VoiceCommand {
  const VoiceCommand({
    required this.type,
    required this.transcript,
    this.confidence = 1.0,
  });

  /// The recognised command type.
  final VoiceCommandType type;

  /// The original transcribed text.
  final String transcript;

  /// Recognition confidence (0.0–1.0).
  final double confidence;

  /// Whether the command was recognised with sufficient confidence.
  bool get isValid => type != VoiceCommandType.unknown && confidence >= 0.5;

  /// The navigation route associated with this command, if any.
  String? get route {
    switch (type) {
      case VoiceCommandType.openDashboard:
        return AppRoutes.dashboard;
      case VoiceCommandType.openProfile:
        return AppRoutes.profile;
      case VoiceCommandType.continueMission:
        return AppRoutes.missionCenter;
      case VoiceCommandType.improveResume:
        return AppRoutes.resume;
      case VoiceCommandType.practiceInterview:
        return AppRoutes.interview;
      case VoiceCommandType.showPortfolio:
        return AppRoutes.portfolio;
      case VoiceCommandType.openAiMentor:
        return AppRoutes.ai;
      case VoiceCommandType.exploreOpportunities:
        return AppRoutes.opportunity;
      case VoiceCommandType.openAcademy:
        return AppRoutes.academy;
      case VoiceCommandType.openMarketplace:
        return AppRoutes.marketplace;
      case VoiceCommandType.showProgress:
        return AppRoutes.progress;
      case VoiceCommandType.openKnowledgeDna:
        return AppRoutes.knowledgeDna;
      case VoiceCommandType.openCareer:
        return AppRoutes.career;
      case VoiceCommandType.openJourney:
        return AppRoutes.journey;
      case VoiceCommandType.showRecommendations:
        return AppRoutes.recommendation;
      case VoiceCommandType.unknown:
        return null;
    }
  }

  /// A human-readable label for the action.
  String get label {
    switch (type) {
      case VoiceCommandType.openDashboard:
        return 'Open Dashboard';
      case VoiceCommandType.openProfile:
        return 'Open Profile';
      case VoiceCommandType.continueMission:
        return 'Continue Mission';
      case VoiceCommandType.improveResume:
        return 'Improve Resume';
      case VoiceCommandType.practiceInterview:
        return 'Practice Interview';
      case VoiceCommandType.showPortfolio:
        return 'Show Portfolio';
      case VoiceCommandType.openAiMentor:
        return 'Open AI Mentor';
      case VoiceCommandType.exploreOpportunities:
        return 'Explore Opportunities';
      case VoiceCommandType.openAcademy:
        return 'Open Academy';
      case VoiceCommandType.openMarketplace:
        return 'Open Marketplace';
      case VoiceCommandType.showProgress:
        return 'Show Progress';
      case VoiceCommandType.openKnowledgeDna:
        return 'Open Knowledge DNA';
      case VoiceCommandType.openCareer:
        return 'Open Career';
      case VoiceCommandType.openJourney:
        return 'Open Journey';
      case VoiceCommandType.showRecommendations:
        return 'Show Recommendations';
      case VoiceCommandType.unknown:
        return 'Unknown command';
    }
  }

  @override
  String toString() =>
      'VoiceCommand(type: $type, transcript: "$transcript", '
      'confidence: $confidence)';
}
