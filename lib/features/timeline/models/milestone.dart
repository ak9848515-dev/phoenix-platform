import 'dart:convert';

import 'timeline_category.dart' show TimelineCategory;

/// A significant milestone detected by the Life Timeline Engine.
///
/// Immutable. Milestones are derived from event patterns and represent
/// meaningful achievements in the user's journey.
class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    this.iconName,
    this.eventIds = const [],
    this.isPinned = false,
  });

  /// Unique identifier.
  final String id;

  /// Milestone title (e.g. "First Lesson Completed").
  final String title;

  /// Detailed description.
  final String description;

  /// Category.
  final TimelineCategory category;

  /// When the milestone was achieved.
  final DateTime timestamp;

  /// Optional icon override.
  final String? iconName;

  /// IDs of the events that triggered this milestone.
  final List<String> eventIds;

  /// Whether the user has pinned this milestone.
  final bool isPinned;

  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    TimelineCategory? category,
    DateTime? timestamp,
    String? iconName,
    List<String>? eventIds,
    bool? isPinned,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      iconName: iconName ?? this.iconName,
      eventIds: eventIds ?? this.eventIds,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'iconName': iconName,
      'eventIds': eventIds,
      'isPinned': isPinned,
    };
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: TimelineCategory.fromString(map['category'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      iconName: map['iconName'] as String?,
      eventIds: List<String>.from(map['eventIds'] as List? ?? []),
      isPinned: map['isPinned'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory Milestone.fromJson(String source) =>
      Milestone.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Milestone && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Milestone(id: $id, title: $title, category: $category)';
}
