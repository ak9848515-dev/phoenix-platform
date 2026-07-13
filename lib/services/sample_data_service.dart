import 'package:flutter/material.dart';

import '../features/identity/models/identity.dart';
import '../features/journey/models/journey.dart';
import '../features/journey/models/journey_stage.dart';
import '../features/knowledge_dna/models/knowledge_dna.dart';
import '../features/mission_engine/mission_engine.dart' as mission_engine;
import '../features/mission_engine/models/mission_category.dart';
import '../features/mission_engine/models/mission_difficulty.dart';
import '../features/mission_engine/models/mission_priority.dart';
import '../features/mission_engine/models/mission_status.dart';
import '../models/academy.dart';
import '../models/lesson.dart';
import '../models/level.dart';
import '../models/mission.dart';
import '../models/progress.dart';
import '../models/stage.dart';

/// Centralised sample data hub used by all Phoenix feature services.
///
/// By routing all sample data through this single source, the platform
/// maintains coherence across Identity → Journey → Mission → Progress →
/// Memory → Recommendation without introducing persistence or state management.
class SampleDataService {
  const SampleDataService();

  // ─────────────────────────────────────────────────────────────────────────
  // Identity
  // ─────────────────────────────────────────────────────────────────────────

  /// The user's selected identity — the root of every Journey.
  Identity get selectedIdentity => const Identity(
    id: 'identity-flutter-developer',
    title: 'Flutter Developer',
    description:
        'Craft beautiful, performant cross-platform applications '
        'with Flutter and Dart.',
    icon: Icons.phone_android_outlined,
    category: 'Technology',
    currentLevel: 1,
    targetLevel: 7,
    estimatedDuration: 400,
    requiredSkills: <String>[
      'Dart Language',
      'Flutter Widgets',
      'State Management',
      'Platform Integrations',
    ],
    roadmap: <String>[
      'Learn Dart fundamentals',
      'Build a simple Flutter app',
      'Master state management',
      'Publish to App Store & Play Store',
    ],
    status: IdentityStatus.active,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Journey
  // ─────────────────────────────────────────────────────────────────────────

  /// The Journey generated from the selected Identity.
  ///
  /// Every Journey is composed of Stages. Every Stage contains Missions.
  /// Knowledge DNA measures progress through the Journey. Recommendation
  /// selects the next best Journey step.
  Journey get journey => const Journey(
    id: 'journey-flutter-dev',
    identityId: 'identity-flutter-developer',
    title: 'Flutter Developer',
    description:
        'Master Flutter from fundamentals to production-ready apps. '
        'This journey takes you through eight stages of progressive '
        'skill building.',
    estimatedDuration: 180,
    completion: 0.18,
    currentStage: 1,
    stages: [
      JourneyStage(
        id: 'stage-programming-fundamentals',
        title: 'Programming Fundamentals',
        description:
            'Learn core programming concepts: variables, control flow, '
            'functions, and data structures.',
        order: 0,
        completion: 1.0,
        estimatedDuration: 14,
        requiredSkills: ['Logical thinking', 'Problem solving'],
        missions: [
          'Variables & Data Types',
          'Control Flow',
          'Functions & Scope',
          'Data Structures',
        ],
        status: StageStatus.completed,
      ),
      JourneyStage(
        id: 'stage-dart',
        title: 'Dart',
        description:
            'Master the Dart language: syntax, sound null safety, '
            'async programming, and core libraries.',
        order: 1,
        completion: 0.45,
        estimatedDuration: 21,
        requiredSkills: ['Programming Fundamentals'],
        missions: [
          'Dart Syntax & Types',
          'Null Safety',
          'Async & Futures',
          'Collections & Generics',
        ],
        status: StageStatus.inProgress,
      ),
      JourneyStage(
        id: 'stage-flutter-widgets',
        title: 'Flutter Widgets',
        description:
            'Build UIs with Flutter widgets: layout, state, styling, '
            'and custom painting.',
        order: 2,
        completion: 0.0,
        estimatedDuration: 28,
        requiredSkills: ['Dart', 'UI/UX basics'],
        missions: [
          'Stateless & Stateful Widgets',
          'Layout Widgets',
          'Styling & Theming',
          'Custom Paint',
        ],
        status: StageStatus.available,
      ),
      JourneyStage(
        id: 'stage-state-management',
        title: 'State Management',
        description:
            'Manage app state effectively: Provider, Riverpod, Bloc, '
            'and when to use each.',
        order: 3,
        completion: 0.0,
        estimatedDuration: 21,
        requiredSkills: ['Flutter Widgets', 'Dart'],
        missions: ['State Fundamentals', 'Provider', 'Riverpod', 'Bloc/Cubit'],
        status: StageStatus.locked,
      ),
      JourneyStage(
        id: 'stage-api-integration',
        title: 'API Integration',
        description:
            'Connect your apps to the world: REST, GraphQL, '
            'local persistence, and offline support.',
        order: 4,
        completion: 0.0,
        estimatedDuration: 28,
        requiredSkills: ['Dart', 'State Management'],
        missions: [
          'HTTP & REST',
          'GraphQL Basics',
          'Local Storage',
          'Offline Mode',
        ],
        status: StageStatus.locked,
      ),
      JourneyStage(
        id: 'stage-architecture',
        title: 'Architecture',
        description:
            'Design scalable Flutter apps: clean architecture, '
            'testing strategies, and performance optimization.',
        order: 5,
        completion: 0.0,
        estimatedDuration: 28,
        requiredSkills: ['Flutter Widgets', 'State Management', 'API'],
        missions: [
          'Clean Architecture',
          'Dependency Injection',
          'Unit & Widget Testing',
          'Performance Tuning',
        ],
        status: StageStatus.locked,
      ),
      JourneyStage(
        id: 'stage-portfolio',
        title: 'Portfolio',
        description:
            'Build your portfolio: capstone project, open source '
            'contributions, and app store deployment.',
        order: 6,
        completion: 0.0,
        estimatedDuration: 21,
        requiredSkills: [
          'Flutter Widgets',
          'State Management',
          'API',
          'Architecture',
        ],
        missions: [
          'Capstone Project',
          'Open Source Contribution',
          'App Store Deployment',
        ],
        status: StageStatus.locked,
      ),
      JourneyStage(
        id: 'stage-job-ready',
        title: 'Job Ready',
        description:
            'Prepare for the job market: resume building, technical '
            'interviews, and networking.',
        order: 7,
        completion: 0.0,
        estimatedDuration: 21,
        requiredSkills: ['Portfolio', 'Architecture'],
        missions: [
          'Resume & Portfolio Review',
          'Mock Interviews',
          'Job Search Strategy',
        ],
        status: StageStatus.locked,
      ),
    ],
  );

  /// The current in-progress journey stage.
  JourneyStage get currentJourneyStage => journey.stages[journey.currentStage];

  // ─────────────────────────────────────────────────────────────────────────
  // Missions (reflecting the current Journey stage)
  // ─────────────────────────────────────────────────────────────────────────

  Mission get featuredMission => const Mission(
    id: 'mission-daily',
    title: "Today's Mission",
    description:
        'Complete the Dart stage missions to master the Dart language '
        'and advance your Flutter Developer journey.',
    lessons: <Lesson>[],
  );

  List<Progress> get missionProgress => const <Progress>[
    Progress(id: 'mission-progress', label: 'Current focus', value: 0.45),
  ];

  /// Daily missions derived from the current Journey stage (Dart).
  ///
  /// This connects Mission → Journey by using the current stage's mission
  /// titles as the source for daily tasks.
  List<mission_engine.Mission> get dailyMissions =>
      const <mission_engine.Mission>[
        mission_engine.Mission(
          id: 'daily-1',
          title: 'Dart Syntax & Types',
          description:
              'Master Dart variables, types, and type inference '
              'to write clean, safe code.',
          category: MissionCategory.daily,
          priority: MissionPriority.high,
          difficulty: MissionDifficulty.beginner,
          estimatedDuration: 30,
          rewardXP: 120,
          status: MissionStatus.completed,
          completedDate: null,
        ),
        mission_engine.Mission(
          id: 'daily-2',
          title: 'Null Safety',
          description:
              'Understand Dart sound null safety: nullable types, '
              'late variables, and null-aware operators.',
          category: MissionCategory.daily,
          priority: MissionPriority.high,
          difficulty: MissionDifficulty.beginner,
          estimatedDuration: 25,
          rewardXP: 90,
          status: MissionStatus.completed,
          completedDate: null,
        ),
        mission_engine.Mission(
          id: 'daily-3',
          title: 'Async & Futures',
          description:
              'Learn async programming with Future, async/await, '
              'and error handling in Dart.',
          category: MissionCategory.daily,
          priority: MissionPriority.high,
          difficulty: MissionDifficulty.easy,
          estimatedDuration: 35,
          rewardXP: 150,
          status: MissionStatus.pending,
          completedDate: null,
        ),
      ];

  /// Weekly missions spanning other Journey stages and skill areas.
  List<mission_engine.Mission> get weeklyMissions =>
      const <mission_engine.Mission>[
        mission_engine.Mission(
          id: 'weekly-1',
          title: 'Collections & Generics',
          description:
              'Use Dart collections (List, Set, Map) and generics '
              'to write reusable, type-safe code.',
          category: MissionCategory.weekly,
          priority: MissionPriority.medium,
          difficulty: MissionDifficulty.easy,
          estimatedDuration: 40,
          rewardXP: 200,
          status: MissionStatus.pending,
          completedDate: null,
        ),
        mission_engine.Mission(
          id: 'weekly-2',
          title: 'Statistics & Data Structures Review',
          description:
              'Revisit programming fundamentals: data structures '
              'and algorithm patterns for the next stage.',
          category: MissionCategory.weekly,
          priority: MissionPriority.medium,
          difficulty: MissionDifficulty.medium,
          estimatedDuration: 30,
          rewardXP: 180,
          status: MissionStatus.pending,
          completedDate: null,
        ),
        mission_engine.Mission(
          id: 'weekly-3',
          title: 'Stage Progress Review',
          description:
              'Review your Dart stage progress and plan the next '
              'learning sprint towards Flutter Widgets.',
          category: MissionCategory.weekly,
          priority: MissionPriority.low,
          difficulty: MissionDifficulty.beginner,
          estimatedDuration: 15,
          rewardXP: 80,
          status: MissionStatus.pending,
          completedDate: null,
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────────
  // Progression (reflecting Journey completion)
  // ─────────────────────────────────────────────────────────────────────────

  List<Progress> get knowledgeProgress => const <Progress>[
    Progress(id: 'knowledge-coverage', label: 'Knowledge DNA', value: 0.72),
  ];

  List<Academy> get academySummaries => const <Academy>[
    Academy(
      id: 'academy-leadership',
      title: 'Leadership Lab',
      description: 'Growth • 4 lessons',
      levels: <Level>[],
    ),
    Academy(
      id: 'academy-product',
      title: 'Product Thinking',
      description: 'Strategy • 6 lessons',
      levels: <Level>[],
    ),
    Academy(
      id: 'academy-design',
      title: 'Design Systems',
      description: 'Craft • 3 lessons',
      levels: <Level>[],
    ),
  ];

  Academy get featuredAcademy => const Academy(
    id: 'academy-leadership',
    title: 'Leadership Lab',
    description:
        'Craft high-leverage habits for leading product and platform teams.',
    levels: <Level>[
      Level(
        id: 'level-1',
        title: 'Foundation',
        stages: <Stage>[
          Stage(
            id: 'stage-1',
            title: 'Mindset',
            missions: <Mission>[
              Mission(
                id: 'mission-1',
                title: 'Daily Reflect',
                description: 'Capture one insight from your day.',
                lessons: <Lesson>[],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  List<Progress> get dashboardSections => const <Progress>[
    Progress(id: 'section-quick-actions', label: 'Quick Actions', value: 0.0),
    Progress(id: 'section-academies', label: 'Academies', value: 0.0),
    Progress(id: 'section-knowledge-dna', label: 'Knowledge DNA', value: 0.72),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Knowledge DNA
  // ─────────────────────────────────────────────────────────────────────────

  KnowledgeDNA get knowledgeProfile => const KnowledgeDNA(
    knowledge: 'Design Systems',
    skill: 'Product Strategy',
    confidence: 0.82,
    retention: 0.74,
    consistency: 0.79,
    learningVelocity: 0.88,
    missionsCompleted: 12,
    projectsCompleted: 7,
    weakAreas: <String>['Stakeholder alignment', 'Presentation pacing'],
    strongAreas: <String>['Systems thinking', 'Execution clarity'],
    careerGoal: 'Lead platform experience strategy',
  );

  List<QuickActionItem> get quickActions => const <QuickActionItem>[
    QuickActionItem(label: 'Daily Check-in', icon: Icons.task_alt_outlined),
    QuickActionItem(label: 'Focus Session', icon: Icons.bolt_outlined),
    QuickActionItem(label: 'Learning Sprint', icon: Icons.school_outlined),
  ];
}

class QuickActionItem {
  const QuickActionItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
