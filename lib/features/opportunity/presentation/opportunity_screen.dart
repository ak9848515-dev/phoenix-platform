import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../../../shared/widgets/phoenix_error_state.dart';
import '../../../theme/spacing.dart';
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
/// Data sourced from OpportunityIntelligenceEngine snapshot only.
/// No SampleRepository. StatelessWidget.
class OpportunityScreen extends StatelessWidget {
  const OpportunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = AppBootstrap.maybeOpportunityIntelligenceEngine;
    final snap = engine?.snapshot;

    if (engine == null || snap == null) {
      return PhoenixErrorState(
        category: PhoenixErrorCategory.data,
        title: 'Opportunities unavailable',
        message: "We couldn't load your career opportunities right now. "
            'Please try again shortly.',
        actionLabel: 'Try Again',
        onAction: () => Navigator.of(context).pushReplacementNamed(
          AppRoutes.opportunity,
        ),
      );
    }

    if (!snap.hasData) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(PhoenixSpacing.lg),
        child: PhoenixEmptyState(
          icon: Icons.work_outline,
          title: 'No Opportunities Yet',
          message: 'Complete your Career Profile to discover matching opportunities.',
          primaryAction: FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.career),
            icon: const Icon(Icons.trending_up_outlined, size: 18),
            label: const Text('Complete Career Profile'),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpportunityHeader(
            identityTitle: snap.topOpportunity?.title ?? 'Opportunities',
            opportunityCount: snap.opportunityCount,
          ),
          const SizedBox(height: AppSpacing.lg),
          OpportunityStatisticsCard(
            opportunityCount: snap.opportunityCount,
            bestMatchScore: snap.bestMatchScore,
            overallReadiness: snap.overallReadiness,
          ),
          const SizedBox(height: AppSpacing.lg),
          ReadinessMatchCard(
            overallReadiness: snap.overallReadiness,
            bestMatchScore: snap.bestMatchScore,
            estimatedTimeline: snap.insight.estimatedTimeline.isNotEmpty
                ? snap.insight.estimatedTimeline
                : 'N/A',
          ),
          const SizedBox(height: AppSpacing.lg),
          RecommendedOpportunitiesCard(
            opportunities: snap.opportunities,
          ),
          const SizedBox(height: AppSpacing.lg),
          SkillGapCard(
            missingSkills: snap.analytics.topSkillGaps,
            gaps: snap.matches.isEmpty
                ? []
                : snap.matches.first.gaps,
          ),
          const SizedBox(height: AppSpacing.lg),
          ActionPlanCard(opportunities: snap.opportunities),
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
