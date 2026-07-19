import 'package:flutter/material.dart';

import '../../core/bootstrap.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/phoenix_empty_state.dart';
import '../../core/design/theme/phoenix_spacing.dart';
import '../mission_intelligence/engine/mission_intelligence_engine.dart';
import '../mission_intelligence/models/mission_snapshot.dart';
import 'widgets/mission_actions_card.dart';
import 'widgets/mission_header.dart';
import 'widgets/mission_progress_card.dart';
import 'widgets/mission_statistics_card.dart';
import 'widgets/mission_tasks_card.dart';

class MissionCenterScreen extends StatefulWidget {
  const MissionCenterScreen({super.key});

  @override
  State<MissionCenterScreen> createState() => _MissionCenterScreenState();
}

class _MissionCenterScreenState extends State<MissionCenterScreen> {
  MissionIntelligenceEngine? _engine;
  MissionSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _engine = AppBootstrap.maybeMissionIntelligenceEngine;
    _snapshot = _engine?.snapshot;
    _engine?.addListener(_onEngineChanged);
  }

  void _onEngineChanged() {
    if (mounted) {
      setState(() {
        _snapshot = _engine?.snapshot;
      });
    }
  }

  @override
  void dispose() {
    _engine?.removeListener(_onEngineChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = _snapshot?.currentMission;
    final alternatives = _snapshot?.alternatives ?? [];
    final history = _snapshot?.history;
    final completedCount = history?.totalCompleted ?? 0;
    final recomCount = (mission != null ? 1 : 0) + alternatives.length;

    if (_engine == null) {
      return PhoenixEmptyState(
        icon: Icons.flag_outlined,
        title: 'Mission engine loading',
        message: 'The mission intelligence system is initializing. '
            'Please wait a moment.',
        positiveMessage: 'Engines are booting up',
      );
    }

    if (mission == null && alternatives.isEmpty && completedCount == 0) {
      return PhoenixEmptyState(
        icon: Icons.flag_outlined,
        title: 'No missions yet',
        message: 'Missions are created based on your growth journey. '
            'Start learning to unlock your first mission.',
        positiveMessage: 'Your journey begins with a single step',
        primaryAction: _StartLearningButton(),
      );
    }

    // Build task items from current mission + alternatives
    final taskItems = <MissionTaskItem>[];
    if (mission != null) {
      taskItems.add(MissionTaskItem(
        title: mission.title,
        completed: false,
        subtitle: mission.description,
      ));
    }
    for (final alt in alternatives.take(3)) {
      taskItems.add(MissionTaskItem(
        title: alt.title,
        completed: false,
        subtitle: alt.description,
        isAlternative: true,
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PhoenixSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionHeader(
            title: mission?.title ?? 'All missions complete',
            description: mission?.description ??
                'Great work! All areas are progressing well.',
            statusLabel: mission != null ? 'Recommended' : 'Complete',
            priority: mission?.priority.displayName ?? 'low',
          ),
          const SizedBox(height: PhoenixSpacing.lg),
          if (mission != null) ...[
            MissionProgressCard(
              progressPercentage: _snapshot?.completionPercent ?? 0.0,
              completedTasks: completedCount,
              remainingTasks: recomCount,
            ),
            const SizedBox(height: PhoenixSpacing.lg),
          ],
          MissionTasksCard(tasks: taskItems),
          const SizedBox(height: PhoenixSpacing.lg),
          MissionStatisticsCard(
            totalTasks: recomCount + completedCount,
            completedTasks: completedCount,
            pendingTasks: recomCount,
            completionPercentage: (recomCount + completedCount) > 0
                ? completedCount / (recomCount + completedCount)
                : 0.0,
            onTotalTasksTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'tasks'},
            ),
            onCompletedTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'completed'},
            ),
            onPendingTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'pending'},
            ),
            onCompletionTap: () => Navigator.of(context).pushNamed(
              AppRoutes.progress,
              arguments: {'focus': 'completion'},
            ),
          ),
          const SizedBox(height: PhoenixSpacing.lg),
          MissionActionsCard(
            onContinueMission: () =>
                Navigator.of(context).pushNamed(AppRoutes.academy),
            onDashboard: () =>
                Navigator.of(context).pushNamed(AppRoutes.dashboard),
            onLearn: () => Navigator.of(context).pushNamed(AppRoutes.academy),
            onProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

/// Reusable start-learning button for empty states.
class _StartLearningButton extends StatelessWidget {
  const _StartLearningButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.academy),
      icon: const Icon(Icons.school_rounded, size: 18),
      label: const Text('Start Learning'),
    );
  }
}
