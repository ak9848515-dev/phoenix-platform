import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../models/journey.dart';

/// Provides journey data derived from the user's selected Identity.
///
class JourneyService {
  JourneyService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  Journey getJourney() {
    return repository.journey;
  }
}
