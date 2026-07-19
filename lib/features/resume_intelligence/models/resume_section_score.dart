/// Score for a specific resume section.
///
/// Each section (e.g. Skills, Projects, Education) is evaluated on
/// completeness, quality, and alignment with the target role.
class ResumeSectionScore {
  const ResumeSectionScore({
    required this.sectionName,
    this.completeness = 0.0,
    this.quality = 0.0,
    this.alignment = 0.0,
    this.notes = '',
  });

  /// Section name (e.g. 'Skills', 'Projects', 'Education', 'Summary').
  final String sectionName;

  /// How complete this section is (0.0–1.0).
  final double completeness;

  /// Quality score for existing content (0.0–1.0).
  final double quality;

  /// How well this section aligns with the target role (0.0–1.0).
  final double alignment;

  /// Human-readable notes about this section.
  final String notes;

  /// Overall section score: weighted combination.
  double get overall => (completeness * 0.3 + quality * 0.4 + alignment * 0.3);
}
