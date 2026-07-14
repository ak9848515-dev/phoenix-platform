import 'dart:convert';

import 'timeline_category.dart' show TimelineCategory;

/// A normalized timeline event aggregated from platform engines.
///
/// Immutable. The Life Timeline Engine creates these from
/// source data — it never owns the business logic of the
/// source engines.
class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timestamp,
    required this.sourceEngine,
    this.sourceId,
    this.iconName,
    this.metadata = const {},
    this.importance = 0,
  });

  /// Unique identifier for this event.
  final String id;

  /// Short title.
  final String title;

  /// Detailed description.
  final String description;

  /// Event category.
  final TimelineCategory category;

  /// When the event occurred.
  final DateTime timestamp;

  /// The engine that produced this event (e.g. 'mission_engine', 'academy').
  final String sourceEngine;

  /// Optional ID of the source entity.
  final String? sourceId;

  /// Optional icon override.
  final String? iconName;

  /// Optional metadata key-value pairs for extensibility.
  final Map<String, dynamic> metadata;

  /// Importance level (0 = normal, 1 = milestone, 2 = major milestone).
  final int importance;

  TimelineEvent copyWith({
    String? id,
    String? title,
    String? description,
    TimelineCategory? category,
    DateTime? timestamp,
    String? sourceEngine,
    String? sourceId,
    String? iconName,
    Map<String, dynamic>? metadata,
    int? importance,
  }) {
    return TimelineEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      sourceEngine: sourceEngine ?? this.sourceEngine,
      sourceId: sourceId ?? this.sourceId,
      iconName: iconName ?? this.iconName,
      metadata: metadata ?? this.metadata,
      importance: importance ?? this.importance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'sourceEngine': sourceEngine,
      'sourceId': sourceId,
      'iconName': iconName,
      'metadata': metadata,
      'importance': importance,
    };
  }

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: TimelineCategory.fromString(map['category'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      sourceEngine: map['sourceEngine'] as String,
      sourceId: map['sourceId'] as String?,
      iconName: map['iconName'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
      importance: map['importance'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory TimelineEvent.fromJson(String source) =>
      TimelineEvent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TimelineEvent(id: $id, title: $title, category: $category, '
      'timestamp: $timestamp)';
}
