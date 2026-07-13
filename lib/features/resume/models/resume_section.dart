/// Immutable representation of a named section in a resume.
///
/// Each section has a title, ordered list of content items, and an
/// optional icon. Used to structure resume content into logical groups
/// like "Experience", "Education", "Projects", etc.
class ResumeSection {
  const ResumeSection({required this.title, this.items = const [], this.icon});

  /// Section title (e.g. 'Professional Summary', 'Skills').
  final String title;

  /// Ordered list of content items or bullet points.
  final List<String> items;

  /// Optional icon identifier for visual grouping.
  final String? icon;

  /// Creates a copy with the given fields replaced.
  ResumeSection copyWith({String? title, List<String>? items, String? icon}) {
    return ResumeSection(
      title: title ?? this.title,
      items: items ?? this.items,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResumeSection &&
        other.title == title &&
        _listEquals(other.items, items) &&
        other.icon == icon;
  }

  @override
  int get hashCode => Object.hash(title, Object.hashAll(items), icon);

  @override
  String toString() => 'ResumeSection(title: $title, items: ${items.length})';

  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
