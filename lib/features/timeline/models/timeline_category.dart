/// Categories for timeline events.
///
/// Architecture supports unlimited future categories — just add
/// a new enum value. No business logic is owned here.
enum TimelineCategory {
  /// Lesson completions, path progress.
  learning,

  /// Mission completions, progress updates.
  mission,

  /// Achievements unlocked.
  achievement,

  /// Career milestones.
  career,

  /// Portfolio project completions.
  portfolio,

  /// Resume milestones.
  resume,

  /// Interview practice sessions.
  interview,

  /// Decision analysis completions.
  decision,

  /// AI mentor interactions.
  ai,

  /// Voice command milestones.
  voice,

  /// Plugin marketplace actions.
  marketplace,

  /// System-level events (identity selection, journey progress).
  system,

  /// Custom user-defined events.
  custom;

  /// Human-readable label.
  String get label {
    switch (this) {
      case TimelineCategory.learning:
        return 'Learning';
      case TimelineCategory.mission:
        return 'Mission';
      case TimelineCategory.achievement:
        return 'Achievement';
      case TimelineCategory.career:
        return 'Career';
      case TimelineCategory.portfolio:
        return 'Portfolio';
      case TimelineCategory.resume:
        return 'Resume';
      case TimelineCategory.interview:
        return 'Interview';
      case TimelineCategory.decision:
        return 'Decision';
      case TimelineCategory.ai:
        return 'AI Mentor';
      case TimelineCategory.voice:
        return 'Voice';
      case TimelineCategory.marketplace:
        return 'Marketplace';
      case TimelineCategory.system:
        return 'System';
      case TimelineCategory.custom:
        return 'Custom';
    }
  }

  /// Icon name for display.
  String get iconName {
    switch (this) {
      case TimelineCategory.learning:
        return 'school';
      case TimelineCategory.mission:
        return 'rocket_launch';
      case TimelineCategory.achievement:
        return 'emoji_events';
      case TimelineCategory.career:
        return 'work';
      case TimelineCategory.portfolio:
        return 'folder';
      case TimelineCategory.resume:
        return 'description';
      case TimelineCategory.interview:
        return 'record_voice_over';
      case TimelineCategory.decision:
        return 'account_tree';
      case TimelineCategory.ai:
        return 'auto_awesome';
      case TimelineCategory.voice:
        return 'mic';
      case TimelineCategory.marketplace:
        return 'store';
      case TimelineCategory.system:
        return 'settings';
      case TimelineCategory.custom:
        return 'star';
    }
  }

  /// Parses from a string.
  static TimelineCategory fromString(String value) {
    return TimelineCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => TimelineCategory.custom,
    );
  }
}
