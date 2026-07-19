import 'dart:convert';

import 'notification_action.dart';
import 'notification_category.dart';
import 'notification_priority.dart';

/// An immutable notification item in the Phoenix Notification Center.
///
/// Every notification contains:
/// - Title and description
/// - Timestamp for display and sorting
/// - Priority for visual distinction
/// - Category for filtering
/// - Icon derived from category
/// - Read/unread state
/// - A deep-link action on tap
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.priority = NotificationPriority.normal,
    this.category = NotificationCategory.system,
    this.isRead = false,
    this.action,
    this.sourceEngine = '',
  });

  /// Unique notification identifier.
  final String id;

  /// Short notification title.
  final String title;

  /// Detailed notification message.
  final String description;

  /// When this notification was created.
  final DateTime timestamp;

  /// Priority level.
  final NotificationPriority priority;

  /// Category (determines icon and filter group).
  final NotificationCategory category;

  /// Whether the user has seen this notification.
  final bool isRead;

  /// Optional deep-link action when tapped.
  final NotificationAction? action;

  /// Which engine generated this notification (for diagnostics).
  final String sourceEngine;

  // ── Computed ─────────────────────────────────────────────────────

  /// Human-readable time description.
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  /// Creates a copy with the given fields replaced.
  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    NotificationPriority? priority,
    NotificationCategory? category,
    bool? isRead,
    NotificationAction? action,
    String? sourceEngine,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      action: action ?? this.action,
      sourceEngine: sourceEngine ?? this.sourceEngine,
    );
  }

  /// Marks this notification as read.
  NotificationItem markRead() => copyWith(isRead: true);

  /// Marks this notification as unread.
  NotificationItem markUnread() => copyWith(isRead: false);

  // ── Serialization ───────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'priority': priority.name,
        'category': category.name,
        'isRead': isRead,
        'action': action != null
            ? {'route': action!.route, 'label': action!.label}
            : null,
        'sourceEngine': sourceEngine,
      };

  factory NotificationItem.fromMap(Map<String, dynamic> map) =>
      NotificationItem(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        priority: NotificationPriority.values.firstWhere(
          (e) => e.name == map['priority'],
          orElse: () => NotificationPriority.normal,
        ),
        category: NotificationCategory.values.firstWhere(
          (e) => e.name == map['category'],
          orElse: () => NotificationCategory.system,
        ),
        isRead: map['isRead'] as bool? ?? false,
        action: map['action'] != null
            ? NotificationAction(
                route: (map['action'] as Map)['route'] as String,
                label: (map['action'] as Map)['label'] as String?,
              )
            : null,
        sourceEngine: map['sourceEngine'] as String? ?? '',
      );

  String toJson() => json.encode(toMap());
  factory NotificationItem.fromJson(String source) =>
      NotificationItem.fromMap(
          json.decode(source) as Map<String, dynamic>);

  static List<NotificationItem> listFromJson(String source) {
    final list = json.decode(source) as List;
    return list
        .map((e) => NotificationItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<NotificationItem> items) =>
      json.encode(items.map((e) => e.toMap()).toList());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'NotificationItem(id: $id, title: $title, priority: ${priority.name}, read: $isRead)';
}
