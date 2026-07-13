import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../core/sample_repository.dart';
import '../../theme/spacing.dart';
import 'widgets/academy_header.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/course_progress_card.dart';
import 'widgets/learning_actions_card.dart';
import 'widgets/learning_statistics_card.dart';
import 'widgets/lesson_list_card.dart';

class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = const SampleRepository();
    final academy = repository.featuredAcademy;
    final academies = repository.academySummaries;

    // Derive lesson data from the featured academy structure
    final allMissions = academy.levels
        .expand((level) => level.stages)
        .expand((stage) => stage.missions)
        .toList();

    final allLessons = allMissions
        .expand((mission) => mission.lessons)
        .toList();

    final totalLessons = allLessons.length;
    final completedLessons = allMissions.isNotEmpty
        ? 1
        : 0; // First mission as "completed"
    final remainingLessons = totalLessons - completedLessons;
    final progressPercentage = totalLessons > 0
        ? completedLessons / totalLessons
        : 0.35;

    // Build lesson list items from the learning path
    final lessonItems = academy.levels.expand((level) {
      return level.stages.expand((stage) {
        return stage.missions.map((mission) {
          final isFirst = stage.missions.first == mission;
          return LessonListItem(
            title: mission.title,
            subtitle: '${stage.title} • ${level.title}',
            status: isFirst ? LessonStatus.completed : LessonStatus.current,
          );
        });
      });
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AcademyHeader(
            courseTitle: academy.title,
            currentLesson: allMissions.isNotEmpty
                ? allMissions.first.title
                : 'Getting Started',
            completionPercentage: progressPercentage,
            welcomeMessage: academy.description,
          ),
          const SizedBox(height: AppSpacing.lg),
          ContinueLearningCard(
            lessonTitle: allMissions.isNotEmpty
                ? allMissions.first.title
                : 'Introduction',
            lessonDescription: allMissions.isNotEmpty
                ? allMissions.first.description
                : 'Begin your learning journey',
            onContinue: () =>
                Navigator.of(context).pushNamed(AppRoutes.academy),
          ),
          const SizedBox(height: AppSpacing.lg),
          CourseProgressCard(
            lessonsCompleted: completedLessons,
            lessonsRemaining: remainingLessons,
            progressPercentage: progressPercentage,
          ),
          const SizedBox(height: AppSpacing.lg),
          LessonListCard(lessons: lessonItems),
          const SizedBox(height: AppSpacing.lg),
          LearningStatisticsCard(
            totalLessons: totalLessons,
            completedLessons: completedLessons,
            remainingLessons: remainingLessons,
            estimatedStudyTime: '${academies.length}h',
          ),
          const SizedBox(height: AppSpacing.lg),
          LearningActionsCard(
            onContinueLearning: () =>
                Navigator.of(context).pushNamed(AppRoutes.academy),
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onMission: () =>
                Navigator.of(context).pushNamed(AppRoutes.missionCenter),
            onProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}
