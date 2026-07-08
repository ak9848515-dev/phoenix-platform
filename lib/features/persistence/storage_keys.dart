class StorageKeys {
  const StorageKeys._();

  static const String completedMissionIds = 'mission.completed_ids';
  static const String missionCompletedCount = 'mission.completed_count';
  static const String missionPendingCount = 'mission.pending_count';
  static const String missionCompletionPercentage = 'mission.completion_percentage';
  static const String missionStreak = 'mission.streak';
  static const String missionSummary = 'mission.summary';

  static const String totalXp = 'progress.total_xp';
  static const String currentLevel = 'progress.current_level';
  static const String dailyStreak = 'progress.daily_streak';
  static const String weeklyStreak = 'progress.weekly_streak';

  static const String knowledgeConfidence = 'knowledge_dna.confidence';
  static const String knowledgeRetention = 'knowledge_dna.retention';
  static const String knowledgeConsistency = 'knowledge_dna.consistency';
  static const String knowledgeLearningVelocity = 'knowledge_dna.learning_velocity';
  static const String knowledgeStrongAreas = 'knowledge_dna.strong_areas';
  static const String knowledgeWeakAreas = 'knowledge_dna.weak_areas';
  static const String knowledgeCareerDirection = 'knowledge_dna.career_direction';

  static const String userPreferencePrefix = 'settings.user_preference.';
}
