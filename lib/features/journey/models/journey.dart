import 'dart:convert';

import 'journey_stage.dart';

/// Immutable representation of a user's entire learning journey.
///
/// A Journey is generated from an Identity and contains a series of Stages.
/// Knowledge DNA measures progress through the Journey, and Recommendation
/// selects the next best step.
class Journey {
  const Journey({
    required this.id,
    required this.identityId,
    required this.title,
    required this.description,
    this.estimatedDuration,
    this.completion = 0.0,
    this.currentStage = 0,
    this.stages = const [],
  });

  final String id;
  final String identityId;
  final String title;
  final String description;
  final int? estimatedDuration;
  final double completion;
  final int currentStage;
  final List<JourneyStage> stages;

  Journey copyWith({
    String? id,
    String? identityId,
    String? title,
    String? description,
    int? estimatedDuration,
    double? completion,
    int? currentStage,
    List<JourneyStage>? stages,
  }) {
    return Journey(
      id: id ?? this.id,
      identityId: identityId ?? this.identityId,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      completion: completion ?? this.completion,
      currentStage: currentStage ?? this.currentStage,
      stages: stages ?? this.stages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'identityId': identityId,
      'title': title,
      'description': description,
      'estimatedDuration': estimatedDuration,
      'completion': completion,
      'currentStage': currentStage,
      'stages': stages.map((stage) => stage.toMap()).toList(),
    };
  }

  factory Journey.fromMap(Map<String, dynamic> map) {
    final stagesData = map['stages'];

    return Journey(
      id: map['id'] as String,
      identityId: map['identityId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      estimatedDuration: map['estimatedDuration'] as int?,
      completion: (map['completion'] as num?)?.toDouble() ?? 0.0,
      currentStage: map['currentStage'] as int? ?? 0,
      stages: stagesData == null
          ? const <JourneyStage>[]
          : (stagesData as List)
                .map(
                  (item) => JourneyStage.fromMap(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Journey.fromJson(String source) =>
      Journey.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Journey &&
        other.id == id &&
        other.identityId == identityId &&
        other.title == title &&
        other.description == description &&
        other.estimatedDuration == estimatedDuration &&
        other.completion == completion &&
        other.currentStage == currentStage &&
        other.stages.length == stages.length;
  }

  @override
  int get hashCode => Object.hash(
    id,
    identityId,
    title,
    description,
    estimatedDuration,
    completion,
    currentStage,
    Object.hashAll(stages),
  );

  @override
  String toString() {
    return 'Journey(id: $id, title: $title, stages: ${stages.length})';
  }
}
