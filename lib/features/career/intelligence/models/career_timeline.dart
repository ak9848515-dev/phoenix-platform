/// A single entry in the career timeline.
///
/// Tracks milestones, applications, interviews, offers, promotions,
/// certifications, and other career events chronologically.
class CareerTimelineEntry {
  const CareerTimelineEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.description,
    this.iconName,
    this.status = 'completed',
    this.metadata = const {},
  });

  /// Unique identifier.
  final String id;

  /// Entry type: 'milestone', 'skill_learned', 'project_completed',
  /// 'interview', 'application', 'offer', 'certification',
  /// 'promotion', 'networking', 'assessment'.
  final String type;

  /// Human-readable title.
  final String title;

  /// When this entry occurred.
  final DateTime date;

  /// Optional description.
  final String? description;

  /// Optional icon name for display.
  final String? iconName;

  /// Status: 'completed', 'in_progress', 'planned', 'expired'.
  final String status;

  /// Additional metadata.
  final Map<String, dynamic> metadata;

  /// Display label for the entry type.
  String get typeLabel {
    switch (type) {
      case 'milestone':
        return 'Milestone';
      case 'skill_learned':
        return 'Skill Learned';
      case 'project_completed':
        return 'Project Completed';
      case 'interview':
        return 'Interview';
      case 'application':
        return 'Application';
      case 'offer':
        return 'Offer';
      case 'certification':
        return 'Certification';
      case 'promotion':
        return 'Promotion';
      case 'networking':
        return 'Networking';
      case 'assessment':
        return 'Assessment';
      default:
        return type;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerTimelineEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CareerTimelineEntry($type: $title, ${date.toIso8601String()})';
}
