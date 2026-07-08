import 'package:flutter/material.dart';

import '../features/knowledge_dna/models/knowledge_dna.dart';
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
