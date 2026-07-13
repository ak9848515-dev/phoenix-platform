import 'dart:convert';

import 'interview_question.dart';

/// Immutable representation of the user's interview preparation profile.
///
/// Automatically derived from Career, Portfolio, Knowledge DNA, Decision,
/// and Identity data. No manual editing, no AI, no persistence.
class InterviewProfile {
  const InterviewProfile({
    required this.id,
    required this.identityId,
    this.interviewReadiness = 0.0,
    this.technicalScore = 0.0,
    this.behavioralScore = 0.0,
    this.communicationScore = 0.0,
    this.strengths = const [],
    this.improvementAreas = const [],
    this.recommendedTopics = const [],
    this.mockQuestions = const [],
    this.estimatedPreparationDays = 0,
  });

  /// Unique identifier.
  final String id;

  /// Identity this profile belongs to.
  final String identityId;

  /// Overall interview readiness from 0.0 to 1.0.
  final double interviewReadiness;

  /// Technical skill score from 0.0 to 1.0.
  final double technicalScore;

  /// Behavioral competency score from 0.0 to 1.0.
  final double behavioralScore;

  /// Communication ability score from 0.0 to 1.0.
  final double communicationScore;

  /// Interview-related strengths.
  final List<String> strengths;

  /// Areas needing improvement.
  final List<String> improvementAreas;

  /// Recommended topics to study.
  final List<String> recommendedTopics;

  /// Practice questions for mock interviews.
  final List<InterviewQuestion> mockQuestions;

  /// Estimated days needed to prepare.
  final int estimatedPreparationDays;

  /// Number of mock questions available.
  int get questionCount => mockQuestions.length;

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'identityId': identityId,
      'interviewReadiness': interviewReadiness,
      'technicalScore': technicalScore,
      'behavioralScore': behavioralScore,
      'communicationScore': communicationScore,
      'strengths': strengths,
      'improvementAreas': improvementAreas,
      'recommendedTopics': recommendedTopics,
      'mockQuestions': mockQuestions.map((q) => q.toMap()).toList(),
      'estimatedPreparationDays': estimatedPreparationDays,
    };
  }

  /// Creates from a JSON-compatible map.
  factory InterviewProfile.fromMap(Map<String, dynamic> map) {
    return InterviewProfile(
      id: map['id'] as String,
      identityId: map['identityId'] as String,
      interviewReadiness:
          (map['interviewReadiness'] as num?)?.toDouble() ?? 0.0,
      technicalScore: (map['technicalScore'] as num?)?.toDouble() ?? 0.0,
      behavioralScore: (map['behavioralScore'] as num?)?.toDouble() ?? 0.0,
      communicationScore:
          (map['communicationScore'] as num?)?.toDouble() ?? 0.0,
      strengths: map['strengths'] != null
          ? List<String>.from(map['strengths'] as List)
          : const [],
      improvementAreas: map['improvementAreas'] != null
          ? List<String>.from(map['improvementAreas'] as List)
          : const [],
      recommendedTopics: map['recommendedTopics'] != null
          ? List<String>.from(map['recommendedTopics'] as List)
          : const [],
      mockQuestions: map['mockQuestions'] != null
          ? (map['mockQuestions'] as List)
              .map((q) => InterviewQuestion.fromMap(
                  Map<String, dynamic>.from(q as Map)))
              .toList()
          : const [],
      estimatedPreparationDays: map['estimatedPreparationDays'] as int? ?? 0,
    );
  }

  /// Serializes to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates from a JSON string.
  factory InterviewProfile.fromJson(String source) =>
      InterviewProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Creates a copy with the given fields replaced.
  InterviewProfile copyWith({
    String? id,
    String? identityId,
    double? interviewReadiness,
    double? technicalScore,
    double? behavioralScore,
    double? communicationScore,
    List<String>? strengths,
    List<String>? improvementAreas,
    List<String>? recommendedTopics,
    List<InterviewQuestion>? mockQuestions,
    int? estimatedPreparationDays,
  }) {
    return InterviewProfile(
      id: id ?? this.id,
      identityId: identityId ?? this.identityId,
      interviewReadiness: interviewReadiness ?? this.interviewReadiness,
      technicalScore: technicalScore ?? this.technicalScore,
      behavioralScore: behavioralScore ?? this.behavioralScore,
      communicationScore: communicationScore ?? this.communicationScore,
      strengths: strengths ?? this.strengths,
      improvementAreas: improvementAreas ?? this.improvementAreas,
      recommendedTopics: recommendedTopics ?? this.recommendedTopics,
      mockQuestions: mockQuestions ?? this.mockQuestions,
      estimatedPreparationDays:
          estimatedPreparationDays ?? this.estimatedPreparationDays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterviewProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InterviewProfile(id: $id, readiness: $interviewReadiness, '
      'questions: $questionCount)';
}
