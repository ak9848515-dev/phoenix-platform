import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/decision/models/decision.dart';
import 'package:phoenix_platform/features/decision/services/decision_service.dart';
import 'package:phoenix_platform/core/sample_repository.dart';

void main() {
  group('DecisionService', () {
    test('returns a non-null decision', () {
      final service = DecisionService(repository: const SampleRepository());

      final decision = service.getDecision();

      expect(decision, isNotNull);
      expect(decision.id, isNotEmpty);
      expect(decision.title, isNotEmpty);
      expect(decision.description, isNotEmpty);
      expect(decision.reason, isNotEmpty);
      expect(decision.estimatedDuration, greaterThan(0));
      expect(decision.sourceModule, isNotEmpty);
      expect(decision.confidence, greaterThan(0.0));
      expect(decision.confidence, lessThanOrEqualTo(1.0));
    });

    test('returns candidates from all source modules', () {
      final service = DecisionService(repository: const SampleRepository());

      final candidates = service.getCandidates();

      expect(candidates.length, greaterThanOrEqualTo(6));
      expect(
        candidates.any((c) => c.id.startsWith('decision-rec')),
        isTrue,
        reason: 'Should include recommendation candidates',
      );
      expect(
        candidates.any((c) => c.sourceModule == 'journey'),
        isTrue,
        reason: 'Should include journey candidate',
      );
      expect(
        candidates.any((c) => c.sourceModule == 'mission'),
        isTrue,
        reason: 'Should include mission candidate',
      );
      expect(
        candidates.any((c) => c.sourceModule == 'knowledge_dna'),
        isTrue,
        reason: 'Should include knowledge_dna candidate',
      );
      expect(
        candidates.any((c) => c.sourceModule == 'progress'),
        isTrue,
        reason: 'Should include progress candidate',
      );
      expect(
        candidates.any((c) => c.sourceModule == 'memory'),
        isTrue,
        reason: 'Should include memory candidate',
      );
    });

    test('candidates are sorted by confidence descending', () {
      final service = DecisionService(repository: const SampleRepository());

      final candidates = service.getCandidates();

      expect(candidates, isNotEmpty);
      for (var i = 0; i < candidates.length - 1; i++) {
        expect(
          candidates[i].confidence >= candidates[i + 1].confidence,
          isTrue,
          reason:
              'Candidate ${candidates[i].id} (confidence: ${candidates[i].confidence}) '
              'should be >= ${candidates[i + 1].id} (confidence: ${candidates[i + 1].confidence})',
        );
      }
    });

    test('the top candidate comes from recommendation module', () {
      final service = DecisionService(repository: const SampleRepository());

      final decision = service.getDecision();

      // The recommendation module has a critical priority item (rec-001)
      // which should score the highest confidence (0.95).
      expect(decision.sourceModule, 'recommendation');
      expect(decision.priority, DecisionPriority.critical);
      expect(decision.confidence, greaterThan(0.9));
    });

    test('every decision has a valid source module', () {
      final service = DecisionService(repository: const SampleRepository());

      final candidates = service.getCandidates();
      final validModules = <String>[
        'recommendation',
        'journey',
        'mission',
        'knowledge_dna',
        'progress',
        'memory',
      ];

      for (final candidate in candidates) {
        expect(
          validModules.contains(candidate.sourceModule),
          isTrue,
          reason: 'Unexpected sourceModule: ${candidate.sourceModule}',
        );
      }
    });

    test('journey candidate references current stage', () {
      final service = DecisionService(repository: const SampleRepository());

      final candidates = service.getCandidates();
      final journeyDecision = candidates.firstWhere(
        (c) => c.sourceModule == 'journey',
      );

      expect(journeyDecision.reason, contains('Stage'));
      expect(journeyDecision.reason, contains('missions remaining'));
      expect(journeyDecision.sourceModule, 'journey');
    });
  });
}
