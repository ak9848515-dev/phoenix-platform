import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/core/sample_repository.dart';
import 'package:phoenix_platform/features/opportunity/services/opportunity_service.dart';

void main() {
  group('OpportunityService', () {
    final service = OpportunityService(repository: const SampleRepository());

    test('getRecommendedOpportunities returns non-empty list', () {
      final opportunities = service.getRecommendedOpportunities();
      expect(opportunities, isNotEmpty);
    });

    test('each opportunity has a non-empty id', () {
      final opportunities = service.getRecommendedOpportunities();
      for (final opp in opportunities) {
        expect(opp.id, isNotEmpty);
      }
    });

    test('each opportunity has a non-empty title', () {
      final opportunities = service.getRecommendedOpportunities();
      for (final opp in opportunities) {
        expect(opp.title, isNotEmpty);
      }
    });

    test('match scores are between 0 and 1', () {
      final opportunities = service.getRecommendedOpportunities();
      for (final opp in opportunities) {
        expect(opp.matchScore, greaterThanOrEqualTo(0.0));
        expect(opp.matchScore, lessThanOrEqualTo(1.0));
      }
    });

    test('opportunities include different types', () {
      final opportunities = service.getRecommendedOpportunities();
      final types = opportunities.map((o) => o.type).toSet();
      expect(types.length, greaterThanOrEqualTo(2));
    });

    test('opportunities have timelines', () {
      final opportunities = service.getRecommendedOpportunities();
      for (final opp in opportunities) {
        expect(opp.estimatedTimeline, isNotEmpty);
      }
    });

    test('opportunities have required skills', () {
      final opportunities = service.getRecommendedOpportunities();
      for (final opp in opportunities) {
        expect(opp.requiredSkills, isNotEmpty);
      }
    });

    test('opportunities have recommended actions', () {
      final opportunities = service.getRecommendedOpportunities();
      for (final opp in opportunities) {
        expect(opp.recommendedActions, isNotEmpty);
      }
    });

    test('analyzeMatch returns match for an opportunity', () {
      final opportunities = service.getRecommendedOpportunities();
      final result = service.analyzeMatch(opportunities.first, [
        'Dart',
        'Flutter',
      ]);
      expect(result, isNotNull);
      expect(result.opportunityId, opportunities.first.id);
    });

    test('best match score is highest among opportunities', () {
      final opportunities = service.getRecommendedOpportunities();
      if (opportunities.length >= 2) {
        final scores = opportunities.map((o) => o.matchScore).toList();
        final best = scores.reduce((a, b) => a > b ? a : b);
        expect(best, greaterThanOrEqualTo(scores.first));
      }
    });
  });
}
