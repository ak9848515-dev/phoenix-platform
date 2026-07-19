/// Categories for organizing long-term memories.
///
/// Each memory is assigned to exactly one category.
enum MemoryCategory {
  identity('Identity', 'Who the user is'),
  goals('Goals', 'Personal and career goals'),
  career('Career', 'Career plans and progress'),
  learning('Learning', 'Learning paths and lessons'),
  projects('Projects', 'Completed and active projects'),
  skills('Skills', 'Acquired and developing skills'),
  achievements('Achievements', 'Milestones and accomplishments'),
  habits('Habits', 'Habit tracking and consistency'),
  interviews('Interviews', 'Interview preparation and history'),
  portfolio('Portfolio', 'Portfolio items and showcases'),
  decisions('Decisions', 'Important decisions made'),
  preferences('Preferences', 'User preferences and settings'),
  milestones('Milestones', 'Key milestones and events'),
  custom('Custom', 'User-defined memories');

  const MemoryCategory(this.displayName, this.description);

  /// Human-readable category name.
  final String displayName;

  /// Short description of what this category contains.
  final String description;
}
