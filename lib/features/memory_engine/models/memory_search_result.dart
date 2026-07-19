import 'memory_entry.dart';

/// A search result from the memory engine.
///
/// Wraps a [MemoryEntry] with relevance and match context.
class MemorySearchResult {
  const MemorySearchResult({
    required this.entry,
    required this.relevance,
    this.matchContext = '',
  });

  /// The matched memory entry.
  final MemoryEntry entry;

  /// Relevance score (0.0–1.0).
  final double relevance;

  /// The context snippet that matched the query.
  final String matchContext;

  @override
  String toString() =>
      'MemorySearchResult(entry: ${entry.title}, '
      'relevance: ${(relevance * 100).round()}%)';
}
