/// Represents a single memory entry in the user's memory timeline.
///
/// Each entry captures a meaningful event, decision, or milestone from
/// the user's personal growth journey.
class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    this.relatedIdentity,
    this.relatedMission,
    required this.importance,
    required this.tags,
    required this.source,
    this.isPinned = false,
  });

  /// Unique identifier for this memory entry.
  final String id;

  /// Short title summarising the memory.
  final String title;

  /// Detailed description of the memory.
  final String description;

  /// Category of the memory (e.g. Learning, Mission, Achievement).
  final MemoryCategory category;

  /// When this memory was created (milliseconds since epoch).
  final int timestamp;

  /// Optional identity this memory is related to.
  final String? relatedIdentity;

  /// Optional mission this memory is related to.
  final String? relatedMission;

  /// Importance level from 0.0 to 1.0.
  final double importance;

  /// Descriptive tags associated with this memory.
  final List<String> tags;

  /// Source that generated this memory (e.g. "system", "user", "mission").
  final String source;

  /// Whether this memory has been pinned by the user.
  final bool isPinned;

  /// Creates a copy of this entry with the given fields replaced.
  MemoryEntry copyWith({
    String? id,
    String? title,
    String? description,
    MemoryCategory? category,
    int? timestamp,
    String? relatedIdentity,
    String? relatedMission,
    double? importance,
    List<String>? tags,
    String? source,
    bool? isPinned,
  }) {
    return MemoryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      relatedIdentity: relatedIdentity ?? this.relatedIdentity,
      relatedMission: relatedMission ?? this.relatedMission,
      importance: importance ?? this.importance,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MemoryEntry(id: $id, title: $title, category: $category, '
        'importance: $importance)';
  }
}

/// Categories for classifying memory entries.
enum MemoryCategory {
  /// A learning milestone or completed course.
  learning,

  /// A mission-related event.
  mission,

  /// An achievement or milestone reached.
  achievement,

  /// A significant decision made.
  decision,

  /// A personal reflection or journal entry.
  reflection,

  /// A project milestone.
  project,

  /// A career-related event.
  career,

  /// A business-related event.
  business,
}