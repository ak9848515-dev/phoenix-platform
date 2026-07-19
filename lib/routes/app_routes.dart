class AppRoutes {
  AppRoutes._();

  static const String missionCenter = '/';
  static const String dashboard = '/dashboard';
  static const String knowledgeDna = '/knowledge-dna';
  static const String academy = '/academy';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String identity = '/identity';
  static const String memory = '/memory';
  static const String recommendation = '/recommendation';
  static const String journey = '/journey';
  static const String dailyFocus = '/daily-focus';
  static const String career = '/career';
  static const String portfolio = '/portfolio';
  static const String resume = '/resume';
  static const String interview = '/interview';

  /// Mock interview session screen.
  static const String interviewSession = '/interview/session';

  static const String opportunity = '/opportunity';
  static const String marketplace = '/marketplace';
  static const String ai = '/ai';

  /// Academy lesson detail screen.
  static const String academyLesson = '/academy/lesson';

  /// Life Timeline screen.
  static const String timeline = '/timeline';

  /// Timeline milestones view.
  static const String timelineMilestones = '/timeline/milestones';

  /// Habits dashboard.
  static const String habits = '/habits';

  /// Habit detail.
  static const String habitDetail = '/habits/detail';

  /// Create habit.
  static const String habitCreate = '/habits/create';

  /// Memory Graph dashboard.
  static const String memoryGraph = '/memory-graph';

  /// Memory Graph entity detail.
  static const String memoryGraphEntity = '/memory-graph/entity';

  /// Memory Graph search.
  static const String memoryGraphSearch = '/memory-graph/search';

  /// Memory Graph explorer.
  static const String memoryGraphExplorer = '/memory-graph/explorer';

  /// Personal Knowledge dashboard.
  static const String knowledge = '/knowledge';

  /// Knowledge skills map.
  static const String knowledgeSkills = '/knowledge/skills';

  /// Knowledge goal map.
  static const String knowledgeGoals = '/knowledge/goals';

  /// Knowledge search.
  static const String knowledgeSearch = '/knowledge/search';

  /// Global search.
  static const String globalSearch = '/search';

  /// Auth gate — root-level authentication routing.
  static const String authGate = '/auth-gate';

  /// Splash screen.
  static const String splash = '/splash';

  /// Login screen.
  static const String login = '/login';

  /// Settings screen.
  static const String settings = '/settings';

  /// AI Providers list screen.
  static const String aiProviders = '/settings/ai-providers';



  // ── Content Generation Routes ──────────────────────────────────

  /// Content Generation Hub — main landing page.
  static const String contentHub = '/content';

  /// Content Library — browse generated content.
  static const String contentLibrary = '/content/library';

  /// Generate Course / Learning Path.
  static const String generateCourse = '/content/generate/course';

  /// Generate Portfolio Project.
  static const String generateProject = '/content/generate/project';

  /// Generate Portfolio Enhancement.
  static const String generatePortfolioEnhancement = '/content/generate/portfolio-enhancement';

  /// Generate Resume Enhancement.
  static const String generateResumeEnhancement = '/content/generate/resume-enhancement';

  /// Generate Interview Questions.
  static const String generateInterviewQuestions = '/content/generate/interview-questions';

  /// Notification Center screen.
  static const String notifications = '/notifications';

  /// Onboarding flow (first-time experience).
  static const String onboarding = '/onboarding';

  /// Daily Journey — the default landing experience after login.
  static const String dailyJourney = '/daily-journey';

  /// Identity Setup — mandatory first-login flow after authentication.
  static const String identitySetup = '/identity-setup';
}

