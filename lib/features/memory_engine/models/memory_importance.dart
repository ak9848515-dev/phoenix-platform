/// Importance levels for long-term memories.
///
/// Used for auto-sorting and filtering memories.
/// Higher importance memories are prioritised in the snapshot.
enum MemoryImportance {
  critical('Critical', 4),
  high('High', 3),
  medium('Medium', 2),
  low('Low', 1);

  const MemoryImportance(this.displayName, this.weight);

  /// Human-readable label.
  final String displayName;

  /// Numeric weight for sorting (higher = more important).
  final int weight;
}
