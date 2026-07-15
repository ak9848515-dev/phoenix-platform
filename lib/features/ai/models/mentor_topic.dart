/// Topic domain for AI mentor coaching sessions.
enum MentorTopic {
  /// Daily planning and focus coaching.
  daily,

  /// Learning path and lesson coaching.
  learning,

  /// Habit tracking and consistency coaching.
  habit,

  /// Career readiness and growth coaching.
  career,

  /// Decision analysis and outcome coaching.
  decision,

  /// Goal setting and progress coaching.
  goal,

  /// Knowledge graph exploration coaching.
  knowledge,

  /// Memory graph and pattern discovery.
  memory,

  /// General progress and momentum coaching.
  progress;

  /// Human-readable label for the topic.
  String get label {
    switch (this) {
      case MentorTopic.daily:
        return 'Daily Coaching';
      case MentorTopic.learning:
        return 'Learning Mentor';
      case MentorTopic.habit:
        return 'Habit Mentor';
      case MentorTopic.career:
        return 'Career Mentor';
      case MentorTopic.decision:
        return 'Decision Mentor';
      case MentorTopic.goal:
        return 'Goal Mentor';
      case MentorTopic.knowledge:
        return 'Knowledge Mentor';
      case MentorTopic.memory:
        return 'Memory Mentor';
      case MentorTopic.progress:
        return 'Progress Mentor';
    }
  }
}
