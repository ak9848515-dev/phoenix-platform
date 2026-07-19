/// Immutable learning profile describing the user's current learning behaviour.
///
/// Maintained and updated by [AdaptiveLearningEngine].
class LearningProfile {
  const LearningProfile({
    this.preferredPace = 'moderate',
    this.preferredDifficulty = 'intermediate',
    this.preferredLessonSize = 'medium',
    this.preferredProjectSize = 'medium',
    this.revisionIntervalDays = 3,
    this.assessmentIntervalDays = 7,
    this.retentionScore = 0.5,
    this.focusScore = 0.5,
    this.consistencyScore = 0.5,
    this.dailyStudyMinutes = 30,
    this.strengths = const [],
    this.weaknesses = const [],
  });

  /// Preferred learning pace: 'slow', 'moderate', 'fast'.
  final String preferredPace;

  /// Preferred difficulty level: 'beginner', 'intermediate', 'advanced'.
  final String preferredDifficulty;

  /// Preferred lesson size: 'small', 'medium', 'large'.
  final String preferredLessonSize;

  /// Preferred project size: 'small', 'medium', 'large'.
  final String preferredProjectSize;

  /// How often to revise (in days).
  final int revisionIntervalDays;

  /// How often to take assessments (in days).
  final int assessmentIntervalDays;

  /// Knowledge retention score (0.0-1.0).
  final double retentionScore;

  /// Focus/attention score (0.0-1.0).
  final double focusScore;

  /// Learning consistency score (0.0-1.0).
  final double consistencyScore;

  /// Estimated daily study minutes.
  final int dailyStudyMinutes;

  /// User's strongest areas.
  final List<String> strengths;

  /// User's weakest areas.
  final List<String> weaknesses;

  /// Creates a copy with the given fields replaced.
  LearningProfile copyWith({
    String? preferredPace,
    String? preferredDifficulty,
    String? preferredLessonSize,
    String? preferredProjectSize,
    int? revisionIntervalDays,
    int? assessmentIntervalDays,
    double? retentionScore,
    double? focusScore,
    double? consistencyScore,
    int? dailyStudyMinutes,
    List<String>? strengths,
    List<String>? weaknesses,
  }) {
    return LearningProfile(
      preferredPace: preferredPace ?? this.preferredPace,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
      preferredLessonSize: preferredLessonSize ?? this.preferredLessonSize,
      preferredProjectSize: preferredProjectSize ?? this.preferredProjectSize,
      revisionIntervalDays: revisionIntervalDays ?? this.revisionIntervalDays,
      assessmentIntervalDays:
          assessmentIntervalDays ?? this.assessmentIntervalDays,
      retentionScore: retentionScore ?? this.retentionScore,
      focusScore: focusScore ?? this.focusScore,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
    );
  }

  @override
  String toString() =>
      'LearningProfile(difficulty: $preferredDifficulty, '
      'pace: $preferredPace, retention: ${(retentionScore * 100).round()}%)';
}
