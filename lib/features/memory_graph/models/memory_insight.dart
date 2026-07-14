import 'dart:convert';

import 'memory_entity.dart';
import 'memory_relation.dart';

/// An insight or discovery from the Memory Graph.
///
/// Immutable. Produced by [MemoryGraphEngine] from graph analysis.
class MemoryInsight {
  const MemoryInsight({
    required this.id,
    required this.title,
    this.description,
    this.type = MemoryInsightType.connection,
    this.entities = const [],
    this.relations = const [],
    this.relevance = 0.0,
  });

  /// Unique identifier.
  final String id;

  /// Short title (e.g. "Connected Learning Path", "Skill Cluster").
  final String title;

  /// Detailed explanation.
  final String? description;

  /// Category of insight.
  final MemoryInsightType type;

  /// Entities involved in this insight.
  final List<MemoryEntity> entities;

  /// Relations involved.
  final List<MemoryRelation> relations;

  /// Relevance score (0.0 - 1.0).
  final double relevance;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'entities': entities.map((e) => e.toMap()).toList(),
      'relations': relations.map((r) => r.toMap()).toList(),
      'relevance': relevance,
    };
  }

  factory MemoryInsight.fromMap(Map<String, dynamic> map) {
    return MemoryInsight(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      type: MemoryInsightType.fromString(
          map['type'] as String? ?? 'connection'),
      entities: (map['entities'] as List?)
              ?.map((e) => MemoryEntity.fromMap(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      relations: (map['relations'] as List?)
              ?.map((r) => MemoryRelation.fromMap(
                  Map<String, dynamic>.from(r as Map)))
              .toList() ??
          [],
      relevance: (map['relevance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());
  factory MemoryInsight.fromJson(String source) =>
      MemoryInsight.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MemoryInsight && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MemoryInsight(id: $id, title: $title, type: $type)';
}

/// Category of graph insight.
enum MemoryInsightType {
  connection,
  pattern,
  gap,
  cluster,
  recommendation,
  milestone;

  String get label {
    switch (this) {
      case MemoryInsightType.connection:
        return 'Connection';
      case MemoryInsightType.pattern:
        return 'Pattern';
      case MemoryInsightType.gap:
        return 'Gap';
      case MemoryInsightType.cluster:
        return 'Cluster';
      case MemoryInsightType.recommendation:
        return 'Recommendation';
      case MemoryInsightType.milestone:
        return 'Milestone';
    }
  }

  static MemoryInsightType fromString(String value) {
    return MemoryInsightType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => MemoryInsightType.connection,
    );
  }
}
