import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/personal_knowledge/engine/personal_knowledge_engine.dart';
import 'package:phoenix_platform/features/personal_knowledge/models/knowledge_domain.dart';
import 'package:phoenix_platform/features/personal_knowledge/models/knowledge_edge.dart';
import 'package:phoenix_platform/features/personal_knowledge/models/knowledge_insight.dart';
import 'package:phoenix_platform/features/personal_knowledge/models/knowledge_node.dart';
import 'package:phoenix_platform/features/personal_knowledge/models/knowledge_recommendation.dart';
import 'package:phoenix_platform/features/personal_knowledge/models/knowledge_snapshot.dart';

void main() {
  const engine = PersonalKnowledgeEngine();

  final sampleNodes = [
    KnowledgeNode(
      id: 'sk-1',
      domain: KnowledgeDomain.skills,
      label: 'Flutter',
      description: 'Cross-platform mobile development',
      tags: ['mobile', 'dart', 'ui'],
      keywords: ['flutter', 'mobile', 'dart', 'ui', 'cross-platform'],
      proficiency: 0.8,
      importance: 0.9,
    ),
    KnowledgeNode(
      id: 'sk-2',
      domain: KnowledgeDomain.skills,
      label: 'Python',
      description: 'General purpose programming',
      tags: ['backend', 'data', 'automation'],
      keywords: ['python', 'programming', 'backend'],
      proficiency: 0.25,
      importance: 0.7,
    ),
    KnowledgeNode(
      id: 'sk-3',
      domain: KnowledgeDomain.skills,
      label: 'Dart',
      description: 'Programming language for Flutter',
      tags: ['mobile', 'language'],
      keywords: ['dart', 'flutter', 'mobile', 'language'],
      proficiency: 0.6,
      importance: 0.6,
    ),
    KnowledgeNode(
      id: 'gl-1',
      domain: KnowledgeDomain.goals,
      label: 'Build a mobile app',
      importance: 0.9,
      prerequisites: ['sk-1'],
    ),
    KnowledgeNode(
      id: 'gl-2',
      domain: KnowledgeDomain.goals,
      label: 'Learn backend',
      importance: 0.6,
    ),
    KnowledgeNode(
      id: 'ln-1',
      domain: KnowledgeDomain.learning,
      label: 'Flutter Advanced UI',
      proficiency: 0.3,
      keywords: ['ui', 'flutter', 'animation'],
      tags: ['learning', 'flutter'],
    ),
    KnowledgeNode(
      id: 'ln-2',
      domain: KnowledgeDomain.learning,
      label: 'Python for Data Science',
      proficiency: 0.5,
      keywords: ['python', 'data', 'ml', 'animation'],
      tags: ['learning', 'python'],
    ),
    KnowledgeNode(
      id: 'cr-1',
      domain: KnowledgeDomain.career,
      label: 'Mobile Developer',
      keywords: ['flutter', 'mobile', 'dart', 'app'],
    ),
  ];

  group('indexNodes', () {
    test('indexes nodes with extracted keywords and tags', () {
      final snapshot = const KnowledgeSnapshot();
      final result = engine.indexNodes(snapshot, sampleNodes);

      expect(result.nodeCount, sampleNodes.length);
      expect(result.lastIndexedAt, isNotNull);

      // Check keyword extraction from label and description
      final flutterNode =
          result.nodes.firstWhere((n) => n.id == 'sk-1');
      // Keywords from label + description + tags
      expect(flutterNode.keywords.contains('flutter'), true);
      expect(flutterNode.keywords.contains('mobile'), true);
      expect(flutterNode.keywords.contains('dart'), true);
      expect(flutterNode.keywords.contains('ui'), true);
    });

    test('deduplicates by ID', () {
      final snapshot = const KnowledgeSnapshot();
      final initial = engine.indexNodes(snapshot, sampleNodes);
      // Re-index same nodes
      final result = engine.indexNodes(initial, sampleNodes);
      expect(result.nodeCount, sampleNodes.length);
    });
  });

  group('buildContext', () {
    test('builds context with skills, goals, learning', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final ctx = engine.buildContext(snapshot);

      expect(ctx.skills, isNotEmpty);
      expect(ctx.goals, isNotEmpty);
      expect(ctx.learning, isNotEmpty);
      expect(ctx.strengths, contains('Flutter'));
      expect(ctx.weaknesses, isNotEmpty);
      expect(ctx.summary, isNotNull);
    });

    test('identifies strengths and weaknesses correctly', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final ctx = engine.buildContext(snapshot);

      expect(ctx.strengths, contains('Flutter')); // proficiency 0.8 >= 0.6
      expect(ctx.weaknesses, contains('Python')); // proficiency 0.4 < 0.7 is medium, > 0 so checked
    });

    test('generates summary text', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final ctx = engine.buildContext(snapshot);

      expect(ctx.summary, contains('3'));
      expect(ctx.summary, contains('skills'));
    });
  });

  group('buildSkillGraph', () {
    test('creates edges between related skills', () {
      final skills = sampleNodes
          .where((n) => n.domain == KnowledgeDomain.skills)
          .toList();
      final edges = engine.buildSkillGraph(skills);

      expect(edges.isNotEmpty, true);
      // Flutter and Dart should be related (keyword overlap)
      final flutterDart = edges.any((e) =>
          (e.sourceNodeId == 'sk-1' && e.targetNodeId == 'sk-3') ||
          (e.sourceNodeId == 'sk-3' && e.targetNodeId == 'sk-1'));
      expect(flutterDart, true);
    });

    test('creates prerequisite edges', () {
      final skills = sampleNodes
          .where((n) => n.domain == KnowledgeDomain.skills)
          .toList();
      // Manually add a prerequisite relationship
      final withPrereq = skills.map((s) {
        if (s.id == 'sk-3') {
          return s.copyWith(prerequisites: ['sk-2']);
        }
        return s;
      }).toList();

      final edges = engine.buildSkillGraph(withPrereq);
      final prereqEdge = edges.any(
          (e) => e.type == KnowledgeEdgeType.requires_);
      expect(prereqEdge, true);
    });
  });

  group('buildGoalGraph', () {
    test('creates edges from prerequisites and keyword overlap', () {
      final goals = sampleNodes
          .where((n) => n.domain == KnowledgeDomain.goals)
          .toList();
      final edges = engine.buildGoalGraph(goals);

      // Should have a prerequisite edge from gl-1 to sk-1
      final prereq = edges.any((e) =>
          e.sourceNodeId == 'gl-1' &&
          e.type == KnowledgeEdgeType.prerequisite);
      expect(prereq, true);
    });
  });

  group('buildLearningGraph', () {
    test('creates edges between related learning nodes', () {
      final learning = sampleNodes
          .where((n) => n.domain == KnowledgeDomain.learning)
          .toList();
      final edges = engine.buildLearningGraph(learning);

      expect(edges.isNotEmpty, true);
    });
  });

  group('buildCareerGraph', () {
    test('links career to related skills and learning', () {
      final career = sampleNodes
          .where((n) => n.domain == KnowledgeDomain.career)
          .toList();
      final skills = sampleNodes
          .where((n) => n.domain == KnowledgeDomain.skills)
          .toList();
      final learning = sampleNodes
          .where((n) => n.domain == KnowledgeDomain.learning)
          .toList();

      final edges = engine.buildCareerGraph(career, skills, learning);
      expect(edges.isNotEmpty, true);
    });
  });

  group('buildKnowledgeGraph', () {
    test('builds all domain-specific edges', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final edges = engine.buildKnowledgeGraph(snapshot);

      expect(edges.isNotEmpty, true);
      // Should include skill, goal, learning, and career edges
      final types = edges.map((e) => e.type).toSet();
      expect(types.length, greaterThanOrEqualTo(2));
    });
  });

  group('search', () {
    test('finds nodes by label', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final results = engine.search(snapshot, 'Flutter');

      expect(results, isNotEmpty);
    });

    test('filters by domain', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final results = engine.search(snapshot, 'Flutter',
          domainFilter: KnowledgeDomain.goals);

      expect(results, isEmpty);
    });

    test('returns empty for non-matching query', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final results = engine.search(snapshot, 'nonexistent123');
      expect(results, isEmpty);
    });

    test('returns empty for empty query', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      expect(engine.search(snapshot, ''), isEmpty);
      expect(engine.search(snapshot, '   '), isEmpty);
    });
  });

  group('generateRecommendations', () {
    test('generates skill gap recommendations', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final recs = engine.generateRecommendations(snapshot);

      expect(recs.isNotEmpty, true);
      expect(recs.any((r) =>
          r.type == KnowledgeRecommendationType.skillGap),
          true);
    });

    test('generates next action recommendations', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final recs = engine.generateRecommendations(snapshot);

      expect(recs.any((r) =>
          r.type == KnowledgeRecommendationType.nextAction),
          true);
    });

    test('sorts by relevance descending', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final recs = engine.generateRecommendations(snapshot);

      for (int i = 0; i < recs.length - 1; i++) {
        expect(recs[i].relevance >= recs[i + 1].relevance, true);
      }
    });
  });

  group('analyze', () {
    test('computes basic analytics', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final analytics = engine.analyze(snapshot);

      expect(analytics['nodeCount'], sampleNodes.length);
      expect(analytics['domainCoverage'], greaterThanOrEqualTo(4));
      expect(analytics['skillCount'], 3);
      expect(analytics['goalCount'], 2);
      expect(analytics['learningCount'], 2);
    });

    test('computes proficiency distribution', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final analytics = engine.analyze(snapshot);

      final ranges = analytics['proficiencyRanges'] as Map;
      expect(ranges['high'], greaterThanOrEqualTo(0));
      expect(ranges['medium'], greaterThanOrEqualTo(0));
      expect(ranges['low'], greaterThanOrEqualTo(0));
    });

    test('identifies top skills and goals', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final analytics = engine.analyze(snapshot);

      final topSkills = analytics['topSkills'] as List;
      expect(topSkills.isNotEmpty, true);
      expect(topSkills.first, 'Flutter'); // highest proficiency

      final topGoals = analytics['topGoals'] as List;
      expect(topGoals.isNotEmpty, true);
    });
  });

  group('generateInsights', () {
    test('generates coverage insights', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final insights = engine.generateInsights(snapshot);

      expect(insights.isNotEmpty, true);
      expect(insights.any((i) =>
          i.type == KnowledgeInsightType.coverage),
          true);
    });

    test('generates strength insights', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final insights = engine.generateInsights(snapshot);

      expect(insights.any((i) =>
          i.type == KnowledgeInsightType.strength),
          true);
    });

    test('sorts insights by relevance descending', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final insights = engine.generateInsights(snapshot);

      for (int i = 0; i < insights.length - 1; i++) {
        expect(insights[i].relevance >= insights[i + 1].relevance, true);
      }
    });
  });

  group('findSimilar', () {
    test('finds similar nodes by domain and keywords', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final similar = engine.findSimilar(snapshot, 'sk-1');

      expect(similar, isNotEmpty);
      // Should include Dart (same domain, keyword overlap with Flutter)
      expect(similar.any((n) => n.id == 'sk-3'), true);
    });

    test('returns empty for non-existent node', () {
      final snapshot = KnowledgeSnapshot(nodes: sampleNodes);
      final similar = engine.findSimilar(snapshot, 'nonexistent');
      expect(similar, isEmpty);
    });
  });

  // ── Immutability & Serialization ─────────────────────────────────

  group('KnowledgeNode serialization', () {
    test('round-trips through toMap/fromMap', () {
      final original = sampleNodes.first;
      final map = original.toMap();
      final restored = KnowledgeNode.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.label, original.label);
      expect(restored.description, original.description);
      expect(restored.domain, original.domain);
      expect(restored.proficiency, original.proficiency);
      expect(restored.importance, original.importance);
    });

    test('copyWith creates modified copy without mutating original', () {
      final original = sampleNodes.first;
      final modified = original.copyWith(proficiency: 1.0);

      expect(modified.proficiency, 1.0);
      expect(original.proficiency, 0.8);
      expect(modified.id, original.id);
    });

    test('equality based on ID', () {
      final a = sampleNodes.first;
      final b = a.copyWith(proficiency: 1.0);
      final c = KnowledgeNode(id: 'different', domain: KnowledgeDomain.custom, label: 'X');

      expect(a == b, true);
      expect(a == c, false);
    });
  });

  group('KnowledgeSnapshot serialization', () {
    test('round-trips through toMap/fromMap', () {
      final original = KnowledgeSnapshot(
        nodes: sampleNodes,
        edges: [
          KnowledgeEdge(
            id: 'e1', sourceNodeId: 'sk-1',
            targetNodeId: 'sk-3', type: KnowledgeEdgeType.relatedTo,
          ),
        ],
        lastSnapshotAt: DateTime.now(),
      );
      final map = original.toMap();
      final restored = KnowledgeSnapshot.fromMap(map);

      expect(restored.nodeCount, original.nodeCount);
      expect(restored.edgeCount, original.edgeCount);
    });
  });

  group('KnowledgeRecommendation priority', () {
    test('high priority for high relevance + urgency', () {
      final rec = KnowledgeRecommendation(
        id: 'r1', type: KnowledgeRecommendationType.skillGap,
        title: 'Test', relevance: 0.9, urgency: 0.9,
      );
      expect(rec.priority, RecommendationPriority.high);
    });

    test('low priority for low relevance + urgency', () {
      final rec = KnowledgeRecommendation(
        id: 'r2', type: KnowledgeRecommendationType.skillGap,
        title: 'Test', relevance: 0.1, urgency: 0.1,
      );
      expect(rec.priority, RecommendationPriority.low);
    });

    test('medium priority for mixed values', () {
      final rec = KnowledgeRecommendation(
        id: 'r3', type: KnowledgeRecommendationType.skillGap,
        title: 'Test', relevance: 0.5, urgency: 0.5,
      );
      expect(rec.priority, RecommendationPriority.medium);
    });
  });
}
