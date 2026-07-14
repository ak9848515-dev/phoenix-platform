import 'academy_lesson.dart';
import 'academy_module.dart' show AcademyModule;

/// A learning path in the Academy.
///
/// Immutable. Represents a structured curriculum (e.g. Flutter, Dart, SAP, AI)
/// composed of ordered modules containing lessons.
class LearningPath {
  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.modules,
    this.iconName = 'school',
    this.color = 0xFF6C63FF,
    this.careerTags = const [],
    this.difficulty = 1,
    this.estimatedHours = 0,
    this.prerequisitePathIds = const [],
    this.contentVersion = 1,
  });

  /// Unique identifier (e.g. 'flutter', 'dart', 'sap').
  final String id;

  /// Display title (e.g. 'Flutter Development').
  final String title;

  /// Detailed description.
  final String description;

  /// Modules in order.
  final List<AcademyModule> modules;

  /// Material icon name for the path card.
  final String iconName;

  /// Color (ARGB int) for visual identity.
  final int color;

  /// Career/skill tags (e.g. 'Mobile', 'UI', 'State Management').
  final List<String> careerTags;

  /// Difficulty level (1-5).
  final int difficulty;

  /// Total estimated hours to complete.
  final int estimatedHours;

  /// IDs of paths that should be completed first.
  final List<String> prerequisitePathIds;

  /// Content version.
  final int contentVersion;

  /// Flutter-compatible Color from the ARGB int.
  // ignore: use_late_for_primary_constants
  int get displayColor => color;

  LearningPath copyWith({
    String? id,
    String? title,
    String? description,
    List<AcademyModule>? modules,
    String? iconName,
    int? color,
    List<String>? careerTags,
    int? difficulty,
    int? estimatedHours,
    List<String>? prerequisitePathIds,
    int? contentVersion,
  }) {
    return LearningPath(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      modules: modules ?? this.modules,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      careerTags: careerTags ?? this.careerTags,
      difficulty: difficulty ?? this.difficulty,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      prerequisitePathIds: prerequisitePathIds ?? this.prerequisitePathIds,
      contentVersion: contentVersion ?? this.contentVersion,
    );
  }

  /// All lessons across all modules.
  List<AcademyLesson> get allLessons =>
      modules.expand((m) => m.lessons).toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'modules': modules.map((m) => m.toMap()).toList(),
      'iconName': iconName,
      'color': color,
      'careerTags': careerTags,
      'difficulty': difficulty,
      'estimatedHours': estimatedHours,
      'prerequisitePathIds': prerequisitePathIds,
      'contentVersion': contentVersion,
    };
  }

  factory LearningPath.fromMap(Map<String, dynamic> map) {
    return LearningPath(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      modules: (map['modules'] as List?)
              ?.map((m) =>
                  AcademyModule.fromMap(Map<String, dynamic>.from(m as Map)))
              .toList() ??
          [],
      iconName: map['iconName'] as String? ?? 'school',
      color: map['color'] as int? ?? 0xFF6C63FF,
      careerTags: List<String>.from(map['careerTags'] as List? ?? []),
      difficulty: map['difficulty'] as int? ?? 1,
      estimatedHours: map['estimatedHours'] as int? ?? 0,
      prerequisitePathIds:
          List<String>.from(map['prerequisitePathIds'] as List? ?? []),
      contentVersion: map['contentVersion'] as int? ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningPath && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LearningPath(id: $id, title: $title, modules: ${modules.length})';
}

