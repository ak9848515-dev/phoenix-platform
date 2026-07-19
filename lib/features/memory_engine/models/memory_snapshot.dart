import 'memory_category.dart';
import 'memory_entry.dart';
import 'memory_graph.dart';

/// Read-only snapshot of the user's long-term memory state.
///
/// Dashboard, AI Mentor, Daily Brief, etc. read this snapshot
/// instead of querying the memory engine directly.
///
/// Immutable. Produced by [MemoryEngine].
class MemorySnapshot {
  const MemorySnapshot({
    this.recentMemories = const [],
    this.importantMemories = const [],
    this.relatedMemories = const [],
    this.activeGoals = const [],
    this.recentAchievements = const [],
    this.pendingKnowledge = const [],
    this.totalMemories = 0,
    this.totalRelationships = 0,
    this.lastUpdated,
    this.graph = const MemoryGraph(),
  });

  /// Most recently created/updated memories (up to 10).
  final List<MemoryEntry> recentMemories;

  /// Memories sorted by importance (critical + high, up to 10).
  final List<MemoryEntry> importantMemories;

  /// Memories related to a specific context.
  final List<MemoryEntry> relatedMemories;

  /// Memory entries for active goals.
  final List<MemoryEntry> activeGoals;

  /// Recent achievement memories.
  final List<MemoryEntry> recentAchievements;

  /// Knowledge the user has pending (learning in progress).
  final List<MemoryEntry> pendingKnowledge;

  /// Total number of memories stored.
  final int totalMemories;

  /// Total number of relationships in the graph.
  final int totalRelationships;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  /// The full memory graph.
  final MemoryGraph graph;

  /// Whether there are any memories.
  bool get hasMemories => totalMemories > 0;

  /// Whether there are important memories.
  bool get hasImportantMemories => importantMemories.isNotEmpty;

  /// Whether there are recent achievements.
  bool get hasAchievements => recentAchievements.isNotEmpty;

  /// The most important single memory.
  MemoryEntry? get topMemory =>
      importantMemories.isNotEmpty ? importantMemories.first : null;

  /// Memory count by category.
  Map<MemoryCategory, int> get categoryCounts {
    final counts = <MemoryCategory, int>{};
    for (final entry in graph.entries.values) {
      counts[entry.category] = (counts[entry.category] ?? 0) + 1;
    }
    return counts;
  }

  @override
  String toString() =>
      'MemorySnapshot(memories: $totalMemories, '
      'relationships: $totalRelationships, '
      'recent: ${recentMemories.length})';
}
