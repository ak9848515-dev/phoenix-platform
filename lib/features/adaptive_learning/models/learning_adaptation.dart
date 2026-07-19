import 'adaptation_priority.dart';
import 'adaptation_reason.dart';
import 'adaptation_type.dart';

/// A single learning adaptation recommendation.
///
/// Contains:
/// - [type]: what kind of adaptation (e.g. increaseRevision)
/// - [priority]: how important this adaptation is
/// - [reason]: explanation of why this adaptation is needed
/// - [confidence]: how certain the engine is (0-100)
/// - [affectedArea]: which domain is affected (e.g. 'knowledge', 'missions')
/// - [suggestedValue]: the recommended new value (e.g. 'advanced' for difficulty)
class LearningAdaptation {
  const LearningAdaptation({
    required this.type,
    required this.priority,
    required this.reason,
    required this.confidence,
    this.affectedArea = '',
    this.suggestedValue = '',
    this.fromValue = '',
  });

  /// The type of adaptation recommended.
  final AdaptationType type;

  /// Priority level of this adaptation.
  final AdaptationPriority priority;

  /// Explanation for the adaptation.
  final AdaptationReason reason;

  /// Confidence score (0-100).
  final int confidence;

  /// Which domain this affects (e.g. 'knowledge', 'missions', 'projects').
  final String affectedArea;

  /// The suggested new value or setting.
  final String suggestedValue;

  /// The previous value being changed from.
  final String fromValue;

  @override
  String toString() =>
      'LearningAdaptation(${type.displayName}, ${priority.displayName})';
}
