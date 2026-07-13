import 'dart:convert';

/// Placeholder model describing the Knowledge DNA profile.
///
/// This is a presentation-only model used to structure sample values for the
/// UI layer without introducing business logic or backend dependencies.
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

  /// Serializes this KnowledgeDNA to a JSON-compatible map.
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

  /// Creates a KnowledgeDNA from a JSON-compatible map.
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

  /// Serializes this KnowledgeDNA to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates a KnowledgeDNA from a JSON string.
  factory KnowledgeDNA.fromJson(String source) =>
      KnowledgeDNA.fromMap(json.decode(source) as Map<String, dynamic>);
}
