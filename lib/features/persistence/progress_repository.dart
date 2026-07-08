import '../knowledge_dna/knowledge_dna_metrics.dart';
import '../progress_engine/progress_engine.dart';

class PersistedProgress {
  const PersistedProgress({
    required this.totalXp,
    required this.currentLevel,
    required this.streaks,
    required this.knowledgeMetrics,
  });

  final int totalXp;
  final int currentLevel;
  final Streaks streaks;
  final KnowledgeDNAMetrics knowledgeMetrics;
}

abstract class ProgressRepository {
  Future<PersistedProgress> loadProgress();

  Future<void> saveProgress(PersistedProgress progress);

  Future<void> saveTotalXp(int totalXp);

  Future<void> saveCurrentLevel(int currentLevel);

  Future<void> saveDailyStreak(int dailyStreak);

  Future<void> saveWeeklyStreak(int weeklyStreak);

  Future<void> saveKnowledgeMetrics(KnowledgeDNAMetrics metrics);

  Future<void> clearProgress();
}
