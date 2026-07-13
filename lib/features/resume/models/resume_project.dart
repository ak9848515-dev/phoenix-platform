/// Immutable representation of a project entry in the resume.
///
/// Automatically derived from the Portfolio's featured projects.
class ResumeProject {
  const ResumeProject({
    required this.title,
    required this.description,
    this.type = 'mission',
    this.skills = const [],
    this.highlights = const [],
  });

  /// Project title.
  final String title;

  /// Short description of the project scope and outcome.
  final String description;

  /// Category of work: 'mission', 'project', 'milestone', 'assessment'.
  final String type;

  /// Skills demonstrated or gained through this project.
  final List<String> skills;

  /// Key accomplishments or highlights for this project.
  final List<String> highlights;

  /// Creates a copy with the given fields replaced.
  ResumeProject copyWith({
    String? title,
    String? description,
    String? type,
    List<String>? skills,
    List<String>? highlights,
  }) {
    return ResumeProject(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      skills: skills ?? this.skills,
      highlights: highlights ?? this.highlights,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResumeProject &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        _listEquals(other.skills, skills) &&
        _listEquals(other.highlights, highlights);
  }

  @override
  int get hashCode => Object.hash(
    title,
    description,
    type,
    Object.hashAll(skills),
    Object.hashAll(highlights),
  );

  @override
  String toString() => 'ResumeProject(title: $title, type: $type)';

  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
