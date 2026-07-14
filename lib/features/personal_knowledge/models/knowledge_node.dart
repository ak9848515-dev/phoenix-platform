import 'dart:convert';

import 'knowledge_domain.dart';

/// A node in the Personal Knowledge Graph representing a
/// distinct piece of knowledge (skill, goal, lesson, etc.).
///
/// Immutable. Each node maps to a source entity from another
/// platform engine but carries its own semantic metadata.
class KnowledgeNode {
  const KnowledgeNode({
    required this.id,
    required this.domain,
    required this.label,
    this.description,
    this.tags = const [],
    this.keywords = const [],
    this.proficiency = 0.0,
    this.importance = 0.0,
    this.confidence = 0.0,
    this.prerequisites = const [],
    this.sourceEngine,
    this.sourceId,
    this.metadata = const {},
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// Knowledge domain (skill, goal, learning, etc.).
  final KnowledgeDomain domain;

  /// Human-readable label.
  final String label;

  /// Optional description.
  final String? description;

  /// Semantic tags for indexing and search.
  final List<String> tags;

  /// Key terms extracted from descriptions.
  final List<String> keywords;

  /// Proficiency level (0.0 - 1.0).
  final double proficiency;

  /// Importance to the user's growth (0.0 - 1.0).
  final double importance;

  /// Confidence in this knowledge (0.0 - 1.0).
  final double confidence;

  /// IDs of prerequisite knowledge nodes.
  final List<String> prerequisites;

  /// Source engine that created this node.
  final String? sourceEngine;

  /// Source entity ID within the engine.
  final String? sourceId;

  /// Additional metadata.
  final Map<String, dynamic> metadata;

  /// When this knowledge was first acquired.
  final DateTime? createdAt;

  /// When this knowledge was last updated.
  final DateTime? updatedAt;

  KnowledgeNode copyWith({
    String? id,
    KnowledgeDomain? domain,
    String? label,
    String? description,
    List<String>? tags,
    List<String>? keywords,
    double? proficiency,
    double? importance,
    double? confidence,
    List<String>? prerequisites,
    String? sourceEngine,
    String? sourceId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KnowledgeNode(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      label: label ?? this.label,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      keywords: keywords ?? this.keywords,
      proficiency: proficiency ?? this.proficiency,
      importance: importance ?? this.importance,
      confidence: confidence ?? this.confidence,
      prerequisites: prerequisites ?? this.prerequisites,
      sourceEngine: sourceEngine ?? this.sourceEngine,
      sourceId: sourceId ?? this.sourceId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'domain': domain.name,
      'label': label,
      'description': description,
      'tags': tags,
      'keywords': keywords,
      'proficiency': proficiency,
      'importance': importance,
      'confidence': confidence,
      'prerequisites': prerequisites,
      'sourceEngine': sourceEngine,
      'sourceId': sourceId,
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory KnowledgeNode.fromMap(Map<String, dynamic> map) {
    return KnowledgeNode(
      id: map['id'] as String,
      domain: KnowledgeDomain.fromString(map['domain'] as String? ?? 'custom'),
      label: map['label'] as String? ?? '',
      description: map['description'] as String?,
      tags: List<String>.from(map['tags'] as List? ?? []),
      keywords: List<String>.from(map['keywords'] as List? ?? []),
      proficiency: (map['proficiency'] as num?)?.toDouble() ?? 0.0,
      importance: (map['importance'] as num?)?.toDouble() ?? 0.0,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      prerequisites: List<String>.from(map['prerequisites'] as List? ?? []),
      sourceEngine: map['sourceEngine'] as String?,
      sourceId: map['sourceId'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory KnowledgeNode.fromJson(String source) =>
      KnowledgeNode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is KnowledgeNode && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'KnowledgeNode(id: $id, domain: $domain, label: $label, '
      'proficiency: ${(proficiency * 100).round()}%)';
}
