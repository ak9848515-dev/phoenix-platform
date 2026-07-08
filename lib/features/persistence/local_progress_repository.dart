import '../knowledge_dna/knowledge_dna_engine.dart';
import '../progress_engine/progress_engine.dart';
import 'local_storage_service.dart';
import 'progress_repository.dart';
import 'storage_keys.dart';

class LocalProgressRepository implements ProgressRepository {
  const LocalProgressRepository({
    this.storageService = const LocalStorageService(),
  });

  final LocalStorageService storageService;

  @override
  Future<PersistedProgress> loadProgress() async {
    final totalXp = await storageService.getInt(StorageKeys.totalXp) ?? 0;
    final currentLevel = await storageService.getInt(StorageKeys.currentLevel) ?? 1;
    final dailyStreak = await storageService.getInt(StorageKeys.dailyStreak) ?? 0;
    final weeklyStreak = await storageService.getInt(StorageKeys.weeklyStreak) ?? 0;

    return PersistedProgress(
      totalXp: totalXp,
      currentLevel: currentLevel,
      dailyStreak: dailyStreak,
      weeklyStreak: weeklyStreak,
    );
  }

  @override
  Future<void> saveProgressSummary(ProgressEngine progress) async {
    await saveTotalXp(progress.totalXp);
    await saveCurrentLevel(progress.level);
    await saveDailyStreak(progress.streaks.daily);
    await saveWeeklyStreak(progress.streaks.weekly);
  }

  @override
  Future<void> saveTotalXp(int totalXp) {
    return storageService.setInt(StorageKeys.totalXp, totalXp);
  }

  @override
  Future<void> saveCurrentLevel(int currentLevel) {
    return storageService.setInt(StorageKeys.currentLevel, currentLevel);
  }

  @override
  Future<void> saveDailyStreak(int dailyStreak) {
    return storageService.setInt(StorageKeys.dailyStreak, dailyStreak);
  }

  @override
  Future<void> saveWeeklyStreak(int weeklyStreak) {
    return storageService.setInt(StorageKeys.weeklyStreak, weeklyStreak);
  }

  @override
  Future<PersistedKnowledgeDNA> loadKnowledgeDNA() async {
    final confidence = await storageService.getDouble(StorageKeys.knowledgeConfidence) ?? 0.0;
    final retention = await storageService.getDouble(StorageKeys.knowledgeRetention) ?? 0.0;
    final consistency = await storageService.getDouble(StorageKeys.knowledgeConsistency) ?? 0.0;
    final learningVelocity = await storageService.getDouble(StorageKeys.knowledgeLearningVelocity) ?? 0.0;
    final strongAreas = await storageService.getStringList(StorageKeys.knowledgeStrongAreas);
    final weakAreas = await storageService.getStringList(StorageKeys.knowledgeWeakAreas);
    final careerDirection = await storageService.getString(StorageKeys.knowledgeCareerDirection) ?? '';

    return PersistedKnowledgeDNA(
      confidence: confidence,
      retention: retention,
      consistency: consistency,
      learningVelocity: learningVelocity,
      strongAreas: strongAreas,
      weakAreas: weakAreas,
      careerDirection: careerDirection,
    );
  }

  @override
  Future<void> saveKnowledgeDNA(KnowledgeDNAEngine knowledgeDNA) async {
    await storageService.setDouble(StorageKeys.knowledgeConfidence, knowledgeDNA.confidenceScore);
    await storageService.setDouble(StorageKeys.knowledgeRetention, knowledgeDNA.retentionScore);
    await storageService.setDouble(StorageKeys.knowledgeConsistency, knowledgeDNA.consistencyScore);
    await storageService.setDouble(StorageKeys.knowledgeLearningVelocity, knowledgeDNA.learningVelocity);
    await storageService.setStringList(StorageKeys.knowledgeStrongAreas, knowledgeDNA.skillStrengths);
    await storageService.setStringList(StorageKeys.knowledgeWeakAreas, knowledgeDNA.skillWeaknesses);
    await storageService.setString(StorageKeys.knowledgeCareerDirection, knowledgeDNA.careerDirection);
  }
}
