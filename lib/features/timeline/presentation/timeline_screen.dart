import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/timeline_event.dart';
import '../services/timeline_service.dart';
import '../widgets/activity_feed.dart';
import '../widgets/milestone_card.dart';
import 'milestone_screen.dart';
import 'timeline_detail_screen.dart';

/// Timeline Dashboard — the main timeline view.
///
/// Shows:
/// - Today's activity summary
/// - Recent milestones
/// - Activity feed grouped by day
/// - Search
/// - Quick actions
class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  TimelineService? _service;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<TimelineEvent> _searchResults = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = AppBootstrap.maybeTimelineService;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = _service;
    if (svc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final todayEvents = svc.todayEvents;
    final milestones = svc.milestones.take(3).toList();
    final eventsByDay = svc.eventsByDay;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, svc),
          const SizedBox(height: AppSpacing.lg),
          _buildStatsRow(theme, svc),
          const SizedBox(height: AppSpacing.lg),
          if (_isSearching) _buildSearchResults(theme) else ...[
            // Today's activity
            if (todayEvents.isNotEmpty) ...[
              _buildSectionTitle(theme, 'Today', Icons.today_rounded),
              const SizedBox(height: AppSpacing.sm),
              ...todayEvents.take(3).map((event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildMiniEventCard(event, theme),
              )),
              const SizedBox(height: AppSpacing.lg),
            ],
            // Milestones
            if (milestones.isNotEmpty) ...[
              _buildSectionTitle(theme, 'Recent Milestones', Icons.emoji_events_rounded),
              const SizedBox(height: AppSpacing.sm),
              ...milestones.map((ms) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: MilestoneCard(
                  milestone: ms,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MilestoneScreen(),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: AppSpacing.lg),
            ],
            // Activity feed
            _buildSectionTitle(theme, 'Activity', Icons.history_rounded),
            const SizedBox(height: AppSpacing.sm),
            ActivityFeed(
              eventsByDay: eventsByDay,
              onEventTap: (event) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TimelineDetailScreen(event: event),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, TimelineService svc) {
    return PhoenixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Life Timeline',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your journey through Phoenix OS',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchResults = [];
                    }
                  });
                },
              ),
            ],
          ),
          if (_isSearching) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search your timeline...',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  _searchResults = svc.search(query);
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, TimelineService svc) {
    final total = svc.allEvents.length;
    final msCount = svc.milestones.length;
    final today = svc.todayEvents.length;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '$total',
            label: 'Total Events',
            icon: Icons.event_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '$msCount',
            label: 'Milestones',
            icon: Icons.emoji_events_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '$today',
            label: 'Today',
            icon: Icons.today_rounded,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text('No results found.',
              style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Column(
      children: _searchResults.map((event) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: _buildMiniEventCard(event, theme),
      )).toList(),
    );
  }

  Widget _buildMiniEventCard(TimelineEvent event, ThemeData theme) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TimelineDetailScreen(event: event),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Text(
              '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                event.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
