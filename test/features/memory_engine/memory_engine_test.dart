import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/memory_engine/engine/memory_engine.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_category.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_entry.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_graph.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_importance.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_index.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_relationship.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_search_result.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_snapshot.dart';
import 'package:phoenix_platform/features/memory_engine/repository/memory_repository_interface.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_state.dart';
import 'package:phoenix_platform/features/mission_intelligence/engine/mission_intelligence_engine.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';

// ── Mock Repository ─────────────────────────────────────────────────────────

class _MockRepo implements MemoryRepositoryInterface {
  List<MemoryEntry> _entries = [];
  List<MemoryRelationship> _relationships = [];
  MemorySnapshot? _cachedSnapshot;
  MemoryIndex _index = const MemoryIndex();

  bool shouldReturnNull = false;

  @override
  Future<List<MemoryEntry>> loadAllEntries() async => _entries;

  @override
  Future<void> saveAllEntries(List<MemoryEntry> entries) async {
    _entries = entries;
  }

  @override
  Future<List<MemoryRelationship>> loadAllRelationships() async =>
      _relationships;

  @override
  Future<void> saveAllRelationships(
      List<MemoryRelationship> relationships) async {
    _relationships = relationships;
  }

  @override
  Future<MemorySnapshot?> loadCachedSnapshot() async {
    if (shouldReturnNull) return null;
    return _cachedSnapshot;
  }

  @override
  Future<void> cacheSnapshot(MemorySnapshot snapshot) async {
    _cachedSnapshot = snapshot;
  }

  @override
  Future<MemoryIndex> loadIndex() async => _index;

  @override
  Future<void> saveIndex(MemoryIndex index) async {
    _index = index;
  }

  @override
  Future<void> clear() async {
    _entries = [];
    _relationships = [];
    _cachedSnapshot = null;
    _index = const MemoryIndex();
  }
}

// ── Mock Engines ────────────────────────────────────────────────────────────

class _MockIdentityEngine extends ChangeNotifier
    implements IdentityEngine {
  @override IdentitySnapshot? get snapshot => null;
  @override IdentityState get identityState => IdentityState.uninitialized;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockGrowthEngine extends ChangeNotifier
    implements GrowthIndexEngine {
  @override GrowthSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _MockMissionEngine extends ChangeNotifier
    implements MissionIntelligenceEngine {
  @override MissionSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ── Test Helpers ────────────────────────────────────────────────────────────

MemoryEntry _entry({
  String id = '1',
  String title = 'Test Memory',
  String content = 'Test content',
  MemoryCategory category = MemoryCategory.learning,
  MemoryImportance importance = MemoryImportance.medium,
  List<String> tags = const [],
}) =>
    MemoryEntry(
      id: id,
      title: title,
      content: content,
      category: category,
      importance: importance,
      tags: tags,
      source: 'test',
      created: DateTime(2026, 7, 15),
    );

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late _MockRepo repo;
  late MemoryEngine engine;

  group('MemoryEngine', () {
    group('initialization', () {
      test('init with empty repo builds empty snapshot', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        expect(engine.isInitialized, isTrue);
        expect(engine.snapshot, isNotNull);
        expect(engine.snapshot!.hasMemories, isFalse);
      });

      test('clear resets all data', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry());
        await engine.clear();
        expect(engine.isInitialized, isFalse);
        expect(engine.entries, isEmpty);
      });
    });

    group('CRUD operations', () {
      test('addEntry stores memory', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry());
        expect(engine.entries.length, 1);
        expect(engine.snapshot!.hasMemories, isTrue);
      });

      test('updateEntry modifies memory', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry());
        await engine.updateEntry('1', _entry(title: 'Updated'));
        expect(engine.getEntry('1')!.title, 'Updated');
      });

      test('removeEntry deletes memory', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry());
        await engine.removeEntry('1');
        expect(engine.entries, isEmpty);
      });

      test('archiveEntry hides from normal view', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry());
        await engine.archiveEntry('1');
        expect(engine.getEntry('1')!.archived, isTrue);
      });

      test('toggleFavorite flips favorite status', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry());
        expect(engine.getEntry('1')!.favorite, isFalse);
        await engine.toggleFavorite('1');
        expect(engine.getEntry('1')!.favorite, isTrue);
      });
    });

    group('relationships', () {
      test('addRelationship creates graph edge', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry(id: '1', title: 'SAP ABAP'));
        await engine.addEntry(_entry(id: '2', title: 'Project Alpha'));
        await engine.addRelationship(MemoryRelationship(
          sourceId: '1',
          targetId: '2',
          type: 'related',
        ));
        expect(engine.relationships.length, 1);
        expect(engine.graph.relationshipCount, 1);
      });

      test('relatedMemories returns connected entries', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry(id: '1', title: 'Memory A'));
        await engine.addEntry(_entry(id: '2', title: 'Memory B'));
        await engine.addRelationship(MemoryRelationship(
          sourceId: '1',
          targetId: '2',
        ));
        final related = engine.relatedMemories('1');
        expect(related.length, 1);
        expect(related.first.title, 'Memory B');
      });
    });

    group('search', () {
      test('searchKeywords finds matches in title', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry(title: 'Flutter Widgets', content: 'All about widgets'));
        await engine.addEntry(_entry(id: '2', title: 'Dart Basics', content: 'Dart language'));
        final results = engine.searchKeywords('flutter');
        expect(results.length, 1);
        expect(results.first.entry.title, 'Flutter Widgets');
      });

      test('searchKeywords finds matches in content', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry(title: 'Widgets', content: 'All about Flutter widgets'));
        final results = engine.searchKeywords('Flutter');
        expect(results.length, 1);
        expect(results.first.relevance, greaterThan(0.0));
      });

      test('searchCategory returns memories in category', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry(category: MemoryCategory.learning));
        await engine.addEntry(_entry(id: '2', category: MemoryCategory.career));
        final learning = engine.searchCategory(MemoryCategory.learning);
        final career = engine.searchCategory(MemoryCategory.career);
        expect(learning.length, 1);
        expect(career.length, 1);
      });

      test('archived memories excluded from search', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry(title: 'Secret'));
        await engine.archiveEntry('1');
        final results = engine.searchKeywords('secret');
        expect(results, isEmpty);
      });
    });

    group('sorting and filtering', () {
      test('importantMemories returns sorted by importance', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry(id: '1', importance: MemoryImportance.low));
        await engine.addEntry(_entry(id: '2', importance: MemoryImportance.critical));
        await engine.addEntry(_entry(id: '3', importance: MemoryImportance.high));
        final important = engine.importantMemories();
        expect(important.length, 3);
        expect(important.first.importance, MemoryImportance.critical);
        expect(important.last.importance, MemoryImportance.low);
      });

      test('favoriteMemories returns only favorites', () async {
        repo = _MockRepo()..shouldReturnNull = true;
        engine = MemoryEngine(
          repository: repo,
          identityEngine: _MockIdentityEngine(),
          growthEngine: _MockGrowthEngine(),
          missionEngine: _MockMissionEngine(),
        );
        await engine.init();
        await engine.addEntry(_entry(id: '1'));
        await engine.addEntry(_entry(id: '2', title: 'Favorite'));
        await engine.toggleFavorite('2');
        final favorites = engine.favoriteMemories();
        expect(favorites.length, 1);
        expect(favorites.first.title, 'Favorite');
      });
    });

    group('models', () {
      test('MemoryEntry copyWith preserves fields', () {
        final entry = _entry(title: 'Original');
        final updated = entry.copyWith(title: 'Updated');
        expect(updated.title, 'Updated');
        expect(updated.id, '1');
      });

      test('MemoryGraph relatedEntries returns connected', () {
        final graph = MemoryGraph(
          entries: {
            '1': _entry(id: '1'),
            '2': _entry(id: '2'),
          },
          relationships: [
            const MemoryRelationship(sourceId: '1', targetId: '2'),
          ],
        );
        final related = graph.relatedEntries('1');
        expect(related.length, 1);
        expect(related.first.id, '2');
      });

      test('MemorySnapshot has correct computed properties', () {
        final snap = MemorySnapshot(
          totalMemories: 5,
          totalRelationships: 3,
          importantMemories: [_entry()],
        );
        expect(snap.hasMemories, isTrue);
        expect(snap.hasImportantMemories, isTrue);
        expect(snap.topMemory, isNotNull);
      });

      test('MemorySearchResult has relevance', () {
        final result = MemorySearchResult(
          entry: _entry(),
          relevance: 0.8,
          matchContext: 'test',
        );
        expect(result.relevance, 0.8);
        expect(result.entry.title, 'Test Memory');
      });

      test('MemoryIndex stores keyword mappings', () {
        final index = MemoryIndex(
          keywordIndex: {'flutter': ['1', '2']},
          tagIndex: {'widget': ['1']},
          categoryIndex: {'learning': ['1']},
        );
        expect(index.searchKeyword('flutter'), contains('1'));
        expect(index.searchTag('widget'), contains('1'));
        expect(index.searchCategory('learning'), contains('1'));
      });
    });
  });
}
