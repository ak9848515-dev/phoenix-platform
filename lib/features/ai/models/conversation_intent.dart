/// User intent categories for the AI conversation system.
///
/// Detected by [ConversationEngine] from user messages.
/// Each intent maps to specific intelligence services.
enum ConversationIntent {
  /// General greeting / opening message.
  greeting,

  /// Asking about progress, stats, XP, level.
  progress,

  /// Asking about recommendations, focus, next action.
  recommendation,

  /// Asking about learning, lessons, academy.
  learning,

  /// Asking about habits, streaks, consistency.
  habit,

  /// Asking about timeline, events, milestones.
  timeline,

  /// Asking about knowledge graph, skills, gaps.
  knowledge,

  /// Asking about decisions, outcomes, follow-ups.
  decision,

  /// Asking about memory graph, entities, clusters.
  memory,

  /// Asking about career, job readiness, portfolio.
  career,

  /// Asking for an explanation or "why".
  explanation,

  /// Asking how to improve, about risks, opportunities.
  insight,

  /// Scheduling or reminder requests.
  planning,

  /// General conversation / chitchat / unknown.
  general,
}
