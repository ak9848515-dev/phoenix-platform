import 'memory_category.dart';
import 'memory_importance.dart';

/// A single durable memory entry.
///
/// Stores an atomic piece of user knowledge: fact, decision,
/// achievement, preference, or progress update.
///
/// Each memory belongs to a [MemoryCategory] and has an [MemoryImportance].
/// Memories can be linked via relationships in [MemoryRelationship].
class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.importance = MemoryImportance.medium,
    this.tags = const [],
    this.relatedMemoryIds = const [],
    this.source = '',
    this.confidence = 1.0,
    this.archived = false,
    this.favorite = false,
    this.created,
    this.updated,
  });

  /// Unique identifier.
  final String id;

  /// Short title for display and search.
  final String title;

  /// Full content of the memory.
  final String content;

  /// The category this memory belongs to.
  final MemoryCategory category;

  /// Importance level for prioritisation.
  final MemoryImportance importance;

  /// Searchable tags.
  final List<String> tags;

  /// IDs of related memories.
  final List<String> relatedMemoryIds;

  /// Where this memory was created (e.g. 'academy', 'career', 'user').
  final String source;

  /// Confidence in this memory's accuracy (0.0–1.0).
  final double confidence;

  /// Whether this memory is archived (hidden from normal view).
  final bool archived;

  /// Whether this memory is favorited.
  final bool favorite;

  /// When this memory was created.
  final DateTime? created;

  /// When this memory was last updated.
  final DateTime? updated;

  /// Create a copy with updated fields.
  MemoryEntry copyWith({
    String? id,
    String? title,
    String? content,
    MemoryCategory? category,
    MemoryImportance? importance,
    List<String>? tags,
    List<String>? relatedMemoryIds,
    String? source,
    double? confidence,
    bool? archived,
    bool? favorite,
    DateTime? created,
    DateTime? updated,
  }) =>
      MemoryEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        importance: importance ?? this.importance,
        tags: tags ?? this.tags,
        relatedMemoryIds: relatedMemoryIds ?? this.relatedMemoryIds,
        source: source ?? this.source,
        confidence: confidence ?? this.confidence,
        archived: archived ?? this.archived,
        favorite: favorite ?? this.favorite,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  @override
  String toString() =>
      'MemoryEntry(id: $id, title: $title, '
      'category: ${category.name}, importance: ${importance.name})';
}
