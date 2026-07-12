import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';
import '../services/memory_service.dart';
import '../widgets/memory_header.dart';
import '../widgets/memory_statistics_card.dart';
import '../widgets/memory_timeline_card.dart';
import '../widgets/recent_memories_card.dart';

/// The Memory Screen displays the user's journey timeline, recent memories,
/// and memory statistics.
///
/// This is a presentation-only screen. No state management, persistence,
/// AI, or business logic is included.
class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memoryService = const MemoryService();
    final allMemories = memoryService.getSampleMemories();
    final timeline = memoryService.getTimeline();
    final recentMemories = memoryService.getRecentMemories();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const MemoryHeader(),
          const SizedBox(height: AppSpacing.lg),
          MemoryStatisticsCard(entries: allMemories),
          const SizedBox(height: AppSpacing.lg),
          RecentMemoriesCard(memories: recentMemories),
          const SizedBox(height: AppSpacing.lg),
          MemoryTimelineCard(entries: timeline),
          const SizedBox(height: AppSpacing.lg),
          PhoenixPrimaryButton(
            onPressed: () => _onAddMemory(context),
            label: 'Add Memory',
            icon: Icons.add_outlined,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _onAddMemory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adding memories will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}