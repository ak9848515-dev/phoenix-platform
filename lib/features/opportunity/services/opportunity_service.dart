import '../../../core/repository.dart';
import '../../../core/sample_repository.dart';
import '../../career/services/career_service.dart';
import '../../decision/services/decision_service.dart';
import '../../interview/services/interview_service.dart';
import '../../journey/services/journey_service.dart';
import '../../portfolio/services/portfolio_service.dart';
import '../../resume/models/resume.dart';
import '../../resume/services/resume_service.dart';
import '../models/opportunity.dart';
import '../models/opportunity_gap.dart';
import '../models/opportunity_match.dart';
import '../models/opportunity_requirement.dart';

/// Recommends the best next career opportunities based on the user's
/// Journey, Portfolio, Resume, Interview readiness, Career Profile,
/// Decision, and Identity.
///
/// This is NOT a job board. It is a recommendation engine.
/// No AI, no networking, no persistence, no duplicate business logic.
///
/// Future capabilities (architecture placeholders only):
///   - LinkedIn Jobs
///   - Indeed
///   - RemoteOK
///   - Wellfound
///   - Upwork
///   - Fiverr
///   - GitHub Issues
class OpportunityService {
  OpportunityService({Repository? repository})
    : repository = repository ?? const SampleRepository();

  final Repository repository;

  // ── Internal service accessors ──────────────────────────────────────

  InterviewService get _interviewService =>
      InterviewService(repository: repository);

  ResumeService get _resumeService => ResumeService(repository: repository);

  PortfolioService get _portfolioService =>
      PortfolioService(repository: repository);

  CareerService get _careerService => CareerService(repository: repository);

  DecisionService get _decisionService =>
      DecisionService(repository: repository);

  JourneyService get _journeyService => JourneyService(repository: repository);

  // ── Public API ──────────────────────────────────────────────────────

  /// Returns recommended opportunities derived from all module data.
  List<Opportunity> getRecommendedOpportunities() {
    final identity = repository.selectedIdentity;
    final portfolio = _portfolioService.buildPortfolio();
    final careerProfile = _careerService.buildProfile();
    final interviewProfile = _interviewService.buildProfile();
    final journey = _journeyService.getJourney();
    final topDecision = _decisionService.getDecision();
    final resume = _resumeService.buildResume();

    final userSkills = _collectUserSkills(portfolio, careerProfile);
    final readiness = _calculateOverallReadiness(
      careerProfile,
      interviewProfile,
      journey,
    );

    return _buildOpportunities(
      identity.title,
      resume.resumeType,
      userSkills,
      readiness,
      topDecision.title,
      careerProfile,
    );
  }

  /// Returns detailed match analysis for a specific opportunity.
  OpportunityMatch analyzeMatch(
    Opportunity opportunity,
    List<String> userSkills,
  ) {
    final requirements = opportunity.requiredSkills.map((skill) {
      final matched = userSkills.any(
        (s) => s.toLowerCase().contains(skill.toLowerCase()),
      );
      return OpportunityRequirement(
        skill: skill,
        isRequired: true,
        isMatched: matched,
      );
    }).toList();

    final matchedCount = requirements.where((r) => r.isMatched).length;
    final matchScore = requirements.isEmpty
        ? 0.0
        : matchedCount / requirements.length;

    final gaps = requirements
        .where((r) => !r.isMatched)
        .map(
          (r) => OpportunityGap(
            skill: r.skill,
            severity: 0.7,
            action: 'Study and practice ${r.skill} through missions.',
          ),
        )
        .toList();

    return OpportunityMatch(
      opportunityId: opportunity.id,
      matchScore: matchScore,
      requirements: requirements,
      gaps: gaps,
    );
  }

  // ── Internal helpers ───────────────────────────────────────────────

  /// Collects all user skills from portfolio and career profile.
  List<String> _collectUserSkills(dynamic portfolio, dynamic careerProfile) {
    final skills = <String>{
      ...portfolio.skills.map((s) => s.name),
      ...portfolio.strengthAreas,
      ...careerProfile.strengths,
    };
    return skills.toList();
  }

  /// Calculates overall readiness from career, interview, and journey data.
  double _calculateOverallReadiness(
    dynamic careerProfile,
    dynamic interviewProfile,
    dynamic journey,
  ) {
    // Weighted: career score (40%) + interview readiness (30%) +
    // journey completion (30%)
    return (careerProfile.careerScore * 0.40 +
            interviewProfile.interviewReadiness * 0.30 +
            journey.completion * 0.30)
        .clamp(0.0, 1.0);
  }

  /// Builds sample opportunities based on user data.
  List<Opportunity> _buildOpportunities(
    String identityTitle,
    ResumeType resumeType,
    List<String> userSkills,
    double readiness,
    String topDecision,
    dynamic careerProfile,
  ) {
    final opportunities = <Opportunity>[];
    final label = resumeType.label;

    // Primary opportunity — Full-time job matching the resume type
    opportunities.add(
      Opportunity(
        id: 'opp-ft-1',
        title: '$label — Entry Level',
        type: OpportunityType.fullTimeJob,
        matchScore: _calculateMatchScore(
          ['${label}Skills'],
          userSkills,
          readiness,
        ),
        requiredSkills: [
          '$label fundamentals',
          'Problem solving',
          'Communication',
          'Version control',
          'Testing',
        ],
        matchedSkills: userSkills.take(3).toList(),
        missingSkills: ['System Design', 'Advanced $label'],
        estimatedReadiness: careerProfile.jobReadiness,
        estimatedTimeline: '${careerProfile.estimatedWeeks} weeks',
        description:
            'An entry-level $label position that matches your current '
            'skill profile and career trajectory.',
        recommendedActions: [
          'Complete your current journey stage.',
          'Practice interview questions daily.',
          'Build a portfolio project showcasing your skills.',
        ],
      ),
    );

    // Secondary opportunity — Internship
    opportunities.add(
      Opportunity(
        id: 'opp-int-1',
        title: '$label Internship',
        type: OpportunityType.internship,
        matchScore:
            _calculateMatchScore(
              ['Learning', 'Fundamentals'],
              userSkills,
              readiness,
            ) *
            1.1,
        requiredSkills: [
          '$label basics',
          'Willingness to learn',
          'Team collaboration',
          'Problem solving',
        ],
        matchedSkills: userSkills.take(2).toList(),
        missingSkills: ['Professional experience'],
        estimatedReadiness: 'Building',
        estimatedTimeline: '8-12 weeks',
        description:
            'An internship opportunity to gain professional experience '
            'as a $label in a supportive environment.',
        recommendedActions: [
          'Focus on ${topDecision.toLowerCase()}.',
          'Complete at least 2 portfolio projects.',
          'Prepare for technical interviews.',
        ],
      ),
    );

    // Certification opportunity
    opportunities.add(
      Opportunity(
        id: 'opp-cert-1',
        title: '$label Certification',
        type: OpportunityType.certification,
        matchScore:
            _calculateMatchScore(
              ['Certification', 'Exam'],
              userSkills,
              readiness,
            ) *
            0.9,
        requiredSkills: [
          '$label proficiency',
          'Exam preparation',
          'Time management',
        ],
        matchedSkills: userSkills.take(2).toList(),
        missingSkills: ['Certification prep'],
        estimatedReadiness: 'Building',
        estimatedTimeline: '4-8 weeks',
        description:
            'Earn a professional $label certification to validate '
            'your skills and boost your resume.',
        recommendedActions: [
          'Research available certifications.',
          'Create a study schedule.',
          'Join a study group or community.',
        ],
      ),
    );

    return opportunities;
  }

  /// Calculates match score based on skill overlap and readiness.
  double _calculateMatchScore(
    List<String> requiredSkills,
    List<String> userSkills,
    double readiness,
  ) {
    final matched = requiredSkills.where((req) {
      return userSkills.any(
        (user) => user.toLowerCase().contains(req.toLowerCase()),
      );
    }).length;

    final skillScore = requiredSkills.isEmpty
        ? 0.0
        : matched / requiredSkills.length;

    return (skillScore * 0.60 + readiness * 0.40).clamp(0.0, 1.0);
  }
}
