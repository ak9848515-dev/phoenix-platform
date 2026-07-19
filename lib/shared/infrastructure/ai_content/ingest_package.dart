import 'metadata.dart';

/// A package of AI-generated content ready for ingestion into a domain engine.
///
/// Each [IngestPackage] pairs the raw content data with provenance metadata
/// so the engine can decide how to merge, replace, or ignore the content.
///
/// **Architecture Rules:**
/// - Engines receive [IngestPackage] and own all merge logic
/// - Orchestrator never manipulates engine internals
/// - Every package has a [type] so engines can route content internally
class IngestPackage {
  const IngestPackage({
    required this.type,
    required this.content,
    required this.metadata,
  });

  /// Content type identifier (e.g., 'mission', 'lesson', 'project', etc.).
  final String type;

  /// The raw content data as a map. Each engine's `ingest()` method
  /// interprets this according to its own schema.
  final Map<String, dynamic> content;

  /// Provenance metadata for this content package.
  final AIContentMetadata metadata;

  /// Convenience hash for duplicate detection (delegates to metadata).
  String get contentHash => metadata.contentHash;

  @override
  String toString() =>
      'IngestPackage(type: $type, hash: ${contentHash.substring(0, 8)}, '
      'source: ${metadata.source})';
}

/// Extension on [List<IngestPackage>] for batch operations.
extension IngestPackagesX on List<IngestPackage> {
  /// Filters packages by type.
  List<IngestPackage> byType(String type) =>
      where((p) => p.type == type).toList();

  /// Returns all unique content hashes from this list.
  Set<String> get contentHashes => map((p) => p.contentHash).toSet();

  /// Removes duplicates based on contentHash (first occurrence wins).
  List<IngestPackage> deduplicated() {
    final seen = <String>{};
    final result = <IngestPackage>[];
    for (final pkg in this) {
      if (seen.add(pkg.contentHash)) {
        result.add(pkg);
      }
    }
    return result;
  }
}
