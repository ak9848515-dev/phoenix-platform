import 'package:flutter/material.dart';

/// Represents a personal growth identity that a user can aspire to become.
///
/// Each identity defines a role archetype with a structured roadmap,
/// skill requirements, and progression levels.
class Identity {
  const Identity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.currentLevel,
    required this.targetLevel,
    required this.estimatedDuration,
    required this.requiredSkills,
    required this.roadmap,
    required this.status,
  });

  /// Unique identifier for the identity.
  final String id;

  /// Display name of the identity (e.g. "Software Engineer").
  final String title;

  /// Short description of what this identity entails.
  final String description;

  /// Material icon for visual representation.
  final IconData icon;

  /// Category grouping (e.g. "Technology", "Business", "Creative").
  final String category;

  /// The user's current proficiency level for this identity.
  final int currentLevel;

  /// The target proficiency level the user aims to reach.
  final int targetLevel;

  /// Estimated time (in days) to reach the target level.
  final int estimatedDuration;

  /// List of skills required to master this identity.
  final List<String> requiredSkills;

  /// Ordered list of roadmap milestones.
  final List<String> roadmap;

  /// Current status of this identity journey.
  final IdentityStatus status;

  /// Creates a copy of this identity with the given fields replaced.
  Identity copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    String? category,
    int? currentLevel,
    int? targetLevel,
    int? estimatedDuration,
    List<String>? requiredSkills,
    List<String>? roadmap,
    IdentityStatus? status,
  }) {
    return Identity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      roadmap: roadmap ?? this.roadmap,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Identity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Identity(id: $id, title: $title, category: $category, '
        'status: $status)';
  }
}

/// The possible states of an identity journey.
enum IdentityStatus {
  /// The identity has been selected and is in progress.
  active,

  /// The identity is available but not yet selected.
  available,

  /// The identity has been fully mastered.
  completed,

  /// The identity is locked and not yet available.
  locked,
}