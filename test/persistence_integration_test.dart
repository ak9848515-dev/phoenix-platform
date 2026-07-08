import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_platform/features/knowledge_dna/knowledge_dna_service.dart';
import 'package:phoenix_platform/features/mission_engine/mission_service.dart';
import 'package:phoenix_platform/features/persistence/local_mission_repository.dart';
import 'package:phoenix_platform/features/persistence/local_progress_repository.dart';
import 'package:phoenix_platform/features/persistence/local_settings_repository.dart';
import 'package:phoenix_platform/features/progress_engine/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Mission persistence integration', () {
    test('restores completed missions', () async {
      const repository = LocalMissionRepository();
      await repository.markMissionCompleted('weekly-1');

      final service = MissionService(missionRepository: repository);
      final missions = await service.restoreMissions();
      final restoredMission = missions.firstWhere((mission) => mission.id == 'weekly-1');

      expect(restoredMission.completed, isTrue);
    });

    test('restores mission progress after initialization', () async {
      const repository = LocalMissionRepository();
      final service = MissionService(missionRepository: repository);

      await service.completeMission('weekly-1');
      final restoredProgress = await service.restoreMissionProgress();

      expect(restoredProgress.completedCount, 4);
      expect(restoredProgress.pendingCount, 1);
      expect(restoredProgress.completionPercentage, 0.8);
    });
  });

  group('Progress persistence integration', () {
    test('restores xp, level, daily streak, and weekly streak', () async {
      const repository = LocalProgressRepository();
      final service = ProgressService(progressRepository: repository);

      await repository.saveTotalXp(820);
      await repository.saveCurrentLevel(4);
      await repository.saveDailyStreak(6);
      await repository.saveWeeklyStreak(3);

      final summary = await service.restoreSummary();

      expect(summary.totalXp, 820);
      expect(summary.level, 4);
      expect(summary.streaks.daily, 6);
      expect(summary.streaks.weekly, 3);
    });
  });

  group('Knowledge DNA persistence integration', () {
    test('persists and restores knowledge dna metrics', () async {
      const repository = LocalProgressRepository();
      final service = KnowledgeDNAService(progressRepository: repository);
      final analysis = service.buildAnalysis();

      await service.saveAnalysis(analysis);
      final restoredAnalysis = await service.restoreAnalysis();

      expect(restoredAnalysis.confidenceScore, analysis.confidenceScore);
      expect(restoredAnalysis.retentionScore, analysis.retentionScore);
      expect(restoredAnalysis.consistencyScore, analysis.consistencyScore);
      expect(restoredAnalysis.learningVelocity, analysis.learningVelocity);
      expect(restoredAnalysis.skillStrengths, analysis.skillStrengths);
      expect(restoredAnalysis.skillWeaknesses, analysis.skillWeaknesses);
      expect(restoredAnalysis.careerDirection, analysis.careerDirection);
    });
  });

  group('Settings persistence integration', () {
    test('restores user preferences', () async {
      const repository = LocalSettingsRepository();

      await repository.saveBoolPreference('dark_mode', true);
      await repository.saveStringPreference('career_direction', 'Platform leadership');

      final preferences = await repository.loadUserPreferences();

      expect(preferences['dark_mode'], true);
      expect(preferences['career_direction'], 'Platform leadership');
    });
  });
}
