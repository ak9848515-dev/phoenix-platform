import 'dart:convert';

import 'knowledge_node.dart';

/// A snapshot of the user's knowledge context, ready for AI consumption.
///
/// Built by [PersonalKnowledgeEngine.buildContext] and consumed
/// by [AIMentorService] to provide Phoenix AI with long-term context.
///
/// Contains summaries of the user's skills, goals, learning,
/// career, and recent activity — all from the semantic index.
class KnowledgeContext {
  const KnowledgeContext({
    this.skills = const [],
    this.goals = const [],
    this.learning = const [],
    this.career = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.recentActivity = const [],
    this.summary,
    this.lastUpdated,
  });

  /// Top skills with proficiency levels.
  final List<KnowledgeNode> skills;

  /// Active and completed goals.
  final List<KnowledgeNode> goals;

  /// Learning progress nodes.
  final List<KnowledgeNode> learning;

  /// Career trajectory nodes.
  final List<KnowledgeNode> career;

  /// Areas of strength (domain labels).
  final List<String> strengths;

  /// Areas needing improvement (domain labels).
  final List<String> weaknesses;

  /// Recent knowledge activity.
  final List<KnowledgeNode> recentActivity;

  /// Natural language summary of the user's knowledge state.
  final String? summary;

  /// When this context was last generated.
  final DateTime? lastUpdated;

  /// Formats the context as a structured prompt for AI consumption.
  String toPromptString() {
    final buf = StringBuffer('USER KNOWLEDGE CONTEXT\n');
    buf.writeln('─' * 40);

    if (summary != null) {
      buf.writeln('\nSummary: $summary\n');
    }

    if (skills.isNotEmpty) {
      buf.writeln('Skills (${skills.length}):');
      for (final s in skills.take(10)) {
        buf.writeln(
            '  - ${s.label} (${(s.proficiency * 100).round()}% proficiency)');
      }
    }

    if (goals.isNotEmpty) {
      buf.writeln('\nGoals (${goals.length}):');
      for (final g in goals.take(5)) {
        buf.writeln(
            '  - ${g.label} (importance: ${(g.importance * 100).round()}%)');
      }
    }

    if (learning.isNotEmpty) {
      buf.writeln('\nLearning (${learning.length}):');
      for (final l in learning.take(5)) {
        buf.writeln('  - ${l.label}');
      }
    }

    if (strengths.isNotEmpty) {
      buf.writeln('\nStrengths: ${strengths.join(', ')}');
    }

    if (weaknesses.isNotEmpty) {
      buf.writeln('Growth areas: ${weaknesses.join(', ')}');
    }

    buf.writeln('\nKnowledge last updated: ${lastUpdated ?? 'unknown'}');
    return buf.toString();
  }

  KnowledgeContext copyWith({
    List<KnowledgeNode>? skills,
    List<KnowledgeNode>? goals,
    List<KnowledgeNode>? learning,
    List<KnowledgeNode>? career,
    List<String>? strengths,
    List<String>? weaknesses,
    List<KnowledgeNode>? recentActivity,
    String? summary,
    DateTime? lastUpdated,
  }) {
    return KnowledgeContext(
      skills: skills ?? this.skills,
      goals: goals ?? this.goals,
      learning: learning ?? this.learning,
      career: career ?? this.career,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      recentActivity: recentActivity ?? this.recentActivity,
      summary: summary ?? this.summary,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skills': skills.map((s) => s.toMap()).toList(),
      'goals': goals.map((g) => g.toMap()).toList(),
      'learning': learning.map((l) => l.toMap()).toList(),
      'career': career.map((c) => c.toMap()).toList(),
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recentActivity': recentActivity.map((r) => r.toMap()).toList(),
      'summary': summary,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory KnowledgeContext.fromMap(Map<String, dynamic> map) {
    return KnowledgeContext(
      skills: _parseNodes(map['skills']),
      goals: _parseNodes(map['goals']),
      learning: _parseNodes(map['learning']),
      career: _parseNodes(map['career']),
      strengths: List<String>.from(map['strengths'] as List? ?? []),
      weaknesses: List<String>.from(map['weaknesses'] as List? ?? []),
      recentActivity: _parseNodes(map['recentActivity']),
      summary: map['summary'] as String?,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());
  factory KnowledgeContext.fromJson(String source) =>
      KnowledgeContext.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<KnowledgeNode> _parseNodes(dynamic data) {
    if (data == null) return const [];
    return (data as List)
        .map((n) =>
            KnowledgeNode.fromMap(Map<String, dynamic>.from(n as Map)))
        .toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeContext && other.summary == summary;

  @override
  int get hashCode => summary.hashCode;

  @override
  String toString() =>
      'KnowledgeContext(skills: ${skills.length}, goals: ${goals.length})';
}
