import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/progress_engine/progress_service.dart';
import 'package:phoenix_platform/services/sample_data_service.dart';

void main() {
  group('ProgressService', () {
    test('builds growth metrics from mission completion data', () {
      final service = ProgressService(seedSource: const SampleDataService());
      final summary = service.buildSummary();

      expect(summary.totalXp, 460);
      expect(summary.level, 2);
      expect(summary.completionPercentage, 0.6);
      expect(summary.streaks.daily, 2);
      expect(summary.streaks.weekly, 1);
      expect(summary.streaks.monthly, 3);
      expect(summary.achievements.length, 2);
    });
  });
}
