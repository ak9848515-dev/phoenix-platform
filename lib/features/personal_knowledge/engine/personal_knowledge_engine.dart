import 'dart:math' as math;

import '../models/knowledge_context.dart';
import '../models/knowledge_domain.dart';
import '../models/knowledge_edge.dart';
import '../models/knowledge_insight.dart';
import '../models/knowledge_node.dart';
import '../models/knowledge_recommendation.dart';
import '../models/knowledge_snapshot.dart';

/// The core Personal Knowledge Engine.
///
/// Owns:
/// - Semantic knowledge indexing (tags, keywords, categories)
/// - Context generation (AI-ready knowledge summaries)
/// - Cross-domain reasoning (relationships across domains)
/// - Skill relationship mapping (dependencies, prerequisites)
/// - Goal dependency mapping (blockers, milestones)
/// - Knowledge snapshots (point-in-time state)
/// - Recommendation context (growth suggestions)
/// - Knowledge search (cross-domain full-text + semantic)
/// - Knowledge analytics (coverage, gaps, density)
///
/// **Never** owns:
/// - Memory relationships (MemoryGraphEngine owns that)
/// - Timeline logic (TimelineEngine owns that)
/// - Mission logic (MissionEngine owns that)
/// - Habit logic (HabitEngine owns that)
/// - AI logic (AIMentorService owns that)
/// - UserState logic (UserStateService owns that)
///
/// Pure Dart — no Flutter or service dependencies.
/// Integration happens in [KnowledgeService].
class PersonalKnowledgeEngine {
  const PersonalKnowledgeEngine();

  // ── Semantic Indexing ─────────────────────────────────────────────

  /// Builds a semantic index from raw knowledge nodes.
  ///
  /// Extracts tags, keywords, and computes proficiency metrics.
  /// Returns a new snapshot with the indexed nodes.
  KnowledgeSnapshot indexNodes(
    KnowledgeSnapshot snapshot,
    List<KnowledgeNode> newNodes,
  ) {
    final existing = {for (final n in snapshot.nodes) n.id: n};
    for (final node in newNodes) {
      final indexed = _indexNode(node);
      existing[node.id] = indexed;
    }
    return snapshot.copyWith(
      nodes: existing.values.toList(),
      lastIndexedAt: DateTime.now(),
    );
  }

  KnowledgeNode _indexNode(KnowledgeNode node) {
    // Extract keywords from label and description
    final keywords = <String>{
      ..._extractKeywords(node.label),
      if (node.description != null) ..._extractKeywords(node.description!),
      ...node.tags,
    };

    // Generate tags from domain
    final tags = <String>{
      node.domain.name,
      node.domain.label,
      ...node.tags,
    };

    return node.copyWith(
      keywords: keywords.toList(),
      tags: tags.toList(),
    );
  }

  List<String> _extractKeywords(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[\s,.;:!?()\[\]{}]+'))
        .where((w) => w.length > 2 && !_stopWords.contains(w))
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();
  }

  static const _stopWords = <String>{
    'the', 'and', 'for', 'are', 'was', 'has', 'had',
    'but', 'not', 'all', 'can', 'its', 'you',
    'this', 'that', 'with', 'from', 'have', 'been',
    'will', 'would', 'could', 'should', 'their',
    'them', 'they', 'what', 'when', 'where', 'which',
  };

  // ── Knowledge Context Builder ─────────────────────────────────────

  /// Builds a [KnowledgeContext] from a snapshot.
  ///
  /// Organizes nodes by domain, identifies strengths and weaknesses,
  /// and generates a natural language summary.
  KnowledgeContext buildContext(KnowledgeSnapshot snapshot) {
    final nodes = snapshot.nodes;

    final skills = nodes
        .where((n) => n.domain == KnowledgeDomain.skills)
        .toList()
      ..sort((a, b) => b.proficiency.compareTo(a.proficiency));

    final goals = nodes
        .where((n) => n.domain == KnowledgeDomain.goals)
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));

    final learning = nodes
        .where((n) => n.domain == KnowledgeDomain.learning)
        .toList()
      ..sort((a, b) => b.proficiency.compareTo(a.proficiency));

    final career = nodes
        .where((n) => n.domain == KnowledgeDomain.career)
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));

    // Identify strengths (high proficiency) and weaknesses (low proficiency)
    final strengths = skills
        .where((s) => s.proficiency >= 0.6)
        .map((s) => s.label)
        .toList();

    final weaknesses = skills
        .where((s) => s.proficiency < 0.4 && s.proficiency > 0)
        .map((s) => s.label)
        .toList();

    // Recent activity
    final recent = nodes
        .where((n) => n.updatedAt != null)
        .toList()
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt ?? DateTime(2000);
        final bTime = b.updatedAt ?? b.createdAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

    // Generate summary
    final summary = _generateSummary(skills, goals, strengths, weaknesses);

    return KnowledgeContext(
      skills: skills,
      goals: goals,
      learning: learning,
      career: career,
      strengths: strengths,
      weaknesses: weaknesses,
      recentActivity: recent.take(10).toList(),
      summary: summary,
      lastUpdated: DateTime.now(),
    );
  }

  String _generateSummary(
    List<KnowledgeNode> skills,
    List<KnowledgeNode> goals,
    List<String> strengths,
    List<String> weaknesses,
  ) {
    final parts = <String>[];

    if (skills.isNotEmpty) {
      parts.add(
          'Has ${skills.length} tracked skills with proficiency ranging from '
          '${(skills.last.proficiency * 100).round()}% to '
          '${(skills.first.proficiency * 100).round()}%.');
    }

    if (goals.isNotEmpty) {
      final active = goals.where(
          (g) => g.importance > 0.5).length;
      parts.add(
          'Currently tracking $active high-priority goals out of '
          '${goals.length} total goals.');
    }

    if (strengths.isNotEmpty) {
      parts.add(
          'Strongest areas: ${strengths.take(3).join(', ')}.');
    }

    if (weaknesses.isNotEmpty) {
      parts.add(
          'Growth opportunities: ${weaknesses.take(3).join(', ')}.');
    }

    return parts.isNotEmpty ? parts.join(' ') : 'Building knowledge profile...';
  }

  // ── Skill Graph ───────────────────────────────────────────────────

  /// Builds semantic edges between skills based on keyword overlap
  /// and explicit prerequisite relationships.
  List<KnowledgeEdge> buildSkillGraph(List<KnowledgeNode> skillNodes) {
    final edges = <KnowledgeEdge>[];
    int edgeCounter = 0;

    for (int i = 0; i < skillNodes.length; i++) {
      for (int j = i + 1; j < skillNodes.length; j++) {
        final a = skillNodes[i];
        final b = skillNodes[j];

        // Keyword overlap → related
        final overlap =
            a.keywords.where((k) => b.keywords.contains(k)).length;
        if (overlap > 0) {
          final strength = (overlap /
                  math.max(a.keywords.length, b.keywords.length))
              .clamp(0.0, 1.0);
          edges.add(KnowledgeEdge(
            id: 'skg-${edgeCounter++}',
            sourceNodeId: a.id,
            targetNodeId: b.id,
            type: overlap > 2
                ? KnowledgeEdgeType.strengthens
                : KnowledgeEdgeType.relatedTo,
            strength: strength,
            label: overlap > 2
                ? 'Strengthens'
                : 'Related to',
          ));
        }

        // Prerequisite relationship from proficiency
        if (a.prerequisites.contains(b.id)) {
          edges.add(KnowledgeEdge(
            id: 'skg-prereq-${edgeCounter++}',
            sourceNodeId: a.id,
            targetNodeId: b.id,
            type: KnowledgeEdgeType.requires_,
            strength: 0.9,
            label: 'Requires',
          ));
        } else if (b.prerequisites.contains(a.id)) {
          edges.add(KnowledgeEdge(
            id: 'skg-prereq-${edgeCounter++}',
            sourceNodeId: b.id,
            targetNodeId: a.id,
            type: KnowledgeEdgeType.requires_,
            strength: 0.9,
            label: 'Requires',
          ));
        }
      }
    }

    return edges;
  }

  // ── Goal Graph ────────────────────────────────────────────────────

  /// Builds edges between goals and their dependencies.
  List<KnowledgeEdge> buildGoalGraph(List<KnowledgeNode> goalNodes) {
    final edges = <KnowledgeEdge>[];
    int edgeCounter = 0;

    for (final goal in goalNodes) {
      for (final prereqId in goal.prerequisites) {
        // prerequisite goals
        edges.add(KnowledgeEdge(
          id: 'gg-${edgeCounter++}',
          sourceNodeId: goal.id,
          targetNodeId: prereqId,
          type: KnowledgeEdgeType.prerequisite,
          strength: 0.8,
          label: 'Requires',
        ));
      }
    }

    // Builds-toward relationship based on importance
    for (int i = 0; i < goalNodes.length; i++) {
      for (int j = i + 1; j < goalNodes.length; j++) {
        final a = goalNodes[i];
        final b = goalNodes[j];
        final overlap =
            a.keywords.where((k) => b.keywords.contains(k)).length;
        if (overlap > 0) {
          edges.add(KnowledgeEdge(
            id: 'gg-rel-${edgeCounter++}',
            sourceNodeId: a.id,
            targetNodeId: b.id,
            type: KnowledgeEdgeType.relatedTo,
            strength: (overlap / 5.0).clamp(0.0, 1.0),
            label: 'Related goal',
          ));
        }
      }
    }

    return edges;
  }

  // ── Learning Graph ────────────────────────────────────────────────

  /// Builds edges between learning nodes to form learning paths.
  List<KnowledgeEdge> buildLearningGraph(List<KnowledgeNode> learningNodes) {
    final edges = <KnowledgeEdge>[];
    int edgeCounter = 0;

    // Link nodes with keyword overlap (recommended learning sequences)
    for (int i = 0; i < learningNodes.length; i++) {
      for (int j = i + 1; j < learningNodes.length; j++) {
        final a = learningNodes[i];
        final b = learningNodes[j];
        final overlap =
            a.keywords.where((k) => b.keywords.contains(k)).length;
        if (overlap > 0) {
          final type = a.proficiency > b.proficiency
              ? KnowledgeEdgeType.buildsToward
              : KnowledgeEdgeType.prerequisite;
          edges.add(KnowledgeEdge(
            id: 'lg-${edgeCounter++}',
            sourceNodeId: a.id,
            targetNodeId: b.id,
            type: type,
            strength: (overlap / 5.0).clamp(0.0, 1.0),
            label: type == KnowledgeEdgeType.buildsToward
                ? 'Builds toward'
                : 'Prerequisite',
          ));
        }
      }
    }

    return edges;
  }

  // ── Career Graph ──────────────────────────────────────────────────

  /// Builds edges between career nodes and skills/learning.
  List<KnowledgeEdge> buildCareerGraph(
    List<KnowledgeNode> careerNodes,
    List<KnowledgeNode> skillNodes,
    List<KnowledgeNode> learningNodes,
  ) {
    final edges = <KnowledgeEdge>[];
    int edgeCounter = 0;

    for (final career in careerNodes) {
      // Link career to related skills
      for (final skill in skillNodes) {
        final overlap =
            career.keywords.where((k) => skill.keywords.contains(k)).length;
        if (overlap > 0) {
          edges.add(KnowledgeEdge(
            id: 'cg-${edgeCounter++}',
            sourceNodeId: career.id,
            targetNodeId: skill.id,
            type: KnowledgeEdgeType.requires_,
            strength: (overlap / 5.0).clamp(0.0, 1.0),
            label: 'Requires skill',
          ));
        }
      }

      // Link career to related learning
      for (final learn in learningNodes) {
        final overlap =
            career.keywords.where((k) => learn.keywords.contains(k)).length;
        if (overlap > 0) {
          edges.add(KnowledgeEdge(
            id: 'cg-learn-${edgeCounter++}',
            sourceNodeId: career.id,
            targetNodeId: learn.id,
            type: KnowledgeEdgeType.recommended,
            strength: (overlap / 5.0).clamp(0.0, 1.0),
            label: 'Recommended learning',
          ));
        }
      }
    }

    return edges;
  }

  /// Builds the complete knowledge graph from a snapshot.
  ///
  /// Combines all domain-specific graphs into a single edge list.
  List<KnowledgeEdge> buildKnowledgeGraph(KnowledgeSnapshot snapshot) {
    final edges = <KnowledgeEdge>[];

    edges.addAll(buildSkillGraph(
        snapshot.nodes.where((n) => n.domain == KnowledgeDomain.skills).toList()));
    edges.addAll(buildGoalGraph(
        snapshot.nodes.where((n) => n.domain == KnowledgeDomain.goals).toList()));
    edges.addAll(buildLearningGraph(
        snapshot.nodes.where((n) => n.domain == KnowledgeDomain.learning).toList()));
    edges.addAll(buildCareerGraph(
      snapshot.nodes.where((n) => n.domain == KnowledgeDomain.career).toList(),
      snapshot.nodes.where((n) => n.domain == KnowledgeDomain.skills).toList(),
      snapshot.nodes.where((n) => n.domain == KnowledgeDomain.learning).toList(),
    ));

    return edges;
  }

  // ── Recommendation Context ────────────────────────────────────────

  /// Generates personalized recommendations based on the user's
  /// knowledge state.
  List<KnowledgeRecommendation> generateRecommendations(
    KnowledgeSnapshot snapshot,
  ) {
    final recommendations = <KnowledgeRecommendation>[];
    final nodes = snapshot.nodes;
    int recCounter = 0;

    final skills = nodes
        .where((n) => n.domain == KnowledgeDomain.skills)
        .toList();
    final goals = nodes
        .where((n) => n.domain == KnowledgeDomain.goals)
        .toList();

    // Skill gap recommendations
    for (final skill in skills) {
      if (skill.proficiency < 0.3 && skill.proficiency > 0) {
        recommendations.add(KnowledgeRecommendation(
          id: 'rec-${recCounter++}',
          type: KnowledgeRecommendationType.skillGap,
          title: 'Improve: ${skill.label}',
          description: 'Your proficiency in ${skill.label} is '
              '${(skill.proficiency * 100).round()}%. '
              'Consider dedicating time to improve this skill.',
          relevance: 1.0 - skill.proficiency,
          urgency: 1.0 - skill.proficiency,
          sourceNodeIds: [skill.id],
        ));
      }
    }

    // Learning path recommendations based on skill gaps
    final lowSkills = skills
        .where((s) => s.proficiency < 0.4 && s.proficiency > 0)
        .toList();
    if (lowSkills.length >= 2) {
      recommendations.add(KnowledgeRecommendation(
        id: 'rec-${recCounter++}',
        type: KnowledgeRecommendationType.learningPath,
        title: 'Learning Path: ${lowSkills.first.label}',
        description: 'You have ${lowSkills.length} skills '
            'that need improvement. Start with ${lowSkills.first.label}.',
        relevance: 0.7,
        urgency: 0.6,
        sourceNodeIds: lowSkills.map((s) => s.id).toList(),
      ));
    }

    // Next action recommendations
    final pendingGoals = goals.where(
        (g) => g.importance > 0.6);
    for (final goal in pendingGoals.take(3)) {
      recommendations.add(KnowledgeRecommendation(
        id: 'rec-${recCounter++}',
        type: KnowledgeRecommendationType.nextAction,
        title: 'Work on: ${goal.label}',
        description:
            'This high-importance goal needs attention.',
        relevance: goal.importance,
        urgency: goal.importance,
        targetNodeIds: [goal.id],
      ));
    }

    // Coverage recommendations (explore new domains)
    final coveredDomains =
        nodes.map((n) => n.domain).toSet();
    for (final domain in KnowledgeDomain.values) {
      if (!coveredDomains.contains(domain) &&
          domain != KnowledgeDomain.custom) {
        recommendations.add(KnowledgeRecommendation(
          id: 'rec-${recCounter++}',
          type: KnowledgeRecommendationType.nextAction,
          title: 'Explore: ${domain.label}',
          description:
              'You haven\'t explored the ${domain.label} domain yet. '
              'Consider adding knowledge in this area.',
          relevance: 0.3,
          urgency: 0.2,
        ));
      }
    }

    // Sort by relevance
    recommendations.sort(
        (a, b) => b.relevance.compareTo(a.relevance));

    return recommendations;
  }

  // ── Knowledge Search ──────────────────────────────────────────────

  /// Searches knowledge nodes by text query across all domains.
  List<KnowledgeNode> search(
    KnowledgeSnapshot snapshot,
    String query, {
    KnowledgeDomain? domainFilter,
    int maxResults = 20,
  }) {
    if (query.trim().isEmpty) return [];

    final lower = query.toLowerCase();
    final terms = lower.split(RegExp(r'\s+'));

    var candidates = snapshot.nodes;
    if (domainFilter != null) {
      candidates =
          candidates.where((n) => n.domain == domainFilter).toList();
    }

    final scored = <_ScoredNode>[];
    for (final node in candidates) {
      double score = 0.0;

      for (final term in terms) {
        // Label match (highest score)
        if (node.label.toLowerCase().contains(term)) score += 0.5;
        // Description match
        if (node.description?.toLowerCase().contains(term) ?? false) {
          score += 0.3;
        }
        // Tag match
        if (node.tags.any((t) => t.toLowerCase().contains(term))) {
          score += 0.2;
        }
        // Keyword match
        if (node.keywords.any((k) => k.contains(term))) {
          score += 0.2;
        }
      }

      if (score > 0) {
        scored.add(_ScoredNode(node, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(maxResults).map((s) => s.node).toList();
  }

  // ── Knowledge Analytics ───────────────────────────────────────────

  /// Computes analytics about the user's knowledge state.
  Map<String, dynamic> analyze(KnowledgeSnapshot snapshot) {
    final nodes = snapshot.nodes;
    final edges = snapshot.edges;

    // Domain coverage
    final domainCounts = <KnowledgeDomain, int>{};
    for (final node in nodes) {
      domainCounts[node.domain] =
          (domainCounts[node.domain] ?? 0) + 1;
    }

    // Proficiency distribution
    final proficiencyRanges = {
      'high': nodes.where((n) => n.proficiency >= 0.7).length,
      'medium': nodes
          .where((n) => n.proficiency >= 0.4 && n.proficiency < 0.7)
          .length,
      'low': nodes
          .where((n) => n.proficiency > 0 && n.proficiency < 0.4)
          .length,
      'untracked': nodes.where((n) => n.proficiency == 0).length,
    };

    // Skill coverage
    final skillCount =
        nodes.where((n) => n.domain == KnowledgeDomain.skills).length;
    final goalCount =
        nodes.where((n) => n.domain == KnowledgeDomain.goals).length;
    final learningCount =
        nodes.where((n) => n.domain == KnowledgeDomain.learning).length;

    // Density
    final density = nodes.length > 1
        ? (edges.length * 2.0) / (nodes.length * (nodes.length - 1))
        : 0.0;

    // Most proficient skills
    final topSkills = nodes
        .where((n) => n.domain == KnowledgeDomain.skills)
        .toList()
      ..sort((a, b) => b.proficiency.compareTo(a.proficiency));

    // Most important goals
    final topGoals = nodes
        .where((n) => n.domain == KnowledgeDomain.goals)
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));

    // Learning velocity (recent additions)
    final recentCount = nodes
        .where((n) =>
            n.createdAt != null &&
            DateTime.now().difference(n.createdAt!).inDays < 30)
        .length;

    return {
      'nodeCount': nodes.length,
      'edgeCount': edges.length,
      'domainCounts': domainCounts.map(
          (k, v) => MapEntry(k.name, v)),
      'domainCoverage': domainCounts.length,
      'totalDomains': KnowledgeDomain.values.length -
          1, // exclude 'custom'
      'proficiencyRanges': proficiencyRanges,
      'skillCount': skillCount,
      'goalCount': goalCount,
      'learningCount': learningCount,
      'density': density,
      'topSkills': topSkills.take(5).map((s) => s.label).toList(),
      'topGoals': topGoals.take(5).map((g) => g.label).toList(),
      'recentActivityCount': recentCount,
    };
  }

  /// Generates insights from the knowledge state.
  List<KnowledgeInsight> generateInsights(KnowledgeSnapshot snapshot) {
    final insights = <KnowledgeInsight>[];
    int insightCounter = 0;
    final analytics = analyze(snapshot);

    // Domain coverage insight
    final coverage = analytics['domainCoverage'] as int;
    final totalDomains = analytics['totalDomains'] as int;
    if (coverage < totalDomains) {
      insights.add(KnowledgeInsight(
        id: 'insight-${insightCounter++}',
        type: KnowledgeInsightType.coverage,
        title: 'Domain Coverage: $coverage / $totalDomains',
        description:
            'You have knowledge in $coverage out of $totalDomains domains. '
            'Explore the remaining domains for a more complete profile.',
        relevance: 1.0 - (coverage / totalDomains),
      ));
    }

    // Skill gap insight
    final low = analytics['proficiencyRanges']['low'] as int;
    if (low > 0) {
      insights.add(KnowledgeInsight(
        id: 'insight-${insightCounter++}',
        type: KnowledgeInsightType.skillGap,
        title: '$low Skills Need Improvement',
        description:
            'You have $low skills with low proficiency. '
            'Focusing on these will accelerate your growth.',
        relevance: (low / 10.0).clamp(0.0, 1.0),
        actionable: true,
      ));
    }

    // Top strength insight
    final topSkills =
        analytics['topSkills'] as List<String>;
    if (topSkills.isNotEmpty) {
      insights.add(KnowledgeInsight(
        id: 'insight-${insightCounter++}',
        type: KnowledgeInsightType.strength,
        title: 'Strongest: ${topSkills.first}',
        description:
            'Your highest proficiency skill is ${topSkills.first}. '
            'Continue building on this strength.',
        relevance: 0.8,
      ));
    }

    // Learning velocity insight
    final recentCount = analytics['recentActivityCount'] as int;
    if (recentCount > 0) {
      insights.add(KnowledgeInsight(
        id: 'insight-${insightCounter++}',
        type: KnowledgeInsightType.pattern,
        title: 'Learning Velocity: $recentCount in 30 days',
        description:
            'You added $recentCount knowledge items in the last 30 days.',
        relevance: 0.6,
      ));
    }

    // Goal progress insight
    final topGoals = analytics['topGoals'] as List<String>;
    if (topGoals.isNotEmpty) {
      insights.add(KnowledgeInsight(
        id: 'insight-${insightCounter++}',
        type: KnowledgeInsightType.pattern,
        title: 'Top Goal: ${topGoals.first}',
        description:
            'Your highest importance goal is ${topGoals.first}.',
        relevance: 0.7,
      ));
    }

    // Density insight
    final density = analytics['density'] as double;
    if (snapshot.nodes.length > 3 && density < 0.1) {
      insights.add(KnowledgeInsight(
        id: 'insight-${insightCounter++}',
        type: KnowledgeInsightType.pattern,
        title: 'Knowledge Graph: Sparse',
        description:
            'Your knowledge graph has low density (${(density * 100).round()}%). '
            'Connect more knowledge nodes to discover hidden patterns.',
        relevance: 0.5,
      ));
    }

    insights.sort((a, b) => b.relevance.compareTo(a.relevance));
    return insights;
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Finds nodes similar to the given node across the snapshot.
  List<KnowledgeNode> findSimilar(
    KnowledgeSnapshot snapshot,
    String nodeId, {
    int maxResults = 5,
  }) {
    final target =
        snapshot.nodes.where((n) => n.id == nodeId).firstOrNull;
    if (target == null) return [];

    final scored = <_ScoredNode>[];
    for (final node in snapshot.nodes) {
      if (node.id == nodeId) continue;

      double score = 0.0;
      if (node.domain == target.domain) score += 0.3;

      final keywordOverlap =
          target.keywords.where((k) => node.keywords.contains(k)).length;
      score += (keywordOverlap / math.max(1, target.keywords.length)) * 0.5;

      final tagOverlap =
          target.tags.where((t) => node.tags.contains(t)).length;
      score += (tagOverlap / math.max(1, target.tags.length)) * 0.2;

      if (score > 0) {
        scored.add(_ScoredNode(node, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(maxResults).map((s) => s.node).toList();
  }
}

/// Internal helper for scored search results.
class _ScoredNode {
  _ScoredNode(this.node, this.score);
  final KnowledgeNode node;
  final double score;
}
