/// Tracks the completeness of each portfolio section.
///
/// Each section has a completion percentage (0.0-1.0) and an
/// optional note about what's missing.
class PortfolioCompleteness {
  const PortfolioCompleteness({
    this.about = 0.0,
    this.projects = 0.0,
    this.skills = 0.0,
    this.achievements = 0.0,
    this.certificates = 0.0,
    this.github = 0.0,
    this.linkedIn = 0.0,
    this.resume = 0.0,
    this.experience = 0.0,
    this.education = 0.0,
    this.missingSections = const [],
    this.sectionNotes = const {},
  });

  /// About section completeness (0.0-1.0).
  final double about;

  /// Projects section completeness (0.0-1.0).
  final double projects;

  /// Skills section completeness (0.0-1.0).
  final double skills;

  /// Achievements section completeness (0.0-1.0).
  final double achievements;

  /// Certificates section completeness (0.0-1.0).
  final double certificates;

  /// GitHub integration completeness (0.0-1.0).
  final double github;

  /// LinkedIn integration completeness (0.0-1.0).
  final double linkedIn;

  /// Resume readiness (0.0-1.0).
  final double resume;

  /// Work experience completeness (0.0-1.0).
  final double experience;

  /// Education section completeness (0.0-1.0).
  final double education;

  /// List of section names that are missing or need attention.
  final List<String> missingSections;

  /// Detailed notes for each section.
  final Map<String, String> sectionNotes;

  // ── Computed Helpers ─────────────────────────────────────────────

  /// Overall completion percentage (0.0-1.0).
  double get overall =>
      (about + projects + skills + achievements + certificates +
          github + linkedIn + resume + experience + education) / 10.0;

  /// Overall as a percentage 0-100.
  double get overallPercent => (overall * 100).roundToDouble();

  /// Number of complete sections (>= 0.8).
  int get completeSectionCount => [
    about, projects, skills, achievements, certificates,
    github, linkedIn, resume, experience, education,
  ].where((s) => s >= 0.8).length;

  /// Number of incomplete sections (< 0.5).
  int get incompleteSectionCount => [
    about, projects, skills, achievements, certificates,
    github, linkedIn, resume, experience, education,
  ].where((s) => s < 0.5).length;

  /// Whether the portfolio is mostly complete (>= 80% overall).
  bool get isComplete => overall >= 0.8;

  /// Whether the portfolio needs significant work (< 50%).
  bool get needsWork => overall < 0.5;

  /// The weakest section (lowest score).
  MapEntry<String, double>? get weakestSection {
    final sections = <String, double>{
      'About': about,
      'Projects': projects,
      'Skills': skills,
      'Achievements': achievements,
      'Certificates': certificates,
      'GitHub': github,
      'LinkedIn': linkedIn,
      'Resume': resume,
      'Experience': experience,
      'Education': education,
    };
    final min = sections.entries.fold<MapEntry<String, double>?>(
      null,
      (a, b) => a == null || b.value < a.value ? b : a,
    );
    return min;
  }

  @override
  String toString() =>
      'PortfolioCompleteness(overall: ${(overall * 100).round()}%, '
      'missing: ${missingSections.length} sections)';
}
