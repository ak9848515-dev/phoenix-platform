import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/memory_graph/engine/memory_graph_engine.dart';
import 'package:phoenix_platform/features/memory_graph/models/entity_type.dart';
import 'package:phoenix_platform/features/memory_graph/models/memory_entity.dart';
import 'package:phoenix_platform/features/memory_graph/models/memory_graph.dart';
import 'package:phoenix_platform/features/memory_graph/models/memory_insight.dart';
import 'package:phoenix_platform/features/memory_graph/models/memory_relation.dart';
import 'package:phoenix_platform/features/memory_graph/models/relation_type.dart';

void main() {
  const engine = MemoryGraphEngine();

  final sampleEntities = [
    MemoryEntity(
      id: 'ent-1', type: EntityType.mission, title: 'Mission Alpha',
      sourceEngine: 'mission_engine', sourceId: 'm1', importance: 0.8,
    ),
    MemoryEntity(
      id: 'ent-2', type: EntityType.habit, title: 'Morning Run',
      sourceEngine: 'habit', sourceId: 'h1',
    ),
    MemoryEntity(
      id: 'ent-3', type: EntityType.decision, title: 'Career Decision',
      sourceEngine: 'decision', sourceId: 'd1',
    ),
    MemoryEntity(
      id: 'ent-4', type: EntityType.skill, title: 'Flutter',
      sourceEngine: 'academy', sourceId: 's1',
    ),
    MemoryEntity(
      id: 'ent-5', type: EntityType.lesson, title: 'State Management',
      sourceEngine: 'academy', sourceId: 'l1',
    ),
  ];

  group('registerEntities', () {
    test('adds new entities to empty graph', () {
      final result = engine.registerEntities(
          const MemoryGraph(), sampleEntities);
      expect(result.entityCount, sampleEntities.length);
    });

    test('deduplicates by ID', () {
      final duplicates = [
        ...sampleEntities,
        sampleEntities.first,
      ];
      final result = engine.registerEntities(
          const MemoryGraph(), duplicates);
      expect(result.entityCount, sampleEntities.length);
    });

    test('preserves existing entities', () {
      final graph = MemoryGraph(entities: [sampleEntities.first]);
      final result = engine.registerEntities(
          graph, [sampleEntities[1]]);
      expect(result.entityCount, 2);
    });
  });

  group('removeEntities', () {
    test('removes specified entities', () {
      final graph = MemoryGraph(entities: sampleEntities);
      final result = engine.removeEntities(graph, ['ent-1']);
      expect(result.entityCount, sampleEntities.length - 1);
      expect(result.entityById('ent-1'), isNull);
    });

    test('removes relations connected to removed entities', () {
      final rel = MemoryRelation(
        id: 'rel-1', sourceEntityId: 'ent-1',
        targetEntityId: 'ent-2', type: RelationType.relatedTo,
      );
      final graph = MemoryGraph(
          entities: sampleEntities, relations: [rel]);
      final result = engine.removeEntities(graph, ['ent-1']);
      expect(result.relations, isEmpty);
    });
  });

  group('findEntityBySource', () {
    test('finds entity by source engine and ID', () {
      final graph = MemoryGraph(entities: sampleEntities);
      final result = engine.findEntityBySource(
          graph, 'mission_engine', 'm1');
      expect(result, isNotNull);
      expect(result!.id, 'ent-1');
    });

    test('returns null for non-existent source', () {
      final graph = MemoryGraph(entities: sampleEntities);
      expect(
          engine.findEntityBySource(graph, 'unknown', 'x'), isNull);
    });
  });

  group('createRelation', () {
    test('adds relation to graph', () {
      final graph = MemoryGraph(entities: sampleEntities);
      final rel = MemoryRelation(
        id: 'rel-1', sourceEntityId: 'ent-1',
        targetEntityId: 'ent-2', type: RelationType.relatedTo,
      );
      final result = engine.createRelation(graph, rel);
      expect(result.relationCount, 1);
    });

    test('skips duplicate relation', () {
      final rel = MemoryRelation(
        id: 'rel-1', sourceEntityId: 'ent-1',
        targetEntityId: 'ent-2', type: RelationType.relatedTo,
      );
      final graph = MemoryGraph(
          entities: sampleEntities, relations: [rel]);
      final result = engine.createRelation(graph, rel);
      expect(result.relationCount, 1);
    });
  });

  group('createRelations', () {
    test('adds multiple relations', () {
      final graph = MemoryGraph(entities: sampleEntities);
      final rels = [
        MemoryRelation(id: 'rel-1', sourceEntityId: 'ent-1',
            targetEntityId: 'ent-2', type: RelationType.relatedTo),
        MemoryRelation(id: 'rel-2', sourceEntityId: 'ent-2',
            targetEntityId: 'ent-3', type: RelationType.relatedTo),
      ];
      final result = engine.createRelations(graph, rels);
      expect(result.relationCount, 2);
    });
  });

  group('removeRelation', () {
    test('removes specified relation', () {
      final rel = MemoryRelation(
        id: 'rel-1', sourceEntityId: 'ent-1',
        targetEntityId: 'ent-2', type: RelationType.relatedTo,
      );
      final graph = MemoryGraph(
          entities: sampleEntities, relations: [rel]);
      final result = engine.removeRelation(graph, 'rel-1');
      expect(result.relationCount, 0);
    });
  });

  group('discoverAutoRelations', () {
    test('discovers relations from shared source ID', () {
      final entities = [
        MemoryEntity(id: 'e1', type: EntityType.mission,
            title: 'M1', sourceEngine: 'ms', sourceId: 'shared'),
        MemoryEntity(id: 'e2', type: EntityType.skill,
            title: 'S1', sourceEngine: 'academy', sourceId: 'shared'),
      ];
      final graph = MemoryGraph(entities: entities);
      final rels = engine.discoverAutoRelations(graph);
      expect(rels.length, 1);
      expect(rels.first.type, RelationType.associated);
    });

    test('returns empty for entities without source IDs', () {
      final entities = [
        MemoryEntity(id: 'e1', type: EntityType.mission,
            title: 'M1', sourceEngine: 'ms'),
      ];
      final graph = MemoryGraph(entities: entities);
      expect(engine.discoverAutoRelations(graph), isEmpty);
    });
  });

  group('bfsTraverse', () {
    test('finds directly connected entities', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
        ],
      );
      final result = engine.bfsTraverse(graph, 'ent-1', maxDepth: 1);
      expect(result.length, 1);
      expect(result.first.id, 'ent-2');
    });

    test('returns empty for non-existent entity', () {
      final result = engine.bfsTraverse(
          const MemoryGraph(), 'unknown');
      expect(result, isEmpty);
    });

    test('respects max depth', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
          MemoryRelation(id: 'r2', sourceEntityId: 'ent-2',
              targetEntityId: 'ent-3', type: RelationType.relatedTo),
        ],
      );
      final result = engine.bfsTraverse(graph, 'ent-1', maxDepth: 1);
      expect(result.length, 1);
      expect(result.first.id, 'ent-2');
    });

    test('finds indirect connections at depth 2', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
          MemoryRelation(id: 'r2', sourceEntityId: 'ent-2',
              targetEntityId: 'ent-3', type: RelationType.relatedTo),
        ],
      );
      final result = engine.bfsTraverse(graph, 'ent-1', maxDepth: 2);
      expect(result.length, 2);
    });
  });

  group('findShortestPath', () {
    test('finds direct path', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
        ],
      );
      final path = engine.findShortestPath(graph, 'ent-1', 'ent-2');
      expect(path, isNotNull);
      expect(path!.length, 2);
    });

    test('returns null for disconnected entities', () {
      final path = engine.findShortestPath(
          MemoryGraph(entities: sampleEntities), 'ent-1', 'ent-5');
      expect(path, isNull);
    });

    test('returns empty for same entity', () {
      final path = engine.findShortestPath(
          MemoryGraph(entities: sampleEntities), 'ent-1', 'ent-1');
      expect(path, isNotNull);
      expect(path, isEmpty);
    });
  });

  group('buildContext', () {
    test('builds context around focal entity', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
        ],
      );
      final ctx = engine.buildContext(graph, 'ent-1');
      expect(ctx.focalEntity.id, 'ent-1');
      expect(ctx.relatedEntities.length, 1);
    });

    test('returns minimal context for unknown entity', () {
      final ctx = engine.buildContext(
          MemoryGraph(entities: sampleEntities), 'unknown');
      expect(ctx.focalEntity.id, 'unknown');
    });
  });

  group('findSimilar', () {
    test('finds similar entities by type', () {
      final entities = [
        MemoryEntity(id: 'e1', type: EntityType.mission,
            title: 'Alpha', sourceEngine: 'ms'),
        MemoryEntity(id: 'e2', type: EntityType.mission,
            title: 'Beta', sourceEngine: 'ms'),
        MemoryEntity(id: 'e3', type: EntityType.habit,
            title: 'Gamma', sourceEngine: 'habit'),
      ];
      final graph = MemoryGraph(entities: entities);
      final similar = engine.findSimilar(graph, 'e1');
      expect(similar.isNotEmpty, true);
      // Same type entity should rank highest
      expect(similar.first.id, 'e2');
    });

    test('returns empty for non-existent entity', () {
      expect(engine.findSimilar(
          MemoryGraph(entities: sampleEntities), 'unknown'),
          isEmpty);
    });
  });

  group('searchEntities', () {
    test('finds entities by title', () {
      final result = engine.searchEntities(
          MemoryGraph(entities: sampleEntities), 'Mission');
      expect(result.isNotEmpty, true);
      expect(result.every((e) => e.title.toLowerCase().contains('mission')),
          true);
    });

    test('returns empty for non-matching query', () {
      final result = engine.searchEntities(
          MemoryGraph(entities: sampleEntities), 'nonexistent');
      expect(result, isEmpty);
    });

    test('filters by entity type', () {
      final result = engine.searchEntities(
          MemoryGraph(entities: sampleEntities),
          'Mission',
          typeFilter: EntityType.habit);
      expect(result, isEmpty);
    });
  });

  group('detectClusters', () {
    test('detects clusters from connected entities', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
          MemoryRelation(id: 'r2', sourceEntityId: 'ent-2',
              targetEntityId: 'ent-3', type: RelationType.relatedTo),
        ],
      );
      final clusters = engine.detectClusters(graph);
      expect(clusters.isNotEmpty, true);
    });

    test('returns empty for no relations', () {
      final clusters = engine.detectClusters(
          MemoryGraph(entities: sampleEntities));
      expect(clusters, isEmpty);
    });
  });

  group('calculateDensity', () {
    test('returns 0 for single entity', () {
      final graph = MemoryGraph(entities: [sampleEntities.first]);
      expect(engine.calculateDensity(graph), 0.0);
    });

    test('returns correct density', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
        ],
      );
      final density = engine.calculateDensity(graph);
      expect(density, greaterThan(0));
      expect(density, lessThanOrEqualTo(1.0));
    });
  });

  group('findHubs', () {
    test('finds most connected entities', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
          MemoryRelation(id: 'r2', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-3', type: RelationType.relatedTo),
          MemoryRelation(id: 'r3', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-4', type: RelationType.relatedTo),
        ],
      );
      final hubs = engine.findHubs(graph);
      expect(hubs.isNotEmpty, true);
      expect(hubs.first.id, 'ent-1');
    });
  });

  group('generateInsights', () {
    test('generates hub insight for connected graph', () {
      final graph = MemoryGraph(
        entities: sampleEntities,
        relations: [
          MemoryRelation(id: 'r1', sourceEntityId: 'ent-1',
              targetEntityId: 'ent-2', type: RelationType.relatedTo),
        ],
      );
      final insights = engine.generateInsights(graph);
      expect(insights.isNotEmpty, true);
      expect(insights.any((i) => i.type == MemoryInsightType.pattern), true);
    });

    test('returns insights for empty graph', () {
      final insights = engine.generateInsights(const MemoryGraph());
      expect(insights, isA<List>());
    });
  });

  group('entityId', () {
    test('generates deterministic ID', () {
      expect(engine.entityId('mission', 'm1'), 'ent-mission-m1');
      expect(engine.entityId('habit', 'h1'), 'ent-habit-h1');
    });
  });
}
