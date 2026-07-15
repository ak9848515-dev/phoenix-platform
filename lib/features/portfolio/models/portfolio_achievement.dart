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
    this.iconName,
    this.date,
    this.type = 'achievement',
  });

  /// Unique identifier for this achievement.
  final String id;

  /// Human-readable title (e.g. 'First Mission Complete').
  final String title;

  /// Optional short description of how this was earned.
  final String? description;

  /// Icon identifier (resolved via [icon] getter to a compile-time constant).
  final String? iconName;

  /// Resolved Material icon for visual representation, or `null` if none set.
  IconData? get icon =>
      iconName != null ? PortfolioAchievement.resolveIcon(iconName!) : null;

  /// When this achievement was earned.
  final DateTime? date;

  /// Category of achievement: 'achievement', 'badge', 'milestone'.
  final String type;

  /// Whether this is a badge type.
  bool get isBadge => type == 'badge';

  /// Whether this is a milestone type.
  bool get isMilestone => type == 'milestone';

  /// Resolves an icon name string to a compile-time constant [IconData].
  ///
  /// **Production note:** All icons used by PortfolioAchievement must be
  /// listed here so that Flutter's tree shaker can statically determine
  /// which icons to keep.
  static IconData resolveIcon(String name) {
    switch (name) {
      case 'stars_outlined':
        return Icons.stars_outlined;
      case 'emoji_events_outlined':
        return Icons.emoji_events_outlined;
      case 'military_tech_outlined':
        return Icons.military_tech_outlined;
      case 'workspace_premium_outlined':
        return Icons.workspace_premium_outlined;
      case 'verified_outlined':
        return Icons.verified_outlined;
      default:
        return Icons.stars_outlined;
    }
  }

  /// Creates a copy with the given fields replaced.
  PortfolioAchievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    DateTime? date,
    String? type,
  }) {
    return PortfolioAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'date': date?.toIso8601String(),
      'type': type,
    };
  }

  /// Creates from a JSON-compatible map.
  factory PortfolioAchievement.fromMap(Map<String, dynamic> map) {
    return PortfolioAchievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      iconName: map['iconName'] as String?,
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : null,
      type: map['type'] as String? ?? 'achievement',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioAchievement &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.iconName == iconName &&
        other.date == date &&
        other.type == type;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, description, iconName, date, type);

  @override
  String toString() =>
      'PortfolioAchievement(id: $id, title: $title, type: $type)';
}
