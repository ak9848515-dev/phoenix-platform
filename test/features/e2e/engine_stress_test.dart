import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/memory_engine/engine/memory_engine.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_category.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_entry.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_importance.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_index.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_relationship.dart';
import 'package:phoenix_platform/features/memory_engine/models/memory_snapshot.dart';
import 'package:phoenix_platform/features/memory_engine/repository/memory_repository_interface.dart';
import 'package:phoenix_platform/features/identity/engine/identity_engine.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_state.dart';
import 'package:phoenix_platform/features/growth_index/engine/growth_index_engine.dart';
import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/engine/mission_intelligence_engine.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';

void main() {
  group('Memory Search Performance', () {
    test('search 100 memories returns quick results', () async {
      final engine = await _createEngineWithMemories(100);
      final stopwatch = Stopwatch()..start();
      final results = engine.searchKeywords('Flutter');
      stopwatch.stop();
      expect(results.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('search 500 memories returns results within limits', () async {
      final engine = await _createEngineWithMemories(500);
      final stopwatch = Stopwatch()..start();
      final results = engine.searchKeywords('Dart');
      stopwatch.stop();
      expect(results.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });

    test('search 1000 memories handles large dataset', () async {
      final engine = await _createEngineWithMemories(1000);
      final stopwatch = Stopwatch()..start();
      final results = engine.searchKeywords('learning');
      stopwatch.stop();
      expect(results.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('no match search returns empty quickly', () async {
      final engine = await _createEngineWithMemories(100);
      final stopwatch = Stopwatch()..start();
      final results = engine.searchKeywords('xyznonexistent');
      stopwatch.stop();
      expect(results, isEmpty);
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('important memories sort correctly at scale', () async {
      final engine = await _createEngineWithMemories(100);
      final stopwatch = Stopwatch()..start();
      final important = engine.importantMemories();
      stopwatch.stop();
      expect(important.length, 10);
      if (important.length >= 2) {
        expect(important[0].importance.weight,
            greaterThanOrEqualTo(important[1].importance.weight));
      }
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}

Future<MemoryEngine> _createEngineWithMemories(int count) async {
  final entries = _generateMemories(count);
  final repo = _MemoryRepo(entries: entries);
  final engine = MemoryEngine(
    repository: repo,
    identityEngine: _StubId(),
    growthEngine: _StubGr(),
    missionEngine: _StubMs(),
  );
  await engine.init();
  return engine;
}

List<MemoryEntry> _generateMemories(int count) {
  final categories = MemoryCategory.values;
  final importances = MemoryImportance.values;
  return List.generate(count, (i) {
    return MemoryEntry(
      id: 'mem-$i',
      title: 'Memory $i - ${i.isEven ? "Flutter Widgets" : "Dart Language"}',
      content: 'This is memory entry number $i. '
          'It contains ${i % 3 == 0 ? "important" : "general"} learning content '
          'about ${i % 2 == 0 ? "Flutter" : "Dart"} development.',
      category: categories[i % categories.length],
      importance: importances[i % importances.length],
      tags: ['tag-${i % 10}', i % 5 == 0 ? 'important' : 'general'],
      source: 'test',
    );
  });
}

class _MemoryRepo implements MemoryRepositoryInterface {
  _MemoryRepo({required this.entries});
  final List<MemoryEntry> entries;
  @override Future<List<MemoryEntry>> loadAllEntries() async => entries;
  @override Future<void> saveAllEntries(List<MemoryEntry> e) async {}
  @override Future<List<MemoryRelationship>> loadAllRelationships() async => [];
  @override Future<void> saveAllRelationships(List<MemoryRelationship> r) async {}
  @override Future<MemorySnapshot?> loadCachedSnapshot() async => null;
  @override Future<void> cacheSnapshot(MemorySnapshot s) async {}
  @override Future<MemoryIndex> loadIndex() async => MemoryIndex();
  @override Future<void> saveIndex(MemoryIndex i) async {}
  @override Future<void> clear() async {}
}

class _StubId extends ChangeNotifier implements IdentityEngine {
  @override IdentitySnapshot? get snapshot => null;
  @override IdentityState get identityState => IdentityState.uninitialized;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StubGr extends ChangeNotifier implements GrowthIndexEngine {
  @override GrowthSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _StubMs extends ChangeNotifier implements MissionIntelligenceEngine {
  @override MissionSnapshot? get snapshot => null;
  @override bool get isInitialized => false;
  @override dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
