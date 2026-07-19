import 'package:flutter/material.dart';

import '../features/content_generation/presentation/content_generation_hub_screen.dart';
import '../features/content_generation/presentation/content_library_screen.dart';
import '../features/content_generation/presentation/generate_course_screen.dart';
import '../features/content_generation/presentation/generate_project_screen.dart';
import '../features/content_generation/presentation/generate_enhancement_screen.dart';
import '../features/academy/presentation/academy_screen.dart';
import '../features/academy/presentation/lesson_detail_screen.dart';
import '../features/academy/presentation/learning_path_screen.dart';
import '../features/career/presentation/career_screen.dart';
import '../features/daily_focus/presentation/daily_focus_screen.dart';
import '../features/dashboard/command_center_screen.dart';
import '../features/identity/presentation/identity_selection_screen.dart';
import '../features/identity/presentation/identity_setup_screen.dart';
import '../features/journey/presentation/journey_screen.dart';
import '../features/memory/presentation/memory_screen.dart';
import '../features/recommendation/presentation/recommendation_screen.dart';
import '../features/knowledge_dna/presentation/knowledge_dna_screen.dart';
import '../features/mission_center/mission_center_screen.dart';
import '../features/portfolio/presentation/portfolio_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/interview/presentation/interview_screen.dart';
import '../features/interview/presentation/mock_interview_session_screen.dart';
import '../features/daily_journey/presentation/daily_journey_screen.dart';
import '../features/opportunity/presentation/opportunity_screen.dart';
import '../features/marketplace/presentation/marketplace_screen.dart';
import '../features/resume/presentation/resume_screen.dart';
import '../features/ai/presentation/ai_screen.dart';
import '../features/habit/presentation/habit_create_screen.dart';
import '../features/habit/presentation/habit_dashboard_screen.dart';
import '../features/habit/presentation/habit_detail_screen.dart';
import '../features/memory_graph/presentation/entity_detail_screen.dart';
import '../features/personal_knowledge/presentation/goal_map_screen.dart';
import '../features/personal_knowledge/presentation/knowledge_dashboard_screen.dart';
import '../features/personal_knowledge/presentation/knowledge_search_screen.dart';
import '../features/personal_knowledge/presentation/skills_map_screen.dart';
import '../features/memory_graph/presentation/graph_explorer_screen.dart';
import '../features/memory_graph/presentation/memory_dashboard_screen.dart';
import '../features/memory_graph/presentation/memory_search_screen.dart';
import '../features/memory_graph/models/memory_entity.dart';
import '../features/memory_graph/models/entity_type.dart';
import '../features/timeline/presentation/milestone_screen.dart';
import '../features/timeline/presentation/timeline_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/search/presentation/global_search_screen.dart';
import '../features/settings/presentation/ai_providers_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/notification_center/presentation/notification_center_screen.dart';
import '../shared/widgets/phoenix_shell.dart';
import 'app_routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dashboard:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Command Center',
            body: CommandCenterScreen(),
          ),
        );
      case AppRoutes.missionCenter:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 1,
            title: 'Mission Center',
            body: MissionCenterScreen(),
          ),
        );
      case AppRoutes.knowledgeDna:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Knowledge DNA',
            body: KnowledgeDNAScreen(),
          ),
        );
      case AppRoutes.academy:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 2,
            title: 'Academy',
            body: AcademyScreen(),
          ),
        );
      case AppRoutes.academyLesson:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) {
            final args =
                settings.arguments as Map<String, dynamic>?;
            final pathId = args?['pathId'] as String?;
            if (pathId != null && args?['lessonId'] == null) {
              // Path detail view (no lessonId = path overview)
              return const PhoenixShell(
                selectedIndex: 2,
                title: 'Learning Path',
                body: LearningPathScreen(),
              );
            }
            // Lesson detail view
            return const LessonDetailScreen();
          },
        );
      case AppRoutes.progress:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 3,
            title: 'Progress',
            body: ProgressScreen(),
          ),
        );
      case AppRoutes.recommendation:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Recommendations',
            body: RecommendationScreen(),
          ),
        );
      case AppRoutes.memory:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Memory',
            body: MemoryScreen(),
          ),
        );
      case AppRoutes.journey:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Journey',
            body: JourneyScreen(),
          ),
        );
      case AppRoutes.dailyFocus:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Daily Focus',
            body: DailyFocusScreen(),
          ),
        );
      case AppRoutes.career:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Career Readiness',
            body: CareerScreen(),
          ),
        );
      case AppRoutes.portfolio:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Portfolio',
            body: PortfolioScreen(),
          ),
        );
      case AppRoutes.resume:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Resume',
            body: ResumeScreen(),
          ),
        );
      case AppRoutes.interview:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Interview Prep',
            body: InterviewScreen(),
          ),
        );
      case AppRoutes.interviewSession:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const MockInterviewSessionScreen(),
        );
      case AppRoutes.opportunity:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Opportunities',
            body: OpportunityScreen(),
          ),
        );
      case AppRoutes.marketplace:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Plugin Marketplace',
            body: MarketplaceScreen(),
          ),
        );
      case AppRoutes.identitySetup:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const IdentitySetupScreen(),
        );
      case AppRoutes.identity:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Identity',
            body: IdentitySelectionScreen(),
          ),
        );
      case AppRoutes.ai:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 2,
            title: 'AI Mentor',
            body: AIScreen(),
          ),
        );
      case AppRoutes.memoryGraph:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Memory Graph',
            body: MemoryGraphDashboardScreen(),
          ),
        );
      case AppRoutes.memoryGraphEntity:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) {
            final args = settings.arguments as Map<String, dynamic>?;
            return EntityDetailScreen(
              entity: MemoryEntity(
                id: args?['entityId'] as String? ?? '',
                type: EntityType.custom,
                title: args?['title'] as String? ?? '',
                sourceEngine: args?['sourceEngine'] as String? ?? '',
              ),
            );
          },
        );
      case AppRoutes.memoryGraphSearch:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const MemorySearchScreen(),
        );
      case AppRoutes.memoryGraphExplorer:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const GraphExplorerScreen(),
        );
      case AppRoutes.habits:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Habits',
            body: HabitDashboardScreen(),
          ),
        );
      case AppRoutes.habitDetail:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => HabitDetailScreen(
            habitId: settings.arguments as String? ?? '',
          ),
        );
      case AppRoutes.habitCreate:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const HabitCreateScreen(),
        );
      case AppRoutes.timeline:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Timeline',
            body: TimelineScreen(),
          ),
        );
      case AppRoutes.timelineMilestones:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Milestones',
            body: MilestoneScreen(),
          ),
        );
      case AppRoutes.knowledge:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Knowledge',
            body: KnowledgeDashboardScreen(),
          ),
        );
      case AppRoutes.knowledgeSkills:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const SkillsMapScreen(),
        );
      case AppRoutes.knowledgeGoals:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const GoalMapScreen(),
        );
      case AppRoutes.knowledgeSearch:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const KnowledgeSearchScreen(),
        );
      case AppRoutes.authGate:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const AuthGate(),
        );
      case AppRoutes.splash:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case AppRoutes.login:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Notifications',
            body: NotificationCenterScreen(),
          ),
        );
      case AppRoutes.dailyJourney:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Daily Journey',
            body: DailyJourneyScreen(),
          ),
        );
      case AppRoutes.onboarding:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 4,
            title: 'Settings',
            body: SettingsScreen(),
          ),
        );
      case AppRoutes.aiProviders:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const AIProvidersScreen(),
        );

      case AppRoutes.globalSearch:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const GlobalSearchScreen(),
        );
      // ── Content Generation Routes ──────────────────────────────
      case AppRoutes.contentHub:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Content Generator',
            body: ContentGenerationHubScreen(),
          ),
        );
      case AppRoutes.contentLibrary:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 0,
            title: 'Content Library',
            body: ContentLibraryScreen(),
          ),
        );
      case AppRoutes.generateCourse:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => PhoenixShell(
            selectedIndex: 0,
            title: 'Generate Course',
            body: const GenerateCourseScreen(),
          ),
        );
      case AppRoutes.generateProject:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => PhoenixShell(
            selectedIndex: 0,
            title: 'Generate Project',
            body: const GenerateProjectScreen(),
          ),
        );
      case AppRoutes.generatePortfolioEnhancement:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => PhoenixShell(
            selectedIndex: 0,
            title: 'Portfolio Enhancement',
            body: GenerateEnhancementScreen.portfolioEnhancement(),
          ),
        );
      case AppRoutes.generateResumeEnhancement:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => PhoenixShell(
            selectedIndex: 0,
            title: 'Resume Enhancement',
            body: GenerateEnhancementScreen.resumeEnhancement(),
          ),
        );
      case AppRoutes.generateInterviewQuestions:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => PhoenixShell(
            selectedIndex: 0,
            title: 'Interview Questions',
            body: GenerateEnhancementScreen.interviewQuestions(),
          ),
        );
      case AppRoutes.profile:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 4,
            title: 'Profile',
            body: ProfileScreen(),
          ),
        );
      default:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const PhoenixShell(
            selectedIndex: 1,
            title: 'Mission Center',
            body: MissionCenterScreen(),
          ),
        );
    }
  }
}
