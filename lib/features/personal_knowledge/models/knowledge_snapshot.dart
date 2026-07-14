import 'dart:convert';

import 'knowledge_context.dart';
import 'knowledge_edge.dart';
import 'knowledge_node.dart';

/// A point-in-time snapshot of the user's knowledge state.
///
/// Persisted via [UserStateService] to maintain knowledge
/// across sessions. Contains the semantic index, edges, and
/// the most recent context for AI consumption.
class KnowledgeSnapshot {
  const KnowledgeSnapshot({
    this.version = 1,
    this.nodes = const [],
    this.edges = const [],
    this.context,
    this.lastIndexedAt,
    this.lastSnapshotAt,
  });

  /// Schema version.
  final int version;

  /// All indexed knowledge nodes.
  final List<KnowledgeNode> nodes;

  /// Semantic edges between nodes.
  final List<KnowledgeEdge> edges;

  /// Most recent AI context.
  final KnowledgeContext? context;

  /// When the semantic index was last rebuilt.
  final DateTime? lastIndexedAt;

  /// When this snapshot was taken.
  final DateTime? lastSnapshotAt;

  int get nodeCount => nodes.length;
  int get edgeCount => edges.length;

  KnowledgeSnapshot copyWith({
    int? version,
    List<KnowledgeNode>? nodes,
    List<KnowledgeEdge>? edges,
    KnowledgeContext? context,
    DateTime? lastIndexedAt,
    DateTime? lastSnapshotAt,
    bool clearContext = false,
  }) {
    return KnowledgeSnapshot(
      version: version ?? this.version,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      context: clearContext ? null : (context ?? this.context),
      lastIndexedAt: lastIndexedAt ?? this.lastIndexedAt,
      lastSnapshotAt: lastSnapshotAt ?? this.lastSnapshotAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'nodes': nodes.map((n) => n.toMap()).toList(),
      'edges': edges.map((e) => e.toMap()).toList(),
      'context': context?.toMap(),
      'lastIndexedAt': lastIndexedAt?.toIso8601String(),
      'lastSnapshotAt': lastSnapshotAt?.toIso8601String(),
    };
  }

  factory KnowledgeSnapshot.fromMap(Map<String, dynamic> map) {
    return KnowledgeSnapshot(
      version: map['version'] as int? ?? 1,
      nodes: (map['nodes'] as List?)
              ?.map((n) => KnowledgeNode.fromMap(
                  Map<String, dynamic>.from(n as Map)))
              .toList() ??
          [],
      edges: (map['edges'] as List?)
              ?.map((e) => KnowledgeEdge.fromMap(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      context: map['context'] != null
          ? KnowledgeContext.fromMap(
              Map<String, dynamic>.from(map['context'] as Map))
          : null,
      lastIndexedAt: map['lastIndexedAt'] != null
          ? DateTime.tryParse(map['lastIndexedAt'] as String)
          : null,
      lastSnapshotAt: map['lastSnapshotAt'] != null
          ? DateTime.tryParse(map['lastSnapshotAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory KnowledgeSnapshot.fromJson(String source) =>
      KnowledgeSnapshot.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeSnapshot &&
          other.version == version &&
          other.nodeCount == nodeCount &&
          other.edgeCount == edgeCount;

  @override
  int get hashCode => Object.hash(version, nodeCount, edgeCount);

  @override
  String toString() =>
      'KnowledgeSnapshot(nodes: $nodeCount, edges: $edgeCount, '
      'indexed: $lastIndexedAt)';
}
