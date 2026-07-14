import 'dart:convert';

import 'knowledge_node.dart';

/// A specialized [KnowledgeNode] for skills with proficiency tracking.
///
/// Adds skill-specific metadata like category, experience level,
/// and practice frequency on top of the base [KnowledgeNode].
class SkillNode {
  const SkillNode({
    required this.node,
    this.category,
    this.experienceLevel = 0,
    this.practiceFrequency = 0,
    this.lastPracticedAt,
  });

  /// The base knowledge node.
  final KnowledgeNode node;

  /// Skill category (e.g., "Programming", "Design", "Communication").
  final String? category;

  /// Years/months of experience.
  final int experienceLevel;

  /// Days since last practice (lower = more frequent).
  final int practiceFrequency;

  /// When this skill was last practiced/applied.
  final DateTime? lastPracticedAt;

  SkillNode copyWith({
    KnowledgeNode? node,
    String? category,
    int? experienceLevel,
    int? practiceFrequency,
    DateTime? lastPracticedAt,
  }) {
    return SkillNode(
      node: node ?? this.node,
      category: category ?? this.category,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      practiceFrequency: practiceFrequency ?? this.practiceFrequency,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'node': node.toMap(),
      'category': category,
      'experienceLevel': experienceLevel,
      'practiceFrequency': practiceFrequency,
      'lastPracticedAt': lastPracticedAt?.toIso8601String(),
    };
  }

  factory SkillNode.fromMap(Map<String, dynamic> map) {
    return SkillNode(
      node: KnowledgeNode.fromMap(
          Map<String, dynamic>.from(map['node'] as Map)),
      category: map['category'] as String?,
      experienceLevel: map['experienceLevel'] as int? ?? 0,
      practiceFrequency: map['practiceFrequency'] as int? ?? 0,
      lastPracticedAt: map['lastPracticedAt'] != null
          ? DateTime.tryParse(map['lastPracticedAt'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory SkillNode.fromJson(String source) =>
      SkillNode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillNode && other.node.id == node.id;

  @override
  int get hashCode => node.id.hashCode;

  @override
  String toString() =>
      'SkillNode(${node.label}, proficiency: '
      '${(node.proficiency * 100).round()}%)';
}
