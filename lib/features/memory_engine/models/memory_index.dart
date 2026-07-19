/// A search index for fast keyword-based memory lookup.
///
/// Maps lowercased keywords to sets of memory entry IDs.
/// Built deterministically — no embeddings or vector search.
class MemoryIndex {
  const MemoryIndex({
    this.keywordIndex = const <String, List<String>>{},
    this.tagIndex = const <String, List<String>>{},
    this.categoryIndex = const <String, List<String>>{},
  });

  /// Maps keyword -> list of memory IDs containing that keyword.
  final Map<String, List<String>> keywordIndex;

  /// Maps tag -> list of memory IDs with that tag.
  final Map<String, List<String>> tagIndex;

  /// Maps category name -> list of memory IDs in that category.
  final Map<String, List<String>> categoryIndex;

  /// Returns memory IDs matching a keyword.
  List<String> searchKeyword(String keyword) =>
      keywordIndex[keyword.toLowerCase()] ?? [];

  /// Returns memory IDs with a specific tag.
  List<String> searchTag(String tag) => tagIndex[tag.toLowerCase()] ?? [];

  /// Returns memory IDs in a specific category.
  List<String> searchCategory(String category) =>
      categoryIndex[category.toLowerCase()] ?? [];

  @override
  String toString() =>
      'MemoryIndex(keywords: ${keywordIndex.length}, '
      'tags: ${tagIndex.length}, categories: ${categoryIndex.length})';
}
