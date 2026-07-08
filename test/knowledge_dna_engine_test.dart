import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/knowledge_dna/knowledge_dna_service.dart';
import 'package:phoenix_platform/services/sample_data_service.dart';

void main() {
  group('KnowledgeDNAService', () {
    test('builds knowledge intelligence output from mission and progress data', () {
      final service = KnowledgeDNAService(seedSource: const SampleDataService());
      final analysis = service.buildAnalysis();

      expect(analysis.recommendedMissions, isNotEmpty);
      expect(analysis.recommendedAcademies, isNotEmpty);
      expect(analysis.skillStrengths, isNotEmpty);
      expect(analysis.skillWeaknesses, isNotEmpty);
      expect(analysis.knowledgeScore, greaterThanOrEqualTo(0.0));
      expect(analysis.confidenceScore, greaterThanOrEqualTo(0.0));
    });
  });
}
