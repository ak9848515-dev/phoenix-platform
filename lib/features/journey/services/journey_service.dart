import '../../../services/sample_data_service.dart';
import '../models/journey.dart';

/// Provides journey data derived from the user's selected Identity.
///
/// The Journey is generated from the Identity stored in SampleDataService.
/// Every Journey is composed of Stages, and every Stage contains Missions.
/// Knowledge DNA measures progress through the Journey. Recommendation
/// selects the next best Journey step.
///
/// No AI, no persistence, no state management.
class JourneyService {
  JourneyService({SampleDataService? seedSource})
    : seedSource = seedSource ?? const SampleDataService();

  final SampleDataService seedSource;

  /// Returns the Journey generated from the selected Identity.
  ///
  /// The journey's identityId references the selected Identity, ensuring
  /// Identity drives the Journey. The title, description, and stage
  /// structure are aligned with the identity's roadmap and skills.
  Journey getJourney() {
    return seedSource.journey;
  }
}
