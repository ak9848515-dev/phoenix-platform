import 'dart:convert';

/// Immutable representation of the user's career readiness profile.
///
/// Measures how close the user is to becoming employable in their chosen
/// Identity by aggregating data from Identity, Journey, Mission, Knowledge
/// DNA, Progress, and Decision modules.
class CareerProfile {
  const CareerProfile({
    required this.id,
    required this.identityId,
    required this.careerScore,
    required this.jobReadiness,
    required this.strengths,
    required this.skillGaps,
    required this.nextGoal,
    required this.estimatedWeeks,
    required this.portfolioProgress,
    required this.resumeProgress,
    required this.interviewReadiness,
  });

  /// Unique identifier for this career profile.
  final String id;

  /// The identity this career profile is associated with.
  final String identityId;

  /// Overall career readiness score from 0.0 to 1.0.
  final double careerScore;

  /// Job readiness level (e.g. "Exploring", "Building", "Ready").
  final String jobReadiness;

  /// Top skills the user can confidently demonstrate.
  final List<String> strengths;

  /// Skills the user still needs to develop.
  final List<String> skillGaps;

  /// The next recommended goal towards career readiness.
  final String nextGoal;

  /// Estimated weeks remaining to reach job readiness.
  final int estimatedWeeks;

  /// Portfolio completion progress from 0.0 to 1.0.
  final double portfolioProgress;

  /// Resume completion progress from 0.0 to 1.0.
  final double resumeProgress;

  /// Interview readiness score from 0.0 to 1.0.
  final double interviewReadiness;

  /// Serializes this career profile to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'identityId': identityId,
      'careerScore': careerScore,
      'jobReadiness': jobReadiness,
      'strengths': strengths,
      'skillGaps': skillGaps,
      'nextGoal': nextGoal,
      'estimatedWeeks': estimatedWeeks,
      'portfolioProgress': portfolioProgress,
      'resumeProgress': resumeProgress,
      'interviewReadiness': interviewReadiness,
    };
  }

  /// Creates a career profile from a JSON-compatible map.
  factory CareerProfile.fromMap(Map<String, dynamic> map) {
    return CareerProfile(
      id: map['id'] as String,
      identityId: map['identityId'] as String,
      careerScore: (map['careerScore'] as num).toDouble(),
      jobReadiness: map['jobReadiness'] as String,
      strengths: List<String>.from(map['strengths'] as List),
      skillGaps: List<String>.from(map['skillGaps'] as List),
      nextGoal: map['nextGoal'] as String,
      estimatedWeeks: map['estimatedWeeks'] as int,
      portfolioProgress: (map['portfolioProgress'] as num).toDouble(),
      resumeProgress: (map['resumeProgress'] as num).toDouble(),
      interviewReadiness: (map['interviewReadiness'] as num).toDouble(),
    );
  }

  /// Serializes this career profile to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates a career profile from a JSON string.
  factory CareerProfile.fromJson(String source) =>
      CareerProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CareerProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CareerProfile(id: $id, identityId: $identityId, '
        'careerScore: $careerScore, jobReadiness: $jobReadiness)';
  }
}
