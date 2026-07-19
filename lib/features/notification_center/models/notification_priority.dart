import 'package:flutter/material.dart';

/// Priority level of a notification.
///
/// Higher priority notifications appear first in the notification list.
enum NotificationPriority {
  /// Time-sensitive — requires immediate attention.
  urgent(4, 'Urgent'),

  /// Important — should be reviewed soon.
  high(3, 'High'),

  /// Normal — part of regular updates.
  normal(2, 'Normal'),

  /// Informational — low-priority updates.
  low(1, 'Low');

  const NotificationPriority(this.weight, this.displayName);

  /// Numeric weight for sorting (descending).
  final int weight;

  /// Human-readable priority label.
  final String displayName;

  /// Color associated with this priority level.
  Color get color {
    switch (this) {
      case NotificationPriority.urgent:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.grey;
    }
  }
}
