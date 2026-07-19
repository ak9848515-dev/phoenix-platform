/// A single entry in the portfolio timeline.
///
/// Tracks projects, achievements, certificates, and experience
/// in chronological order.
class PortfolioTimelineEntry {
  const PortfolioTimelineEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.description,
    this.iconName,
    this.metadata = const {},
  });

  /// Unique identifier.
  final String id;

  /// Entry type: 'project', 'achievement', 'certificate', 'experience',
  /// 'milestone', 'education', 'publication'.
  final String type;

  /// Human-readable title.
  final String title;

  /// When this entry occurred.
  final DateTime date;

  /// Optional description.
  final String? description;

  /// Optional icon name for display.
  final String? iconName;

  /// Additional metadata (e.g., URL, technologies used).
  final Map<String, dynamic> metadata;

  /// Display label for the entry type.
  String get typeLabel {
    switch (type) {
      case 'project':
        return 'Project';
      case 'achievement':
        return 'Achievement';
      case 'certificate':
        return 'Certificate';
      case 'experience':
        return 'Experience';
      case 'milestone':
        return 'Milestone';
      case 'education':
        return 'Education';
      case 'publication':
        return 'Publication';
      default:
        return type;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioTimelineEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PortfolioTimelineEntry($type: $title, ${date.toIso8601String()})';
}
