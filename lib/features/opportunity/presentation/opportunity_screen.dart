import 'package:flutter/material.dart';

import '../../../core/sample_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../services/opportunity_service.dart';
import '../widgets/action_plan_card.dart';
import '../widgets/opportunity_actions_card.dart';
import '../widgets/opportunity_header.dart';
import '../widgets/opportunity_statistics_card.dart';
import '../widgets/readiness_match_card.dart';
import '../widgets/recommended_opportunities_card.dart';
import '../widgets/skill_gap_card.dart';

/// The Opportunity Intelligence screen recommends the best next career
/// opportunities based on the user's Journey, Portfolio, Resume,
/// Interview readiness, Career Profile, Decision, and Identity.
///
/// This is NOT a job board. It is a recommendation engine.
/// No AI, no networking, no persistence.
///
/// Presentation only. StatelessWidget.
class OpportunityScreen extends StatelessWidget {
  const OpportunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final opportunityService = OpportunityService(repository: repository);
    final opportunities = opportunityService.getRecommendedOpportunities();

    final bestMatch = opportunities.isEmpty
        ? 0.0
        : opportunities
              .map((o) => o.matchScore)
              .reduce((a, b) => a > b ? a : b);

    // Collect all missing skills for the gap analysis
    final allMissingSkills = <String>{};
    for (final opp in opportunities) {
      allMissingSkills.addAll(opp.missingSkills);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpportunityHeader(
            identityTitle: repository.selectedIdentity.title,
            opportunityCount: opportunities.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          OpportunityStatisticsCard(
            opportunityCount: opportunities.length,
            bestMatchScore: bestMatch,
            overallReadiness: opportunities.first.matchScore,
          ),
          const SizedBox(height: AppSpacing.lg),
          ReadinessMatchCard(
            overallReadiness: opportunities.first.matchScore,
            bestMatchScore: bestMatch,
            estimatedTimeline: opportunities.isNotEmpty
                ? opportunities.first.estimatedTimeline
                : 'N/A',
          ),
          const SizedBox(height: AppSpacing.lg),
          RecommendedOpportunitiesCard(opportunities: opportunities),
          const SizedBox(height: AppSpacing.lg),
          SkillGapCard(
            missingSkills: allMissingSkills.toList(),
            gaps: const [],
          ),
          const SizedBox(height: AppSpacing.lg),
          ActionPlanCard(opportunities: opportunities),
          const SizedBox(height: AppSpacing.lg),
          OpportunityActionsCard(
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onResume: () => Navigator.of(context).pushNamed(AppRoutes.resume),
            onInterview: () =>
                Navigator.of(context).pushNamed(AppRoutes.interview),
            onCareer: () => Navigator.of(context).pushNamed(AppRoutes.career),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
