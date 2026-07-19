import 'learning_adaptation.dart';
import 'learning_profile.dart';

/// Immutable snapshot of the user's adaptive learning state.
///
/// Produced by [AdaptiveLearningEngine]. All consumers read this
/// snapshot instead of computing adaptations themselves.
///
/// Contains:
/// - [profile]: the user's current learning profile
/// - [adaptations]: recommended learning adaptations (ranked)
/// - [topAdaptation]: the single highest-priority adaptation
/// - [generatedAt]: when this snapshot was generated
/// - [history]: previous snapshots for trend comparison
class AdaptiveLearningSnapshot {
  const AdaptiveLearningSnapshot({
    required this.profile,
    required this.adaptations,
    this.topAdaptation,
    required this.generatedAt,
    this.history = const [],
  });

  /// The user's current learning profile.
  final LearningProfile profile;

  /// All recommended adaptations, ranked by priority.
  final List<LearningAdaptation> adaptations;

  /// The single highest-priority adaptation.
  final LearningAdaptation? topAdaptation;

  /// When this snapshot was generated.
  final DateTime generatedAt;

  /// Previous snapshots for trend comparison.
  final List<AdaptiveLearningSnapshot> history;

  /// Whether the snapshot has meaningful data.
  bool get hasData => adaptations.isNotEmpty || profile.consistencyScore > 0;

  /// Whether this represents a new user with minimal data.
  bool get isNewUser => !hasData;

  /// Whether any critical adaptations are needed.
  bool get hasCriticalAdaptations =>
      adaptations.any((a) => a.priority.index <= 0);

  /// Summary string for dashboard display.
  String get summary {
    if (topAdaptation != null) {
      return '${topAdaptation!.type.displayName}: '
          '${topAdaptation!.reason.why}';
    }
    if (profile.consistencyScore > 0) {
      return 'Learning on track — ${(profile.retentionScore * 100).round()}% retention';
    }
    return 'Insufficient data for learning adaptations';
  }

  @override
  String toString() =>
      'AdaptiveLearningSnapshot(adaptations: ${adaptations.length}, '
      'top: ${topAdaptation?.type.displayName ?? "none"})';
}
