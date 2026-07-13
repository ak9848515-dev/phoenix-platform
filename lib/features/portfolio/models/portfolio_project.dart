/// Immutable representation of a project or mission in the user's portfolio.
///
/// Automatically derived from completed missions, journey milestones,
/// and projects. Not manually editable.
class PortfolioProject {
  const PortfolioProject({
    required this.id,
    required this.title,
    required this.description,
    this.type = 'mission',
    this.completedDate,
    this.skills = const [],
    this.technologies = const [],
  });

  /// Unique identifier for this project.
  final String id;

  /// Human-readable title (e.g. 'Build a REST API').
  final String title;

  /// Short description of the project scope and outcome.
  final String description;

  /// Category of work: 'mission', 'project', 'milestone', 'assessment'.
  final String type;

  /// When the project was completed. Null if still in progress.
  final DateTime? completedDate;

  /// Skills demonstrated or gained through this project.
  final List<String> skills;

  /// Technologies, tools, or frameworks used in this project.
  final List<String> technologies;

  /// Whether this project has been completed.
  bool get isCompleted => completedDate != null;

  /// Creates a copy with the given fields replaced.
  PortfolioProject copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? completedDate,
    List<String>? skills,
    List<String>? technologies,
  }) {
    return PortfolioProject(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      completedDate: completedDate ?? this.completedDate,
      skills: skills ?? this.skills,
      technologies: technologies ?? this.technologies,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioProject &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.completedDate == completedDate &&
        _listEquals(other.skills, skills) &&
        _listEquals(other.technologies, technologies);
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    type,
    completedDate,
    Object.hashAll(skills),
    Object.hashAll(technologies),
  );

  @override
  String toString() => 'PortfolioProject(id: $id, title: $title, type: $type)';

  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
