import 'resume_project.dart';
import 'resume_skill.dart';

/// Type of resume to generate. Selected automatically from active plugins.
enum ResumeType {
  /// Generic resume for any career path.
  generic('Generic', 'General'),

  /// Software Engineer resume (from software_engineer plugin).
  softwareEngineer('Software Engineer', 'Technology'),

  /// Flutter Developer resume (future plugin).
  flutterDeveloper('Flutter Developer', 'Technology'),

  /// SAP Consultant resume (future plugin).
  sapConsultant('SAP Consultant', 'Enterprise');

  const ResumeType(this.label, this.category);

  /// Human-readable resume type label.
  final String label;

  /// Career category grouping.
  final String category;

  /// Creates a ResumeType from a plugin ID string.
  ///
  /// Maps plugin IDs to their corresponding resume type.
  /// Falls back to [generic] for unknown plugin IDs.
  factory ResumeType.fromPluginId(String pluginId) {
    switch (pluginId) {
      case 'software_engineer':
        return ResumeType.softwareEngineer;
      case 'flutter_developer':
        return ResumeType.flutterDeveloper;
      case 'sap_consultant':
        return ResumeType.sapConsultant;
      default:
        return ResumeType.generic;
    }
  }

  /// Creates a ResumeType from an identity title string.
  ///
  /// Maps identity titles like 'Software Engineer' to their
  /// corresponding resume type. Falls back to [generic] for
  /// unrecognized titles.
  factory ResumeType.fromIdentityTitle(String title) {
    switch (title.toLowerCase()) {
      case 'software engineer':
        return ResumeType.softwareEngineer;
      case 'flutter developer':
        return ResumeType.flutterDeveloper;
      case 'sap consultant':
        return ResumeType.sapConsultant;
      default:
        return ResumeType.generic;
    }
  }
}

/// Immutable representation of the user's Living Resume.
///
/// Automatically generated from the Living Portfolio and Career Profile.
/// Not manually editable. Always reflects the latest Portfolio data.
///
/// Future capabilities (not yet implemented):
///   - ATS Score
///   - PDF Export
///   - LinkedIn Export
///   - Version History
class Resume {
  const Resume({
    required this.id,
    required this.identityId,
    this.resumeType = ResumeType.generic,
    this.professionalSummary = '',
    this.projects = const [],
    this.skills = const [],
    this.achievements = const [],
    this.careerHighlights = const [],
    this.technologyStack = const [],
    this.careerReadiness = '',
    this.resumeScore = 0.0,
    this.generatedAt,
  });

  /// Unique identifier for this resume.
  final String id;

  /// Identity this resume belongs to.
  final String identityId;

  /// Type of resume (Generic, Software Engineer, etc.).
  final ResumeType resumeType;

  /// Professional summary paragraph derived from career profile.
  final String professionalSummary;

  /// Projects and completed missions from the portfolio.
  final List<ResumeProject> projects;

  /// Skills with proficiency levels.
  final List<ResumeSkill> skills;

  /// Achievement descriptions from the portfolio.
  final List<String> achievements;

  /// Career highlight bullet points.
  final List<String> careerHighlights;

  /// Technology stack (languages, frameworks, tools).
  final List<String> technologyStack;

  /// Career readiness label.
  final String careerReadiness;

  /// Overall resume quality score from 0.0 to 1.0.
  final double resumeScore;

  /// When this resume was generated.
  final DateTime? generatedAt;

  /// Number of projects.
  int get projectCount => projects.length;

  /// Number of skills.
  int get skillCount => skills.length;

  /// Creates a copy with the given fields replaced.
  Resume copyWith({
    String? id,
    String? identityId,
    ResumeType? resumeType,
    String? professionalSummary,
    List<ResumeProject>? projects,
    List<ResumeSkill>? skills,
    List<String>? achievements,
    List<String>? careerHighlights,
    List<String>? technologyStack,
    String? careerReadiness,
    double? resumeScore,
    DateTime? generatedAt,
  }) {
    return Resume(
      id: id ?? this.id,
      identityId: identityId ?? this.identityId,
      resumeType: resumeType ?? this.resumeType,
      professionalSummary: professionalSummary ?? this.professionalSummary,
      projects: projects ?? this.projects,
      skills: skills ?? this.skills,
      achievements: achievements ?? this.achievements,
      careerHighlights: careerHighlights ?? this.careerHighlights,
      technologyStack: technologyStack ?? this.technologyStack,
      careerReadiness: careerReadiness ?? this.careerReadiness,
      resumeScore: resumeScore ?? this.resumeScore,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Resume &&
        other.id == id &&
        other.identityId == identityId &&
        other.resumeType == resumeType &&
        other.resumeScore == resumeScore;
  }

  @override
  int get hashCode => Object.hash(id, identityId, resumeType, resumeScore);

  @override
  String toString() =>
      'Resume(id: $id, type: ${resumeType.label}, score: $resumeScore)';
}
