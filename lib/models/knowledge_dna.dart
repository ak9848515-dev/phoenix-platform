import 'dart:convert';

/// Immutable representation of a user's Knowledge DNA profile.
class KnowledgeDNA {
  const KnowledgeDNA({
    required this.knowledge,
    required this.skill,
    required this.confidence,
    required this.retention,
    required this.consistency,
    required this.learningVelocity,
    required this.missionsCompleted,
    required this.projectsCompleted,
    required this.weakAreas,
    required this.strongAreas,
    required this.careerGoal,
  });

  final String knowledge;
  final String skill;
  final double confidence;
  final double retention;
  final double consistency;
  final double learningVelocity;
  final int missionsCompleted;
  final int projectsCompleted;
  final List<String> weakAreas;
  final List<String> strongAreas;
  final String careerGoal;

  KnowledgeDNA copyWith({
    String? knowledge,
    String? skill,
    double? confidence,
    double? retention,
    double? consistency,
    double? learningVelocity,
    int? missionsCompleted,
    int? projectsCompleted,
    List<String>? weakAreas,
    List<String>? strongAreas,
    String? careerGoal,
  }) {
    return KnowledgeDNA(
      knowledge: knowledge ?? this.knowledge,
      skill: skill ?? this.skill,
      confidence: confidence ?? this.confidence,
      retention: retention ?? this.retention,
      consistency: consistency ?? this.consistency,
      learningVelocity: learningVelocity ?? this.learningVelocity,
      missionsCompleted: missionsCompleted ?? this.missionsCompleted,
      projectsCompleted: projectsCompleted ?? this.projectsCompleted,
      weakAreas: weakAreas ?? this.weakAreas,
      strongAreas: strongAreas ?? this.strongAreas,
      careerGoal: careerGoal ?? this.careerGoal,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'knowledge': knowledge,
      'skill': skill,
      'confidence': confidence,
      'retention': retention,
      'consistency': consistency,
      'learningVelocity': learningVelocity,
      'missionsCompleted': missionsCompleted,
      'projectsCompleted': projectsCompleted,
      'weakAreas': weakAreas,
      'strongAreas': strongAreas,
      'careerGoal': careerGoal,
    };
  }

  factory KnowledgeDNA.fromMap(Map<String, dynamic> map) {
    return KnowledgeDNA(
      knowledge: map['knowledge'] as String,
      skill: map['skill'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      retention: (map['retention'] as num).toDouble(),
      consistency: (map['consistency'] as num).toDouble(),
      learningVelocity: (map['learningVelocity'] as num).toDouble(),
      missionsCompleted: map['missionsCompleted'] as int,
      projectsCompleted: map['projectsCompleted'] as int,
      weakAreas: List<String>.from(map['weakAreas'] as List),
      strongAreas: List<String>.from(map['strongAreas'] as List),
      careerGoal: map['careerGoal'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory KnowledgeDNA.fromJson(String source) => KnowledgeDNA.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is KnowledgeDNA &&
        other.knowledge == knowledge &&
        other.skill == skill &&
        other.confidence == confidence &&
        other.retention == retention &&
        other.consistency == consistency &&
        other.learningVelocity == learningVelocity &&
        other.missionsCompleted == missionsCompleted &&
        other.projectsCompleted == projectsCompleted &&
        other.weakAreas.length == weakAreas.length &&
        other.strongAreas.length == strongAreas.length &&
        other.careerGoal == careerGoal;
  }

  @override
  int get hashCode => Object.hash(
        knowledge,
        skill,
        confidence,
        retention,
        consistency,
        learningVelocity,
        missionsCompleted,
        projectsCompleted,
        Object.hashAll(weakAreas),
        Object.hashAll(strongAreas),
        careerGoal,
      );

  @override
  String toString() {
    return 'KnowledgeDNA(knowledge: $knowledge, skill: $skill, confidence: $confidence, retention: $retention, consistency: $consistency, learningVelocity: $learningVelocity, missionsCompleted: $missionsCompleted, projectsCompleted: $projectsCompleted, weakAreas: $weakAreas, strongAreas: $strongAreas, careerGoal: $careerGoal)';
  }
}
