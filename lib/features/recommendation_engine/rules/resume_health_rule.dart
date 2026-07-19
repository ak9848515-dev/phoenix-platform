import 'package:phoenix_platform/features/growth_index/models/growth_snapshot.dart';
import 'package:phoenix_platform/features/identity/models/identity_snapshot.dart';
import 'package:phoenix_platform/features/mission_intelligence/models/mission_snapshot.dart';
import 'package:phoenix_platform/features/user_state/models/user_state.dart';

import '../models/recommendation_category.dart';
import '../models/recommendation_reason.dart';
import '../models/recommendation_result.dart';
import '../models/recommendation_score.dart';
import '../models/recommendation_urgency.dart';
import 'recommendation_rules.dart';

/// Recommends actions to improve resume health and career readiness.
///
/// Uses growth snapshot career, portfolio, and interview dimensions
/// to recommend the highest-impact improvement area.
class ResumeHealthRule extends RecommendationRule {
  const ResumeHealthRule();

  @override
  String get name => 'ResumeHealth';

  @override
  int get priority => 3;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    // Get career-related scores
    final careerScore = growthSnapshot.career.score;
    final portfolioScore = growthSnapshot.portfolio.score;
    final interviewScore = growthSnapshot.interview.score;
    final projectScore = growthSnapshot.projects.score;
    final skillScore = growthSnapshot.skills.score;

    // Find the weakest career dimension
    final dimensions = {
      'career': careerScore,
      'portfolio': portfolioScore,
      'interview': interviewScore,
      'projects': projectScore,
      'skills': skillScore,
    };

    final sorted = dimensions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final weakest = sorted.first;
    final weakestScore = weakest.value;

    // Only recommend if there's a clear weakness
    if (weakestScore >= 0.5) return null;

    // Build recommendation based on the weakest dimension
    switch (weakest.key) {
      case 'career':
        return RecommendationResult(
          id: 'rec-resume-career',
          title: 'Define Your Career Path',
          description:
              'Your career readiness is ${(careerScore * 100).round()}%. '
              'Define your target role and start building aligned skills.',
          category: RecommendationCategory.career,
          score: RecommendationScore(
            priority: 8,
            urgency: const RecommendationUrgency(
              score: 0.7,
              reason: 'Career clarity drives focused growth.',
            ),
            confidence: 0.8,
            estimatedBenefit: 0.5,
            priorityWeight: 1.2,
          ),
          reason: const RecommendationReason(
            why: 'A clear career goal focuses your learning and growth.',
            whyNow: 'Early definition leads to faster career progression.',
            improvement: 'All growth dimensions become more targeted.',
            unlock: 'Career missions, skill gap analysis, targeted recommendations.',
            template: 'ResumeHealth',
          ),
          estimatedDuration: 15,
          careerImpact: 0.5,
          growthImpact: 0.3,
          ruleName: name,
        );

      case 'portfolio':
        return RecommendationResult(
          id: 'rec-resume-portfolio',
          title: 'Strengthen Your Portfolio',
          description:
              'Your portfolio score is ${(portfolioScore * 100).round()}%. '
              'Adding projects with measurable outcomes will significantly '
              'improve your career prospects.',
          category: RecommendationCategory.portfolio,
          score: RecommendationScore(
            priority: 8,
            urgency: const RecommendationUrgency(
              score: 0.6,
              reason: 'Portfolio is critical for career opportunities.',
            ),
            confidence: 0.8,
            estimatedBenefit: 0.5,
            priorityWeight: 1.2,
          ),
          reason: const RecommendationReason(
            why: 'Portfolio quality directly impacts job prospects.',
            whyNow: 'Projects are the strongest signal of capability.',
            improvement: 'Career readiness and opportunity match improve.',
            unlock: 'Portfolio reviews, referrals, interview opportunities.',
            template: 'ResumeHealth',
          ),
          estimatedDuration: 30,
          careerImpact: 0.4,
          growthImpact: 0.3,
          ruleName: name,
        );

      case 'interview':
        return RecommendationResult(
          id: 'rec-resume-interview',
          title: 'Prepare for Interviews',
          description:
              'Your interview readiness is ${(interviewScore * 100).round()}%. '
              'Regular practice builds confidence and improves performance.',
          category: RecommendationCategory.interview,
          score: RecommendationScore(
            priority: 7,
            urgency: const RecommendationUrgency(
              score: 0.6,
              reason: 'Interview readiness affects career outcomes.',
            ),
            confidence: 0.75,
            estimatedBenefit: 0.4,
            priorityWeight: 1.1,
          ),
          reason: const RecommendationReason(
            why: 'Interview skills are essential for career advancement.',
            whyNow: 'Consistent practice dramatically improves performance.',
            improvement: 'Confidence, clarity, and offer rates improve.',
            unlock: 'Mock interviews, feedback, real interview readiness.',
            template: 'ResumeHealth',
          ),
          estimatedDuration: 20,
          careerImpact: 0.4,
          learningImpact: 0.2,
          growthImpact: 0.3,
          ruleName: name,
        );

      case 'projects':
        return RecommendationResult(
          id: 'rec-resume-projects',
          title: 'Complete a Project',
          description:
              'Your project score is ${(projectScore * 100).round()}%. '
              'Completing projects demonstrates practical ability.',
          category: RecommendationCategory.portfolio,
          score: RecommendationScore(
            priority: 7,
            urgency: const RecommendationUrgency(
              score: 0.5,
              reason: 'Projects demonstrate real capability.',
            ),
            confidence: 0.7,
            estimatedBenefit: 0.4,
            priorityWeight: 1.0,
          ),
          reason: const RecommendationReason(
            why: 'Projects bridge the gap between knowledge and skill.',
            whyNow: 'Every completed project adds to your evidence base.',
            improvement: 'Portfolio depth and career readiness improve.',
            unlock: 'Project showcases, experience section content.',
            template: 'ResumeHealth',
          ),
          estimatedDuration: 45,
          careerImpact: 0.4,
          growthImpact: 0.3,
          ruleName: name,
        );

      case 'skills':
        return RecommendationResult(
          id: 'rec-resume-skills',
          title: 'Develop In-Demand Skills',
          description:
              'Your skills score is ${(skillScore * 100).round()}%. '
              'Focus on building skills aligned with your career goals.',
          category: RecommendationCategory.learning,
          score: RecommendationScore(
            priority: 7,
            urgency: const RecommendationUrgency(
              score: 0.5,
              reason: 'Skills are the foundation of career growth.',
            ),
            confidence: 0.7,
            estimatedBenefit: 0.4,
            priorityWeight: 1.0,
          ),
          reason: const RecommendationReason(
            why: 'Skills directly impact career opportunities.',
            whyNow: 'Building skills now prepares you for future roles.',
            improvement: 'Career readiness and confidence improve.',
            unlock: 'Advanced projects, certifications, specialized roles.',
            template: 'ResumeHealth',
          ),
          estimatedDuration: 20,
          learningImpact: 0.4,
          careerImpact: 0.3,
          growthImpact: 0.3,
          ruleName: name,
        );

      default:
        return null;
    }
  }
}
