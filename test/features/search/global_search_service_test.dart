import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phoenix_platform/services/global_search_service.dart';

void main() {
  group('GlobalSearchService', () {
    late GlobalSearchService service;

    setUp(() {
      service = GlobalSearchService();
      SharedPreferences.setMockInitialValues({});
    });

    test('returns empty list for empty query', () {
      final results = service.search('');
      expect(results, isEmpty);
    });

    test('returns empty list for whitespace query', () {
      final results = service.search('   ');
      expect(results, isEmpty);
    });

    test('returns grouped results that are properly structured', () {
      final results = service.search('Flutter');
      
      // Each group should have required fields
      for (final group in results) {
        expect(group.engine, isNotEmpty);
        expect(group.label, isNotEmpty);
        expect(group.icon, isNotEmpty);
        expect(group.results, isNotEmpty);
        expect(group.count, greaterThan(0));
        
        // Each result should have required fields
        for (final result in group.results) {
          expect(result.id, isNotEmpty);
          expect(result.title, isNotEmpty);
          expect(result.sourceEngine, isNotEmpty);
          expect(result.route, isNotEmpty);
          expect(result.relevance, greaterThanOrEqualTo(0));
        }
      }
    });

    test('search results are sorted by relevance descending', () {
      final results = service.search('Dart');
      
      for (final group in results) {
        for (int i = 0; i < group.results.length - 1; i++) {
          expect(
            group.results[i].relevance,
            greaterThanOrEqualTo(group.results[i + 1].relevance),
          );
        }
      }
    });

    test('search is case-insensitive', () {
      final lowerResults = service.search('flutter');
      final upperResults = service.search('FLUTTER');
      
      expect(lowerResults.length, equals(upperResults.length));
    });

    test('SearchResult toMap returns correct structure', () {
      final result = SearchResult(
        id: 'test-1',
        title: 'Test Title',
        description: 'Test Description',
        sourceEngine: 'test_engine',
        route: '/test',
        relevance: 0.8,
        subtitle: 'Test',
        icon: 'rocket_launch',
      );

      final map = result.toMap();
      expect(map['id'], equals('test-1'));
      expect(map['title'], equals('Test Title'));
      expect(map['description'], equals('Test Description'));
      expect(map['sourceEngine'], equals('test_engine'));
      expect(map['route'], equals('/test'));
      expect(map['relevance'], equals(0.8));
      expect(map['subtitle'], equals('Test'));
      expect(map['icon'], equals('rocket_launch'));
    });

    test('SearchResultGroup count returns correct length', () {
      final group = SearchResultGroup(
        engine: 'test',
        label: 'Test',
        icon: 'test',
        results: [
          SearchResult(
            id: '1', title: 'A', description: null,
            sourceEngine: 'test', route: '/test', relevance: 1.0,
          ),
          SearchResult(
            id: '2', title: 'B', description: null,
            sourceEngine: 'test', route: '/test', relevance: 0.5,
          ),
        ],
      );
      expect(group.count, equals(2));
    });
  });
}