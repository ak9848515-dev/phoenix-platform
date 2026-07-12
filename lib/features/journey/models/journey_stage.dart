import 'dart:convert';

/// The status of a stage within a journey.
enum StageStatus { locked, available, inProgress, completed }

/// Immutable representation of a single stage within a journey.
class JourneyStage {
  const JourneyStage({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    this.completion = 0.0,
    this.estimatedDuration,
    this.requiredSkills = const [],
    this.missions = const [],
    this.status = StageStatus.locked,
  });

  final String id;
  final String title;
  final String description;
  final int order;
  final double completion;
  final int? estimatedDuration;
  final List<String> requiredSkills;
  final List<String> missions;
  final StageStatus status;

  JourneyStage copyWith({
    String? id,
    String? title,
    String? description,
    int? order,
    double? completion,
    int? estimatedDuration,
    List<String>? requiredSkills,
    List<String>? missions,
    StageStatus? status,
  }) {
    return JourneyStage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      completion: completion ?? this.completion,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      missions: missions ?? this.missions,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'completion': completion,
      'estimatedDuration': estimatedDuration,
      'requiredSkills': requiredSkills,
      'missions': missions,
      'status': status.name,
    };
  }

  factory JourneyStage.fromMap(Map<String, dynamic> map) {
    return JourneyStage(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      order: map['order'] as int,
      completion: (map['completion'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration: map['estimatedDuration'] as int?,
      requiredSkills: map['requiredSkills'] != null
          ? List<String>.from(map['requiredSkills'] as List)
          : const [],
      missions: map['missions'] != null
          ? List<String>.from(map['missions'] as List)
          : const [],
      status: map['status'] != null
          ? StageStatus.values.firstWhere(
              (s) => s.name == map['status'],
              orElse: () => StageStatus.locked,
            )
          : StageStatus.locked,
    );
  }

  String toJson() => json.encode(toMap());

  factory JourneyStage.fromJson(String source) =>
      JourneyStage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JourneyStage &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.order == order &&
        other.completion == completion &&
        other.estimatedDuration == estimatedDuration &&
        other.requiredSkills.length == requiredSkills.length &&
        other.missions.length == missions.length &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    order,
    completion,
    estimatedDuration,
    Object.hashAll(requiredSkills),
    Object.hashAll(missions),
    status,
  );

  @override
  String toString() {
    return 'JourneyStage(id: $id, title: $title, order: $order, status: ${status.name})';
  }
}
