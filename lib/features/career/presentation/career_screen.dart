import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_colors.dart';
import '../../../core/design/theme/phoenix_radius.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../features/growth_intelligence/models/forecast_prediction.dart';
import '../../../features/resume_intelligence/models/resume_intelligence_snapshot.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/phoenix_empty_state.dart';
import '../services/career_service.dart';
import '../widgets/career_actions_card.dart';
import '../widgets/career_header.dart';
import '../widgets/next_goal_card.dart';
import '../widgets/readiness_card.dart';
import '../widgets/skill_gap_card.dart';
import '../widgets/strengths_card.dart';

/// The Career Screen measures how close the user is to becoming employable.
///
/// All data sourced from [CareerEngine] snapshot. No SampleRepository.
///
/// Presentation only. No AI, no persistence, no networking.
class CareerScreen extends StatelessWidget {
  const CareerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final careerEngine = AppBootstrap.maybeCareerEngine;
    final snapshot = careerEngine?.snapshot;

    // Resume Intelligence Engine
    final resumeEngine = AppBootstrap.maybeResumeIntelligenceEngine;
    final resumeSnap = resumeEngine?.snapshot;

    // Growth Intelligence forecast
    final forecastEngine = AppBootstrap.maybeGrowthIntelligenceEngine;
    final forecastSnap = forecastEngine?.snapshot;
    final careerForecast = forecastSnap?.forecasts
        .where((f) => f.type.name == 'careerReadiness')
        .toList()
      ?..sort((a, b) => a.timelineDays.compareTo(b.timelineDays));

    if (snapshot == null || (snapshot.careerScore == 0.0 && snapshot.strengths.isEmpty)) {
      return PhoenixEmptyState(
        icon: Icons.work_outline,
        title: 'Career path not yet defined',
        message: 'Your career profile will appear here once you complete '
            'your identity profile and start learning.',
        positiveMessage: 'Define your goals to unlock career insights',
        primaryAction: _StartCareerJourneyButton(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CareerHeader(
            identityTitle: 'Career Path',
            careerScore: snapshot.careerScore,
            jobReadiness: snapshot.jobReadiness,
          ),
          const SizedBox(height: PhoenixSpacing.lg),
          ReadinessCard(
            portfolioProgress: snapshot.portfolioProgress,
            resumeProgress: snapshot.resumeProgress,
            interviewReadiness: snapshot.interviewReadiness,
            estimatedWeeks: snapshot.estimatedWeeks,
          ),
          const SizedBox(height: PhoenixSpacing.lg),
          NextGoalCard(
            goal: snapshot.nextGoal.isNotEmpty ? snapshot.nextGoal : 'Define your career goal',
            estimatedWeeks: snapshot.estimatedWeeks,
            onStartGoal: () => _onStartGoal(context),
          ),
          const SizedBox(height: PhoenixSpacing.lg),
          StrengthsCard(
            strengths: _buildStrengths(snapshot.strengths),
          ),
          const SizedBox(height: PhoenixSpacing.lg),
          SkillGapCard(
            gaps: _buildGaps(snapshot.skillGaps),
          ),
          const SizedBox(height: PhoenixSpacing.lg),
          // Career Forecast Section
          if (careerForecast != null && careerForecast.isNotEmpty) ...[
            _buildCareerForecastCard(context, careerForecast),
            const SizedBox(height: PhoenixSpacing.lg),
          ],
          // Resume Intelligence Section
          if (resumeSnap != null && resumeSnap.hasData) ...[
            _buildResumeIntelligenceSection(context, resumeSnap),
            const SizedBox(height: PhoenixSpacing.lg),
          ],

          CareerActionsCard(
            onWorkOnGoal: () => _onStartGoal(context),
            goalLabel: snapshot.jobReadiness == 'Ready'
                ? 'Prepare Applications'
                : 'Work on Next Goal',
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onJourney: () => Navigator.of(context).pushNamed(AppRoutes.journey),
            onProgress: () =>
                Navigator.of(context).pushNamed(AppRoutes.progress),
          ),
          const SizedBox(height: PhoenixSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildResumeIntelligenceSection(
    BuildContext context,
    ResumeIntelligenceSnapshot snap,
  ) {
    final theme = Theme.of(context);
    final healthColor = snap.isHealthy
        ? PhoenixColors.success
        : snap.needsUrgentAttention
            ? PhoenixColors.error
            : PhoenixColors.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            healthColor.withValues(alpha: 0.1),
            healthColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: PhoenixRadius.xlRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_rounded, size: 20, color: healthColor),
              const SizedBox(width: PhoenixSpacing.sm),
              Text('Resume Intelligence',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  snap.healthLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),

          // Score Grid
          Row(
            children: [
              _buildScoreItem(context, 'ATS Score', snap.atsScore, PhoenixColors.info),
              const SizedBox(width: PhoenixSpacing.md),
              _buildScoreItem(context, 'Tech', snap.technicalScore, PhoenixColors.primary),
              const SizedBox(width: PhoenixSpacing.md),
              _buildScoreItem(context, 'Projects', snap.projectScore, PhoenixColors.warning),
              const SizedBox(width: PhoenixSpacing.md),
              _buildScoreItem(context, 'Experience', snap.experienceScore, PhoenixColors.success),
            ],
          ),

          // Gaps
          if (snap.gaps.isNotEmpty) ...[
            const Divider(height: PhoenixSpacing.md),
            Text('Improvement Areas',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: PhoenixSpacing.sm),
            ...snap.gaps.take(3).map((gap) => Padding(
              padding: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 6, color: healthColor),
                  const SizedBox(width: PhoenixSpacing.sm),
                  Expanded(
                    child: Text(
                      gap.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          // Action
          if (snap.topRecommendation != null) ...[
            const SizedBox(height: PhoenixSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.resume),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(snap.topRecommendation!.description),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String label,
    double score,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            '${score.round()}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _onStartGoal(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.journey);
  }

  List<StrengthItem> _buildStrengths(List<String> strengths) {
    return strengths.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      final confidence = (1.0 - index * 0.15).clamp(0.4, 1.0);
      return StrengthItem(
        name: name,
        confidence: confidence,
        category: 'Knowledge',
      );
    }).toList();
  }

  List<GapItem> _buildGaps(List<String> gaps) {
    return gaps.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      final priority = index == 0 ? 'High' : index == 1 ? 'Medium' : 'Low';
      return GapItem(
        name: name,
        priority: priority,
        isCurrentStage: index == 0,
      );
    }).toList();
  }

  Widget _buildCareerForecastCard(
    BuildContext context,
    List<ForecastPrediction> forecasts,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PhoenixColors.info.withValues(alpha: 0.1),
            PhoenixColors.info.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: PhoenixRadius.xlRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 18, color: PhoenixColors.info),
              const SizedBox(width: PhoenixSpacing.sm),
              Text('Career Trajectory',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: PhoenixSpacing.md),
          ...forecasts.take(4).map((f) => Padding(
            padding: const EdgeInsets.only(bottom: PhoenixSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text('${f.timelineDays}d',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                ),
                Expanded(
                  child: Text(
                    '${f.predictedValue.toStringAsFixed(0)}${f.unit}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '+${f.improvement.toStringAsFixed(0)}${f.unit}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: PhoenixColors.success,
                    fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: PhoenixSpacing.sm),
                Text('${f.confidence.overall}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Reusable start-career-journey button for empty career state.
class _StartCareerJourneyButton extends StatelessWidget {
  const _StartCareerJourneyButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.journey),
      icon: const Icon(Icons.flag_rounded, size: 18),
      label: const Text('Define Career Goal'),
    );
  }
}
