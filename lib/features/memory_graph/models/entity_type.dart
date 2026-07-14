/// Types of entities in the Memory Graph.
///
/// Architecture supports unlimited future types — just add a new
/// enum value. No business logic is owned here.
enum EntityType {
  person,
  skill,
  project,
  goal,
  habit,
  mission,
  lesson,
  decision,
  career,
  resume,
  portfolio,
  interview,
  opportunity,
  timelineEvent,
  aiConversation,
  document,
  custom;

  String get label {
    switch (this) {
      case EntityType.person:
        return 'Person';
      case EntityType.skill:
        return 'Skill';
      case EntityType.project:
        return 'Project';
      case EntityType.goal:
        return 'Goal';
      case EntityType.habit:
        return 'Habit';
      case EntityType.mission:
        return 'Mission';
      case EntityType.lesson:
        return 'Lesson';
      case EntityType.decision:
        return 'Decision';
      case EntityType.career:
        return 'Career';
      case EntityType.resume:
        return 'Resume';
      case EntityType.portfolio:
        return 'Portfolio';
      case EntityType.interview:
        return 'Interview';
      case EntityType.opportunity:
        return 'Opportunity';
      case EntityType.timelineEvent:
        return 'Timeline Event';
      case EntityType.aiConversation:
        return 'AI Conversation';
      case EntityType.document:
        return 'Document';
      case EntityType.custom:
        return 'Custom';
    }
  }

  String get iconName {
    switch (this) {
      case EntityType.person:
        return 'person';
      case EntityType.skill:
        return 'psychology';
      case EntityType.project:
        return 'folder';
      case EntityType.goal:
        return 'flag';
      case EntityType.habit:
        return 'checklist';
      case EntityType.mission:
        return 'rocket_launch';
      case EntityType.lesson:
        return 'school';
      case EntityType.decision:
        return 'account_tree';
      case EntityType.career:
        return 'work';
      case EntityType.resume:
        return 'description';
      case EntityType.portfolio:
        return 'portfolio';
      case EntityType.interview:
        return 'record_voice_over';
      case EntityType.opportunity:
        return 'trending_up';
      case EntityType.timelineEvent:
        return 'timeline';
      case EntityType.aiConversation:
        return 'auto_awesome';
      case EntityType.document:
        return 'article';
      case EntityType.custom:
        return 'star';
    }
  }

  static EntityType fromString(String value) {
    return EntityType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => EntityType.custom,
    );
  }
}
