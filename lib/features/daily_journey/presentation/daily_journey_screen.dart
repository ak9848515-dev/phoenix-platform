import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/spacing.dart';
import '../../decision_intelligence/models/decision_intelligence_snapshot.dart';
import '../models/daily_journey_snapshot.dart';
import '../widgets/daily_focus_card.dart';
import '../widgets/daily_mission_card.dart';
import '../widgets/daily_interview_card.dart';
import '../widgets/daily_opportunity_card.dart';
import '../widgets/daily_resume_card.dart';
import '../widgets/daily_portfolio_card.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/daily_timeline_card.dart';
import '../widgets/daily_quick_actions_card.dart';

/// The Daily Journey — the default landing experience after login.
///
/// NOT an engine. This is an ORCHESTRATION screen that reads from all
/// existing intelligence engine snapshots to answer:
/// "What should I do today?"
///
/// Architecture:
/// ```text
/// DailyBriefEngine + ContinueJourneyEngine + InterviewEngine + ...
///   ↓
/// DailyJourneyScreen  ← reads engine snapshots directly
///   ↓
/// DailyJourneySnapshot → Widgets
/// ```
class DailyJourneyScreen extends StatelessWidget {
  const DailyJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read all engine snapshots
    final briefEngine = AppBootstrap.maybeDailyBriefEngine;
    final journeyEngine = AppBootstrap.maybeContinueJourneyEngine;
    final growthEngine = AppBootstrap.maybeGrowthEngine;
    final interviewEngine = AppBootstrap.maybeInterviewIntelligenceEngine;
    final opportunityEngine = AppBootstrap.maybeOpportunityIntelligenceEngine;
    final resumeEngine = AppBootstrap.maybeResumeIntelligenceEngine;
    final portfolioEngine = AppBootstrap.maybePortfolioEngine;
    final orchestrator = AppBootstrap.maybeDecisionIntelligenceOrchestrator;

    final briefSnap = briefEngine?.snapshot;
    final journeySnap = journeyEngine?.snapshot;
    final growthSnap = growthEngine?.snapshot;
    final orchestratorSnap = orchestrator?.snapshot;

    if (briefSnap == null || journeySnap == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Journey')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Build orchestration snapshot
    final snapshot = DailyJourneySnapshot(
      dailyBrief: briefSnap,
      journey: journeySnap,
      growthSnapshot: growthSnap,
      interviewSnapshot: interviewEngine?.snapshot,
      opportunitySnapshot: opportunityEngine?.snapshot,
      resumeSnapshot: resumeEngine?.snapshot,
      portfolioSnapshot: portfolioEngine?.snapshot,
      hasData: briefSnap.hasBrief || journeySnap.hasResumePoint,
      lastUpdated: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Good ${_greeting()}, ${journeySnap.currentJourney.isNotEmpty ? journeySnap.currentJourney.split(" ").first : "Explorer"}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Dashboard',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. AI Daily Summary
            DailySummaryCard(snapshot: snapshot),
            const SizedBox(height: AppSpacing.lg),

            // 2. Today's Focus
            DailyFocusCard(snapshot: snapshot),
            const SizedBox(height: AppSpacing.lg),

            // 2.5 Decision Intelligence — Next Best Action
            if (orchestratorSnap != null && orchestratorSnap.hasData) ...[
              _buildOrchestratorInsightCard(context, orchestratorSnap),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 3. Today's Mission
            if (snapshot.todaysMission.isNotEmpty) ...[
              DailyMissionCard(snapshot: snapshot),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 4. Today's Timeline
            DailyTimelineCard(snapshot: snapshot),
            const SizedBox(height: AppSpacing.lg),

            // 5. Interview Practice
            if (snapshot.hasInterviewData) ...[
              DailyInterviewCard(snapshot: snapshot),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 6. Resume Improvement
            if (snapshot.hasResumeData) ...[
              DailyResumeCard(snapshot: snapshot),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 7. Portfolio Improvement
            DailyPortfolioCard(snapshot: snapshot),
            const SizedBox(height: AppSpacing.lg),

            // 8. Opportunity
            if (snapshot.hasOpportunityData) ...[
              DailyOpportunityCard(snapshot: snapshot),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 9. Quick Actions
            DailyQuickActionsCard(snapshot: snapshot),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildOrchestratorInsightCard(
    BuildContext context,
    DecisionIntelligenceSnapshot snap,
  ) {
    final theme = Theme.of(context);
    final top = snap.topPriority;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 20,
                    color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Decision Intelligence',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Top Priority',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(top.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            Text(top.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
            if (top.reasoning.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 14,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(top.reasoning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${top.score.estimatedMinutes} min',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.trending_up_rounded, size: 14,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${(top.score.careerImpact * 100).round()}% impact',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (top.route.isNotEmpty) {
                    Navigator.of(context).pushNamed(top.route);
                  }
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(top.category.isNotEmpty
                    ? 'Go to ${top.category}'
                    : 'Take Action'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
