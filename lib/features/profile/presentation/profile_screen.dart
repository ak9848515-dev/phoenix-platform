import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../core/design/theme/phoenix_spacing.dart';
import '../../../core/sample_repository.dart';
import '../../../routes/app_routes.dart';
import '../../career/services/career_service.dart';
import '../../interview/services/interview_service.dart';
import '../../knowledge_dna/knowledge_dna_service.dart';
import '../../mission_engine/mission_service.dart';
import '../../opportunity/services/opportunity_service.dart';
import '../../portfolio/services/portfolio_service.dart';
import '../../progress_engine/progress_service.dart';
import '../../recommendation/services/recommendation_service.dart';
import '../../resume/services/resume_service.dart';
import '../widgets/career_readiness_card.dart';
import '../widgets/growth_summary_card.dart';
import '../widgets/knowledge_skills_card.dart';
import '../widgets/portfolio_snapshot_card.dart';
import '../widgets/preferences_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/resume_snapshot_card.dart';

/// The premium Profile Experience for Phoenix OS.
///
/// Presentation-only. All data comes from existing services.
/// No business logic, no calculations.
///
/// Sections:
/// 1. Profile Header — avatar, identity, journey stage, level badge
/// 2. Growth Summary — XP, Level, Streak, Missions, Progress
/// 3. Knowledge & Skills — Knowledge DNA, strengths, improvements
/// 4. Portfolio Snapshot — projects, score, featured project
/// 5. Resume Snapshot — score, completion, highlights
/// 6. Career Readiness — interview, career, timeline, next goal
/// 7. Preferences — navigation to settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final userStateService = AppBootstrap.maybeUserStateService;
    final progressSummary = ProgressService(
      repository: repository,
      userStateService: userStateService,
    ).buildSummary();
    final knowledgeAnalysis = KnowledgeDNAService(
      repository: repository,
    ).buildAnalysis();
    final portfolio = PortfolioService(
      repository: repository,
    ).buildPortfolio();
    final resume = ResumeService(
      repository: repository,
    ).buildResume();
    final careerProfile = CareerService(
      repository: repository,
    ).buildProfile();
    final interviewProfile = InterviewService(
      repository: repository,
    ).buildProfile();
    final opportunityService = OpportunityService(
      repository: repository,
    );
    final opportunities = opportunityService.getRecommendedOpportunities();
    final topRecommendation = RecommendationService(
      repository: repository,
    ).getTodaysFocus();
    final missionService = MissionService(
      repository: repository,
      userStateService: userStateService,
    );
    final missionProgress = missionService.buildProgress();

    // Read identity and journey from UserStateService when available,
    // fall back to SampleRepository for backward compatibility.
    final identity = userStateService?.identity ?? repository.selectedIdentity;
    final journey = userStateService?.journey ?? repository.journey;
    final stage = userStateService?.currentJourneyStage ?? repository.currentJourneyStage;

    final totalMissions =
        missionProgress.dailyMissions.length +
        missionProgress.weeklyMissions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Profile Header ──────────────────────────────────────
          ProfileHeader(
            identityTitle: identity.title,
            journeyStage: stage.title,
            currentLevel: progressSummary.level,
            journeyCompletion: journey.completion,
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 2. Growth Summary ──────────────────────────────────────
          GrowthSummaryCard(
            totalXp: progressSummary.totalXp,
            currentLevel: progressSummary.level,
            currentStreak: progressSummary.streaks.daily,
            completedMissions: missionProgress.completedCount,
            totalMissions: totalMissions,
            overallProgress: progressSummary.completionPercentage,
            onXpTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'xp'},
            ),
            onLevelTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'level'},
            ),
            onStreakTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'streak'},
            ),
            onMissionsTap: () => Navigator.of(context).pushNamed(
              AppRoutes.missionCenter,
            ),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 3. Knowledge & Skills ──────────────────────────────────
          KnowledgeSkillsCard(
            knowledgeScore: knowledgeAnalysis.knowledgeScore,
            confidenceScore: knowledgeAnalysis.confidenceScore,
            retentionScore: knowledgeAnalysis.retentionScore,
            skillStrengths: knowledgeAnalysis.skillStrengths,
            skillWeaknesses: knowledgeAnalysis.skillWeaknesses,
            summary: knowledgeAnalysis.summary,
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 4. Portfolio Snapshot ──────────────────────────────────
          PortfolioSnapshotCard(
            portfolioScore: portfolio.portfolioScore,
            projectCount: portfolio.projectCount,
            achievementCount: portfolio.achievementCount,
            technologyCount: portfolio.technologyCount,
            featuredProjectTitle:
                portfolio.featuredProjects.isNotEmpty
                    ? portfolio.featuredProjects.first.title
                    : 'No projects yet',
            onViewPortfolio: () =>
                Navigator.of(context).pushNamed(AppRoutes.portfolio),
            onProjectsTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.portfolio),
            onAchievementsTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'achievements'},
            ),
            onTechnologiesTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.knowledge),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 5. Resume Snapshot ─────────────────────────────────────
          ResumeSnapshotCard(
            resumeScore: resume.resumeScore,
            skillCount: resume.skillCount,
            projectCount: resume.projectCount,
            careerHighlights: resume.careerHighlights,
            lastUpdated: resume.generatedAt,
            isComplete: resume.resumeScore >= 0.7,
            onViewResume: () =>
                Navigator.of(context).pushNamed(AppRoutes.resume),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 6. Career Readiness ────────────────────────────────────
          CareerReadinessCard(
            jobReadiness: careerProfile.jobReadiness,
            careerScore: careerProfile.careerScore,
            interviewReadiness: interviewProfile.interviewReadiness,
            estimatedWeeks: careerProfile.estimatedWeeks,
            nextGoal: careerProfile.nextGoal,
            opportunityReadiness:
                opportunities.isNotEmpty
                    ? opportunities.first.matchScore
                    : null,
            careerRecommendation: topRecommendation?.title,
            onViewCareer: () =>
                Navigator.of(context).pushNamed(AppRoutes.career),
            onCareerTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.career),
            onInterviewTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.career),
            onTimelineTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'streak'},
            ),
          ),
          SizedBox(height: PhoenixSpacing.lg),

          // ── 7. Preferences ────────────────────────────────────────
          PreferencesCard(
            onTheme: () =>
                Navigator.of(context).pushNamed(AppRoutes.settingsTheme),
            onNotifications: () =>
                Navigator.of(context).pushNamed(AppRoutes.settingsNotifications),
            onSync: () =>
                Navigator.of(context).pushNamed(AppRoutes.settingsSync),
            onPrivacy: () =>
                Navigator.of(context).pushNamed(AppRoutes.settingsPrivacy),
          ),
          SizedBox(height: PhoenixSpacing.xxl),
        ],
      ),
    );
  }
}
