/// Severity level of a resume gap.
enum GapSeverity {
  /// Critical gap — significantly reduces resume quality.
  critical('Critical'),

  /// Moderate gap — noticeable but not blocking.
  moderate('Moderate'),

  /// Minor gap — marginal improvement opportunity.
  minor('Minor');

  const GapSeverity(this.displayName);

  final String displayName;
}

/// A single identified gap in the user's resume.
///
/// Each gap has a category, severity, and human-readable description
/// explaining what is missing and how to address it.
class ResumeGap {
  const ResumeGap({
    required this.category,
    required this.description,
    this.severity = GapSeverity.moderate,
    this.suggestion = '',
    this.impact = 0.0,
  });

  /// Gap category (e.g. 'skills', 'projects', 'certifications').
  final String category;

  /// Human-readable description of the gap.
  final String description;

  /// How severe this gap is.
  final GapSeverity severity;

  /// Suggested action to close the gap.
  final String suggestion;

  /// Estimated impact on overall resume score if closed (0.0–1.0).
  final double impact;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeGap &&
          other.category == category &&
          other.description == description;

  @override
  int get hashCode => Object.hash(category, description);
}
