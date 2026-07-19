/// Categories of resume scores evaluated by [ResumeIntelligenceEngine].
///
/// Each category represents a distinct dimension of resume quality.
enum ResumeScoreCategory {
  /// Overall resume quality (0–100).
  overall('Overall', 0.30),

  /// ATS compatibility score (0–100).
  ats('ATS Score', 0.20),

  /// Demonstrates technical competency (0–100).
  technical('Technical', 0.15),

  /// Project depth and diversity (0–100).
  project('Projects', 0.10),

  /// Experience alignment (0–100).
  experience('Experience', 0.10),

  /// Portfolio evidence strength (0–100).
  portfolio('Portfolio', 0.05),

  /// ATS keyword coverage (0–100).
  keywordCoverage('Keywords', 0.05),

  /// How ready a recruiter would find the resume (0–100).
  recruiterReadiness('Recruiter Ready', 0.05);

  const ResumeScoreCategory(this.displayName, this.weight);

  /// Human-readable category name.
  final String displayName;

  /// Weight used when calculating the overall composite score.
  final double weight;
}
