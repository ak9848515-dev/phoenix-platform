import 'dart:convert';

import 'knowledge_node.dart';

/// A specialized [KnowledgeNode] for goals with progress tracking.
///
/// Adds goal-specific metadata like deadline, status, and
/// measurable target on top of the base [KnowledgeNode].
class GoalNode {
  const GoalNode({
    required this.node,
    this.targetDate,
    this.status = GoalStatus.active,
    this.progress = 0.0,
    this.milestones = const [],
    this.blockedBy = const [],
  });

  /// The base knowledge node.
  final KnowledgeNode node;

  /// Optional target completion date.
  final DateTime? targetDate;

  /// Current status.
  final GoalStatus status;

  /// Progress toward completion (0.0 - 1.0).
  final double progress;

  /// Milestones achieved.
  final List<String> milestones;

  /// IDs of nodes blocking this goal.
  final List<String> blockedBy;

  GoalNode copyWith({
    KnowledgeNode? node,
    DateTime? targetDate,
    GoalStatus? status,
    double? progress,
    List<String>? milestones,
    List<String>? blockedBy,
  }) {
    return GoalNode(
      node: node ?? this.node,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      milestones: milestones ?? this.milestones,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'node': node.toMap(),
      'targetDate': targetDate?.toIso8601String(),
      'status': status.name,
      'progress': progress,
      'milestones': milestones,
      'blockedBy': blockedBy,
    };
  }

  factory GoalNode.fromMap(Map<String, dynamic> map) {
    return GoalNode(
      node: KnowledgeNode.fromMap(
          Map<String, dynamic>.from(map['node'] as Map)),
      targetDate: map['targetDate'] != null
          ? DateTime.tryParse(map['targetDate'] as String)
          : null,
      status: GoalStatus.fromString(map['status'] as String? ?? 'active'),
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      milestones: List<String>.from(map['milestones'] as List? ?? []),
      blockedBy: List<String>.from(map['blockedBy'] as List? ?? []),
    );
  }

  String toJson() => json.encode(toMap());
  factory GoalNode.fromJson(String source) =>
      GoalNode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalNode && other.node.id == node.id;

  @override
  int get hashCode => node.id.hashCode;

  @override
  String toString() =>
      'GoalNode(${node.label}, status: $status, progress: '
      '${(progress * 100).round()}%)';
}

/// Status of a knowledge goal.
enum GoalStatus {
  active('Active'),
  inProgress('In Progress'),
  completed('Completed'),
  archived('Archived'),
  blocked('Blocked');

  const GoalStatus(this.label);
  final String label;

  static GoalStatus fromString(String value) {
    return GoalStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => GoalStatus.active,
    );
  }
}
