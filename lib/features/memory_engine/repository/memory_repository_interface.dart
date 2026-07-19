import '../models/memory_entry.dart';
import '../models/memory_index.dart';
import '../models/memory_relationship.dart';
import '../models/memory_snapshot.dart';

/// Data access boundary for the Long-Term Memory Engine.
abstract class MemoryRepositoryInterface {
  /// Loads all persisted memory entries.
  Future<List<MemoryEntry>> loadAllEntries();

  /// Persists all memory entries (full replace).
  Future<void> saveAllEntries(List<MemoryEntry> entries);

  /// Loads all persisted relationships.
  Future<List<MemoryRelationship>> loadAllRelationships();

  /// Persists all relationships (full replace).
  Future<void> saveAllRelationships(List<MemoryRelationship> relationships);

  /// Loads the cached memory snapshot, or `null` if none.
  Future<MemorySnapshot?> loadCachedSnapshot();

  /// Caches the current snapshot for fast restart.
  Future<void> cacheSnapshot(MemorySnapshot snapshot);

  /// Loads the search index, or empty index if none.
  Future<MemoryIndex> loadIndex();

  /// Persists the search index.
  Future<void> saveIndex(MemoryIndex index);

  /// Clears all persisted memory data.
  Future<void> clear();
}
