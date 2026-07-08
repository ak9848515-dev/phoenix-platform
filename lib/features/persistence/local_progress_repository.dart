import '../knowledge_dna/knowledge_dna_metrics.dart';
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
    final knowledgeScore = await storageService.getDouble(StorageKeys.knowledgeScore) ?? 0.0;
    final confidenceScore = await storageService.getDouble(StorageKeys.confidenceScore) ?? 0.0;
    final retentionScore = await storageService.getDouble(StorageKeys.retentionScore) ?? 0.0;
    final learningVelocity = await storageService.getDouble(StorageKeys.learningVelocity) ?? 0.0;
    final knowledgeSummary = await storageService.getString(StorageKeys.knowledgeSummary) ?? '';

    return PersistedProgress(
      totalXp: totalXp,
      currentLevel: currentLevel,
      streaks: Streaks(
        daily: dailyStreak,
        weekly: weeklyStreak,
        monthly: 0,
      ),
      knowledgeMetrics: KnowledgeDNAMetrics(
        knowledgeScore: knowledgeScore,
        confidenceScore: confidenceScore,
        retentionScore: retentionScore,
        learningVelocity: learningVelocity,
        summary: knowledgeSummary,
      ),
    );
  }

  @override
  Future<void> saveProgress(PersistedProgress progress) async {
    await saveTotalXp(progress.totalXp);
    await saveCurrentLevel(progress.currentLevel);
    await saveDailyStreak(progress.streaks.daily);
    await saveWeeklyStreak(progress.streaks.weekly);
    await saveKnowledgeMetrics(progress.knowledgeMetrics);
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
  Future<void> saveKnowledgeMetrics(KnowledgeDNAMetrics metrics) async {
    await storageService.setDouble(StorageKeys.knowledgeScore, metrics.knowledgeScore);
    await storageService.setDouble(StorageKeys.confidenceScore, metrics.confidenceScore);
    await storageService.setDouble(StorageKeys.retentionScore, metrics.retentionScore);
    await storageService.setDouble(StorageKeys.learningVelocity, metrics.learningVelocity);
    await storageService.setString(StorageKeys.knowledgeSummary, metrics.summary);
  }

  @override
  Future<void> clearProgress() async {
    await storageService.remove(StorageKeys.totalXp);
    await storageService.remove(StorageKeys.currentLevel);
    await storageService.remove(StorageKeys.dailyStreak);
    await storageService.remove(StorageKeys.weeklyStreak);
    await storageService.remove(StorageKeys.knowledgeScore);
    await storageService.remove(StorageKeys.confidenceScore);
    await storageService.remove(StorageKeys.retentionScore);
    await storageService.remove(StorageKeys.learningVelocity);
    await storageService.remove(StorageKeys.knowledgeSummary);
  }
}
