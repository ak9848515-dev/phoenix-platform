import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/knowledge_dna/knowledge_dna_metrics.dart';
import 'package:phoenix_platform/features/persistence/local_mission_repository.dart';
import 'package:phoenix_platform/features/persistence/local_progress_repository.dart';
import 'package:phoenix_platform/features/persistence/local_settings_repository.dart';
import 'package:phoenix_platform/features/persistence/progress_repository.dart';
import 'package:phoenix_platform/features/progress_engine/progress_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('LocalMissionRepository', () {
    test('persists completed mission ids without duplicates', () async {
      const repository = LocalMissionRepository();

      await repository.markMissionCompleted('mission-1');
      await repository.markMissionCompleted('mission-1');
      await repository.markMissionCompleted('mission-2');

      expect(
        await repository.loadCompletedMissionIds(),
        <String>['mission-1', 'mission-2'],
      );
    });
  });

  group('LocalProgressRepository', () {
    test('persists progress values and knowledge dna metrics', () async {
      const repository = LocalProgressRepository();
      const progress = PersistedProgress(
        totalXp: 640,
        currentLevel: 3,
        streaks: Streaks(daily: 5, weekly: 2, monthly: 0),
        knowledgeMetrics: KnowledgeDNAMetrics(
          knowledgeScore: 0.74,
          confidenceScore: 0.82,
          retentionScore: 0.68,
          learningVelocity: 0.91,
          summary: 'Momentum is building.',
        ),
      );

      await repository.saveProgress(progress);

      final persistedProgress = await repository.loadProgress();
      expect(persistedProgress.totalXp, 640);
      expect(persistedProgress.currentLevel, 3);
      expect(persistedProgress.streaks.daily, 5);
      expect(persistedProgress.streaks.weekly, 2);
      expect(persistedProgress.knowledgeMetrics.knowledgeScore, 0.74);
      expect(persistedProgress.knowledgeMetrics.summary, 'Momentum is building.');
    });
  });

  group('LocalSettingsRepository', () {
    test('persists user preferences by type', () async {
      const repository = LocalSettingsRepository();

      await repository.saveBoolPreference('dark_mode', true);
      await repository.saveStringPreference('learning_goal', 'Leadership');
      await repository.saveIntPreference('daily_target_minutes', 25);
      await repository.saveDoublePreference('focus_intensity', 0.8);

      final preferences = await repository.loadUserPreferences();
      expect(preferences['dark_mode'], true);
      expect(preferences['learning_goal'], 'Leadership');
      expect(preferences['daily_target_minutes'], 25);
      expect(preferences['focus_intensity'], 0.8);
    });
  });
}
