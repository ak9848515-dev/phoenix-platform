import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/progress_engine/progress_service.dart';
import 'package:phoenix_platform/core/sample_repository.dart';

void main() {
  group('ProgressService', () {
    test('builds growth metrics from mission completion data', () {
      final service = ProgressService(repository: const SampleRepository());
      final summary = service.buildSummary();

      expect(summary.totalXp, 210);
      expect(summary.level, 1);
      expect(summary.completionPercentage, closeTo(2 / 6, 0.001));
      expect(summary.streaks.daily, 2);
      expect(summary.streaks.weekly, 0);
      expect(summary.streaks.monthly, 2);
      expect(summary.achievements.length, 5);
    });
  });
}
