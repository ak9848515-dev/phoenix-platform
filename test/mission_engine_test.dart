import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/mission_engine/mission_service.dart';
import 'package:phoenix_platform/services/sample_data_service.dart';

void main() {
  group('MissionService', () {
    test('builds progress from seeded missions', () {
      final service = MissionService(seedSource: const SampleDataService());
      final progress = service.buildProgress();

      expect(progress.dailyMissions, isNotEmpty);
      expect(progress.weeklyMissions, isNotEmpty);
      expect(progress.completedCount, 3);
      expect(progress.pendingCount, 2);
      expect(progress.completionPercentage, 0.6);
      expect(progress.streak, 2);
    });
  });
}
