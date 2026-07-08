import 'package:flutter/material.dart';

import '../features/knowledge_dna/models/knowledge_dna.dart';
import '../features/mission_engine/mission_engine.dart' as mission_engine;
import '../models/academy.dart';
import '../models/lesson.dart';
import '../models/level.dart';
import '../models/mission.dart';
import '../models/progress.dart';
import '../models/stage.dart';

class SampleDataService {
  const SampleDataService();

  Mission get featuredMission => const Mission(
        id: 'mission-daily',
        title: "Today's Mission",
        description:
            'Complete the onboarding sprint and unlock the next level of your learning path.',
        lessons: <Lesson>[],
      );

  List<Progress> get missionProgress => const <Progress>[
        Progress(id: 'mission-progress', label: 'Current focus', value: 0.45),
      ];

  List<mission_engine.Mission> get dailyMissions => const <mission_engine.Mission>[
        mission_engine.Mission(
          id: 'daily-1',
          title: 'Daily Reflect',
          description: 'Capture one insight from your day.',
          category: 'daily',
          priority: 'high',
          estimatedDuration: 15,
          completed: true,
          completionDate: null,
          xpReward: 120,
          academyId: 'academy-leadership',
        ),
        mission_engine.Mission(
          id: 'daily-2',
          title: 'Weekly Sprint Plan',
          description: 'Sketch the next three priorities for the week.',
          category: 'daily',
          priority: 'medium',
          estimatedDuration: 20,
          completed: true,
          completionDate: null,
          xpReward: 90,
          academyId: 'academy-product',
        ),
      ];

  List<mission_engine.Mission> get weeklyMissions => const <mission_engine.Mission>[
        mission_engine.Mission(
          id: 'weekly-1',
          title: 'Leadership Review',
          description: 'Review one team signal and document an action.',
          category: 'weekly',
          priority: 'high',
          estimatedDuration: 30,
          completed: false,
          completionDate: null,
          xpReward: 180,
          academyId: 'academy-leadership',
        ),
        mission_engine.Mission(
          id: 'weekly-2',
          title: 'Design Systems Audit',
          description: 'Check one reusable pattern and improve it.',
          category: 'weekly',
          priority: 'medium',
          estimatedDuration: 45,
          completed: true,
          completionDate: null,
          xpReward: 250,
          academyId: 'academy-design',
        ),
        mission_engine.Mission(
          id: 'weekly-3',
          title: 'Opportunity Capture',
          description: 'Capture one new product opportunity from customer feedback.',
          category: 'weekly',
          priority: 'low',
          estimatedDuration: 25,
          completed: false,
          completionDate: null,
          xpReward: 110,
          academyId: 'academy-product',
        ),
      ];

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
        description: 'Craft high-leverage habits for leading product and platform teams.',
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
