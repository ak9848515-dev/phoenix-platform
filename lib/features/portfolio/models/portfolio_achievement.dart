import 'package:flutter/material.dart';

/// Immutable representation of an achievement or badge in the user's portfolio.
///
/// Automatically derived from ProgressService achievements, mission
/// completions, and journey milestones. Not manually editable.
class PortfolioAchievement {
  const PortfolioAchievement({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.date,
    this.type = 'achievement',
  });

  /// Unique identifier for this achievement.
  final String id;

  /// Human-readable title (e.g. 'First Mission Complete').
  final String title;

  /// Optional short description of how this was earned.
  final String? description;

  /// Optional icon representing this achievement.
  final IconData? icon;

  /// When this achievement was earned.
  final DateTime? date;

  /// Category of achievement: 'achievement', 'badge', 'milestone'.
  final String type;

  /// Whether this is a badge type.
  bool get isBadge => type == 'badge';

  /// Whether this is a milestone type.
  bool get isMilestone => type == 'milestone';

  /// Creates a copy with the given fields replaced.
  PortfolioAchievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    DateTime? date,
    String? type,
  }) {
    return PortfolioAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioAchievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.icon?.codePoint == icon?.codePoint &&
        other.date == date &&
        other.type == type;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, icon?.codePoint, date, type);

  @override
  String toString() =>
      'PortfolioAchievement(id: $id, title: $title, type: $type)';
}
