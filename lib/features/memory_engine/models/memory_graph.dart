import 'memory_entry.dart';
import 'memory_relationship.dart';

/// An in-memory graph of memory entries and their relationships.
///
/// Supports traversal: find related memories, paths between memories,
/// and clusters of connected memories.
class MemoryGraph {
  const MemoryGraph({
    this.entries = const <String, MemoryEntry>{},
    this.relationships = const <MemoryRelationship>[],
  });

  /// All entries indexed by ID.
  final Map<String, MemoryEntry> entries;

  /// All relationships.
  final List<MemoryRelationship> relationships;

  /// Returns the entry with the given ID, or `null`.
  MemoryEntry? getEntry(String id) => entries[id];

  /// Returns all relationships where the given memory is the source.
  List<MemoryRelationship> outgoingRelationships(String memoryId) =>
      relationships.where((r) => r.sourceId == memoryId).toList();

  /// Returns all relationships where the given memory is the target.
  List<MemoryRelationship> incomingRelationships(String memoryId) =>
      relationships.where((r) => r.targetId == memoryId).toList();

  /// Returns directly related memory entries (both incoming and outgoing).
  List<MemoryEntry> relatedEntries(String memoryId) {
    final related = <MemoryEntry>{};
    for (final rel in relationships) {
      if (rel.sourceId == memoryId) {
        final target = entries[rel.targetId];
        if (target != null) related.add(target);
      }
      if (rel.targetId == memoryId) {
        final source = entries[rel.sourceId];
        if (source != null) related.add(source);
      }
    }
    return related.toList();
  }

  /// Total number of entries.
  int get entryCount => entries.length;

  /// Total number of relationships.
  int get relationshipCount => relationships.length;

  /// Whether the graph contains the given entry.
  bool containsEntry(String id) => entries.containsKey(id);

  @override
  String toString() =>
      'MemoryGraph(entries: $entryCount, relationships: $relationshipCount)';
}
