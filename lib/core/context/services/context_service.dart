import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../builders/phoenix_context_builder.dart';
import '../models/phoenix_context.dart';

/// Convenience API for building a [PhoenixContext] from the current
/// application state.
///
/// Delegates to [PhoenixContextBuilder] under the hood. Screens, widgets,
/// and future AI/OmniRoute consumers should use this service rather than
/// the builder directly.
///
/// Usage:
/// ```dart
/// final context = ContextService().buildContext();
/// ```
///
/// No AI, no persistence, no networking.
class ContextService {
  ContextService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  /// Builds and returns a fresh [PhoenixContext] snapshot.
  ///
  /// Each call re-computes all derived data (mission progress, knowledge
  /// DNA, career profile, decision) from the current [Repository] state.
  PhoenixContext buildContext() {
    return PhoenixContextBuilder(repository: repository).build();
  }
}
