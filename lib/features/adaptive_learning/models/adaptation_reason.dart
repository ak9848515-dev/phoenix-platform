/// Immutable reason explaining WHY an adaptation is recommended.
class AdaptationReason {
  const AdaptationReason({
    required this.why,
    required this.evidence,
    this.expectedImpact = '',
    this.alternativeAction = '',
  });

  /// Primary reason for this adaptation.
  final String why;

  /// Supporting data that triggered the adaptation.
  final String evidence;

  /// Expected outcome if the adaptation is applied.
  final String expectedImpact;

  /// Alternative action if the adaptation is not suitable.
  final String alternativeAction;

  @override
  String toString() => 'AdaptationReason(why: $why)';
}
