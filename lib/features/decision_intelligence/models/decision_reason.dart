/// Structured explanation for a decision recommendation.
///
/// Every recommendation must answer four questions:
/// - Why? (reason for the recommendation)
/// - Why now? (urgency/current relevance)
/// - What happens if skipped? (consequence)
/// - What unlocks next? (future benefit)
///
/// Immutable.
class DecisionReason {
  const DecisionReason({
    required this.why,
    required this.whyNow,
    this.ifSkipped = '',
    this.unlocks = '',
  });

  /// "Why this?" — The core reason for the recommendation.
  final String why;

  /// "Why now?" — Why this is relevant at this moment.
  final String whyNow;

  /// "What happens if skipped?" — Consequence of inaction.
  final String ifSkipped;

  /// "What unlocks next?" — Future benefit after completion.
  final String unlocks;

  /// Combined full explanation string.
  String get fullExplanation => '$why $whyNow'.trim();

  /// Long form with all fields.
  String get fullText {
    final parts = <String>[why, whyNow];
    if (ifSkipped.isNotEmpty) parts.add(ifSkipped);
    if (unlocks.isNotEmpty) parts.add(unlocks);
    return parts.join(' ');
  }

  @override
  String toString() =>
      'DecisionReason(why: ${why.length > 40 ? '${why.substring(0, 40)}...' : why})';
}
