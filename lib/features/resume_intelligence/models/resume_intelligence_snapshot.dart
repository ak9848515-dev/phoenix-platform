import 'resume_gap.dart';
import 'resume_recommendation.dart';
import 'resume_score_category.dart';
import 'resume_section_score.dart';
import 'resume_strength.dart';

/// Immutable snapshot of the user's resume intelligence state.
///
/// Single source of truth for resume quality data consumed by
/// CareerScreen, Dashboard, Profile, and Phoenix Assistant.
///
/// Produced by [ResumeIntelligenceEngine]. Widgets read this snapshot only.
class ResumeIntelligenceSnapshot {
  const ResumeIntelligenceSnapshot({
    this.overallScore = 0.0,
    this.atsScore = 0.0,
    this.technicalScore = 0.0,
    this.projectScore = 0.0,
    this.experienceScore = 0.0,
    this.portfolioScore = 0.0,
    this.keywordCoverage = 0.0,
    this.recruiterReadiness = 0.0,
    this.scores = const {},
    this.gaps = const [],
    this.recommendations = const [],
    this.strengths = const [],
    this.sectionScores = const [],
    this.completeness = 0.0,
    this.atsCompleteness = 0.0,
    this.strengthCount = 0,
    this.gapCount = 0,
    this.topGap,
    this.topRecommendation,
    this.topStrength,
    this.hasData = false,
    this.lastUpdated,
  });

  // ── Score Dimensions ───────────────────────────────────────────────

  /// Overall resume quality score (0–100).
  final double overallScore;

  /// ATS compatibility score (0–100).
  final double atsScore;

  /// Technical competency score (0–100).
  final double technicalScore;

  /// Project depth score (0–100).
  final double projectScore;

  /// Experience alignment score (0–100).
  final double experienceScore;

  /// Portfolio evidence score (0–100).
  final double portfolioScore;

  /// ATS keyword coverage score (0–100).
  final double keywordCoverage;

  /// Recruiter readiness score (0–100).
  final double recruiterReadiness;

  /// All category scores keyed by [ResumeScoreCategory].
  final Map<ResumeScoreCategory, double> scores;

  // ── Analysis ───────────────────────────────────────────────────────

  /// Identified resume gaps.
  final List<ResumeGap> gaps;

  /// Deterministic recommendations.
  final List<ResumeRecommendation> recommendations;

  /// Identified resume strengths.
  final List<ResumeStrength> strengths;

  /// Per-section scores.
  final List<ResumeSectionScore> sectionScores;

  // ── Summary Metrics ────────────────────────────────────────────────

  /// Overall resume completeness (0.0–1.0).
  final double completeness;

  /// ATS-specific completeness (0.0–1.0).
  final double atsCompleteness;

  /// Number of identified strengths.
  final int strengthCount;

  /// Number of identified gaps.
  final int gapCount;

  // ── Top Items ──────────────────────────────────────────────────────

  /// The most critical gap.
  final ResumeGap? topGap;

  /// The highest-priority recommendation.
  final ResumeRecommendation? topRecommendation;

  /// The strongest asset.
  final ResumeStrength? topStrength;

  /// Whether resume data has been evaluated.
  final bool hasData;

  /// When this snapshot was generated.
  final DateTime? lastUpdated;

  // ── Computed Helpers ───────────────────────────────────────────────

  /// Whether the resume is in good shape (score >= 70).
  bool get isHealthy => overallScore >= 70;

  /// Whether urgent attention is needed (score < 40).
  bool get needsUrgentAttention => overallScore < 40;

  /// Human-readable health label.
  String get healthLabel {
    if (overallScore >= 85) return 'Excellent';
    if (overallScore >= 70) return 'Good';
    if (overallScore >= 50) return 'Needs Work';
    if (overallScore >= 30) return 'Needs Significant Work';
    return 'Not Started';
  }

  @override
  String toString() =>
      'ResumeIntelligenceSnapshot(score: $overallScore, '
      'ats: $atsScore, gaps: $gapCount, strengths: $strengthCount)';
}
