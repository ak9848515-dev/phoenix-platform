import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../shared/widgets/phoenix_card.dart';
import '../../../shared/widgets/phoenix_loading_widget.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/milestone.dart';
import '../models/timeline_category.dart';
import '../services/timeline_service.dart';
import '../widgets/milestone_card.dart';

/// Milestone View — all detected milestones in the user's timeline.
///
/// Displays a full list of milestones with:
/// - Pinned milestones first
/// - AI-powered milestone highlight
/// - Paginated list
class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  TimelineService? _service;
  String? _aiHighlight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = AppBootstrap.maybeTimelineService;
    _loadAiHighlight();
  }

  Future<void> _loadAiHighlight() async {
    final svc = _service;
    if (svc == null) return;
    final highlight = await svc.getAiMilestoneHighlight();
    if (mounted) {
      setState(() => _aiHighlight = highlight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = _service;
    if (svc == null) {
      return const PhoenixLoadingWidget(
        icon: Icons.emoji_events_rounded,
        title: 'Loading milestones...',
        subtitle: 'Preparing your achievement timeline.',
      );
    }

    final theme = Theme.of(context);
    final milestones = svc.milestones;
    final pinned = milestones.where((m) => m.isPinned).toList();
    final unpinned = milestones.where((m) => !m.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              svc.invalidateCache();
              setState(() {});
              _loadAiHighlight();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: milestones.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No milestones yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Complete activities across Phoenix OS\n'
                    'to earn milestones.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Highlight Card
                  if (_aiHighlight != null && _aiHighlight != 'No milestones yet.') ...[
                    _buildAiHighlightCard(theme, _aiHighlight!),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Stats
                  _buildStatsRow(theme, milestones.length, pinned.length),
                  const SizedBox(height: AppSpacing.lg),

                  // Pinned milestones
                  if (pinned.isNotEmpty) ...[
                    _buildSectionTitle(theme, 'Pinned',
                        Icons.push_pin_rounded),
                    const SizedBox(height: AppSpacing.sm),
                    ...pinned.map((ms) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: MilestoneCard(
                        milestone: ms,
                        onTap: () => _showMilestoneDetail(context, ms),
                      ),
                    )),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // All milestones
                  _buildSectionTitle(
                      theme, 'All Milestones', Icons.emoji_events_rounded),
                  const SizedBox(height: AppSpacing.sm),
                  ...unpinned.map((ms) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: MilestoneCard(
                      milestone: ms,
                      onTap: () => _showMilestoneDetail(context, ms),
                    ),
                  )),
                ],
              ),
            ),
    );
  }

  Widget _buildAiHighlightCard(ThemeData theme, String highlight) {
    return PhoenixCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI Milestone Highlights',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  highlight,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, int total, int pinnedCount) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '$total',
            label: 'Total Milestones',
            icon: Icons.emoji_events_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '$pinnedCount',
            label: 'Pinned',
            icon: Icons.push_pin_rounded,
            color: AppColors.primary,
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

  void _showMilestoneDetail(BuildContext context, Milestone milestone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final color = _colorForCategory(milestone.category);
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestone.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            milestone.category.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                milestone.description,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow(theme, 'Date', _formatDate(milestone.timestamp)),
              if (milestone.eventIds.isNotEmpty)
                _buildInfoRow(
                    theme, 'Events', '${milestone.eventIds.length} related'),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Color _colorForCategory(TimelineCategory category) {
    switch (category) {
      case TimelineCategory.learning:
        return AppColors.primary;
      case TimelineCategory.mission:
        return Colors.orange;
      case TimelineCategory.achievement:
        return AppColors.warning;
      case TimelineCategory.career:
        return const Color(0xFF7C3AED);
      case TimelineCategory.portfolio:
        return Colors.teal;
      case TimelineCategory.resume:
        return Colors.blue;
      case TimelineCategory.interview:
        return Colors.purple;
      case TimelineCategory.decision:
        return const Color(0xFF0891B2);
      case TimelineCategory.ai:
        return const Color(0xFFD97706);
      case TimelineCategory.voice:
        return Colors.indigo;
      case TimelineCategory.marketplace:
        return Colors.pink;
      case TimelineCategory.system:
        return Colors.grey;
      case TimelineCategory.custom:
        return Colors.amber;
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
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
