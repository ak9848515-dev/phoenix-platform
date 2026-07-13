import 'dart:convert';

import 'models/mission_category.dart';
import 'models/mission_difficulty.dart';
import 'models/mission_priority.dart';
import 'models/mission_status.dart';

/// Immutable mission entity — the single source of truth for all missions
/// in Phoenix OS.
///
/// The [Mission] model owns all fields required for generation,
/// prioritisation, scheduling, completion, recurrence, difficulty,
/// dependencies, and rewards.
///
/// Use [copyWith] to produce modified copies.
/// Use [toMap] / [fromMap] for serialization.
class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.difficulty,
    required this.estimatedDuration,
    required this.rewardXP,
    this.status = MissionStatus.pending,
    this.progress = 0.0,
    this.dueDate,
    this.createdDate,
    this.completedDate,
    this.recurring = false,
    this.recurrenceIntervalDays,
    this.dependencyMissionId,
    this.recommendationReason,
    this.sourceService,
  });

  /// Unique identifier for this mission.
  final String id;

  /// Short, actionable title.
  final String title;

  /// Detailed description of what the mission entails.
  final String description;

  /// The domain category of this mission.
  final MissionCategory category;

  /// Priority level (calculated by Mission Engine, never set in UI).
  final MissionPriority priority;

  /// Difficulty level (affects XP multiplier).
  final MissionDifficulty difficulty;

  /// Estimated time to complete in minutes.
  final int estimatedDuration;

  /// XP awarded on completion.
  final int rewardXP;

  /// Current completion status.
  final MissionStatus status;

  /// Progress as a fraction (0.0–1.0).
  final double progress;

  /// Optional deadline for completion.
  final DateTime? dueDate;

  /// When this mission was created/generated.
  final DateTime? createdDate;

  /// When this mission was completed.
  final DateTime? completedDate;

  /// Whether this mission repeats on an interval.
  final bool recurring;

  /// Days between recurrence (null if not recurring).
  final int? recurrenceIntervalDays;

  /// Optional ID of a mission that must be completed first.
  final String? dependencyMissionId;

  /// Why Phoenix recommended this mission (for AI/Recommendation context).
  final String? recommendationReason;

  /// Which platform service generated this mission.
  final String? sourceService;

  /// Whether this mission has been completed.
  bool get isCompleted => status == MissionStatus.completed;

  /// Whether this mission is currently actionable.
  bool get isActionable =>
      status == MissionStatus.pending ||
      status == MissionStatus.inProgress ||
      status == MissionStatus.available;

  /// Whether this mission has a dependency that is not yet met.
  bool get isBlocked => status == MissionStatus.blocked;

  /// Returns a copy with the given fields replaced.
  Mission copyWith({
    String? id,
    String? title,
    String? description,
    MissionCategory? category,
    MissionPriority? priority,
    MissionDifficulty? difficulty,
    int? estimatedDuration,
    int? rewardXP,
    MissionStatus? status,
    double? progress,
    DateTime? dueDate,
    DateTime? createdDate,
    DateTime? completedDate,
    bool? recurring,
    int? recurrenceIntervalDays,
    String? dependencyMissionId,
    String? recommendationReason,
    String? sourceService,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      rewardXP: rewardXP ?? this.rewardXP,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      dueDate: dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
      completedDate: completedDate ?? this.completedDate,
      recurring: recurring ?? this.recurring,
      recurrenceIntervalDays:
          recurrenceIntervalDays ?? this.recurrenceIntervalDays,
      dependencyMissionId: dependencyMissionId ?? this.dependencyMissionId,
      recommendationReason:
          recommendationReason ?? this.recommendationReason,
      sourceService: sourceService ?? this.sourceService,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'difficulty': difficulty.name,
      'estimatedDuration': estimatedDuration,
      'rewardXP': rewardXP,
      'status': status.name,
      'progress': progress,
      'dueDate': dueDate?.toIso8601String(),
      'createdDate': createdDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'recurring': recurring,
      'recurrenceIntervalDays': recurrenceIntervalDays,
      'dependencyMissionId': dependencyMissionId,
      'recommendationReason': recommendationReason,
      'sourceService': sourceService,
    };
  }

  /// Creates from a JSON-compatible map.
  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: MissionCategory.fromString(map['category'] as String),
      priority: MissionPriority.fromString(map['priority'] as String),
      difficulty: MissionDifficulty.fromString(map['difficulty'] as String),
      estimatedDuration: map['estimatedDuration'] as int,
      rewardXP: map['rewardXP'] as int,
      status: MissionStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String),
        orElse: () => MissionStatus.pending,
      ),
      progress: (map['progress'] as num).toDouble(),
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.parse(map['dueDate'] as String),
      createdDate: map['createdDate'] == null
          ? null
          : DateTime.parse(map['createdDate'] as String),
      completedDate: map['completedDate'] == null
          ? null
          : DateTime.parse(map['completedDate'] as String),
      recurring: map['recurring'] as bool? ?? false,
      recurrenceIntervalDays: map['recurrenceIntervalDays'] as int?,
      dependencyMissionId: map['dependencyMissionId'] as String?,
      recommendationReason: map['recommendationReason'] as String?,
      sourceService: map['sourceService'] as String?,
    );
  }

  /// Serializes to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates from a JSON string.
  factory Mission.fromJson(String source) =>
      Mission.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Mission(id: $id, title: $title, status: $status, priority: $priority)';
}
