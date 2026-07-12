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
      expect(progress.completedCount, 2);
      expect(progress.pendingCount, 4);
      expect(progress.completionPercentage, closeTo(2 / 6, 0.001));
      expect(progress.streak, 2);
    });
  });
}
