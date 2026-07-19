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

/// Recommends learning paths based on knowledge interconnections,
/// skill gaps, and career alignment.
///
/// Analyzes the knowledge-growth relationship to find high-ROI areas:
/// - Weak skills that are prerequisites for stronger skills
/// - Knowledge areas with high career impact but low current score
/// - Adjacent topics to mastered skills (easy wins)
/// - Career-aligned skill gaps
class KnowledgeRelationshipRule extends RecommendationRule {
  const KnowledgeRelationshipRule();

  @override
  String get name => 'KnowledgeRelationship';

  @override
  int get priority => 3;

  @override
  RecommendationResult? evaluate({
    required IdentitySnapshot identitySnapshot,
    required GrowthSnapshot growthSnapshot,
    required MissionSnapshot missionSnapshot,
    required UserState userState,
  }) {
    final knowledgeScore = growthSnapshot.knowledge.score;
    final skillsScore = growthSnapshot.skills.score;
    final careerScore = growthSnapshot.career.score;
    final portfolioScore = growthSnapshot.portfolio.score;

    // 1. Find the highest-impact knowledge gap
    final dimensions = <String, double>{
      'knowledge': knowledgeScore,
      'skills': skillsScore,
      'career': careerScore,
      'portfolio': portfolioScore,
    };

    final sorted = dimensions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final weakest = sorted.first;
    final weakestScore = weakest.value;

    // Only recommend if there's a meaningful gap
    if (weakestScore >= 0.5) return null;

    // 2. Determine the interconnection: what does this gap affect?
    String title;
    String description;
    double impact;
    RecommendationCategory category;
    String template;
    double urgency;
    double confidence;

    switch (weakest.key) {
      case 'knowledge':
        title = 'Build Knowledge Foundation';
        description =
            'Knowledge score is ${(knowledgeScore * 100).round()}%. '
            'Strengthening knowledge directly improves skills (+${((skillsScore - knowledgeScore) * 100).round()}% gap) '
            'and career readiness.';
        category = RecommendationCategory.learning;
        impact = 0.4 * (1.0 - knowledgeScore);
        template = 'KnowledgeGap';
        urgency = 0.6;
        confidence = 0.75;
        break;

      case 'skills':
        title = 'Apply Knowledge as Skills';
        description =
            'Skills score (${(skillsScore * 100).round()}%) trails knowledge '
            '(${(knowledgeScore * 100).round()}%). Bridge this gap by '
            'practicing what you\'ve learned through projects and exercises.';
        category = RecommendationCategory.learning;
        impact = 0.4 * (1.0 - skillsScore);
        template = 'SkillsGap';
        urgency = 0.7;
        confidence = 0.8;
        break;

      case 'career':
        title = 'Align Growth with Career Goals';
        description =
            'Career score (${(careerScore * 100).round()}%) is your weakest '
            'dimension. Focus on career-aligned learning to maximize ROI '
            'on your growth effort.';
        category = RecommendationCategory.career;
        impact = 0.5 * (1.0 - careerScore);
        template = 'CareerAlignment';
        urgency = 0.7;
        confidence = 0.8;
        break;

      case 'portfolio':
        title = 'Portfolio Needs Attention';
        description =
            'Portfolio score (${(portfolioScore * 100).round()}%) lags behind '
            'your knowledge (${(knowledgeScore * 100).round()}%). Convert '
            'knowledge into portfolio projects for career impact.';
        category = RecommendationCategory.portfolio;
        impact = 0.5 * (1.0 - portfolioScore);
        template = 'PortfolioGap';
        urgency = 0.6;
        confidence = 0.75;
        break;

      default:
        return null;
    }

    // 3. Prerequisites: identify what to master first
    // For knowledge and skills, suggest foundational topics
    final hasPrerequisites = knowledgeScore < 0.3 || skillsScore < 0.3;

    // 4. Career impact assessment
    final careerImpact = weakest.key == 'career' || weakest.key == 'portfolio'
        ? 0.5
        : 0.3;

    return RecommendationResult(
      id: 'rec-${weakest.key}-relationship',
      title: title,
      description: description +
          (hasPrerequisites
              ? '\n\nStart with foundational topics before advancing.'
              : ''),
      category: category,
      score: RecommendationScore(
        priority: (8 - (weakestScore * 5).round()).clamp(4, 9),
        urgency: RecommendationUrgency(
          score: urgency * (1.0 - weakestScore),
          reason: '$weakest dimension is significantly behind other areas.',
          isTimeSensitive: weakestScore < 0.3,
        ),
        confidence: confidence,
        estimatedBenefit: impact,
        priorityWeight: 1.2,
      ),
      reason: RecommendationReason(
        why: 'Your ${weakest.key} score (${(weakestScore * 100).round()}%) is '
            'your biggest growth opportunity.',
        whyNow: 'Improving this area unlocks progress in all other dimensions.',
        improvement: 'Balanced growth across all dimensions accelerates overall progress.',
        unlock: 'Advanced opportunities in career, portfolio, and expertise.',
        template: template,
      ),
      estimatedDuration: weakestScore < 0.3 ? 15 : 25,
      learningImpact: weakest.key == 'knowledge' || weakest.key == 'skills'
          ? 0.5
          : 0.3,
      growthImpact: 0.4,
      careerImpact: careerImpact,
      ruleName: name,
    );
  }
}
