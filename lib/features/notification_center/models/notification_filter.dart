/// Filter options for the Notification Center.
enum NotificationFilter {
  /// Show all notifications.
  all('All', 'all'),

  /// Show only unread notifications.
  unread('Unread', 'unread'),

  /// Show only mission-related notifications.
  mission('Missions', 'mission'),

  /// Show only career-related notifications.
  career('Career', 'career'),

  /// Show only learning-related notifications.
  learning('Learning', 'learning'),

  /// Show only AI-related notifications.
  ai('AI', 'ai'),

  /// Show only system notifications.
  system('System', 'system');

  const NotificationFilter(this.displayName, this.key);

  /// Human-readable filter label.
  final String displayName;

  /// URL-safe key for the filter.
  final String key;
}
