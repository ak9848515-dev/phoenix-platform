import '../knowledge_dna/knowledge_dna_engine.dart';
import '../progress_engine/progress_engine.dart';

class PersistedProgress {
  const PersistedProgress({
    required this.totalXp,
    required this.currentLevel,
    required this.dailyStreak,
    required this.weeklyStreak,
  });

  final int totalXp;
  final int currentLevel;
  final int dailyStreak;
  final int weeklyStreak;
}

class PersistedKnowledgeDNA {
  const PersistedKnowledgeDNA({
    required this.confidence,
    required this.retention,
    required this.consistency,
    required this.learningVelocity,
    required this.strongAreas,
    required this.weakAreas,
    required this.careerDirection,
  });

  final double confidence;
  final double retention;
  final double consistency;
  final double learningVelocity;
  final List<String> strongAreas;
  final List<String> weakAreas;
  final String careerDirection;
}

abstract class ProgressRepository {
  Future<PersistedProgress> loadProgress();

  Future<void> saveProgressSummary(ProgressEngine progress);

  Future<void> saveTotalXp(int totalXp);

  Future<void> saveCurrentLevel(int currentLevel);

  Future<void> saveDailyStreak(int dailyStreak);

  Future<void> saveWeeklyStreak(int weeklyStreak);

  Future<PersistedKnowledgeDNA> loadKnowledgeDNA();

  Future<void> saveKnowledgeDNA(KnowledgeDNAEngine knowledgeDNA);
}
